--------------------------------------------------------
--  DDL for Package Body PER_GB_P11D_TEMPLATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_GB_P11D_TEMPLATE" as
/* $Header: pegbxdtp.pkb 120.0 2005/05/31 09:15:46 appldev noship $ */
   PROCEDURE end_date_2003(p_file_id NUMBER)
   IS
      l_upload_name       VARCHAR2(1000);
      l_file_name         VARCHAR2(1000);
      l_gb_file_id        NUMBER;
      l_start_date        DATE := TO_DATE('01/01/1900', 'dd/mm/yyyy');
      l_end_date          DATE := TO_DATE('05/04/2003', 'dd/mm/yyyy');
   BEGIN
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
         SELECT p_file_id, l_file_name, 'Template for year 2002-2003',
                l_start_date, l_end_date
           FROM fnd_lobs
          WHERE file_id = p_file_id;
   END;
--
   PROCEDURE end_date_2004(p_file_id NUMBER)
   IS
      l_upload_name       VARCHAR2(1000);
      l_file_name         VARCHAR2(1000);
      l_gb_file_id        NUMBER;
      l_start_date        DATE := TO_DATE('06/04/2003', 'dd/mm/yyyy');
      l_end_date          DATE := TO_DATE('05/04/2004', 'dd/mm/yyyy');
   BEGIN
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
         SELECT p_file_id, l_file_name, 'Template for year 2003-2004',
                l_start_date, l_end_date
           FROM fnd_lobs
          WHERE file_id = p_file_id;
   END;
--
   PROCEDURE end_date_2005(p_file_id NUMBER)
   IS
      l_upload_name       VARCHAR2(1000);
      l_file_name         VARCHAR2(1000);
      l_gb_file_id        NUMBER;
      l_start_date        DATE := TO_DATE('06/04/2004', 'dd/mm/yyyy');
      l_end_date          DATE := TO_DATE('05/04/2005', 'dd/mm/yyyy');
   BEGIN
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
         SELECT p_file_id, l_file_name, 'Template for year 2004-2005',
                l_start_date, l_end_date
           FROM fnd_lobs
          WHERE file_id = p_file_id;
   END;
--
END;

/
