--------------------------------------------------------
--  DDL for Package Body PER_FR_TEMPLATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_FR_TEMPLATE" as
/* $Header: pefrxdtp.pkb 120.1 2005/07/22 08:57 sbairagi noship $ */
PROCEDURE insert_data(p_file_id NUMBER)
   IS

      l_file_name         VARCHAR2(1000);

   BEGIN


        SELECT substr(substr(file_name,instr(translate(file_name,'/\','//'),'/',-1)+1),1,20)
        INTO l_file_name
        FROM fnd_lobs
        WHERE file_id = p_file_id;



      if( l_file_name <>'BIAF2005.rtf') then

          UPDATE fnd_lobs set program_name='BIAF_FR_XML_O'
                   where file_name like '%BIAF2005.rtf'
                   and program_name='BIAF_FR_XML';
      end if;




      DELETE FROM per_gb_xdo_templates
            WHERE file_name = l_file_name;

      INSERT INTO per_gb_xdo_templates
                  (file_id,
                   file_name,
                   file_description,
                   effective_start_date,
                   effective_end_date)
         SELECT p_file_id, l_file_name, 'Template Uploaded on '||to_char(sysdate,'dd-MON-yyyy'),
                sysdate, to_date('31-12-4000','dd-MM-yyyy')
           FROM fnd_lobs
          WHERE file_id = p_file_id;
   END insert_data;
 end PER_FR_TEMPLATE;

/
