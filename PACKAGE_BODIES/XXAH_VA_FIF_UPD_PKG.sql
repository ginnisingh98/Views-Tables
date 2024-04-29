--------------------------------------------------------
--  DDL for Package Body XXAH_VA_FIF_UPD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XXAH_VA_FIF_UPD_PKG" 
AS
   PROCEDURE UPDATE_SA_LINES (
      errbuf                OUT VARCHAR2,
      retcode               OUT VARCHAR2,
      p_blanket_number   IN     oe_blanket_headers_all.order_number%TYPE,
      p_line_number      IN     oe_blanket_lines_all.line_number%TYPE
   )
   IS
      l_invoice_flag   oe_blanket_lines_all.attribute10%TYPE := NULL;
      l_order_number oe_blanket_headers_all.order_number%TYPE;
      l_header_id oe_blanket_headers_all.header_id%TYPE;
      l_line_number oe_blanket_lines_all.line_number%TYPE;
      l_line_id oe_blanket_lines_all.line_id%TYPE;
      e_invalid_data EXCEPTION;

      CURSOR c_blanket
      IS
         SELECT   obha.order_number,
                  obha.header_id,
                  obla.line_number,
                  obla.line_id
           FROM   oe_blanket_headers_all obha, oe_blanket_lines_all obla
          WHERE       obha.header_id = obla.header_id
                  AND obha.order_number = p_blanket_number
                  AND obla.line_number = p_line_number
                  AND obha.flow_status_code = 'EXPIRED'
                  AND NVL (obla.attribute10, ' ') <> 'Y';

   BEGIN

--      FOR c_obla IN c_blanket
--      LOOP

      OPEN c_blanket;
      FETCH c_blanket into l_order_number,l_header_id,l_line_number,l_line_id;
         IF c_blanket%NOTFOUND
         THEN
         fnd_file.put_line (
               fnd_file.output,'----------------------------------------------------------------------');
            fnd_file.put_line (
               fnd_file.output,
               'Sales Agreement Line Number not exists or Final Invoice Flag is already set as "Y"  for selected Agreement: '
            );
            RAISE e_invalid_data;
         ELSIF c_blanket%FOUND
         THEN

            BEGIN

               SELECT   obla.attribute10
                 INTO   l_invoice_flag
                 FROM   oe_blanket_headers_all obha,
                        oe_blanket_lines_all obla
                WHERE       obha.header_id = obla.header_id
                        AND obha.header_id = l_header_id
                        AND obla.line_number = l_line_number;
            EXCEPTION
               WHEN OTHERS
               THEN
                  l_invoice_flag := NULL;
            END;
         END IF;

         IF NVL (l_invoice_flag, ' ') <> 'Y'
         THEN

            UPDATE   oe_blanket_lines_all
               SET   attribute10 = 'Y'
             WHERE   header_id = l_header_id
                     AND line_number =l_line_number;

            COMMIT;
               fnd_file.put_line (
               fnd_file.output,'----------------------------------------------------------------------');

            fnd_file.put_line (fnd_file.output, 'Updated Agreements: ');
            fnd_file.put_line (
               fnd_file.output,
               'Agreement Number                          Line Number'
            );
            fnd_file.put_line (
               fnd_file.output,
                  l_order_number
               || '                                     '
               || l_line_number
            );
         END IF;
      --END LOOP;
      CLOSE c_blanket;
   END UPDATE_SA_LINES;
END xxah_va_fif_upd_pkg;

/
