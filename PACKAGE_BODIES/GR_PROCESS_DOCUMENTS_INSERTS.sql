--------------------------------------------------------
--  DDL for Package Body GR_PROCESS_DOCUMENTS_INSERTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GR_PROCESS_DOCUMENTS_INSERTS" AS
/*  $Header: GRPDOCIB.pls 115.2 2003/02/28 15:10:12 mgrosser noship $    */

/*===========================================================================
--  PROCEDURE:
--    Worksheet_Insert_Row
--
--  DESCRIPTION:
--    This PL/SQL procedure is used to identify missing data in the worksheet
--    and to insert data into gr_work_worksheets.
--
--  PARAMETERS:
--    p_line_number IN OUT NOCOPY NUMBER     - Line number of inserted record
--    p_output_type     IN VARCHAR2   - 'PDF','XML','HTML', etc
--    p_language_code   IN VARCHAR2   - Language that worksheet is being printed in
--    p_session_id      IN NUMBER     - Session id for report
--    p_item_code       IN VARCHAR2   - Item that document is being printed for
--    p_print_font      IN VARCHAR2   - Type of font to print the text in
--    p_print_size      IN NUMBER     - Size of font to print the text in
--    p_text_line       IN VARCHAR2   - Text to be inserted
--    p_line_type       IN VARCHAR2   - Type of value being inserted
--    x_return_status  OUT NOCOPY VARCHAR2   - 'S'uccess, 'E'rror, 'U'nexpected Error
--
--  SYNOPSIS:
--    Worksheet_Insert_Row(g_line_number,g_output_type,g_language_code, g_session_id,l_item_code,
--                         l_print_font,l_print_size,l_text_line,l_line_type,l_return_status);
--
--  HISTORY
--    M. Grosser 27-Feb-2003 BUG 2718956 - Put an IF statment around the selection of
--                           organization data and the error message associated with it.
--                           It is only applicable to organization data.
--=========================================================================== */
PROCEDURE Worksheet_Insert_Row
                (p_line_number IN OUT NOCOPY NUMBER,
                 p_output_type IN VARCHAR2,
                 p_user_id IN NUMBER,
                 p_current_date IN DATE,
                 p_language_code IN VARCHAR2,
                 p_session_id IN NUMBER,
                 p_item_code IN VARCHAR2,
                 p_print_font IN VARCHAR2,
                 p_print_size IN NUMBER,
                 p_text_line IN VARCHAR2,
                 p_line_type IN VARCHAR2,
                 x_return_status OUT NOCOPY VARCHAR2)
IS

/*  ------------- LOCAL VARIABLES ------------------- */
L_TEXT_LINE          GR_WORK_WORKSHEETS.text_line%TYPE;
L_LABEL_CODE         GR_LABELS_B.label_code%TYPE;
L_ADDR_LINE          SY_ADDR_MST.addr1%TYPE;
L_DEFAULT_ORGN       SY_ORGN_MST.orgn_code%TYPE;
L_TELEPHONE_NUMBER   VARCHAR2(78);
L_LINE_LEN           NUMBER;
L_LABEL_LEN          NUMBER;
L_LANGUAGE_CODE      VARCHAR(4);


/*  ------------------ CURSORS ---------------------- */
/* Get the organization name, address and contact information */
CURSOR c_get_orgn_info IS
   SELECT   om.orgn_name,
            oa.addr1,
            oa.addr2,
            oa.addr3,
            oa.addr4,
            oa.postal_code,
            oa.state_code,
            oa.country_code,
            oc.daytime_contact_name,
            oc.daytime_telephone,
            oc.daytime_extension,
            oc.daytime_area_code,
            oc.evening_contact_name,
            oc.evening_telephone,
            oc.evening_extension,
            oc.evening_area_code,
            oc.daytime_fax_no,
            oc.daytime_email,
            oc.evening_fax_no,
            oc.evening_email
   FROM     gr_organization_contacts oc,
            sy_addr_mst oa,
            sy_orgn_mst om
   WHERE    om.orgn_code = l_default_orgn
   AND      om.addr_id = oa.addr_id
   AND      oc.orgn_code = om.orgn_code;
LocalOrgnRecord     c_get_orgn_info%ROWTYPE;

/*	Get the label description and print information */
CURSOR c_get_label_info IS
   SELECT   lab.data_position_indicator,
            lat.label_description
   FROM     gr_labels_tl lat,
            gr_labels_b lab
   WHERE    lab.label_code = l_label_code
   AND      lat.label_code = lab.label_code
   AND      lat.language = l_language_code;
LocalLabelRecord    c_get_label_info%ROWTYPE;


/*
**	Get the country description
*/
CURSOR c_get_country_info (V_country_code VARCHAR2) IS
   SELECT   geog_desc
   FROM     sy_geog_mst
   WHERE    geog_type = 1
   AND      geog_code = V_country_code;
LocalCountryRecord     c_get_country_info%ROWTYPE;


