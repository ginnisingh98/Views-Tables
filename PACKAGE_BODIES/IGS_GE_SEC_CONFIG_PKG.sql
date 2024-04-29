--------------------------------------------------------
--  DDL for Package Body IGS_GE_SEC_CONFIG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_GE_SEC_CONFIG_PKG" AS
/* $Header: IGSNIA3B.pls 115.5 2004/01/08 15:34:08 pkpatel noship $ */
  FUNCTION check_form_security
     ( p_responsibility_id IN NUMBER,
       p_form_name IN VARCHAR2)
     RETURN  BOOLEAN
    IS
  /*
  ||  Created By : kiran.padiyar@oracle.com
  ||  Created On : 07-OCT-2002
  ||  Purpose : Checks the forms existance for the responsibility.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
     lv_rowid ROWID;
     CURSOR c_form_exists IS
     SELECT rowid
     FROM   igs_ge_cfg_form
     WHERE  responsibility_id = p_responsibility_id
     AND    form_code = p_form_name
     AND    NVL(query_only_ind,'N') = 'Y';

   BEGIN
      OPEN c_form_exists;
      FETCH c_form_exists INTO lv_rowid;
      IF c_form_exists%FOUND THEN
        RETURN TRUE;
      ELSE
        RETURN FALSE;
      END IF;
      CLOSE c_form_exists;
   END check_form_security;


  FUNCTION check_tab_security
     ( p_responsibility_id IN NUMBER,
       p_form_name IN VARCHAR2
     )
       RETURN tb_result_set
    IS
  /*
  ||  Created By : kiran.padiyar@oracle.com
  ||  Created On : 07-OCT-2002
  ||  Purpose : Checks the tab validity for the form and resp combination.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  KUMMA           30-DEC-2002     2684922, Added Trim around tab_code
  ||  (reverse chronological order - newest change first)
  ||
  ||  nsidana      9/22/2003     Modified the cursor to pick data from IGS_GE_CFG_TAB_V which
  ||                             holds the enabled tab pages for any form.
  */
     CURSOR c_tab_exists IS
     SELECT TRIM(substr(tab_code,(instr(tab_code,'-')+1))) tab_code,config_opt
     FROM   igs_ge_cfg_tab_v
     WHERE  responsibility_id = p_responsibility_id
     AND    form_code = p_form_name;

     j BINARY_INTEGER := 0;
     lv_result_set tb_result_set;
   BEGIN

      FOR i in c_tab_exists LOOP
         j := NVL(j,0) + 1;
        lv_result_set(j).l_canvas:= i.tab_code;
        lv_result_set(j).l_query_hide:= i.config_opt;
      END LOOP;
      RETURN lv_result_set;

   END check_tab_security;

   FUNCTION check_tab_exists
     ( p_responsibility_id IN NUMBER,
       p_form_name IN VARCHAR2,
       p_tab_name  IN VARCHAR2
     )
      RETURN BOOLEAN
    IS
  /*
  ||  Created By : kiran.padiyar@oracle.com
  ||  Created On : 07-OCT-2002
  ||  Purpose : Checks the existance of the tab.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  KUMMA           30-DEC-2002     2684922, Added Trim around tab_code on both sides in where clause
  ||  (reverse chronological order - newest change first)
  ||
  ||  nsidana      9/22/2003     Modified the cursor to pick data from IGS_GE_CFG_TAB_V which
  ||                             holds the enabled tab pages for any form.
  ||  gmaheswa     01/07/2004    Bug : 3294107 Modified cursor c_tab_exists to select row_id instead of rowid
  ||  pkpatel      01/08/2003    Bug : 3294107 Added the check config_opt = 'H'
  */

     CURSOR c_tab_exists IS
     SELECT row_id
     FROM   igs_ge_cfg_tab_v
     WHERE  responsibility_id = p_responsibility_id
     AND    form_code = p_form_name
     AND    TRIM(substr(tab_code,(instr(tab_code,'-')+1))) = TRIM(p_tab_name)
	 AND    config_opt = 'H';

     lv_rowid ROWID;
   BEGIN
     OPEN c_tab_exists;
     FETCH c_tab_exists INTO lv_rowid;
      IF c_tab_exists%FOUND THEN
        RETURN TRUE;
      ELSE
        RETURN FALSE;
      END IF;
     CLOSE c_tab_exists;
   END check_tab_exists;

END igs_ge_sec_config_pkg;

/
