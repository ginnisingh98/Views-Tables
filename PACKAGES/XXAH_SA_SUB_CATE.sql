--------------------------------------------------------
--  DDL for Package XXAH_SA_SUB_CATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XXAH_SA_SUB_CATE" 
AS
/**************************************************************************
 * VERSION      : $Id: XXAH_SA_SUB_CATE  2014-03-07 07:57:54Z vema.reddy@atos.net $
 * DESCRIPTION  : Contains BPA Category and Sub Category change.
 *
 * CHANGE HISTORY
 * ==============
 *
 * Date        Authors           Change reference/Description
 * ----------- ----------------- ----------------------------------
 * 07-MAR-2014 Vema Reddy          RFC-AES003
 *************************************************************************/
 /**************************************************************************
   *
   * PROCEDURE
   *
   * DESCRIPTION
   *   Get the old  and New (Sub) category detais and  processing.
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
procedure XXAH_SA_SUB_CATEGORY(
      errbuf                         OUT VARCHAR2,
      retcode                        OUT VARCHAR2,
      p_effective_start_date         in    varchar2,
    p_sa_structure_name                     in varchar2,
    p_old_sub_category                       in varchar2,
    p_new_sub_category                    in varchar2
   );
end    XXAH_SA_SUB_CATE;

/