BEGIN
   x_return_status := 'S';

   IF p_line_number IS NULL THEN
      p_line_number := 0;
   END IF;

   l_text_line := p_text_line;

   l_default_orgn := FND_PROFILE.Value('GR_ORGN_DEFAULT');

   IF p_language_code is NULL THEN
      l_language_code := USERENV('LANG');
   ELSE
      l_language_code := p_language_code;
   END IF;

   /* M. Grosser 27-Feb-2003 BUG 2718956 - Put an IF statment around the selection of
                        organization data and the error message associated with it.
                        It is only applicable to organization data.
   */
   IF l_text_line in ('01100','01101','01102','01103','01104','01105','01106','01107','01008') THEN
      OPEN c_get_orgn_info;
      FETCH c_get_orgn_info INTO LocalOrgnRecord;
      IF c_get_orgn_info%NOTFOUND THEN
         FND_FILE.PUT(FND_FILE.LOG,l_default_orgn || ' orgn address/contact missing');
         FND_FILE.NEW_LINE(FND_FILE.LOG,1);
      END IF;
      CLOSE c_get_orgn_info;
   END IF; /* If printing organization information */
   /* M. Grosser 27-Feb-2003  BUG 2718956 - End of changes */

   IF l_text_line = '01100' THEN
      l_label_code := '01100';
      OPEN c_get_label_info;
      FETCH c_get_label_info INTO LocalLabelRecord;

      /*
      **  If no label info print the code and ????
      */
      IF c_get_label_info%NOTFOUND THEN
         l_text_line := l_label_code || ' has no details';
         FND_FILE.PUT(FND_FILE.LOG,l_text_line);
         FND_FILE.NEW_LINE(FND_FILE.LOG,1);
      ELSE
         l_text_line := LocalLabelRecord.label_description;
         IF LocalLabelRecord.data_position_indicator = 'I' THEN
            l_text_line := l_text_line || ' '||LocalOrgnRecord.orgn_name;
            l_label_len := LENGTH(LocalLabelRecord.label_description) + 1;
         ELSIF LocalLabelRecord.data_position_indicator IN ('C', 'R') THEN
            l_text_line := RPAD(l_text_line,30)||' '||LocalOrgnRecord.orgn_name;
            l_label_len := 31;
         END IF;

         /* Created new procedure to avoid redundant code */
         Insert_Gr_Work_Worksheets (p_output_type,p_line_number,p_session_id,
                p_item_code, p_print_font, p_print_size,l_text_line, p_line_type, x_return_status);

         IF LocalLabelRecord.data_position_indicator = 'N' THEN
            l_text_line := LocalOrgnRecord.orgn_name;
            l_label_len := 0;

            /* Created new procedure to avoid redundant code */
            Insert_Gr_Work_Worksheets (p_output_type,p_line_number,p_session_id,
                   p_item_code, p_print_font, p_print_size,l_text_line, p_line_type, x_return_status);
         END IF;

         IF LocalOrgnRecord.addr1 IS NOT NULL THEN
            l_addr_line := LocalOrgnRecord.addr1;
            l_line_len := l_label_len + LENGTH(l_addr_line);
            l_text_line := LPAD(l_addr_line,l_line_len,' ');


            /* Created new procedure to avoid redundant code */
            Insert_Gr_Work_Worksheets (p_output_type,p_line_number,p_session_id,
                   p_item_code, p_print_font, p_print_size,l_text_line, p_line_type, x_return_status);
         END IF;

         IF LocalOrgnRecord.addr2 IS NOT NULL THEN
            l_addr_line := LocalOrgnRecord.addr2;
            l_line_len := l_label_len + LENGTH(l_addr_line);
            l_text_line := LPAD(l_addr_line,l_line_len,' ');


            /* Created new procedure to avoid redundant code */
            Insert_Gr_Work_Worksheets (p_output_type,p_line_number,p_session_id,
                   p_item_code, p_print_font, p_print_size,l_text_line, p_line_type, x_return_status);
		 END IF;

		 IF LocalOrgnRecord.addr3 IS NOT NULL THEN
            l_addr_line := LocalOrgnRecord.addr3;
            l_line_len := l_label_len + LENGTH(l_addr_line);
            l_text_line := LPAD(l_addr_line,l_line_len,' ');

            /* Created new procedure to avoid redundant code */
            Insert_Gr_Work_Worksheets (p_output_type,p_line_number,p_session_id,
                   p_item_code, p_print_font, p_print_size,l_text_line, p_line_type, x_return_status);
		 END IF;

         IF (LocalOrgnRecord.addr4 IS NOT NULL) OR
              (LocalOrgnRecord.state_code IS NOT NULL) OR
              (LocalOrgnRecord.postal_code IS NOT NULL) THEN
            l_addr_line := NULL;

            IF LocalOrgnRecord.addr4 IS NOT NULL THEN
               l_addr_line := LocalOrgnRecord.addr4;
            END IF;

            IF LocalOrgnRecord.state_code IS NOT NULL THEN
               l_addr_line := l_addr_line ||' '||LocalOrgnRecord.state_code;
            END IF;

            IF LocalOrgnRecord.postal_code IS NOT NULL THEN
               l_addr_line := l_addr_line||' '||LocalOrgnRecord.postal_code;
            END IF;

            l_line_len := l_label_len + LENGTH(l_addr_line);
            l_text_line := LPAD(l_addr_line,l_line_len,' ');

            /* Created new procedure to avoid redundant code */
            Insert_Gr_Work_Worksheets (p_output_type,p_line_number,p_session_id,
                   p_item_code, p_print_font, p_print_size,l_text_line, p_line_type, x_return_status);
         END IF;

         IF LocalOrgnRecord.country_code IS NOT NULL THEN
            l_addr_line := LocalOrgnRecord.country_code;
            OPEN c_get_country_info(l_addr_line);
            FETCH c_get_country_info INTO LocalCountryRecord;

            IF c_get_country_info%FOUND THEN
               l_addr_line := LocalCountryRecord.geog_desc;
            END IF;

            CLOSE c_get_country_info;
            l_line_len := l_label_len + LENGTH(l_addr_line);
            l_text_line := LPAD(l_addr_line,l_line_len,' ');

            /* Created new procedure to avoid redundant code */
            Insert_Gr_Work_Worksheets (p_output_type,p_line_number,p_session_id,
                   p_item_code, p_print_font, p_print_size,l_text_line, p_line_type, x_return_status);
         END IF;

      END IF;
      CLOSE c_get_label_info;
      l_text_line := NULL;


   /*
   **  Label code for printing the daytime contact name
   */
   ELSIF l_text_line = '01101' THEN
      IF LocalOrgnRecord.daytime_contact_name IS NOT NULL THEN
         l_label_code := '01101';
         OPEN c_get_label_info;
         FETCH c_get_label_info INTO LocalLabelRecord;

         /*
         **  If no label info print the label code and ??????
         */
         IF c_get_label_info%NOTFOUND THEN
            l_text_line := l_label_code || '??????' || ' ';
            l_text_line := l_text_line || LocalOrgnRecord.daytime_contact_name;
         ELSE
            l_text_line := LocalLabelRecord.label_description;

            /*
            **  Label info and print data on the same line
            */
            IF LocalLabelRecord.data_position_indicator = 'I' THEN
               l_text_line := l_text_line || ' '||LocalOrgnRecord.daytime_contact_name;
            ELSIF LocalLabelRecord.data_position_indicator IN ('C', 'R') THEN
               l_text_line := RPAD(l_text_line,30)||' '||LocalOrgnRecord.daytime_contact_name;
            /*
            **  Label info and print data on the next line
            */
            ELSE
               /* Created new procedure to avoid redundant code */
               Insert_Gr_Work_Worksheets (p_output_type,p_line_number,p_session_id,
                      p_item_code, p_print_font, p_print_size,l_text_line, p_line_type, x_return_status);
               l_text_line := LocalOrgnRecord.daytime_contact_name;
            END IF;
         END IF;
         CLOSE c_get_label_info;
      END IF;

   /*
   **  Label code for printing the daytime contact number
   */
   ELSIF l_text_line = '01102' THEN
      IF LocalOrgnRecord.daytime_telephone IS NOT NULL THEN
         l_label_code := '01102';
         l_telephone_number := LocalOrgnRecord.daytime_area_code;

         IF l_telephone_number IS NOT NULL THEN
            l_telephone_number := l_telephone_number || ' ' || LocalOrgnRecord.daytime_telephone;
         ELSE
            l_telephone_number := LocalOrgnRecord.daytime_telephone;
         END IF;

         l_telephone_number := l_telephone_number || ' ' || LocalOrgnRecord.daytime_extension;
		 OPEN c_get_label_info;
         FETCH c_get_label_info INTO LocalLabelRecord;

         /*
         **	 If no label info print the label code and ??????
         */
         IF c_get_label_info%NOTFOUND THEN
            l_text_line := l_label_code || '??????' || ' ' || l_telephone_number;
         ELSE
            l_text_line := LocalLabelRecord.label_description;

            /*
            **  Label info and print data on the same line
            */
            IF LocalLabelRecord.data_position_indicator = 'I' THEN
               l_text_line := l_text_line || ' '||l_telephone_number;
            ELSIF LocalLabelRecord.data_position_indicator IN ('C', 'R') THEN
               l_text_line := RPAD(LocalLabelRecord.label_description,30,' ')||' '||l_telephone_number;
            /*
            **  Label info and print data on the next line
            */
            ELSE
               /* Created new procedure to avoid redundant code */
               Insert_Gr_Work_Worksheets (p_output_type,p_line_number,p_session_id,
                      p_item_code, p_print_font, p_print_size,l_text_line, p_line_type, x_return_status);
               l_text_line := l_telephone_number;
            END IF;
         END IF;
         CLOSE c_get_label_info;
      END IF;

   /*
   **  Label code for printing the evening contact name
   */
   ELSIF l_text_line = '01103' THEN
      IF LocalOrgnRecord.evening_contact_name IS NOT NULL THEN
         l_label_code := '01103';
         OPEN c_get_label_info;
         FETCH c_get_label_info INTO LocalLabelRecord;

         /*
         **  If no label info print the label code and ??????
         */
         IF c_get_label_info%NOTFOUND THEN
            l_text_line := l_label_code || '??????' || ' ';
            l_text_line := l_text_line || LocalOrgnRecord.evening_contact_name;
         ELSE
            l_text_line := LocalLabelRecord.label_description;

            /*
            **  Label info and print data on the same line
            */
            IF LocalLabelRecord.data_position_indicator = 'I' THEN
               l_text_line := l_text_line || ' '||LocalOrgnRecord.evening_contact_name;
            ELSIF LocalLabelRecord.data_position_indicator IN ('C', 'R') THEN
               l_text_line := RPAD(LocalLabelRecord.label_description,30,' ')|| ' '||LocalOrgnRecord.evening_contact_name;
            /*
            **	Label info and print data on the next line
            */
            ELSE
               /* Created new procedure to avoid redundant code */
               Insert_Gr_Work_Worksheets (p_output_type,p_line_number,p_session_id,
                      p_item_code, p_print_font, p_print_size,l_text_line, p_line_type, x_return_status);
               l_text_line := LocalOrgnRecord.evening_contact_name;
            END IF;
            END IF;
         CLOSE c_get_label_info;
      END IF;

   /*
   **  Label code for printing the evening contact number
   */
   ELSIF l_text_line = '01104' THEN
      IF LocalOrgnRecord.evening_telephone IS NOT NULL THEN
         l_label_code := '01104';
         l_telephone_number := LocalOrgnRecord.evening_area_code;

         IF l_telephone_number IS NOT NULL THEN
            l_telephone_number := l_telephone_number || ' ' || LocalOrgnRecord.evening_telephone;
         ELSE
            l_telephone_number := LocalOrgnRecord.evening_telephone;
         END IF;

         l_telephone_number := l_telephone_number || ' ' || LocalOrgnRecord.evening_extension;
         OPEN c_get_label_info;
         FETCH c_get_label_info INTO LocalLabelRecord;

         /*
         **  If no label info print the label code and ??????
         */
         IF c_get_label_info%NOTFOUND THEN
            l_text_line := l_label_code || '??????' || ' ' || l_telephone_number;
         ELSE
            l_text_line := LocalLabelRecord.label_description;

            /*
            **  Label info and print data on the same line
            */
            IF LocalLabelRecord.data_position_indicator = 'I' THEN
               l_text_line := l_text_line || ' '||l_telephone_number;
            ELSIF LocalLabelRecord.data_position_indicator IN ('C', 'R') THEN
               l_text_line := RPAD(LocalLabelRecord.label_description,30,' ')||' '||l_telephone_number;
            /*
            **  Label info and print data on the next line
            */
            ELSE
               /* Created new procedure to avoid redundant code */
               Insert_Gr_Work_Worksheets (p_output_type,p_line_number,p_session_id,
                      p_item_code, p_print_font, p_print_size,l_text_line, p_line_type, x_return_status);
               l_text_line := l_telephone_number;
            END IF;

         END IF;
         CLOSE c_get_label_info;
      END IF;

   ELSIF l_text_line = '01105' THEN
      IF LocalOrgnRecord.daytime_fax_no IS NOT NULL THEN
         l_label_code := '01105';
         OPEN c_get_label_info;
         FETCH c_get_label_info INTO LocalLabelRecord;

         /*
         **  If no label info print the label code and ??????
         */
         IF c_get_label_info%NOTFOUND THEN
            l_text_line := l_label_code || '??????' || ' ';
            l_text_line := l_text_line || LocalOrgnRecord.daytime_fax_no;
         ELSE
            l_text_line := LocalLabelRecord.label_description;

            /*
            **  Label info and print data on the same line
            */
            IF LocalLabelRecord.data_position_indicator = 'I' THEN
               l_text_line := l_text_line || ' '||LocalOrgnRecord.daytime_fax_no;
            ELSIF LocalLabelRecord.data_position_indicator IN ('C', 'R') THEN
               l_text_line := RPAD(LocalLabelRecord.label_description,30,' ')|| ' '||LocalOrgnRecord.daytime_fax_no;
            /*
            **  Label info and print data on the next line
            */
            ELSE
               /* Created new procedure to avoid redundant code */
               Insert_Gr_Work_Worksheets (p_output_type,p_line_number,p_session_id,
                      p_item_code, p_print_font, p_print_size,l_text_line, p_line_type, x_return_status);

               l_text_line := LocalOrgnRecord.daytime_fax_no;
            END IF;

         END IF;
         CLOSE c_get_label_info;
      END IF;

   ELSIF l_text_line = '01106' THEN
      IF LocalOrgnRecord.daytime_email IS NOT NULL THEN
         l_label_code := '01106';
         OPEN c_get_label_info;
         FETCH c_get_label_info INTO LocalLabelRecord;

         /*
         **  If no label info print the label code and ??????
         */
         IF c_get_label_info%NOTFOUND THEN
            l_text_line := l_label_code || '??????' || ' ';
            l_text_line := l_text_line || LocalOrgnRecord.daytime_email;
         ELSE
            l_text_line := LocalLabelRecord.label_description;

            /*
            **  Label info and print data on the same line
            */
            IF LocalLabelRecord.data_position_indicator = 'I' THEN
               l_text_line := l_text_line || ' '||LocalOrgnRecord.daytime_email;
            ELSIF LocalLabelRecord.data_position_indicator IN ('C', 'R') THEN
               l_text_line := RPAD(LocalLabelRecord.label_description,30,' ')|| ' '||LocalOrgnRecord.daytime_email;
            /*
            **  Label info and print data on the next line
            */
            ELSE
               /* Created new procedure to avoid redundant code */
               Insert_Gr_Work_Worksheets (p_output_type,p_line_number,p_session_id,
                      p_item_code, p_print_font, p_print_size,l_text_line, p_line_type, x_return_status);
               l_text_line := LocalOrgnRecord.daytime_email;
            END IF;

         END IF;
         CLOSE c_get_label_info;
      END IF;

   ELSIF l_text_line = '01107' THEN
      IF LocalOrgnRecord.evening_fax_no IS NOT NULL THEN
         l_label_code := '01107';
         OPEN c_get_label_info;
         FETCH c_get_label_info INTO LocalLabelRecord;

         /*
         **  If no label info print the label code and ??????
         */
         IF c_get_label_info%NOTFOUND THEN
            l_text_line := l_label_code || '??????' || ' ';
            l_text_line := l_text_line || LocalOrgnRecord.evening_fax_no;
         ELSE
            l_text_line := LocalLabelRecord.label_description;

            /*
            **  Label info and print data on the same line
            */
            IF LocalLabelRecord.data_position_indicator = 'I' THEN
               l_text_line := l_text_line || ' '||LocalOrgnRecord.evening_fax_no;
            ELSIF LocalLabelRecord.data_position_indicator IN ('C', 'R') THEN
               l_text_line := RPAD(LocalLabelRecord.label_description,30,' ')|| ' '||LocalOrgnRecord.evening_fax_no;
            /*
            **  Label info and print data on the next line
            */
            ELSE
               /* Created new procedure to avoid redundant code */
               Insert_Gr_Work_Worksheets (p_output_type,p_line_number,p_session_id,
                      p_item_code, p_print_font, p_print_size,l_text_line, p_line_type, x_return_status);
               l_text_line := LocalOrgnRecord.evening_fax_no;
            END IF;

         END IF;
         CLOSE c_get_label_info;
      END IF;

   ELSIF l_text_line = '01108' THEN
      IF LocalOrgnRecord.evening_email IS NOT NULL THEN
         l_label_code := '01108';
         OPEN c_get_label_info;
         FETCH c_get_label_info INTO LocalLabelRecord;

         /*
         **	If no label info print the label code and ??????
         */
         IF c_get_label_info%NOTFOUND THEN
            l_text_line := l_label_code || '??????' || ' ';
            l_text_line := l_text_line || LocalOrgnRecord.evening_email;
         ELSE
            l_text_line := LocalLabelRecord.label_description;

            /*
            **  Label info and print data on the same line
            */
            IF LocalLabelRecord.data_position_indicator = 'I' THEN
               l_text_line := l_text_line || ' '||LocalOrgnRecord.evening_email;
            ELSIF LocalLabelRecord.data_position_indicator IN ('C', 'R') THEN
               l_text_line := RPAD(LocalLabelRecord.label_description,30,' ')|| ' '||LocalOrgnRecord.evening_email;
            /*
            **  Label info and print data on the next line
            */
            ELSE
               /* Created new procedure to avoid redundant code */
               Insert_Gr_Work_Worksheets (p_output_type,p_line_number,p_session_id,
                      p_item_code, p_print_font, p_print_size,l_text_line, p_line_type, x_return_status);
               l_text_line := LocalOrgnRecord.evening_email;
            END IF;

         END IF;
         CLOSE c_get_label_info;
      END IF;

   END IF;

   IF NVL(l_label_code, '00000') <> '01100' THEN

      /* Modified to allow proper formatting of XML*/
      IF p_output_type in ('XML','HTML') THEN
         IF p_line_type = 'LIN' THEN
            p_line_number := trunc(p_line_number/1000) * 1000 +1000;
         ELSIF p_line_type = 'COL' THEN
            p_line_number := p_line_number + 1;
         ELSE
            p_line_number := trunc(p_line_number /10000) * 10000 + 10000;
         END IF;
      ELSE
         p_line_number := p_line_number + 1;
      END IF; /* If XML or HTML */

      INSERT INTO gr_work_worksheets
                (session_id,
                 text_line_number,
                 item_code,
                 print_font,
                 print_size,
                 text_line,
                 line_type)
          VALUES
                (p_session_id,
                 p_line_number,
                 p_item_code,
                 p_print_font,
                 p_print_size,
                 l_text_line,
                 p_line_type);
   END IF;

