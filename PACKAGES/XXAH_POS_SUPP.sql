--------------------------------------------------------
--  DDL for Package XXAH_POS_SUPP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XXAH_POS_SUPP" as
/**************************************************************************
 * VERSION      : $Id: xxah_pos_supp.pks  2016-05-25 08:28:10Z vema.reddy@atos.net $
 * DESCRIPTION  : Contains functionality for Deleting Old Records
 *
 * CHANGE HISTORY
 * ==============
 *
 * Date        Authors           Change reference/Description
 * ----------- ----------------- ----------------------------------
 * 25-May-2016 Vema Reddy       Initial
 *************************************************************************/

   /**************************************************************************
   *
   * PROCEDURE
   *   Delete records
   *
   * DESCRIPTION
   *    Delete ol Records on POS_SUPP_PUB_HISTORY table
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
procedure xxah_pub_history_delete(errorbuf out varchar2,
                                               retcode out  number );
end   xxah_pos_supp;

/
