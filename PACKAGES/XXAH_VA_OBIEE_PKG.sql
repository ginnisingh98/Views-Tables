--------------------------------------------------------
--  DDL for Package XXAH_VA_OBIEE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XXAH_VA_OBIEE_PKG" AS
/**************************************************************************
 * VERSION      : $Id$
 * DESCRIPTION  : Contains functionality for the OBIEE reporting tool
 *
 * CHANGE HISTORY
 * ==============
 *
 * Date        Authors           Change reference/Description
 * ----------- ----------------- ----------------------------------
 * 05-OCT-2010 Serge Vervaet     Genesis
 *************************************************************************/

  PROCEDURE extract_obiee_data ( errbuf               OUT VARCHAR2
                               , retcode              OUT NUMBER
                               , p_refresh_from_date  IN  VARCHAR2
                               );

END XXAH_VA_OBIEE_PKG;
 

/
