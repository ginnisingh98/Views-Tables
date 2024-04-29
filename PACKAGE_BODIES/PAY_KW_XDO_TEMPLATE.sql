--------------------------------------------------------
--  DDL for Package Body PAY_KW_XDO_TEMPLATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_KW_XDO_TEMPLATE" as
/* $Header: pykwxdtp.pkb 120.1 2006/04/12 04:32:48 abppradh noship $ */
--
   PROCEDURE end_date_2005(p_file_id NUMBER)
   IS
      l_upload_name       VARCHAR2(1000);
      l_file_name         VARCHAR2(1000);
      l_gb_file_id        NUMBER;
      l_start_date        DATE ;
      l_end_date          DATE ;
   BEGIN

   L_START_DATE := TO_DATE('01/01/2005', 'mm/dd/yyyy');
   l_end_date := TO_DATE('12/31/4712', 'mm/dd/yyyy');
      -- program_name will be used to store the file_name
      -- this is bcos the file_name in fnd_lobs contains
      -- the full patch of the doc and not just the file name
      SELECT program_name
        INTO l_file_name
        FROM fnd_lobs
       WHERE file_id = p_file_id;

-- the delete will ensure that the patch is rerunnable!
      DELETE FROM per_gb_xdo_templates
            WHERE file_name = l_file_name AND
                  effective_start_date = l_start_date AND
                  effective_end_date = l_end_date;

      INSERT INTO per_gb_xdo_templates
                  (file_id,
                   file_name,
                   file_description,
                   effective_start_date,
                   effective_end_date)
         SELECT p_file_id, l_file_name, 'Template for year 2005',
                l_start_date, l_end_date
           FROM fnd_lobs
          WHERE file_id = p_file_id;
   END end_date_2005;
--
   PROCEDURE end_date_2006(p_file_id NUMBER)
   IS
      l_upload_name       VARCHAR2(1000);
      l_file_name         VARCHAR2(1000);
      l_gb_file_id        NUMBER;
      l_start_date        DATE ;
      l_end_date          DATE ;
   BEGIN

   L_START_DATE := TO_DATE('01/01/2006', 'mm/dd/yyyy');
   l_end_date := TO_DATE('12/31/4712', 'mm/dd/yyyy');
      -- program_name will be used to store the file_name
      -- this is bcos the file_name in fnd_lobs contains
      -- the full patch of the doc and not just the file name
      SELECT program_name
        INTO l_file_name
        FROM fnd_lobs
       WHERE file_id = p_file_id;

-- the delete will ensure that the patch is rerunnable!
      DELETE FROM per_gb_xdo_templates
            WHERE file_name = l_file_name AND
                  effective_start_date = l_start_date AND
                  effective_end_date = l_end_date;

      INSERT INTO per_gb_xdo_templates
                  (file_id,
                   file_name,
                   file_description,
                   effective_start_date,
                   effective_end_date)
         SELECT p_file_id, l_file_name, 'Template for year 2006',
                l_start_date, l_end_date
           FROM fnd_lobs
          WHERE file_id = p_file_id;
   END end_date_2006;
--
END;

/