EXCEPTION
   WHEN OTHERS THEN
      FND_FILE.PUT(FND_FILE.LOG,'   WORKSHEET INSERT: '||sqlerrm);
      FND_FILE.NEW_LINE(FND_FILE.LOG,1);
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END Worksheet_Insert_Row;




/*===========================================================================
--  PROCEDURE:
--    Document_Insert_Row
--
--  DESCRIPTION:
--    This PL/SQL procedure is used to insert a row into GR_DOCUMENT_DETAILS.
--
--  PARAMETERS:
--    p_line_number     IN OUT NOCOPY NUMBER     - Line number of inserted record
--    p_output_type         IN VARCHAR2   - 'PDF','XML','HTML', etc
--    p_document_text_id    IN VARCHAR2   - Language that worksheet is being printed in
--    p_user_id             IN NUMBER     - Id of user running the report
--    p_current_date        IN DATE       - Date that report is being printed
--    p_session_id          IN NUMBER     - Session id for report
--    p_item_code           IN VARCHAR2   - Item that document is being printed for
--    p_print_font          IN VARCHAR2   - Type of font to print the text in
--    p_print_size          IN NUMBER     - Size of font to print the text in
--    p_text_line           IN VARCHAR2   - Text to be inserted
--    p_line_type           IN VARCHAR2   - Type of value being inserted
--    x_return_status      OUT NOCOPY VARCHAR2   - 'S'uccess, 'E'rror, 'U'nexpected Error
--    x_msg_data           OUT NOCOPY VARCHAR2   - If there is an error, send back the approriate message
--
--  SYNOPSIS:
--    Document_Insert_Row(g_line_number,g_document_text_id,g_user_id,g_current_date,
--                        g_session_id,l_item_code,l_print_font,l_print_size,l_text_line,
--                        l_line_type,l_return_status);
--
--  HISTORY
--=========================================================================== */
PROCEDURE Document_Insert_Row
                (p_line_number IN OUT NOCOPY NUMBER,
                 p_output_type IN VARCHAR2,
                 p_document_text_id IN NUMBER,
                 p_user_id IN NUMBER,
                 p_current_date IN DATE,
                 p_session_id IN NUMBER,
                 p_item_code IN VARCHAR2,
                 p_print_font IN VARCHAR2,
                 p_print_size IN NUMBER,
                 p_text_line IN VARCHAR2,
                 p_line_type IN VARCHAR2,
                 x_return_status OUT NOCOPY VARCHAR2,
                 x_msg_data OUT NOCOPY VARCHAR2)


 IS

