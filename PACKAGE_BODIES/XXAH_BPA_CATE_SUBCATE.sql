--------------------------------------------------------
--  DDL for Package Body XXAH_BPA_CATE_SUBCATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XXAH_BPA_CATE_SUBCATE" 
AS
/**************************************************************************
 * VERSION      : $Id: XXAH_BPA_CATE_SUBCATE  2014-03-07 07:57:54Z vema.reddy@atos.net $
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
   PROCEDURE XXAH_BPA_CATE_SUBCATE_PRC (
      errbuf                      OUT VARCHAR2,
      retcode                     OUT VARCHAR2,
      p_effective_start_date   IN     VARCHAR2,
      p_structure_name         IN     VARCHAR2,
      p_old_sub_category       IN     VARCHAR2,
      p_new_sub_category       IN     VARCHAR2
   )
   IS
      v_structure_id       FND_ID_FLEX_STRUCTURES.ID_FLEX_NUM%TYPE;
      n_category_id        mtl_categories_b.category_id%TYPE;
      p_buyer_name         per_all_people_f.full_name%TYPE;
      l_n_count            NUMBER;
      total_rows_updated   NUMBER := 0;



      CURSOR bpa
      IS
         SELECT   pla.po_line_id,pla.line_num,pha.segment1, pha.agent_id
           FROM   po_headers_all pha, po_lines_all pla, mtl_categories_b mcb
          WHERE   pha.PO_HEADER_ID = pla.PO_HEADER_ID
                  AND pla.CATEGORY_ID = mcb.CATEGORY_ID
                  AND UPPER (mcb.segment1 || '.' || mcb.segment2) =
                        UPPER (p_old_sub_category)
                  AND mcb.structure_id =
                        (SELECT   ID_FLEX_NUM
                           FROM   FND_ID_FLEX_STRUCTURES
                          WHERE   ID_FLEX_STRUCTURE_CODE = p_structure_name)
                  AND pha.start_date >=
                        TO_DATE (p_effective_start_date,
                                 'YYYY/MM/DD HH24:MI:SS')
                                 order by pha.segment1,pla.line_num;
   BEGIN
      SELECT   ID_FLEX_NUM
        INTO   v_structure_id
        FROM   FND_ID_FLEX_STRUCTURES
       WHERE   ID_FLEX_STRUCTURE_CODE = p_structure_name;

      SELECT   COUNT ( * )
        INTO   l_n_count
        FROM   po_headers_all pha, po_lines_all pla, mtl_categories_b mcb
       WHERE   pha.PO_HEADER_ID = pla.PO_HEADER_ID
               AND pla.CATEGORY_ID = mcb.CATEGORY_ID
               AND UPPER (mcb.segment1 || '.' || mcb.segment2) =
                     UPPER (p_old_sub_category)
               AND mcb.structure_id = v_structure_id
               AND pha.start_date >=
                     TO_DATE (p_effective_start_date,
                              'YYYY/MM/DD HH24:MI:SS');

      --p_effective_start_date;



      IF l_n_count >= 1
      THEN
         SELECT   category_id
           INTO   n_category_id
           FROM   mtl_categories_b mcb
          WHERE   UPPER (mcb.segment1 || '.' || mcb.segment2) =
                     UPPER (p_new_sub_category)
                  AND mcb.structure_id = v_structure_id;

         fnd_file.PUT_LINE (
            fnd_file.OUTPUT,
            ' *****************************************--> BPA Details <--*******************************************'
         );

         FOR cur_bpa IN bpa
         LOOP
            BEGIN
               SELECT   full_name
                 INTO   p_buyer_name
                 FROM   per_all_people_f papf
                WHERE   person_id = cur_bpa.agent_id
                        AND TRUNC (SYSDATE) BETWEEN papf.effective_start_date
                                                AND  papf.effective_end_Date;

               UPDATE   po_lines_all
                  SET   category_id = n_category_id
                WHERE   po_line_id = cur_bpa.po_line_id;

               total_rows_updated := total_rows_updated + 1;

               COMMIT;

               fnd_file.PUT_LINE (
                  fnd_file.OUTPUT,
                        TO_CHAR (SYSTIMESTAMP, 'HH24:MI:SS.FF2 ')
                  || 'BPA Number -->'
                  || cur_bpa.segment1
                  || ' '
                  || 'Line Number -->'
                  || cur_bpa.line_num
                  || ' '
                  || 'Buyer Name -->'
                  || p_buyer_name
               );
            EXCEPTION
               WHEN OTHERS
               THEN
                  fnd_file.put_line (
                     fnd_file.LOG,
                     ' an unexpected error occured during update on '
                     || SQLERRM
                  );
                  errbuf := SQLERRM;
                  retcode := 2;
            END;
         END LOOP;
      END IF;

      fnd_file.PUT_LINE (
         fnd_file.OUTPUT,
         ' *************************************************'
      );
      fnd_file.PUT_LINE (
         fnd_file.OUTPUT,
         ' --> Number of records updated =' || total_rows_updated
      );
      fnd_file.PUT_LINE (
         fnd_file.OUTPUT,
         ' --> End BPA Program  ('
         || TO_CHAR (SYSDATE, 'DD-MON-YYYY HH24:MI:SS')
         || ')'
      );
      fnd_file.PUT_LINE (
         fnd_file.OUTPUT,
         ' *************************************************'
      );
      fnd_file.PUT_LINE (fnd_file.OUTPUT, ' ');
      errbuf := '';
      retcode := 0;
   EXCEPTION
      WHEN OTHERS
      THEN
         fnd_file.PUT_LINE (
            fnd_file.LOG,
            ' an unexpected error occured during ' || SQLERRM
         );
         errbuf := SQLERRM;
         retcode := 2;
   END XXAH_BPA_CATE_SUBCATE_PRC;
END XXAH_BPA_CATE_SUBCATE;

/
