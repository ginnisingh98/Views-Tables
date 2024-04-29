--------------------------------------------------------
--  DDL for Package XXAH_VA_AUTOACCRUAL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XXAH_VA_AUTOACCRUAL_PKG" AS
/**************************************************************************
 * VERSION      : $Id: XXAH_VA_AUTOACCRUAL_PKG.pls 4 2012-04-18 07:57:54Z marc.smeenge@oracle.com $
 * DESCRIPTION  : Contains functionality for the approval workflow.
 *
 * CHANGE HISTORY
 * ==============
 *
 * Date        Authors           Change reference/Description
 * ----------- ----------------- ----------------------------------
 * 11-AUG-2010 Kevin Bouwmeester Genesis
 *  7-DEC-2010 Joost Voordouw    updated spec to be in line with body
 *************************************************************************/

-- ----------------------------------------------------------------------
-- Global types
-- ----------------------------------------------------------------------

-- ----------------------------------------------------------------------
-- Global constants
-- ----------------------------------------------------------------------

-- ----------------------------------------------------------------------
-- Global variables
-- ----------------------------------------------------------------------

-- ----------------------------------------------------------------------
-- Global cursors
-- ----------------------------------------------------------------------

-- ----------------------------------------------------------------------
-- Global exceptions
-- ----------------------------------------------------------------------

  /**************************************************************************
   *
   * PROCEDURE
   *   periodic_accrual
   *
   * DESCRIPTION
   *   Get the detais for the approval notification body.
   *
   * PARAMETERS
   * ==========
   * NAME              TYPE           DESCRIPTION
   * ----------------- -------------  --------------------------------------
   * errbuf            OUT            output buffer for error messages
   * retcode           OUT            return code for concurrent program
   *
   * PREREQUISITES
   *   List prerequisites to be satisfied
   *
   * CALLED BY
   *   List caller of this procedure
   *
   *************************************************************************/
    PROCEDURE periodic_accrual
  ( errbuf          OUT VARCHAR2
  , retcode         OUT NUMBER
  , p_period_name   IN VARCHAR2
  );

END XXAH_VA_AUTOACCRUAL_PKG;
 

/