/*  ------------- LOCAL VARIABLES ------------------- */
/*	Alpha Variables */
L_COMMIT            VARCHAR2(1) := 'F';
L_CALLED_BY_FORM    VARCHAR2(1) := 'F';
L_ROWID	            VARCHAR2(18);
L_RETURN_STATUS	    VARCHAR2(1) := 'S';
L_MSG_DATA          VARCHAR2(2000);

/*	Number variables */
L_ORACLE_ERROR      NUMBER;


BEGIN
   x_return_status := 'S';
   l_return_status := 'S';

   IF p_line_number IS NULL THEN
      p_line_number := 0;
   END IF;

   /* Modified to allow proper formatting of XML*/
   IF p_output_type in ('XML','HTML') THEN
      IF p_line_type = 'LIN' THEN
         p_line_number := trunc(p_line_number/1000) * 1000 +1000;
      ELSIF p_line_type = 'COL' THEN
         p_line_number := p_line_number + 1;
      ELSE
         p_line_number := trunc(p_line_number /10000) * 10000 + 10000;
      END IF;
   ELSE
      p_line_number := p_line_number + 1;
   END IF; /* If XML or HTML */

   GR_DOCUMENT_DETAILS_PKG.Insert_Row
                 (l_commit,
                  l_called_by_form,
                  p_line_number,
                  p_document_text_id,
                  p_print_font,
                  p_print_size,
                  p_text_line,
                  p_line_type,
                  p_user_id,
                  p_current_date,
                  p_user_id,
                  p_current_date,
                  p_user_id,
                  l_rowid,
                  l_return_status,
                  l_oracle_error,
                  l_msg_data);

