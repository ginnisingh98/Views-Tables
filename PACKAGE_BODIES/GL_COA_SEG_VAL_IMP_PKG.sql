--------------------------------------------------------
--  DDL for Package Body GL_COA_SEG_VAL_IMP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_COA_SEG_VAL_IMP_PKG" AS
/* $Header: GLSVISPB.pls 120.3.12010000.1 2009/12/16 11:55:04 sommukhe noship $ */
  /***********************************************************************************************
    Created By     :  Somnath Mukherjee
    Date Created By:  01-AUG-2008
    Purpose        :  This package has the 2 sub processes, which will be called from
                      Chart of Accounts Segment Values API.
                      process 1 : create_gl_coa_flex_values
                                    Imports GL COA flex values (segment values)
                      process 2 : create_gl_coa_flex_values_nh
		                    Imports Child ranges for the segment values.

    Known limitations,enhancements,remarks:
    Change History (in reverse chronological order)
    Who         When            What
      ********************************************************************************************** */

  g_n_user_id fnd_flex_values.created_by%TYPE := NVL(fnd_global.user_id,-1);          -- Stores the User Id
  g_n_login_id fnd_flex_values.last_update_login%TYPE := NVL(fnd_global.login_id,-1); -- Stores the Login Id
  g_n_sysdate DATE := SYSDATE;

   --PL/SQL table to store the unique flex value set ids.
   TYPE flex_vl_set_id_tbl_type IS TABLE OF fnd_flex_values.flex_value_set_id%TYPE INDEX BY BINARY_INTEGER;
      flex_vl_set_id_tab flex_vl_set_id_tbl_type;

  --Cursor to verify that the Value set name passed is valid.
  CURSOR c_fnd_flex_values ( cp_flex_value_set_name fnd_flex_value_sets.flex_value_set_name%TYPE) IS
     SELECT ffvs.rowid,ffvs.*
     FROM   FND_FLEX_VALUE_SETS ffvs
     WHERE FLEX_VALUE_SET_NAME = cp_flex_value_set_name;

     l_cur_co c_fnd_flex_values%ROWTYPE;

  FUNCTION isexists(p_flex_value_set_id IN fnd_flex_values.flex_value_set_id%TYPE,
                  p_tab_flex_value_set_id  IN flex_vl_set_id_tbl_type) RETURN BOOLEAN AS
  /***********************************************************************************************
    Created By     :  sommukhe
    Date Created By:  01-AUG-2008.
    Purpose        :  This utility procedure is to check if a flex Value Set id exists in a pl/sql table

    Known limitations,enhancements,remarks:
    Change History (in reverse chronological order)
    Who         When            What
  ***********************************************************************************************/
  BEGIN
    FOR i in 1..p_tab_flex_value_set_id.count LOOP
       IF p_flex_value_set_id = p_tab_flex_value_set_id(i) THEN
	  RETURN TRUE;
       END IF;
    END LOOP;
    RETURN FALSE;
  END isexists;

    PROCEDURE set_msg(p_c_msg_name IN VARCHAR2,
                    p_c_token IN VARCHAR2
                    )AS
  /***********************************************************************************************
    Created By     :  Sommukhe
    Date Created By:  01-AUG-2008
    Purpose        :  This procedure sets the particular message in the  message stack.
                      Based upon the input arguments this procedure does the following functions
                      -- if the p_c_msg_name is null then returns immediately

    Known limitations,enhancements,remarks:
    Change History (in reverse chronological order)
    Who         When            What
  ********************************************************************************************** */
  l_n_count NUMBER;
  BEGIN
    -- If the message name is null, then return false
    IF p_c_msg_name IS NULL THEN
      RETURN;
    END IF;

    FND_MESSAGE.SET_NAME('GL',p_c_msg_name);
      IF p_c_token IS NOT NULL THEN
          FND_MESSAGE.SET_TOKEN('PARAM',p_c_token);
       END IF;
    FND_MSG_PUB.ADD;

  END set_msg;

  --Create process for fnd_flex_values
  PROCEDURE create_gl_coa_flex_values(
          p_gl_flex_values_tbl IN OUT NOCOPY gl_coa_seg_val_imp_pub.gl_flex_values_tbl_type,
          p_c_rec_status OUT NOCOPY VARCHAR2

  ) AS
  /***********************************************************************************************
    Created By     :  Sommukhe
    Date Created By: 01-AUG-2008
    Purpose        :  This procedure is a sub process to import records of s.

    Known limitations,enhancements,remarks:
    Change History (in reverse chronological order)
    Who         When            What
    SOMMUKHE    28-JAN-2009     Bug#8208641 Included manual updates to fnd_flex_values as suugested by ATG in 7668121/7528069
  ********************************************************************************************** */
     l_insert_update      VARCHAR2(1);
     v_message_name       VARCHAR2(30);
     v_compiled_value_attribute_s   VARCHAR2(2000);
     req_id    NUMBER;
     result    BOOLEAN;
     row_count NUMBER;
     vsid      NUMBER;
     --cursor to fetch the existing data
     CURSOR c_fnd_flex_val ( cp_flex_value_set_id fnd_flex_values.flex_value_set_id%TYPE,
                             cp_flex_value fnd_flex_values.flex_value%TYPE) IS
     SELECT ffvs.rowid,ffvs.*
     FROM   fnd_flex_values ffvs
     WHERE flex_value_set_id = cp_flex_value_set_id
     AND flex_value = cp_flex_value;

     rec_fnd_flex_val c_fnd_flex_val%ROWTYPE;

    /* Private Procedures for create_gl_coa_flex_values */
    PROCEDURE trim_values ( gl_coa_flex_values_rec IN OUT NOCOPY gl_coa_seg_val_imp_pub.gl_flex_values_rec_type ) AS
    BEGIN

      gl_coa_flex_values_rec.value_set_name := trim(gl_coa_flex_values_rec.value_set_name);
      gl_coa_flex_values_rec.flex_value := trim(gl_coa_flex_values_rec.flex_value);
      gl_coa_flex_values_rec.flex_desc := trim(gl_coa_flex_values_rec.flex_desc);
      gl_coa_flex_values_rec.parent_flex_value := trim(gl_coa_flex_values_rec.parent_flex_value);
      gl_coa_flex_values_rec.summary_flag := trim(gl_coa_flex_values_rec.summary_flag);
      gl_coa_flex_values_rec.roll_up_group := trim(gl_coa_flex_values_rec.roll_up_group);
      gl_coa_flex_values_rec.hierarchy_level := trim(gl_coa_flex_values_rec.hierarchy_level);
      gl_coa_flex_values_rec.allow_budgeting := trim(gl_coa_flex_values_rec.allow_budgeting);
      gl_coa_flex_values_rec.allow_posting := trim(gl_coa_flex_values_rec.allow_posting);
      gl_coa_flex_values_rec.account_type := trim(gl_coa_flex_values_rec.account_type);
      gl_coa_flex_values_rec.reconcile := trim(gl_coa_flex_values_rec.reconcile);
      gl_coa_flex_values_rec.third_party_control_account := trim(gl_coa_flex_values_rec.third_party_control_account);
      gl_coa_flex_values_rec.enabled_flag := trim(gl_coa_flex_values_rec.enabled_flag);
      gl_coa_flex_values_rec.effective_from := gl_coa_flex_values_rec.effective_from;
      gl_coa_flex_values_rec.effective_to := gl_coa_flex_values_rec.effective_to;

    END trim_values;

   --Check the validity of the Value set name and derive the Flex_value_set_id
   PROCEDURE validate_derivations ( gl_coa_flex_values_rec IN OUT NOCOPY gl_coa_seg_val_imp_pub.gl_flex_values_rec_type ) AS
    BEGIN
      OPEN c_fnd_flex_values(gl_coa_flex_values_rec.value_set_name);
       FETCH c_fnd_flex_values INTO l_cur_co;
       IF c_fnd_flex_values%NOTFOUND THEN
	 CLOSE c_fnd_flex_values;
	 set_msg('GL_COA_SVI_INV_VSET', gl_coa_flex_values_rec.value_set_name);
         gl_coa_flex_values_rec.status := 'E';
       ELSE
	 CLOSE c_fnd_flex_values;
       END IF;

    END validate_derivations;

    -- validate parameters passed.
    PROCEDURE validate_parameters ( gl_coa_flex_values_rec IN OUT NOCOPY gl_coa_seg_val_imp_pub.gl_flex_values_rec_type  ) AS
    BEGIN

            /* Check for Mandatory Parameters */
      IF gl_coa_flex_values_rec.value_set_name IS NULL  THEN
        set_msg('GL_COA_SVI_SEG_VAL_MAND', 'VALUE_SET_NAME');
        gl_coa_flex_values_rec.status := 'E';
      END IF;
      IF gl_coa_flex_values_rec.flex_value IS NULL  THEN
       	set_msg('GL_COA_SVI_SEG_VAL_MAND', 'FLEX_VALUE');
        gl_coa_flex_values_rec.status := 'E';
      END IF;

     END validate_parameters;


    -- Check for Update. If the flex value passed is already existing then certain validations need to be performed.
    FUNCTION check_insert_update ( gl_coa_flex_values_rec IN OUT NOCOPY gl_coa_seg_val_imp_pub.gl_flex_values_rec_type  ) RETURN VARCHAR2 IS
    E_RESOURCE_BUSY   EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_RESOURCE_BUSY, -54);
    BEGIN
       OPEN c_fnd_flex_val(l_cur_co.flex_value_set_id,gl_coa_flex_values_rec.flex_value);
       FETCH c_fnd_flex_val INTO rec_fnd_flex_val;
       IF c_fnd_flex_val%NOTFOUND THEN
	 CLOSE c_fnd_flex_val;
	 RETURN 'I';
       ELSE
	 CLOSE c_fnd_flex_val;
	 RETURN 'U';
       END IF;
       EXCEPTION
	 WHEN E_RESOURCE_BUSY THEN
	 CLOSE c_fnd_flex_values;
	 fnd_message.set_name( 'GL', 'GL_COA_SVI_REC_LOCK');
	 fnd_msg_pub.add;
	 gl_coa_flex_values_rec.status := 'E';

    END check_insert_update;

  -- Assign default values to the parameters passed.
  PROCEDURE assign_defaults ( gl_coa_flex_values_rec IN OUT NOCOPY gl_coa_seg_val_imp_pub.gl_flex_values_rec_type, p_insert IN VARCHAR2) IS
    -- Cursor to check if child ranges exist for the flex value passed
    CURSOR c_fnd_flex_value_nh_exists(cp_flex_value_set_id fnd_flex_value_sets.flex_value_set_id%TYPE,
                                      cp_parent_flex_value fnd_flex_value_norm_hierarchy.parent_flex_value%TYPE ) IS
    SELECT 'X'
    FROM fnd_flex_value_norm_hierarchy
    WHERE flex_value_set_id = cp_flex_value_set_id
    AND parent_flex_value = cp_parent_flex_value;

    rec_fnd_flex_value_nh_exists c_fnd_flex_value_nh_exists%ROWTYPE;
    BEGIN
      --Insert Operation
      IF p_insert = 'I' THEN
         --Default summary_flag to N
	 IF ( gl_coa_flex_values_rec.summary_flag IS NULL ) THEN
	  gl_coa_flex_values_rec.summary_flag := 'N';
	 END IF;

         --Default enabled_flag to N
         IF ( gl_coa_flex_values_rec.enabled_flag IS NULL ) THEN
	  gl_coa_flex_values_rec.enabled_flag := 'N';
	 END IF;
      END IF;

       --Update Operation
      IF p_insert = 'U' THEN
         --Default summary_flag to the db value
	 IF ( gl_coa_flex_values_rec.summary_flag IS NULL ) THEN
	  gl_coa_flex_values_rec.summary_flag := rec_fnd_flex_val.summary_flag;
	 END IF;

	 --If update is being performed and summary_flag is changed to 'N' then delete the children.
         IF ( gl_coa_flex_values_rec.summary_flag = 'N' AND rec_fnd_flex_val.summary_flag = 'Y') THEN
	    OPEN c_fnd_flex_value_nh_exists(l_cur_co.flex_value_set_id,gl_coa_flex_values_rec.flex_value);
            FETCH c_fnd_flex_value_nh_exists INTO rec_fnd_flex_value_nh_exists;
	    IF c_fnd_flex_value_nh_exists%NOTFOUND THEN
	      CLOSE c_fnd_flex_value_nh_exists;
	    ELSE
	      CLOSE c_fnd_flex_value_nh_exists;
              DELETE FROM FND_FLEX_VALUE_NORM_HIERARCHY  WHERE FLEX_VALUE_SET_ID =  l_cur_co.flex_value_set_id  AND PARENT_FLEX_VALUE =  gl_coa_flex_values_rec.flex_value;
	    END IF;
	 END IF;

	 --Default enabled_flag to the db value
         IF ( gl_coa_flex_values_rec.enabled_flag IS NULL ) THEN
	  gl_coa_flex_values_rec.enabled_flag := rec_fnd_flex_val.enabled_flag;
	 END IF;
      END IF;


    END assign_defaults;


