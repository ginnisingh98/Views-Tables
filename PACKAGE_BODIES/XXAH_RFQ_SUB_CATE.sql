--------------------------------------------------------
--  DDL for Package Body XXAH_RFQ_SUB_CATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XXAH_RFQ_SUB_CATE" 
AS
/**************************************************************************
 * VERSION      : $Id: XXAH_RFQ_SUB_CATE  2014-03-07 07:57:54Z vema.reddy@atos.net $
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
   PROCEDURE XXAH_RFQ_SUB_CATEGORY (errbuf                      OUT VARCHAR2,
                                    retcode                     OUT VARCHAR2,
                                    p_effective_start_date   IN     VARCHAR2,
                                    p_rfq_structure_name     IN     VARCHAR2,
                                    p_old_sub_category       IN     VARCHAR2,
                                    p_new_sub_category       IN     VARCHAR2)
   IS
      v_structure_id       FND_ID_FLEX_STRUCTURES.ID_FLEX_NUM%TYPE;
      new_category_id      mtl_categories_b.category_id%TYPE;
      p_buyer_name         per_all_people_f.full_name%TYPE;
      l_count              NUMBER;
      total_rows_updated   NUMBER := 0;


      CURSOR RFQ
      IS
         SELECT   paip.auction_header_id,
                  paip.line_number,
                  paha.TRADING_PARTNER_CONTACT_ID
           FROM   PON_AUCTION_HEADERS_ALL paha,
                  pon_aUction_item_prices_all paip,
                  mtl_categories_b mcb
          WHERE   paha.AUCTION_HEADER_ID = paip.AUCTION_HEADER_ID
                  AND mcb.category_id = paip.category_id
                  AND UPPER (mcb.segment1 || '.' || mcb.segment2) =
                        UPPER (p_old_sub_category)
                  AND mcb.structure_id =
                        (SELECT   ID_FLEX_NUM
                           FROM   FND_ID_FLEX_STRUCTURES
                          WHERE   ID_FLEX_STRUCTURE_CODE =
                                     p_rfq_structure_name)
                  AND paha.OPEN_BIDDING_DATE >=
                        TO_DATE (p_effective_start_date,
                                 'YYYY/MM/DD HH24:MI:SS')
                                 order by paip.auction_header_id,
                  paip.line_number;
   BEGIN
      SELECT   ID_FLEX_NUM
        INTO   v_structure_id
        FROM   FND_ID_FLEX_STRUCTURES
       WHERE   ID_FLEX_STRUCTURE_CODE = p_rfq_structure_name;

      SELECT   COUNT (1)
        INTO   l_count
        FROM   PON_AUCTION_HEADERS_ALL paha,
               PON_AUCTION_ITEM_PRICES_ALL paip,
               mtl_categories_b mcb
       WHERE       paha.AUCTION_HEADER_ID = paip.AUCTION_HEADER_ID
               AND mcb.category_id = paip.category_id
               AND mcb.segment1 || '.' || mcb.segment2 = p_old_sub_category
               AND mcb.structure_id = v_structure_id
               AND paha.OPEN_BIDDING_DATE >=
                     TO_DATE (p_effective_start_date,
                              'YYYY/MM/DD HH24:MI:SS');

      --TRUNC (p_effective_start_date);

      SELECT   category_id
        INTO   new_category_id
        FROM   mtl_categories_b
       WHERE   UPPER (segment1 || '.' || segment2) =
                  UPPER (p_new_sub_category)
               AND structure_id = v_structure_id;

      IF l_count >= 1
      THEN
         fnd_file.PUT_LINE (
            fnd_file.OUTPUT,
            ' *****************************************--> RFQ Details <--***************************************'
         );

         FOR cur_rfq IN rfq
         LOOP
            BEGIN
               SELECT   full_name
                 INTO   p_buyer_name
                 FROM   per_all_people_f papf
                WHERE   party_id = cur_rfq.TRADING_PARTNER_CONTACT_ID
                        AND TRUNC (SYSDATE) BETWEEN papf.effective_start_date
                                                AND  papf.effective_end_Date;

               UPDATE   PON_AUCTION_ITEM_PRICES_ALL
                  SET   category_id = new_category_id,
                        category_name = p_new_sub_category
                WHERE   auction_header_id = cur_rfq.auction_header_id
                        AND line_number = cur_rfq.line_number;

               total_rows_updated := total_rows_updated + 1;
               fnd_file.PUT_LINE (
                  fnd_file.OUTPUT,
                     TO_CHAR (SYSTIMESTAMP, 'HH24:MI:SS.FF2 ')
                  || 'RFQ Number -->'
                  || cur_rfq.auction_header_id
                  || ' '
                  || 'Line Number -->'
                  || cur_rfq.line_number
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
         ' --> End RFQ Program  ('
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
   END XXAH_RFQ_SUB_CATEGORY;
END XXAH_RFQ_SUB_CATE;

/