EXCEPTION
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_data := l_msg_data;
      FND_FILE.PUT(FND_FILE.LOG,' others '||sqlerrm);
      FND_FILE.NEW_LINE(FND_FILE.LOG,1);
END Document_Insert_Row;





/*===========================================================================
--  PROCEDURE:
--    Insert_Work_Row
--
--  DESCRIPTION:
--    This PL/SQL procedure is used to insert a row into GR_WORK_BUILD_DOCS.
--
--  PARAMETERS:
--    p_session_id              IN NUMBER     - Session id for report
--    p_document_code           IN VARCHAR2   - Document type being printed
--    p_main_heading_code       IN VARCHAR2   - Main heading that this data is being printed under
--    p_main_display_order      IN NUMBER     - Sequence number of headng
--    p_sub_heading_code        IN VARCHAR2   - Sub heading that this data is being printed under
--    p_sub_display_order       IN NUMBER     - Sequence number of subheading
--    p_record_type             IN VARCHAR2   - Type of record being inserted
--    p_label_or_phrase_code    IN VARCHAR2   - Field name or label code
--    p_concentration_percent   IN NUMBER     - Ingredient concentration percentage
--    p_label_class             IN VARCHAR2   - Field name class
--    p_phrase_hierarchy        IN NUMBER     - Phrase heirarchy
--    p_phrase_type             IN VARCHAR2   - Phrase type
--    p_print_flag              IN VARCHAR2   - Print  - yes or no
--    p_item_code               IN VARCHAR2   - Item that document is being printed for
--    p_structure_display_order IN NUMBER     - Display order of structure
--    x_return_status          OUT NOCOPY VARCHAR2   - 'S'uccess, 'E'rror, 'U'nexpected Error
--    x_msg_data               OUT NOCOPY VARCHAR2   - If there is an error, send back the approriate message
--
--  SYNOPSIS:
--    Insert_Work_Row(g_session_id,g_document_code,l_main_heading_code,l_main_display_order,l_sub_heading_code,
--               l_sub_display_order,l_record_type,l_label_or_phrase_code,l_concentration_percent,l_label_class,
--               l_phrase_hierarchy,l_phrase_type,l_print_flag,l_source_itemcode,l_structure_display_order,
--               l_return_status,l_msg_data);
--
--  HISTORY
--=========================================================================== */
PROCEDURE Insert_Work_Row
                (p_session_id IN NUMBER,
                 p_document_code IN VARCHAR2,
                 p_main_heading_code IN VARCHAR2,
                 p_main_display_order IN NUMBER,
                 p_sub_heading_code IN VARCHAR2,
                 p_sub_display_order IN NUMBER,
                 p_record_type IN VARCHAR2,
                 p_label_or_phrase_code IN VARCHAR2,
                 p_concentration_percent IN NUMBER,
                 p_label_class IN VARCHAR2,
                 p_phrase_hierarchy IN NUMBER,
                 p_phrase_type IN VARCHAR2,
                 p_print_flag IN VARCHAR2,
                 p_source_itemcode IN VARCHAR2,
                 p_structure_display_order IN NUMBER,
                 x_return_status OUT NOCOPY VARCHAR2,
                 x_msg_data OUT NOCOPY VARCHAR2)
 IS