-- Carry out business validations
    PROCEDURE validate_flex_values ( gl_coa_flex_values_rec IN OUT NOCOPY gl_coa_seg_val_imp_pub.gl_flex_values_rec_type  ) AS
    -- Cursor to validate the Roll up group information
    CURSOR c_roll_up_group ( cp_flex_value_set_id    IN  fnd_flex_hierarchies.flex_value_set_id%TYPE,
                             cp_hierarchy_code       IN  fnd_flex_hierarchies.hierarchy_code%TYPE) IS
      SELECT'X'
      FROM fnd_flex_hierarchies
      WHERE FLEX_VALUE_SET_ID =cp_flex_value_set_id
      AND HIERARCHY_CODE =cp_hierarchy_code;
      rec_roll_up_group c_roll_up_group%ROWTYPE;

    -- Cursor to validate the flex qualifiers and to form appropriate compiled_value_attribute
    CURSOR c_flex_val_qual ( cp_flex_value_set_id    IN  fnd_flex_hierarchies.flex_value_set_id%TYPE,
                             cp_id_flex_code         IN   fnd_flex_validation_qualifiers.id_flex_code%TYPE,
			     cp_id_flex_application_id IN  fnd_flex_validation_qualifiers.id_flex_application_id%TYPE) IS
      SELECT segment_attribute_type,value_attribute_type
      FROM fnd_flex_validation_qualifiers
      WHERE id_flex_code = cp_id_flex_code
      AND id_flex_application_id = cp_id_flex_application_id
      AND flex_value_set_id = cp_flex_value_set_id
      ORDER BY assignment_date, value_attribute_type;

      rec_flex_val_qual c_flex_val_qual%ROWTYPE;

    BEGIN


      IF gl_coa_flex_values_rec.summary_flag IS NOT NULL AND gl_coa_flex_values_rec.summary_flag  NOT IN ('N','Y') THEN
	set_msg('GL_COA_SVI_Y_OR_N', 'SUMMARY_FLAG');
        gl_coa_flex_values_rec.status := 'E';
      END IF;

      IF gl_coa_flex_values_rec.roll_up_group IS NOT NULL  THEN
         OPEN c_roll_up_group(l_cur_co.flex_value_set_id,gl_coa_flex_values_rec.roll_up_group);
         FETCH c_roll_up_group INTO rec_roll_up_group;
         IF c_fnd_flex_values%NOTFOUND THEN
	   CLOSE c_roll_up_group;
	   set_msg('GL_COA_SVI_INVALID_VALUE', 'ROLL_UP_GROUP');
           gl_coa_flex_values_rec.status := 'E';
         ELSE
	   CLOSE c_roll_up_group;
         END IF;

      END IF;

      IF gl_coa_flex_values_rec.allow_budgeting IS NOT NULL AND gl_coa_flex_values_rec.allow_budgeting  NOT IN ('N','Y') THEN
        set_msg('GL_COA_SVI_Y_OR_N', 'ALLOW_BUDGETING');
        gl_coa_flex_values_rec.status := 'E';
      END IF;

      IF gl_coa_flex_values_rec.allow_posting IS NOT NULL AND gl_coa_flex_values_rec.allow_posting  NOT IN ('N','Y') THEN
        set_msg('GL_COA_SVI_Y_OR_N', 'ALLOW_POSTING');
        gl_coa_flex_values_rec.status := 'E';
      END IF;

      IF gl_coa_flex_values_rec.account_type IS NOT NULL AND gl_coa_flex_values_rec.account_type  NOT IN ('A','L','R','E','O') THEN
        fnd_message.set_name('GL','GL_COA_SVI_INV_AC_TYPE');
        fnd_msg_pub.add;
        gl_coa_flex_values_rec.status := 'E';
      END IF;

      IF gl_coa_flex_values_rec.reconcile IS NOT NULL AND gl_coa_flex_values_rec.reconcile  NOT IN ('N','Y') THEN
        set_msg('GL_COA_SVI_Y_OR_N', 'RECONCILE');
        gl_coa_flex_values_rec.status := 'E';
      END IF;

      IF gl_coa_flex_values_rec.third_party_control_account IS NOT NULL AND gl_coa_flex_values_rec.third_party_control_account  NOT IN ('N','Y') THEN
        set_msg('GL_COA_SVI_Y_OR_N', 'THIRD_PARTY_CONTROL_ACCOUNT');
        gl_coa_flex_values_rec.status := 'E';
      END IF;

      /* Validation for compiled value attributes*/
      FOR rec_c_flex_val_qual IN c_flex_val_qual(l_cur_co.flex_value_set_id,'GL#',101)
           LOOP
           IF rec_c_flex_val_qual.value_attribute_type = 'DETAIL_BUDGETING_ALLOWED' AND gl_coa_flex_values_rec.allow_budgeting IS NOT NULL THEN
	    v_compiled_value_attribute_s := gl_coa_flex_values_rec.allow_budgeting;
	   END IF;

           IF rec_c_flex_val_qual.value_attribute_type = 'DETAIL_POSTING_ALLOWED' AND gl_coa_flex_values_rec.allow_posting IS NOT NULL THEN
	     v_compiled_value_attribute_s := v_compiled_value_attribute_s||FND_GLOBAL.newline||gl_coa_flex_values_rec.allow_posting;
	   END IF;

           IF rec_c_flex_val_qual.value_attribute_type = 'GL_ACCOUNT_TYPE' AND gl_coa_flex_values_rec.account_type IS NOT NULL THEN
	     v_compiled_value_attribute_s := v_compiled_value_attribute_s||FND_GLOBAL.newline||gl_coa_flex_values_rec.account_type;
	   END IF;

           IF rec_c_flex_val_qual.value_attribute_type = 'RECONCILIATION FLAG' AND gl_coa_flex_values_rec.reconcile IS NOT NULL THEN
	      v_compiled_value_attribute_s := v_compiled_value_attribute_s||FND_GLOBAL.newline||gl_coa_flex_values_rec.reconcile;
	   END IF;

           IF rec_c_flex_val_qual.value_attribute_type = 'GL_CONTROL_ACCOUNT' AND gl_coa_flex_values_rec.third_party_control_account IS NOT NULL THEN
	     v_compiled_value_attribute_s := v_compiled_value_attribute_s||FND_GLOBAL.newline||gl_coa_flex_values_rec.third_party_control_account;
	   END IF;

           END LOOP;


    END validate_flex_values;


  /* Main Flex Values Sub Process */
  BEGIN

    v_compiled_value_attribute_s := NULL;
    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string( fnd_log.level_procedure, 'gl.plsql.gl_coa_seg_val_imp_pkg.create_gl_coa_flex_values.start_logging_for','Fnd Flex Values');
    END IF;

    p_c_rec_status := 'S';
    FOR I in 1..p_gl_flex_values_tbl.LAST LOOP
      IF p_gl_flex_values_tbl.EXISTS(I) THEN

        p_gl_flex_values_tbl(I).status := 'S';
        p_gl_flex_values_tbl(I).msg_from := fnd_msg_pub.count_msg;
	trim_values(p_gl_flex_values_tbl(I) );

	validate_derivations( p_gl_flex_values_tbl(I) );

	IF p_gl_flex_values_tbl(I).status = 'S'  THEN
          validate_parameters( p_gl_flex_values_tbl(I) );
	  IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	     fnd_log.string( fnd_log.level_statement, 'gl.plsql.gl_coa_seg_val_imp_pkg.create_gl_coa_flex_values.Status_after_validate_parameters',
	     'Value Set Name:'||p_gl_flex_values_tbl(I).value_set_name||'  '||'Parent Flex Value:'||p_gl_flex_values_tbl(I).parent_flex_value||'  '||'Flex Value:'
	     ||p_gl_flex_values_tbl(I).flex_value||'  '||'Status:'||p_gl_flex_values_tbl(I).status );
          END IF;
        END IF;

	--Find out whether it is insert/update of record
        l_insert_update:='I';
        IF p_gl_flex_values_tbl(I).status = 'S' THEN
            l_insert_update:= check_insert_update(p_gl_flex_values_tbl(I));
	  IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	     fnd_log.string( fnd_log.level_statement, 'gl.plsql.gl_coa_seg_val_imp_pkg.create_gl_coa_flex_values.Insert_update',
	     'Value Set Name:'||p_gl_flex_values_tbl(I).value_set_name||'  '||'Parent Flex Value:'||p_gl_flex_values_tbl(I).parent_flex_value||'  '||'Flex Value:'
	     ||p_gl_flex_values_tbl(I).flex_value||'  '||'Insert_update:'||l_insert_update);
          END IF;
        END IF;

	 --Defaulting depending upon insert or update
	IF p_gl_flex_values_tbl(I).status = 'S' THEN
	  assign_defaults(p_gl_flex_values_tbl(I),l_insert_update);
	   IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	     fnd_log.string( fnd_log.level_statement, 'gl.plsql.gl_coa_seg_val_imp_pkg.create_gl_coa_flex_values.Status_after_assign_defaults',
	     'Value Set Name:'||p_gl_flex_values_tbl(I).value_set_name||'  '||'Parent Flex Value:'||p_gl_flex_values_tbl(I).parent_flex_value||'  '||'Flex Value:'
	     ||p_gl_flex_values_tbl(I).flex_value||'  '||'Status:'||p_gl_flex_values_tbl(I).status );
          END IF;
	END IF;

	/* Business Validations */
	IF p_gl_flex_values_tbl(I).status = 'S'  THEN
          validate_flex_values( p_gl_flex_values_tbl(I) );
          IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	     fnd_log.string( fnd_log.level_statement, 'gl.plsql.gl_coa_seg_val_imp_pkg.create_gl_coa_flex_values.Status_after_Business_Val',
	     'Value Set Name:'||p_gl_flex_values_tbl(I).value_set_name||'  '||'Parent Flex Value:'||p_gl_flex_values_tbl(I).parent_flex_value||'  '||'Flex Value:'
	     ||p_gl_flex_values_tbl(I).flex_value||'  '||'Status:'||p_gl_flex_values_tbl(I).status );
          END IF;
        END IF;

         IF p_gl_flex_values_tbl(I).status = 'S'  THEN
	  BEGIN
	  IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	    fnd_log.string( fnd_log.level_statement, 'gl.plsql.gl_coa_seg_val_imp_pkg.create_gl_coa_flex_values.Creation_values',
	    'Value Set Name:'||p_gl_flex_values_tbl(I).value_set_name||'  '||'Parent Flex Value:'||p_gl_flex_values_tbl(I).parent_flex_value||'  '||'Flex Value:'
	    ||p_gl_flex_values_tbl(I).flex_value||'  '||'enabled_flag:'||p_gl_flex_values_tbl(I).enabled_flag||'  '||'summary_flag:'||
	    p_gl_flex_values_tbl(I).summary_flag||'  '||'roll_up_group:'||p_gl_flex_values_tbl(I).roll_up_group
	    ||'  '||'hierarchy_level:'||p_gl_flex_values_tbl(I).hierarchy_level
	    ||'  '||'compiled_value_attribute_s:'||v_compiled_value_attribute_s
	    ||'  '||'flex_desc:'||p_gl_flex_values_tbl(I).flex_desc);
          END IF;
	  fnd_flex_loader_apis.up_value_set_value
		     (p_upload_phase                    => 'BEGIN',
		      p_upload_mode                     => NULL,
		      p_custom_mode                     => 'FORCE',
		      p_flex_value_set_name             => p_gl_flex_values_tbl(I).value_set_name,
		      p_parent_flex_value_low           => p_gl_flex_values_tbl(I).parent_flex_value,
		      p_flex_value                      => p_gl_flex_values_tbl(I).flex_value,
		      p_owner                           => NULL,
		      p_last_update_date                => to_char(g_n_sysdate,'YYYY/MM/DD HH24:MI:SS'),
		      p_enabled_flag                    => p_gl_flex_values_tbl(I).enabled_flag,
		      p_summary_flag                    => p_gl_flex_values_tbl(I).summary_flag,
		      p_start_date_active               => to_char(p_gl_flex_values_tbl(I).effective_from,'YYYY/MM/DD HH24:MI:SS'),
		      p_end_date_active                 => to_char(p_gl_flex_values_tbl(I).effective_to,'YYYY/MM/DD HH24:MI:SS'),
		      p_parent_flex_value_high          => NULL,
		      p_rollup_flex_value_set_name      => NULL,
		      p_rollup_hierarchy_code           => p_gl_flex_values_tbl(I).roll_up_group,
		      p_hierarchy_level                 => p_gl_flex_values_tbl(I).hierarchy_level,
		      p_compiled_value_attributes       => v_compiled_value_attribute_s,
		      p_value_category                  => NULL,
		      p_attribute1                      => NULL,
		      p_attribute2                      => NULL,
		      p_attribute3                      => NULL,
		      p_attribute4                      => NULL,
		      p_attribute5                      => NULL,
		      p_attribute6                      => NULL,
		      p_attribute7                      => NULL,
		      p_attribute8                      => NULL,
		      p_attribute9                      => NULL,
		      p_attribute10                     => NULL,
		      p_attribute11                     => NULL,
		      p_attribute12                     => NULL,
		      p_attribute13                     => NULL,
		      p_attribute14                     => NULL,
		      p_attribute15                     => NULL,
		      p_attribute16                     => NULL,
		      p_attribute17                     => NULL,
		      p_attribute18                     => NULL,
		      p_attribute19                     => NULL,
		      p_attribute20                     => NULL,
		      p_attribute21                     => NULL,
		      p_attribute22                     => NULL,
		      p_attribute23                     => NULL,
		      p_attribute24                     => NULL,
		      p_attribute25                     => NULL,
		      p_attribute26                     => NULL,
		      p_attribute27                     => NULL,
		      p_attribute28                     => NULL,
		      p_attribute29                     => NULL,
		      p_attribute30                     => NULL,
		      p_attribute31                     => NULL,
		      p_attribute32                     => NULL,
		      p_attribute33                     => NULL,
		      p_attribute34                     => NULL,
		      p_attribute35                     => NULL,
		      p_attribute36                     => NULL,
		      p_attribute37                     => NULL,
		      p_attribute38                     => NULL,
		      p_attribute39                     => NULL,
		      p_attribute40                     => NULL,
		      p_attribute41                     => NULL,
		      p_attribute42                     => NULL,
		      p_attribute43                     => NULL,
		      p_attribute44                     => NULL,
		      p_attribute45                     => NULL,
		      p_attribute46                     => NULL,
		      p_attribute47                     => NULL,
		      p_attribute48                     => NULL,
		      p_attribute49                     => NULL,
		      p_attribute50                     => NULL,
		      p_flex_value_meaning              => NULL,
		      p_description                     => p_gl_flex_values_tbl(I).flex_desc);
          ---As suggested by the Flex team in  the bug 7668121 going ahead with the direct update on the LUD
           IF l_insert_update = 'U' THEN
              UPDATE fnd_flex_values
	      SET last_update_date = sysdate
	      WHERE rowid = rec_fnd_flex_val.rowid ;
	   ELSE
	      UPDATE fnd_flex_values
	      SET last_update_date = sysdate
	      WHERE flex_value_set_id = l_cur_co.flex_value_set_id
	      AND flex_value = p_gl_flex_values_tbl(I).flex_value;
	   END IF;

	   EXCEPTION
	     WHEN OTHERS THEN
	       IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	         fnd_log.string( fnd_log.level_statement, 'gl.plsql.gl_coa_seg_val_imp_pkg.create_gl_coa_flex_values.Error_in_flex_API',
	         'Value Set Name:'||p_gl_flex_values_tbl(I).value_set_name||'  '||'Parent Flex Value:'||p_gl_flex_values_tbl(I).parent_flex_value||'  '||'Flex Value:'
	         ||p_gl_flex_values_tbl(I).flex_value||'  '||'Error_Message:'||FND_MESSAGE.GET
		 ||'  '||'Unhandled Exception :'||sqlerrm);
               END IF;
	       fnd_message.set_name( 'GL', 'GL_COA_SVI_FLEX_UN_EX');
	       fnd_msg_pub.add;
	       p_gl_flex_values_tbl(I).status := 'E';
	   END;

         END IF;--insert/update

      IF  p_gl_flex_values_tbl(I).status = 'S' THEN
	 p_gl_flex_values_tbl(I).msg_from := NULL;
	 p_gl_flex_values_tbl(I).msg_to := NULL;

	 IF flex_vl_set_id_tab.count = 0 THEN
           flex_vl_set_id_tab(flex_vl_set_id_tab.count+1) :=l_cur_co.flex_value_set_id;
         ELSE
	   IF NOT isExists(l_cur_co.flex_value_set_id,flex_vl_set_id_tab) THEN
	   flex_vl_set_id_tab(flex_vl_set_id_tab.count+1) :=l_cur_co.flex_value_set_id;
          END IF;
	 END IF;

       ELSE
         IF p_c_rec_status = 'S' THEN
  	    p_c_rec_status := p_gl_flex_values_tbl(I).status;
	 END IF;
	 p_gl_flex_values_tbl(I).msg_from := p_gl_flex_values_tbl(I).msg_from+1;
	 p_gl_flex_values_tbl(I).msg_to := fnd_msg_pub.count_msg;
  	 IF p_gl_flex_values_tbl(I).status = 'E' THEN
	   NULL;--RETURN;
	 END IF;
        END IF;

     END IF;--exists
   END LOOP;

   /* Fork the Compile value set hierarchies Program for the Distinct Set of Value set ids having at least one successful create*/
   FOR i in 1..flex_vl_set_id_tab.count LOOP
      result := fnd_request.set_options('NO', 'NO', NULL, NULL);
      req_id := fnd_request.submit_request(
                'FND', 'FDFCHY', '', '', FALSE,
                TO_CHAR(flex_vl_set_id_tab(i)), chr(0),
                '', '', '', '', '', '', '', '',
                '', '', '', '', '', '', '', '', '', '',
                '', '', '', '', '', '', '', '', '', '',
                '', '', '', '', '', '', '', '', '', '',
                '', '', '', '', '', '', '', '', '', '',
                '', '', '', '', '', '', '', '', '', '',
                '', '', '', '', '', '', '', '', '', '',
                '', '', '', '', '', '', '', '', '', '',
                '', '', '', '', '', '', '', '', '', '',
                '', '', '', '', '', '', '', '', '', '');
       IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	    fnd_log.string( fnd_log.level_statement, 'gl.plsql.gl_coa_seg_val_imp_pkg.create_gl_coa_flex_values.Triggered_FDFCHY',
	    'Value Set id:'||TO_CHAR(flex_vl_set_id_tab(i))||'  '||'Request id:'||req_id);
       END IF;
       IF (req_id = 0) THEN
         IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	    fnd_log.string( fnd_log.level_statement, 'gl.plsql.gl_coa_seg_val_imp_pkg.create_gl_coa_flex_values.Error_in_FDFCHY',
	    'Value Set Name:'||p_gl_flex_values_tbl(I).value_set_name||'  '||'Parent Flex Value:'||p_gl_flex_values_tbl(I).parent_flex_value||'  '||'Flex Value:'
	    ||p_gl_flex_values_tbl(I).flex_value||'  '||'Value_set_id:'||TO_CHAR(flex_vl_set_id_tab(i))||'  '||'Error_Message:'||
	    FND_MESSAGE.GET);
         END IF;
	 fnd_message.set_name ( 'GL', 'GL_COA_SVI_COM_HIER_ERR' );
	 fnd_msg_pub.add;
      END IF;
   END LOOP;

   flex_vl_set_id_tab.delete;

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string( fnd_log.level_procedure, 'gl.plsql.gl_coa_seg_val_imp_pkg.create_gl_coa_flex_values.status_after_import',p_c_rec_status);
    END IF;
 END create_gl_coa_flex_values;

 PROCEDURE create_gl_coa_flex_values_nh(
          p_gl_flex_values_nh_tbl IN OUT NOCOPY gl_coa_seg_val_imp_pub.gl_flex_values_nh_tbl_type,
          p_c_rec_status OUT NOCOPY VARCHAR2

  ) AS
  /***********************************************************************************************
    Created By     :  Sommukhe
    Date Created By: 01-AUG-2008
    Purpose        :  This procedure is a sub process to import records of s.

    Known limitations,enhancements,remarks:
    Change History (in reverse chronological order)
    Who         When            What
  ********************************************************************************************** */
     l_insert_update      VARCHAR2(1);
     v_message_name       VARCHAR2(30);
     req_id    NUMBER;
     result    BOOLEAN;
     row_count NUMBER;
     vsid      NUMBER;
     l_nh_exists BOOLEAN;
     flex_vl_set_id_del_tab flex_vl_set_id_tbl_type;

    /* Private Procedures for create_gl_coa_flex_values_nh */
    PROCEDURE trim_values ( gl_coa_flex_values_nh_rec IN OUT NOCOPY gl_coa_seg_val_imp_pub.gl_flex_values_nh_rec_type ) AS
    BEGIN
      gl_coa_flex_values_nh_rec.value_set_name := trim(gl_coa_flex_values_nh_rec.value_set_name);
      gl_coa_flex_values_nh_rec.parent_flex_value := trim(gl_coa_flex_values_nh_rec.parent_flex_value);
      gl_coa_flex_values_nh_rec.range_attribute := trim(gl_coa_flex_values_nh_rec.range_attribute);
      gl_coa_flex_values_nh_rec.child_flex_value_low := trim(gl_coa_flex_values_nh_rec.child_flex_value_low);
      gl_coa_flex_values_nh_rec.child_flex_value_high := trim(gl_coa_flex_values_nh_rec.child_flex_value_high);

    END trim_values;

    PROCEDURE validate_derivations ( gl_coa_flex_values_nh_rec IN OUT NOCOPY gl_coa_seg_val_imp_pub.gl_flex_values_nh_rec_type, p_nh_exists OUT BOOLEAN ) AS
    --Cursor to check if child ranges already exist
    CURSOR c_fnd_flex_value_nh_exists(cp_flex_value_set_id fnd_flex_value_sets.flex_value_set_id%TYPE,
                                      cp_parent_flex_value fnd_flex_value_norm_hierarchy.parent_flex_value%TYPE ) IS
    SELECT 'X'
    FROM fnd_flex_value_norm_hierarchy
    WHERE flex_value_set_id = cp_flex_value_set_id
    AND parent_flex_value = cp_parent_flex_value;

    rec_fnd_flex_value_nh_exists c_fnd_flex_value_nh_exists%ROWTYPE;

    BEGIN
      --Validate the Value set name
      OPEN c_fnd_flex_values(gl_coa_flex_values_nh_rec.value_set_name);
       FETCH c_fnd_flex_values INTO l_cur_co;
       IF c_fnd_flex_values%NOTFOUND THEN
	 CLOSE c_fnd_flex_values;
	 fnd_message.set_name('GL','GL_COA_SVI_INVALID_VALUE');
         fnd_msg_pub.add;
         gl_coa_flex_values_nh_rec.status := 'E';
       ELSE
	 CLOSE c_fnd_flex_values;
       END IF;

       OPEN c_fnd_flex_value_nh_exists(l_cur_co.flex_value_set_id,gl_coa_flex_values_nh_rec.parent_flex_value);
       FETCH c_fnd_flex_value_nh_exists INTO rec_fnd_flex_value_nh_exists;
       IF c_fnd_flex_value_nh_exists%NOTFOUND THEN
	 CLOSE c_fnd_flex_value_nh_exists;
	 p_nh_exists := FALSE;
       ELSE
	 CLOSE c_fnd_flex_value_nh_exists;
	 p_nh_exists := TRUE;
       END IF;

    END validate_derivations;

    -- validate parameters passed.
    PROCEDURE validate_parameters ( gl_coa_flex_values_nh_rec IN OUT NOCOPY gl_coa_seg_val_imp_pub.gl_flex_values_nh_rec_type  ) AS
    BEGIN

      IF gl_coa_flex_values_nh_rec.value_set_name IS NULL  THEN
        set_msg('GL_COA_SVI_SEG_VAL_MAND', 'VALUE_SET_NAME');
        gl_coa_flex_values_nh_rec.status := 'E';
      END IF;

      IF gl_coa_flex_values_nh_rec.parent_flex_value IS NULL  THEN
       	 set_msg('GL_COA_SVI_SEG_VAL_MAND', 'PARENT_FLEX_VALUE');
        gl_coa_flex_values_nh_rec.status := 'E';
      END IF;

      IF gl_coa_flex_values_nh_rec.range_attribute IS NULL THEN
        set_msg('GL_COA_SVI_SEG_VAL_MAND', 'RANGE_ATTRIBUTE');
        gl_coa_flex_values_nh_rec.status := 'E';
      END IF;

      IF gl_coa_flex_values_nh_rec.child_flex_value_low IS NULL  THEN
       	 set_msg('GL_COA_SVI_SEG_VAL_MAND', 'CHILD_FLEX_VALUE_LOW');
        gl_coa_flex_values_nh_rec.status := 'E';
      END IF;

      IF gl_coa_flex_values_nh_rec.child_flex_value_high IS NULL  THEN
       	 set_msg('GL_COA_SVI_SEG_VAL_MAND', 'CHILD_FLEX_VALUE_HIGH');
        gl_coa_flex_values_nh_rec.status := 'E';
      END IF;

    END validate_parameters;

    -- Validate Database Constraints
    PROCEDURE validate_db_cons (gl_coa_flex_values_nh_rec IN OUT NOCOPY gl_coa_seg_val_imp_pub.gl_flex_values_nh_rec_type  ) AS
    --Cursor to validate the parent flex value
    CURSOR c_fnd_flex_value_exists(cp_flex_value_set_id fnd_flex_value_sets.flex_value_set_id%TYPE,
                                      cp_parent_flex_value fnd_flex_value_norm_hierarchy.parent_flex_value%TYPE ) IS
    SELECT summary_flag
    FROM fnd_flex_values
    WHERE flex_value_set_id = cp_flex_value_set_id
    AND flex_value = cp_parent_flex_value;

    rec_fnd_flex_value_exists c_fnd_flex_value_exists%ROWTYPE;
    BEGIN
    -- Parent Flex Value should be valid
    OPEN c_fnd_flex_value_exists(l_cur_co.flex_value_set_id,gl_coa_flex_values_nh_rec.parent_flex_value);
       FETCH c_fnd_flex_value_exists INTO rec_fnd_flex_value_exists;
       IF c_fnd_flex_value_exists%NOTFOUND THEN
	 CLOSE c_fnd_flex_value_exists;
	 set_msg('GL_COA_SVI_INV_P_FLEX', gl_coa_flex_values_nh_rec.parent_flex_value);
	 gl_coa_flex_values_nh_rec.status := 'E';
       ELSE
         IF rec_fnd_flex_value_exists.summary_flag <> 'Y' THEN
           set_msg('GL_COA_SVI_NO_SUM_FLG', gl_coa_flex_values_nh_rec.parent_flex_value);
	   gl_coa_flex_values_nh_rec.status := 'E';
	 END IF;
	 CLOSE c_fnd_flex_value_exists;
       END IF;
    END validate_db_cons;

    -- Carry out business validations
    PROCEDURE validate_nh ( gl_coa_flex_values_nh_rec IN OUT NOCOPY gl_coa_seg_val_imp_pub.gl_flex_values_nh_rec_type  ) AS
    BEGIN

     --If Range Attribute should be in ('C','P')
     IF gl_coa_flex_values_nh_rec.range_attribute NOT IN ('C','P') THEN
        set_msg('GL_COA_SVI_INVALID_VALUE', 'RANGE_ATTRIBUTE');
        gl_coa_flex_values_nh_rec.status := 'E';
      END IF;

     -- Child Flex Value Low should be less than Child Flex Value high
     IF gl_coa_flex_values_nh_rec.child_flex_value_low > gl_coa_flex_values_nh_rec.child_flex_value_high THEN
        fnd_message.set_name('GL','GL_COA_SVI_CFH_LESS_CFL');
        fnd_msg_pub.add;
        gl_coa_flex_values_nh_rec.status := 'E';
      END IF;

      --Loop detected if Range Attribute is 'P' and the parent flex value falls in between child_flex_value_low and child_flex_value_high
      IF gl_coa_flex_values_nh_rec.range_attribute = 'P' THEN
        IF gl_coa_flex_values_nh_rec.parent_flex_value BETWEEN gl_coa_flex_values_nh_rec.child_flex_value_low AND gl_coa_flex_values_nh_rec.child_flex_value_high THEN
	  set_msg('GL_COA_SVI_FLEX_HIER_LOOP', gl_coa_flex_values_nh_rec.parent_flex_value);
	  gl_coa_flex_values_nh_rec.status := 'E';
	END IF;
      END IF;

    END validate_nh;



  /* Main Child ranges Sub Process */
  BEGIN

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string( fnd_log.level_procedure, 'gl.plsql.gl_coa_seg_val_imp_pkg.create_gl_coa_flex_values_nh.start_logging_for','Child ranges');
    END IF;

    p_c_rec_status := 'S';
    l_nh_exists := NULL;
    FOR I in 1..p_gl_flex_values_nh_tbl.LAST LOOP
      IF p_gl_flex_values_nh_tbl.EXISTS(I) THEN

        p_gl_flex_values_nh_tbl(I).status := 'S';
        p_gl_flex_values_nh_tbl(I).msg_from := fnd_msg_pub.count_msg;
	trim_values(p_gl_flex_values_nh_tbl(I) );
	validate_derivations( p_gl_flex_values_nh_tbl(I),l_nh_exists );

	--Check for the presence of the mandatory parameters
	IF p_gl_flex_values_nh_tbl(I).status = 'S' THEN
          validate_parameters ( p_gl_flex_values_nh_tbl(I) );
	END IF;

        --Parent Flex Value should be valid
	IF p_gl_flex_values_nh_tbl(I).status = 'S' THEN
          validate_db_cons ( p_gl_flex_values_nh_tbl(I) );
	END IF;

	--Business Validations for the fnd_flex_value_norm_hierarchy entities
	IF p_gl_flex_values_nh_tbl(I).status = 'S' THEN
          validate_nh ( p_gl_flex_values_nh_tbl(I) );
	END IF;

        /* Delete the already existing child ranges records*/
         IF flex_vl_set_id_del_tab.count = 0 THEN
	   IF l_nh_exists THEN
             flex_vl_set_id_del_tab(flex_vl_set_id_del_tab.count+1) :=l_cur_co.flex_value_set_id;
	     DELETE FROM fnd_flex_value_norm_hierarchy
	     WHERE flex_value_set_id =l_cur_co.flex_value_set_id
	     AND parent_flex_value =p_gl_flex_values_nh_tbl(I).parent_flex_value  ;
	   END IF;
         ELSE
	   IF NOT isExists(l_cur_co.flex_value_set_id,flex_vl_set_id_del_tab) THEN
             IF l_nh_exists THEN
	       flex_vl_set_id_del_tab(flex_vl_set_id_del_tab.count+1) :=l_cur_co.flex_value_set_id;
	       DELETE FROM fnd_flex_value_norm_hierarchy
	       WHERE flex_value_set_id =l_cur_co.flex_value_set_id
	       AND parent_flex_value =p_gl_flex_values_nh_tbl(I).parent_flex_value  ;
             END IF;
          END IF;
	 END IF;

         IF p_gl_flex_values_nh_tbl(I).status = 'S'  THEN
           BEGIN
	   fnd_flex_loader_apis.up_vset_value_hierarchy
		  (p_upload_phase                 => 'BEGIN' ,
		   p_upload_mode                  => NULL,
		   p_custom_mode                  => 'FORCE',
		   p_flex_value_set_name          => p_gl_flex_values_nh_tbl(I).value_set_name,
		   p_parent_flex_value            => p_gl_flex_values_nh_tbl(I).parent_flex_value,
		   p_range_attribute              => p_gl_flex_values_nh_tbl(I).range_attribute,
		   p_child_flex_value_low         => p_gl_flex_values_nh_tbl(I).child_flex_value_low,
		   p_child_flex_value_high        => p_gl_flex_values_nh_tbl(I).child_flex_value_high,
		   p_owner                        => NULL,
		   p_last_update_date             => NULL,
		   p_start_date_active            => NULL,
		   p_end_date_active              => NULL);
           EXCEPTION
	     WHEN OTHERS THEN
	       fnd_message.set_name( 'GL', 'GL_COA_SVI_FLEX_UN_EX');
	       fnd_msg_pub.add;
	       p_gl_flex_values_nh_tbl(I).status := 'E';
	   END;
         END IF;

      IF  p_gl_flex_values_nh_tbl(I).status = 'S' THEN
	 p_gl_flex_values_nh_tbl(I).msg_from := NULL;
	 p_gl_flex_values_nh_tbl(I).msg_to := NULL;

	 IF flex_vl_set_id_tab.count = 0 THEN
           flex_vl_set_id_tab(flex_vl_set_id_tab.count+1) :=l_cur_co.flex_value_set_id;
         ELSE
	   IF NOT isExists(l_cur_co.flex_value_set_id,flex_vl_set_id_tab) THEN
	   flex_vl_set_id_tab(flex_vl_set_id_tab.count+1) :=l_cur_co.flex_value_set_id;
          END IF;
	 END IF;

       ELSE
         IF p_c_rec_status = 'S' THEN
  	    p_c_rec_status := p_gl_flex_values_nh_tbl(I).status;
	 END IF;
	 p_gl_flex_values_nh_tbl(I).msg_from := p_gl_flex_values_nh_tbl(I).msg_from+1;
	 p_gl_flex_values_nh_tbl(I).msg_to := fnd_msg_pub.count_msg;
  	 IF p_gl_flex_values_nh_tbl(I).status = 'E' THEN
	   NULL;--RETURN;
	 END IF;
        END IF;

        END IF;-- if exists


   END LOOP;

    /* Fork the Compile value set hierarchies Program for the Distinct Set of Value set ids having at least one successful create*/
     FOR i in 1..flex_vl_set_id_tab.count LOOP
      result := fnd_request.set_options('NO', 'NO', NULL, NULL);
      req_id := fnd_request.submit_request(
                'FND', 'FDFCHY', '', '', FALSE,
                TO_CHAR(flex_vl_set_id_tab(i)), chr(0),
                '', '', '', '', '', '', '', '',
                '', '', '', '', '', '', '', '', '', '',
                '', '', '', '', '', '', '', '', '', '',
                '', '', '', '', '', '', '', '', '', '',
                '', '', '', '', '', '', '', '', '', '',
                '', '', '', '', '', '', '', '', '', '',
                '', '', '', '', '', '', '', '', '', '',
                '', '', '', '', '', '', '', '', '', '',
                '', '', '', '', '', '', '', '', '', '',
                '', '', '', '', '', '', '', '', '', '');
       IF (req_id = 0) THEN
         fnd_message.set_name ( 'GL', 'GL_COA_SVI_COM_HIER_ERR' );
	 fnd_msg_pub.add;
      END IF;
    END LOOP;

    flex_vl_set_id_tab.delete;

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string( fnd_log.level_procedure, 'gl.plsql.gl_coa_seg_val_imp_pkg.create_gl_coa_flex_values_nh.status_after_import',p_c_rec_status);
    END IF;

 END create_gl_coa_flex_values_nh;

END gl_coa_seg_val_imp_pkg;

/
