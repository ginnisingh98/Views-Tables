--------------------------------------------------------
--  DDL for Package Body PAY_SD_CREATE_TEMPLATES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_SD_CREATE_TEMPLATES" AS
/* $Header: paysdlobins.pkb 120.1 2007/01/11 20:59:12 ndorai noship $ */
--
-- Package Variables
--
  g_package  varchar2(33) := 'PER_SD_CREATE_TEMPLATES.';
--
-- ----------------------------------------------------------------------------
-- |---------------------< POST_INSERT >--------------------------------------|
-- ----------------------------------------------------------------------------
--
--
  PROCEDURE post_insert(file_id IN NUMBER) IS
    CURSOR csr_fnd_lob(p_file_id NUMBER) IS
      SELECT file_name,
             file_data
        FROM fnd_lobs
       WHERE file_id = p_file_id;
    --
    l_count     NUMBER(1);
    l_file_name per_solution_cmpt_names.name%type;
    l_proc      varchar2(72) := g_package || 'POST_INSERT';
  BEGIN
    hr_utility.set_location('Entering:'|| l_proc, 10);
    FOR cur_fnd_lob_rec IN csr_fnd_lob(file_id)
    LOOP
      /* fix for bug# 5745886 */
      /* l_file_name := SUBSTR(cur_fnd_lob_rec.file_name,INSTR(cur_fnd_lob_rec.file_name,'/',-1)+1); */
      l_file_name := SUBSTR(SUBSTR(cur_fnd_lob_rec.file_name,
                                     INSTR(cur_fnd_lob_rec.file_name,'/',-1)+1),
                             INSTR(cur_fnd_lob_rec.file_name,'\',-1)+1);
      SELECT count(1) INTO l_count
        FROM per_solution_cmpt_names
       WHERE name = l_file_name;
      --
      IF l_count > 0 THEN
         hr_utility.set_location(l_proc, 30);
         UPDATE per_solution_cmpt_names SET template_file = cur_fnd_lob_rec.file_data
          WHERE name = l_file_name;
      END IF;
    END LOOP;
    COMMIT;
    hr_utility.set_location(' Leaving:'||l_proc, 70);
  EXCEPTION
    WHEN OTHERS THEN
      hr_utility.set_location(' Leaving:'||l_proc, 90);
      raise;
  END post_insert;
END pay_sd_create_templates;

/
