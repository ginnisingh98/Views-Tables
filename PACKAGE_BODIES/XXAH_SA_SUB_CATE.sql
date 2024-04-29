--------------------------------------------------------
--  DDL for Package Body XXAH_SA_SUB_CATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XXAH_SA_SUB_CATE" 
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
   PROCEDURE XXAH_SA_SUB_CATEGORY (errbuf                      OUT VARCHAR2,
                                   retcode                     OUT VARCHAR2,
                                   p_effective_start_date   IN     VARCHAR2,
                                   p_sa_structure_name      IN     VARCHAR2,
                                   p_old_sub_category       IN     VARCHAR2,
                                   p_new_sub_category       IN     VARCHAR2)
   IS
      v_structure_id       FND_ID_FLEX_STRUCTURES.ID_FLEX_NUM%TYPE;
      new_category_id      mtl_categories_b.category_id%TYPE;
      sales_person_name    ra_salesreps.name%TYPE;
      l_count              NUMBER;
      total_rows_updated   NUMBER := 0;

      CURSOR sa
      IS
         SELECT   obha.header_id, obha.order_number, obha.salesrep_id
           FROM   oe_blanket_headers_all obha,
                  oe_blanket_headers_ext obhe,
                  mtl_categories_b mcb
          WHERE   obha.order_number = obhe.order_number
                  AND obha.attribute2 = mcb.category_id
                  AND UPPER (mcb.segment1 || '.' || mcb.segment2) =
                        UPPER (p_old_sub_category)
                  AND mcb.structure_id =
                        (SELECT   ID_FLEX_NUM
                           FROM   FND_ID_FLEX_STRUCTURES
                          WHERE   ID_FLEX_STRUCTURE_CODE =
                                     p_sa_structure_name)
                  AND obhe.start_date_active >=
                        TO_DATE (p_effective_start_date,
                                 'YYYY/MM/DD HH24:MI:SS')
                                 order by obha.order_number;
   --TRUNC (SYSDATE - 9000);
   -- p_effective_start_date;
   --and trunc(to_date(obhe.start_date_active,'MM-DD-YYYY'))>=trunc(to_date(p_effective_start_date,'MM-DD-YYYY'));
   BEGIN
      SELECT   ID_FLEX_NUM
        INTO   v_structure_id
        FROM   FND_ID_FLEX_STRUCTURES
       WHERE   ID_FLEX_STRUCTURE_CODE = p_sa_structure_name;

      fnd_file.PUT_LINE (
         fnd_file.LOG,
            ' an unexpected error occured during v_structure_id '
         || ', '
         || v_structure_id
         || ' , '
         || p_sa_structure_name
         || ','
         || p_effective_start_date
         || ','
         || SQLERRM
      );

      --BEGIN
      SELECT   COUNT (1)
        INTO   l_count
        FROM   oe_blanket_headers_all obha,
               oe_blanket_headers_ext obhe,
               mtl_categories_b mcb
       WHERE   obha.order_number = obhe.order_number
               AND obha.attribute2 = mcb.category_id
               AND UPPER (mcb.segment1 || '.' || mcb.segment2) =
                     UPPER (p_old_sub_category)
               --AND mcb.category_id = v_category_id
               AND mcb.structure_id = v_structure_id
               --and trunc(to_date(obhe.start_date_active,'MM-DD-YYYY'))>=trunc(to_date(p_effective_start_date,'MM-DD-YYYY'));
               --               AND TRUNC (obhe.start_date_active) >=-- TRUNC (SYSDATE - 9000);
               --     p_effective_start_date;
               AND obhe.start_date_active >=
                     TO_DATE (p_effective_start_date,
                              'YYYY/MM/DD HH24:MI:SS');

      fnd_file.PUT_LINE (
         fnd_file.LOG,
            ' an unexpected error occured during l_count '
         || p_old_sub_category
         || ','
         || ','
         || p_effective_start_date
         || SQLERRM
      );

      SELECT   category_id
        INTO   new_category_id
        FROM   mtl_categories_b
       WHERE   UPPER (segment1 || '.' || segment2) =
                  UPPER (p_new_sub_category)
               AND structure_id = v_structure_id;

      fnd_file.PUT_LINE (
         fnd_file.LOG,
            ' an unexpected error occured during new_category_id '
         || p_new_sub_category
         || ','
         || SQLERRM
      );


      IF l_count >= 1
      THEN
         fnd_file.PUT_LINE (
            fnd_file.OUTPUT,
            ' *****************************************--> Sales Agreement Details <--***********************************'
         );

         FOR cur_sa IN sa
         LOOP
            SELECT   name
              INTO   sales_person_name
              FROM   ra_salesreps
             WHERE   salesrep_id = cur_sa.salesrep_id;

            BEGIN
               UPDATE   oe_blanket_headers_all
                  SET   attribute2 = new_category_id
                WHERE   header_id = cur_sa.header_id;

               --total_rows_updated:=sa%rowcount;
               total_rows_updated := total_rows_updated + 1;
               fnd_file.PUT_LINE (
                  fnd_file.OUTPUT,
                     TO_CHAR (SYSTIMESTAMP, 'HH24:MI:SS.FF2 ')
                  || 'Sales Agreement Number-->'
                  || cur_sa.order_number
                  || ' '
                  || 'Sales Person -->'
                  || sales_person_name
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

            COMMIT;
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
         ' --> End XXAH_SA_SUB_CATEGORY  ('
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
   END XXAH_SA_SUB_CATEGORY;
END XXAH_SA_SUB_CATE;

/