/*  ------------- LOCAL VARIABLES ------------------- */
/*	Alpha Variables */
L_CODE_BLOCK      VARCHAR2(2000);
L_UPDATE_OK       VARCHAR2(2);

/* 	Numeric Variables */
L_ORACLE_ERROR    NUMBER;


/*  ------------------ CURSORS ---------------------- */
/*	Check to see if a phrase is already written for this
**  heading and subheading combination
*/
CURSOR c_get_existing_phrase IS
   SELECT   wbd.print_flag
   FROM     gr_work_build_docs wbd
   WHERE    wbd.document_code = p_document_code
   AND      wbd.main_heading_code = p_main_heading_code
   AND      wbd.sub_heading_code = p_sub_heading_code
   AND      wbd.record_type = p_label_or_phrase_code
   AND		wbd.label_or_phrase_code = p_label_or_phrase_code;
LocalPhraseRecord         c_get_existing_phrase%ROWTYPE;


BEGIN
   SAVEPOINT Insert_Work_Row;
   l_code_block := NULL;
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   IF p_label_or_phrase_code = 'L' THEN
      l_update_ok := 'YS';
   ELSE
      OPEN c_get_existing_phrase;
	  FETCH c_get_existing_phrase INTO LocalPhraseRecord;
	  IF c_get_existing_phrase%NOTFOUND THEN
	     l_update_ok := 'YS';
	  ELSE
	     l_update_ok := 'NO';
	  END IF;
	  CLOSE c_get_existing_phrase;
   END IF;

   IF l_update_ok = 'YS' THEN
      INSERT INTO gr_work_build_docs
            (session_id,
             sequence_number,
             document_code,
             main_heading_code,
             main_display_order,
             sub_heading_code,
             sub_display_order,
             record_type,
             label_or_phrase_code,
             concentration_percent,
             label_class,
             phrase_hierarchy,
             phrase_type,
             print_flag,
             source_itemcode,
             structure_display_order)
          VALUES
            (p_session_id,
             gr_work_build_docs_s.nextval,
             p_document_code,
             p_main_heading_code,
             p_main_display_order,
             p_sub_heading_code,
             p_sub_display_order,
             p_record_type,
             p_label_or_phrase_code,
             p_concentration_percent,
             p_label_class,
             p_phrase_hierarchy,
             p_phrase_type,
             p_print_flag,
             p_source_itemcode,
             p_structure_display_order);
   END IF;

