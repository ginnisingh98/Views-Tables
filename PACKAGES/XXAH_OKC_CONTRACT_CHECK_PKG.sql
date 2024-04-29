--------------------------------------------------------
--  DDL for Package XXAH_OKC_CONTRACT_CHECK_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XXAH_OKC_CONTRACT_CHECK_PKG" AS
/**************************************************************************
 * VERSION      : $Id: XXAH_OKC_CONTRACT_CHECK_PKG.pls 01 2010-04-13 10:33:00Z kbouwmee $
 * DESCRIPTION  : Perform checks on contract
 *
 * CHANGE HISTORY
 * ==============
 *
 * Date        Authors           Change reference/Description
 * ----------- ----------------- ----------------------------------
 * 13-APR-2010 Kevin Bouwmeester Genesis
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
   *   check_contract
   *
   * DESCRIPTION
   *   Describe what procedure does
   *
   * PARAMETERS
   * ==========
   * NAME              TYPE           DESCRIPTION
   * ----------------- -------------  --------------------------------------
   * param_name        IN,OUT,IN/OUT  Describe parameter
   *
   * PREREQUISITES
   *   List prerequisites to be satisfied
   *
   * CALLED BY
   *   List caller of this procedure
   *
   *************************************************************************/
  PROCEDURE check_contract
  ( p_itemtype  IN VARCHAR2
  , p_itemkey   IN VARCHAR2
  , p_actid     IN NUMBER
  , p_funcmode  IN VARCHAR2
  , p_resultout IN OUT NOCOPY VARCHAR2
  );

END XXAH_OKC_CONTRACT_CHECK_PKG;
 

/
