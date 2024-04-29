--------------------------------------------------------
--  DDL for Package XXAH_BPA_CATE_SUBCATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XXAH_BPA_CATE_SUBCATE" 
as
/**************************************************************************
 * VERSION      : $Id: XXAH_BPA_CATE_SUBCATE  2014-03-07 07:57:54Z vema.reddy@atos.net $
 * DESCRIPTION  : Contains BPA Category and Sub Category change.
 *
 * CHANGE HISTORY
 * ==============
 *
 * Date        Authors           Change reference/Description
 * ----------- ----------------- ----------------------------------
 * 07-MAR-2014 Vema REddy          RFC-AES003
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
   procedure XXAH_BPA_CATE_SUBCATE_PRC
(   errbuf      OUT VARCHAR2,
    retcode     OUT VARCHAR2,
   p_effective_start_date         in    VARCHAR2,
                                    p_structure_name     IN     VARCHAR2,
                                    p_old_sub_category   IN     VARCHAR2,
                                    p_new_sub_category   IN     VARCHAR2
);
end XXAH_BPA_CATE_SUBCATE;

/