EXCEPTION
   WHEN OTHERS THEN
      ROLLBACK TO SAVEPOINT Insert_Work_Row;
      l_oracle_error := SQLCODE;
      l_code_block := SUBSTR(SQLERRM, 1, 200);
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MESSAGE.SET_NAME('GR','GR_UNEXPECTED_ERROR');
      FND_MESSAGE.SET_TOKEN('TEXT',l_code_block,FALSE);
      x_msg_data := FND_MESSAGE.Get;

END Insert_Work_Row;






/*===========================================================================
--  PROCEDURE:
--    Insert_Data_Record
--
--  DESCRIPTION:
--    This PL/SQL procedure is used to write field name data for the report.
--
--  PARAMETERS:
--    p_session_id          IN NUMBER     - Session id for report
--    p_document_item       IN VARCHAR2   - Item that document is being printed for
--    p_print_font          IN VARCHAR2   - Type of font to print the text in
--    p_print_size          IN NUMBER     - Size of font to print the text in
--    p_text_line1          IN VARCHAR2   - Text to be inserted
--    p_text_line2          IN VARCHAR2   - Second text to be inserted
--    p_source_action       IN VARCHAR2   - 'WORKSHEET' or 'DOCUMENT'
--    x_return_status      OUT NOCOPY VARCHAR2   - 'S'uccess, 'E'rror, 'U'nexpected Error
--
--  SYNOPSIS:
--    Insert_Data_Record(g_session_id,l_item_code,l_print_font,l_print_size,l_text_line,
--                        p_source_action,l_return_status);
--
--  HISTORY
--=========================================================================== */
PROCEDURE Insert_Data_Record
            (p_line_number IN OUT NOCOPY NUMBER,
             p_line_type IN VARCHAR2,
             p_output_type IN VARCHAR2,
             p_user_id IN NUMBER,
             p_current_date IN DATE,
             p_language_code IN VARCHAR2,
             p_document_text_id IN NUMBER,
             p_session_id IN NUMBER,
             p_document_item IN VARCHAR2,
             p_print_font IN VARCHAR2,
             p_print_size IN NUMBER,
             p_text_line_1 IN VARCHAR2,
             p_text_line_2 IN VARCHAR2,
             p_source_action IN VARCHAR2,
             x_return_status OUT NOCOPY VARCHAR2)
 IS

/*  ------------- LOCAL VARIABLES ------------------- */
L_RETURN_STATUS          VARCHAR2(1);
L_MSG_DATA               VARCHAR2(2000);
L_LINE_TYPE              VARCHAR2(8);

/*  ------------------ EXCEPTIONS ---------------------- */
WORKSHEET_INSERT_ERROR   EXCEPTION;
DOCUMENT_INSERT_ERROR    EXCEPTION;

BEGIN
   x_return_status := 'S';
   l_return_status := 'S';

   /* If printing PDF */
   IF p_output_type NOT IN ('HTML','XML') THEN
      l_line_type := 'M';
   ELSE
      l_line_type := p_line_type;
   END IF;

   /* If printing a worksheet */
   IF p_source_action = 'WORKSHEET' THEN
      Worksheet_Insert_Row
          (p_line_number,
           p_output_type,
           p_user_id,
           p_current_date,
           p_language_code,
           p_session_id,
           p_document_item,
           p_print_font,
           p_print_size,
           p_text_line_1,
           l_line_type,
           l_return_status);

      IF l_return_status <> 'S' THEN
         RAISE Worksheet_Insert_Error;
      END IF;

      IF p_text_line_2 IS NOT NULL THEN
         Worksheet_Insert_Row
             (p_line_number,
              p_output_type,
              p_user_id,
              p_current_date,
              p_language_code,
              p_session_id,
              p_document_item,
              p_print_font,
              p_print_size,
              p_text_line_2,
              l_line_type,
              l_return_status);

         IF l_return_status <> 'S' THEN
            RAISE Worksheet_Insert_Error;
         END IF;
      END IF;  /* If p_text_line_2 is NOT NULL */

  ELSE  /* Printing a document */
     Document_Insert_Row
            (p_line_number,
             p_output_type,
             p_document_text_id,
             p_user_id,
             p_current_date,
             p_session_id,
             p_document_item,
             p_print_font,
             p_print_size,
             p_text_line_1,
             l_line_type,
             l_return_status,
             l_msg_data);

     IF l_return_status <> 'S' THEN
        RAISE Worksheet_Insert_Error;
     END IF;

     IF p_text_line_2 IS NOT NULL THEN
        Document_Insert_Row
            (p_line_number,
             p_output_type,
             p_document_text_id,
             p_user_id,
             p_current_date,
             p_session_id,
             p_document_item,
             p_print_font,
             p_print_size,
             p_text_line_2,
             l_line_type,
             l_return_status,
             l_msg_data);


        IF l_return_status <> 'S' THEN
           RAISE Worksheet_Insert_Error;
        END IF;
     END IF;   /* If p_text_line_2 IS NOT NULL */

  END IF;   /* Worksheet or Document */


EXCEPTION
   WHEN Document_Insert_Error THEN
      x_return_status := FND_API.G_RET_STS_ERROR;

   WHEN Worksheet_Insert_Error THEN
      x_return_status := FND_API.G_RET_STS_ERROR;

   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_ERROR;

END Insert_Data_Record;




