--------------------------------------------------------
--  DDL for Package XLA_CMP_PAD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XLA_CMP_PAD_PKG" AUTHID CURRENT_USER AS
/* $Header: xlacppad.pkh 120.9 2006/08/23 18:27:11 wychan ship $   */
/*===========================================================================+
|             Copyright (c) 2001-2002 Oracle Corporation                     |
|                       Redwood Shores, CA, USA                              |
|                         All rights reserved.                               |
+============================================================================+
| PACKAGE NAME                                                               |
|     xla_cmp_pad_pkg                                                        |
|                                                                            |
| DESCRIPTION                                                                |
|     This is a XLA private package, which contains all the APIs required    |
|     for package body generation                                            |
|                                                                            |
|                                                                            |
| HISTORY                                                                    |
|     25-JUN-2002 K.Boussema    Created                                      |
|     25-FEB-2003 K.Boussema    Added 'dbdrv' command                        |
|     27-FEB-2003 K.Boussema    Made changes for the new bulk approach of the|
|                               accounting engine                            |
|     18-MAR-2003 K.Boussema    Added amb_context_code                       |
|     22-APR-2003 K.Boussema    Included error messages                      |
|     17-JUL-2003 K.Boussema    Reviewd the code                             |
+===========================================================================*/

--
--+==========================================================================+
--|                                                                          |
--| Private global type declarations                                         |
--|                                                                          |
--+==========================================================================+
--
--
--+==========================================================================+
--|                                                                          |
--| Private global constant or variable declarations                         |
--|                                                                          |
--+==========================================================================+
--
--
--+==========================================================================+
--|            Template  Package Name                                        |
--+==========================================================================+
--
C_PACKAGE_NAME             CONSTANT VARCHAR2(30):= 'XLA_$appl$_PAD_$pd$_PKG';

--+==========================================================================+
--|                                                                          |
--|                                                                          |
--| Global variables                                                         |
--|                                                                          |
--|                                                                          |
--+==========================================================================+
--
g_component_name          VARCHAR2(80);
g_component_appl          VARCHAR2(240);
g_owner                   VARCHAR2(30);
g_bc_pkg_flag             VARCHAR2(1);
--
--
--+==========================================================================+
--|                                                                          |
--| PRIVATE  function                                                        |
--|                                                                          |
--+==========================================================================+
--
FUNCTION GetApplicationName (p_application_id   IN NUMBER)
RETURN VARCHAR2
;

--+==========================================================================+
--| PUBLIC function                                                          |
--|    Compile                                                               |
--| DESCRIPTION : generates the PL/SQL packages from the Product Accounting  |
--|               definition.                                                |
--|                                                                          |
--| INPUT PARAMETERS                                                         |
--|                                                                          |
--| 1. p_application_id          : NUMBER, application identifier            |
--| 2. p_product_rule_code       : VARCHAR2(30), product definition code     |
--| 3. p_product_rule_type_code  : VARCHAR2(30), product definition type     |
--| 4. p_product_rule_version    : VARCHAR2(30), product definition Version  |
--|                                                                          |
--|  RETURNS                                                                 |
--|   1. l_IsCompiled  : BOOLEAN, TRUE if Product accounting definition has  |
--|                      been successfully created, FALSE otherwise.         |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--+==========================================================================+
--
FUNCTION Compile    (  p_application_id           IN NUMBER
                     , p_product_rule_code        IN VARCHAR2
                     , p_product_rule_type_code   IN VARCHAR2
                     , p_product_rule_version     IN VARCHAR2
                     , p_amb_context_code         IN VARCHAR2 )
RETURN BOOLEAN
;
--
--
END xla_cmp_pad_pkg; -- end of package spec
 

/
