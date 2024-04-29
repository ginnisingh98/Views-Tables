--------------------------------------------------------
--  DDL for Package Body IBY_ASSIGNEXT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBY_ASSIGNEXT_PUB" AS
/*$Header: ibyasgnextb.pls 120.0.12010000.2 2009/06/25 09:25:06 jnallam noship $*/

 --
 -- Declare global variables
 --
 G_PKG_NAME CONSTANT VARCHAR2(30) := 'IBY_ASSIGNEXT_PUB';
 G_LEVEL_STATEMENT CONSTANT NUMBER := FND_LOG.LEVEL_STATEMENT;
 G_CUR_RUNTIME_LEVEL CONSTANT NUMBER := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
 G_LEVEL_UNEXPECTED CONSTANT NUMBER := FND_LOG.LEVEL_UNEXPECTED;
 G_LEVEL_ERROR CONSTANT NUMBER := FND_LOG.LEVEL_ERROR;
 G_LEVEL_EXCEPTION CONSTANT NUMBER := FND_LOG.LEVEL_EXCEPTION;
 G_LEVEL_EVENT CONSTANT NUMBER := FND_LOG.LEVEL_EVENT;
 G_LEVEL_PROCEDURE CONSTANT NUMBER := FND_LOG.LEVEL_PROCEDURE;

 --
 -- Forward declarations
 --
 PROCEDURE print_debuginfo(
              p_module      IN VARCHAR2,
              p_debug_text  IN VARCHAR2,
              p_debug_level IN VARCHAR2  DEFAULT FND_LOG.LEVEL_STATEMENT
              );

 /*--------------------------------------------------------------------
 | NAME:
 |      hookForAssignments
 |
 | PURPOSE:
 |      The assignment flow will call this hook with a list of
 |      unassigned documents (documents that do not have account/
 |      profile even after the assignment flow attempted to default
 |      them).
 |
 |      The customer can implement custom assignment logic here to
 |      assign defaults to the unassigned documents. The assignment
 |      flow will use these custom assignments to update the individual
 |      documents.
 |
 |      This hook will ship with an empty body from Oracle. The customer
 |      may implement this hook on their environment if they wish.
 |
 | PARAMETERS:
 |     IN
 |
 |     OUT
 |
 |
 | RETURNS:
 |
 | NOTES:
 |
 *---------------------------------------------------------------------*/
 PROCEDURE hookForAssignments(
     x_unassgnDocsTab IN OUT NOCOPY IBY_ASSIGN_PUB.unassignedDocsTabType
     )
 IS
 l_module_name CONSTANT VARCHAR2(200) := G_PKG_NAME || '.hookForAssignments';
 BEGIN

     IF (G_LEVEL_STATEMENT >= G_CUR_RUNTIME_LEVEL) THEN
     print_debuginfo(l_module_name, 'ENTER');
     END IF;

     /*
      * This hook will ship out-of-the-box with an empty
      * body.
      *
      * The customer can add custom assignment logic this
      * hook to perform. The implementation and maintainence
      * of this hook has to be performed on site by the
      * customer.
      */
     NULL;

     IF (G_LEVEL_STATEMENT >= G_CUR_RUNTIME_LEVEL) THEN
     print_debuginfo(l_module_name, 'EXIT');
     END IF;

 END hookForAssignments;

 /*--------------------------------------------------------------------
 | NAME:
 |     print_debuginfo
 |
 | PURPOSE:
 |     This procedure prints the debug message to the concurrent manager
 |     log file.
 |
 | PARAMETERS:
 |     IN
 |      p_debug_text - The debug message to be printed
 |
 |     OUT
 |
 |
 | RETURNS:
 |
 | NOTES:
 |
 *---------------------------------------------------------------------*/
 PROCEDURE print_debuginfo(
     p_module      IN VARCHAR2,
     p_debug_text  IN VARCHAR2,
     p_debug_level IN VARCHAR2  DEFAULT FND_LOG.LEVEL_STATEMENT
     )
 IS
 l_default_debug_level VARCHAR2(200) := FND_LOG.LEVEL_STATEMENT;
 BEGIN

     /*
      * Set the debug level to the value passed in
      * (provided this value is not null).
      */
     IF (p_debug_level IS NOT NULL) THEN
         l_default_debug_level := p_debug_level;
     END IF;

     /*
      * Write the debug message to the concurrent manager log file.
      */
     IF (l_default_debug_level >= G_CUR_RUNTIME_LEVEL) THEN
         iby_build_utils_pkg.print_debuginfo(p_module, p_debug_text,
             p_debug_level);
     END IF;

 END print_debuginfo;

 END IBY_ASSIGNEXT_PUB;

/