/*===========================================================================
--  PROCEDURE:
--    Insert_Gr_Work_Worksheets
--
--  DESCRIPTION:
--    This PL/SQL procedure is used to set the line number and insert data
--    into gr_work_worksheets. The line numbers will be spaced out differently
--    for XML and HTML in order to correctly associate the data.
--
--  PARAMETERS:
--    p_output_type     IN VARCHAR2   - 'PDF','XML','HTML', etc
--    p_line_number IN OUT NOCOPY NUMBER     - Line number of inserted record
--    p_session_id      IN NUMBER     - Session id for report
--    p_item_code       IN VARCHAR2   - Item that document is being printed for
--    p_print_font      IN VARCHAR2   - Type of font to print the text in
--    p_print_size      IN NUMBER     - Size of font to print the text in
--    p_text_line       IN VARCHAR2   - Text to be inserted
--    p_line_type       IN VARCHAR2   - Type of value being inserted
--    x_return_status  OUT NOCOPY VARCHAR2   - 'S'uccess, 'E'rror, 'U'nexpected Error
--
--  SYNOPSIS:
--    Insert_Gr_Work_Worksheets (g_output_type,g_line_number,g_session_id,l_item_code,
--                               l_print_font,l_print_size,l_text_line,l_line_type,l_return_status);
--
--  HISTORY
--=========================================================================== */
PROCEDURE Insert_Gr_Work_Worksheets
           (p_output_type IN VARCHAR2,
            p_line_number IN OUT NOCOPY NUMBER,
            p_session_id IN NUMBER,
            p_item_code IN VARCHAR2,
            p_print_font IN VARCHAR2,
            p_print_size IN NUMBER,
            p_text_line IN VARCHAR2,
            p_line_type IN VARCHAR2,
            x_return_status OUT NOCOPY VARCHAR2)
  IS

BEGIN
   x_return_status := 'S';

   /* Printing XML or HTML */
   IF p_output_type in ('XML','HTML') THEN
      p_line_number := p_line_number + 10000;
   ELSE  /* Printing pdf */
      p_line_number := p_line_number + 1;
   END IF;

   INSERT INTO gr_work_worksheets
       (session_id,
        text_line_number,
        item_code,
        print_font,
        print_size,
        text_line,
        line_type)
   VALUES
       (p_session_id,
        p_line_number,
        p_item_code,
        p_print_font,
        p_print_size,
        p_text_line,
        p_line_type);

EXCEPTION
   WHEN OTHERS THEN
      FND_FILE.PUT(FND_FILE.LOG,' PROCEDURE WORKSHEET INSERT: '||sqlerrm);
      FND_FILE.NEW_LINE(FND_FILE.LOG,1);
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END Insert_Gr_Work_Worksheets;




/*===========================================================================
--  PROCEDURE:
--    Insert_XML_Data
--
--  DESCRIPTION:
--    This PL/SQL procedure is used to insert XML data for the document
--    if the output type is XML or HTML.
--
--  PARAMETERS:
--    p_output_type    IN VARCHAR2   - 'PDF','XML','HTML', etc
--    p_session_id     IN NUMBER     - Session id for report
--    p_document_item  IN VARCHAR2   - Item that document is being printed for
--    p_print_font     IN VARCHAR2   - Type of font to print the text in
--    p_print_size     IN NUMBER     - Size of font to print the text in
--    p_value          IN VARCHAR2   - Text to be inserted
--    p_line_type      IN VARCHAR2   - Type of value being inserted
--    p_source         IN VARCHAR2   - 'WORKSHEET' or 'DOCUMENT'
--    x_return_status OUT NOCOPY VARCHAR2   - 'S'uccess, 'E'rror, 'U'nexpected Error
--
--  SYNOPSIS:
--    Insert_XML_Data(g_output_type,g_session_id,'',6,RPAD(G_INGSAFETY_HDG,l_max_safe),
--                    'COL',p_source_procedure,l_return_status);
--
--  HISTORY
--=========================================================================== */
PROCEDURE Insert_XML_Data
          (p_line_number IN OUT NOCOPY NUMBER,
           p_output_type IN VARCHAR2,
           p_user_id IN NUMBER,
           p_current_date IN DATE,
           p_language_code IN VARCHAR2,
           p_document_text_id IN NUMBER,
           p_session_id IN NUMBER,
           p_document_item IN VARCHAR2,
           p_print_font  IN VARCHAR2,
           p_print_size  IN NUMBER,
           p_value IN  VARCHAR2,
           p_line_type IN  VARCHAR2,
           p_source IN VARCHAR2,
           x_return_status OUT NOCOPY VARCHAR2)
  IS

/*  ------------- LOCAL VARIABLES ------------------- */
L_RETURN_STATUS   VARCHAR2(4);
L_MSG_DATA        VARCHAR2(2000);


/*  ------------------ EXCEPTIONS ---------------------- */
WORKSHEET_INSERT_ERROR	        EXCEPTION;


BEGIN
   x_return_status := 'S';

   /* Only run through this code is printing XML or HTML */
   IF p_output_type in ('XML','HTML') THEN

      Insert_Data_Record
            (p_line_number,
             p_line_type,
             p_output_type,
             p_user_id,
             p_current_date,
             p_language_code,
             p_document_text_id,
             p_session_id,
             p_document_item,
             p_print_font,
             p_print_size,
             p_value,
             NULL,
             p_source,
             l_return_status);

        IF l_return_status <> 'S' THEN
           RAISE Worksheet_Insert_Error;
        END IF;

   END IF;   /* If printing XML or HTML */

EXCEPTION
   WHEN Worksheet_Insert_Error THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_ERROR;

END Insert_XML_Data;


END GR_PROCESS_DOCUMENTS_INSERTS;


/
