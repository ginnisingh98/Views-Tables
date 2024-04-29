--------------------------------------------------------
--  DDL for Package Body GL_REP_ATTRIBUTES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_REP_ATTRIBUTES" AS
/* $Header: glgrattb.pls 120.8 2006/03/29 09:59:24 kbhatt noship $ */

procedure gl_preparation( retcode     OUT NOCOPY    VARCHAR2,
  			  errbuf      OUT NOCOPY    VARCHAR2,
			  p_chart_of_accounts_id  IN NUMBER) is
 	  ---------------------
	   -- Flexfield API type
	   ---------------------
         lseg_gl_segs        fnd_flex_key_api.segment_type;   -- Segment Type
         lseg_glat_segs      fnd_flex_key_api.segment_type;   -- Segment Type
         lseg_new_seg        fnd_flex_key_api.segment_type;
         lseg_att_new_seg    fnd_flex_key_api.segment_type;
	    --
         lstr_gl_struc       fnd_flex_key_api.structure_type; -- Structure Type
         lstr_new_struc      fnd_flex_key_api.structure_type;
         lstr_glat_struc     fnd_flex_key_api.structure_type;
	    --
         lflx_gl_flex        fnd_flex_key_api.flexfield_type; -- Flexfield Type
         lflx_new_flex       fnd_flex_key_api.flexfield_type;
         lflx_glat_flex      fnd_flex_key_api.flexfield_type;
	    --
         llst_gl_seg_list    fnd_flex_key_api.segment_list;   -- Segment List
         llst_glat_seg_list  fnd_flex_key_api.segment_list;
         ---------------------
         -- Value set API
         ---------------------
         lval_valueset fnd_vset.valueset_r;
         lval_format fnd_vset.valueset_dr;
         ---------------------
         -- Flags and Counters
         ---------------------
         lc_flex_val_set_name fnd_flex_value_sets.flex_value_set_name%type;
         lc_new_flex_flag    varchar2(1):='N';
         ln_no_of_attributes number;
         ln_func             number;
         ln_gl_nsegs         number;
         ln_glat_nsegs       number;
         ln_segs_ctr         number;
         ln_seg_num         number;
         ln_glat_segs_ctr    number;
         ln_flex_attr_flag    number:=0;
         p_coa_id          number:= p_chart_of_accounts_id;
         ----------------------
         --Messages
         ----------------------
         lc_api_message      varchar2(2000);      -- For API Message
         lc_rep_profile      varchar2(132);
         lc_err_message      varchar2(200);
         lexp_error          exception;
         ln_userid           number;
         ---------------------------
         -- For FND_INSTALLATION API
         ---------------------------
         lc_int_status       varchar2(10);
         lc_int_industry     varchar2(10);
         lc_int_schema       varchar2(10);
	 ---------------------------
	 --  INDUSTRY profile option
	 ---------------------------
	 lp_user_id	     number;
	 lp_user_resp_id     number;
	 lp_resp_appl_id     number;
	 l_defined	     boolean;

         --------------------------------
         -- Segment Attribute Types Cursor
         --------------------------------
         CURSOR seg_attr_cur (p_id_flex_num number,
                              p_id_flex_code varchar2,
                              p_application_id number,
                              p_app_seg_name varchar2) IS
         SELECT
              typ.segment_attribute_type segment_attribute_type,
              typ.segment_prompt segment_prompt,
              typ.description description,
              typ.global_flag global_flag,
              typ.required_flag required_flag,
              typ.unique_flag unique_flag,
              val.attribute_value attribute_value
         FROM fnd_segment_attribute_values val,
              fnd_segment_attribute_types typ
         WHERE val.id_flex_num =p_id_flex_num	-- Bug 3813504
         AND val.id_flex_code = p_id_flex_code
         AND val.id_flex_code = typ.id_flex_code
         AND typ.segment_attribute_type = val.segment_attribute_type
         AND val.application_id = p_application_id
         AND val.application_id = typ.application_id
         AND val.application_column_name = p_app_seg_name;
         -----------------------------
         -- Reporting Attributes Cursor
         -- This cursor will select all
         -- the attributes defined for
         -- the segment
         -----------------------------
         -- Bug 4128077
         CURSOR rep_attr_cur(p_seg_name varchar , p_seg_vset_name VARCHAR2,  p_application_id number) IS
         SELECT sequence,
                att.application_id,
                att.id_flex_code,
                att.id_flex_num,
                att.attr_segment_name,
                att.application_column_name,
                val.flex_value_set_name value_set_name,
                att.user_column_name,
                att.index_flag,
                att.form_left_prompt,
                att.form_above_prompt,
                att.display_size,
                att.description,
                att.table_id,
                att.attribute_num,
                att.segment_name,
                fdu.default_type ,
                fdu.default_value ,
                fdu.range_code
         FROM fnd_seg_rpt_attributes att,
              fnd_flex_value_sets val ,
              fnd_descr_flex_column_usages  fdu
         WHERE segment_name = p_seg_name
         AND att.attr_value_set_id = val.flex_value_set_id
         AND att.enabled_flag = 'Y'
         AND att.id_flex_num = p_coa_id
         AND fdu.descriptive_flexfield_name = 'FND_FLEX_VALUES'
         AND fdu.descriptive_flex_context_code = p_seg_vset_name
         AND fdu.flex_value_set_id =  val.flex_value_set_id
         AND att.application_column_name = fdu.end_user_column_name
        AND fdu.application_id=p_application_id
         ORDER BY 1;

--================================
  BEGIN  -- This is the main Block
--================================
    ---------------------------------------
    --This Block does the validation to
    --check whether the eporting Attributes
    --profile is set and the installation
    --is Goverment type
    ---------------------------------------
    BEGIN

    -- The installation info is now implemented as a profile option (INDUSTRY).

    -- Get Calling Application ID / Responsibility ID / User ID

    lp_resp_appl_id := FND_GLOBAL.RESP_APPL_ID;
    lp_user_resp_id := FND_GLOBAL.RESP_ID;
    lp_user_id      := FND_GLOBAL.USER_ID;

    FND_PROFILE.GET_SPECIFIC('INDUSTRY',
                             lp_user_id,
                             lp_user_resp_id,
                             lp_resp_appl_id,
                             lc_int_industry,
                             l_defined);

    IF not l_defined then
         IF fnd_installation.get_app_info( application_short_name=>'SQLGL'
                                          ,status=>lc_int_status
                                          ,industry=>lc_int_industry
                                          ,oracle_schema=>lc_int_schema) THEN

             IF lc_int_industry <> 'G' THEN
                 lc_err_message := 'Oracle Government Ledger is not Installed';
                 RAISE lexp_error;
             END IF;

         END IF;
    ELSE
             IF lc_int_industry <> 'G' THEN
                 lc_err_message := 'Oracle Government Ledger is not Installed';
                 RAISE lexp_error;
             END IF;

    END IF;

         --
         fnd_profile.get('USER_ID',ln_userid);
         fnd_profile.get('ATTRIBUTE_REPORTING',lc_rep_profile);
         IF lc_rep_profile = 'N' THEN
              lc_err_message := 'The Value for the Profile Option: ATTRIBUTE REPORTING is not set ';
              RAISE lexp_error;
         END IF;
         --
         SELECT  COUNT(*)
         INTO    ln_no_of_attributes
         FROM    fnd_seg_rpt_attributes
         WHERE   application_id = 101
         AND     id_flex_code = 'GLAT'
         AND     id_flex_num  = p_coa_id;
         IF ln_no_of_attributes > 42 THEN
             lc_err_message := 'The number of attributes defined can not be greater than 42';
             RAISE lexp_error;
         END IF;
    END;
    --------------------------------------------------
    --Initiate the flexfied api
    --Find the Info about the GL Accounting flexfied
    --Find the Structure and Segments for the entered
    --chart of accounts ID
    --------------------------------------------------
    BEGIN
         fnd_flex_key_api.set_session_mode('seed_data');
         --
         lflx_gl_flex  := fnd_flex_key_api.find_flexfield('SQLGL','GL#');
         lstr_gl_struc := fnd_flex_key_api.find_structure(lflx_gl_flex,p_coa_id);
         fnd_flex_key_api.get_segments(flexfield=>lflx_gl_flex,
                                       structure=>lstr_gl_struc,
                                       nsegments=>ln_gl_nsegs,    --nseg stores the number of segments
                                       segments=>llst_gl_seg_list);
    END;
    ---------------------------------------------
    --Find Whether GLAT Flexfield exists
    --When GLAT flexfield does not exist
    --create a new Flexfield with Flex code GLAT
    --and register the flexfield
    --and Create New Structure for GLAT Flexfield
    --Set the Check Flag as there is no need to
    --delete records for GLAT Flexfield
    --Also set the flag for new GLAT flexfield
    ---------------------------------------------
    BEGIN
         lflx_glat_flex  :=fnd_flex_key_api.find_flexfield('SQLGL',
                                                           'GLAT');
         EXCEPTION WHEN no_data_found THEN
             lflx_new_flex := fnd_flex_key_api.new_flexfield
                                      (appl_short_name     =>lflx_gl_flex.appl_short_name,
                                       flex_code           =>'GLAT',
                                       flex_title          =>substr('Reporting Attributes:'||lflx_gl_flex.flex_title,1,30),
                                       description         =>substr('Reporting Attributes:'||lflx_gl_flex.description,1,240),
                                       table_appl_short_name=>lflx_gl_flex.table_appl_short_name,
                                       table_name          =>lflx_gl_flex.table_name,
                                       unique_id_column    =>lflx_gl_flex.unique_id_column,
                                       structure_column    =>lflx_gl_flex.structure_column,
                                       dynamic_inserts     =>lflx_gl_flex.dynamic_inserts,
                                       allow_id_value_sets =>lflx_gl_flex.allow_id_value_sets,
                                       index_flag          =>lflx_gl_flex.index_flag,
                                       concat_seg_len_max  =>lflx_gl_flex.concat_seg_len_max,
                                       concat_len_warning  =>lflx_gl_flex.concat_len_warning);
         --
         fnd_flex_key_api.register(flexfield      =>lflx_new_flex,
                                   enable_columns => 'Y');
         --
         lflx_glat_flex  :=fnd_flex_key_api.find_flexfield('SQLGL',
                                                           'GLAT');
         --
         lc_new_flex_flag :='Y';
    END;
    -------------------------------------------------
    --Intialize the counter
    --LOOP for the each segment in the GL Flexfield
    --  Get the GL Segment Details
    --     IF GLAT flexfied exists THEN
    --        Get segments for GLAT Structure
    --        Delete the GLAT segments and other details
    --        Create a new GLAT structure
    --     END IF
    -- Create new Segments for GLAT from GL segments
    -- Create new Segments for GLAT from Attributes
    --END LOOP
    -------------------------------------------------
    ln_segs_ctr := 1;
    ln_seg_num := 1;
    WHILE ln_segs_ctr<=ln_gl_nsegs LOOP
         lseg_gl_segs:=fnd_flex_key_api.find_segment(lflx_gl_flex,
                                                     lstr_gl_struc,
                                                     llst_gl_seg_list(ln_segs_ctr));
         BEGIN
              lstr_glat_struc:=fnd_flex_key_api.find_structure
                                               (flexfield       =>lflx_glat_flex,
                                                structure_number=>p_coa_id);
              EXCEPTION WHEN no_data_found THEN
                  --
                  lstr_new_struc.structure_number      :=p_coa_id;
                  lstr_new_struc.structure_code        :=lstr_gl_struc.structure_code;
                  lstr_new_struc.structure_name        :=lstr_gl_struc.structure_name;
                  lstr_new_struc.description           :=substr('Reporting Attributes:'||lstr_gl_struc.description,1,240);
                  lstr_new_struc.view_name             :=lstr_gl_struc.view_name;
                  lstr_new_struc.freeze_flag           :='Y';
                  lstr_new_struc.enabled_flag          :=lstr_gl_struc.enabled_flag;
                  lstr_new_struc.segment_separator     :=lstr_gl_struc.segment_separator;
                  lstr_new_struc.cross_val_flag        :=lstr_gl_struc.cross_val_flag;
                  lstr_new_struc.freeze_rollup_flag    :=lstr_gl_struc.freeze_rollup_flag;
                  lstr_new_struc.dynamic_insert_flag   :=lstr_gl_struc.dynamic_insert_flag;
                  lstr_new_struc.shorthand_enabled_flag:=lstr_gl_struc.shorthand_enabled_flag;
                  lstr_new_struc.shorthand_prompt      :=lstr_gl_struc.shorthand_prompt;
                  lstr_new_struc.shorthand_length      :=lstr_gl_struc.shorthand_length;
                  --
                  fnd_flex_key_api.add_structure(flexfield=>lflx_glat_flex,
                                                 structure=>lstr_new_struc);
                  --
                  lstr_glat_struc :=fnd_flex_key_api.find_structure(flexfield=>lflx_glat_flex,
                                                                    structure_number=>p_coa_id);
         END;


         IF lc_new_flex_flag = 'N' THEN  --GLAT Flexfield Structure
              -----------------------------------------------------------
              -- Delete the qualifiers for each segment of GLAT Structure
              -- Delete the GLAT flexfield Structure
              -- Deletes segments and attribute values
              -----------------------------------------------------------
              FOR cv_del_seg_attr_cur in seg_attr_cur(p_coa_id,
                                                      'GL#',
                                                      101,
                                                      lseg_gl_segs.column_name) LOOP
                  ln_func:=fnd_flex_key_api.delete_flex_qualifier
                                          (flexfield=>lflx_glat_flex,
                                           qualifier_name=>cv_del_seg_attr_cur.segment_attribute_type);
              END LOOP;
              --
              fnd_flex_key_api.delete_structure(lflx_glat_flex,
                                                lstr_glat_struc);
              ---------------------------------------
              -- Create New structure for GLAT Flexfield
              ----------------------------------------
              lflx_glat_flex  :=fnd_flex_key_api.find_flexfield('SQLGL',
                                                                'GLAT');
              --
              lstr_new_struc.structure_number       :=p_coa_id;
              lstr_new_struc.structure_code         :=lstr_gl_struc.structure_code;
              lstr_new_struc.structure_name         :=lstr_gl_struc.structure_name;
              lstr_new_struc.description            :=substr('Reporting Attributes:'||lstr_gl_struc.description,1,240);
              lstr_new_struc.view_name              :=lstr_gl_struc.view_name;
              lstr_new_struc.freeze_flag            :='Y';
              lstr_new_struc.enabled_flag           :=lstr_gl_struc.enabled_flag;
              lstr_new_struc.segment_separator      :=lstr_gl_struc.segment_separator;
              lstr_new_struc.cross_val_flag         :=lstr_gl_struc.cross_val_flag;
              lstr_new_struc.freeze_rollup_flag     :=lstr_gl_struc.freeze_rollup_flag;
              lstr_new_struc.dynamic_insert_flag    :=lstr_gl_struc.dynamic_insert_flag;
              lstr_new_struc.shorthand_enabled_flag :=lstr_gl_struc.shorthand_enabled_flag;
              lstr_new_struc.shorthand_prompt       :=lstr_gl_struc.shorthand_prompt;
              lstr_new_struc.shorthand_length       :=lstr_gl_struc.shorthand_length;
              -------------------
              --Add new structure
              -------------------
              fnd_flex_key_api.add_structure(flexfield=>lflx_glat_flex,
                                             structure=>lstr_new_struc);
              lstr_glat_struc:=fnd_flex_key_api.find_structure(flexfield=>lflx_glat_flex,
                                                        structure_number=>p_coa_id);
              -- Set the flag so that this executes only once
              lc_new_flex_flag     :='E';
         END IF;
         --


         BEGIN
              -----------------------------
              -- Add the GL Segment to GLAT
              -----------------------------
              IF lseg_gl_segs.value_set_name IS NULL AND
                 lseg_gl_segs.value_set_id IS NOT NULL THEN
                   fnd_vset.get_valueset(valueset_id =>lseg_gl_segs.value_set_id,
                                         valueset =>lval_valueset,
                                         format =>lval_format);
                   lc_flex_val_set_name := lval_valueset.name;
              ELSE
                   lc_flex_val_set_name := lseg_gl_segs.value_set_name;
              END IF;

              --


              lseg_new_seg:= fnd_flex_key_api.new_segment
                                            (flexfield        =>lflx_glat_flex,
                                             structure        =>lstr_glat_struc,
                                             segment_name     =>lseg_gl_segs.segment_name,
                                             description      =>lseg_gl_segs.description,
                                             column_name      =>lseg_gl_segs.column_name,
                                             segment_number   =>ln_seg_num,
                                             enabled_flag     =>lseg_gl_segs.enabled_flag,
                                             displayed_flag   =>lseg_gl_segs.displayed_flag,
                                             indexed_flag     =>lseg_gl_segs.indexed_flag,
                                             value_set        =>lc_flex_val_set_name,
                                             default_type     =>lseg_gl_segs.default_type,
                                             default_value    =>lseg_gl_segs.default_value,
                                             required_flag    =>lseg_gl_segs.required_flag,
                                             security_flag    =>lseg_gl_segs.security_flag,
                                             range_code       =>lseg_gl_segs.range_code,
                                             display_size     =>lseg_gl_segs.display_size,
                                             description_size =>lseg_gl_segs.description_size,
                                             concat_size      =>lseg_gl_segs.concat_size,
                                             lov_prompt       =>lseg_gl_segs.lov_prompt,
                                             window_prompt    =>lseg_gl_segs.window_prompt);
              --------------------------------------
              --Add a new segment for GLAT Flexfield
              --------------------------------------
              fnd_flex_key_api.add_segment(flexfield =>lflx_glat_flex,
                                           structure =>lstr_glat_struc,
                                           segment   =>lseg_new_seg);
              ln_seg_num:=ln_seg_num+1;
         END;

         ------------------------------------------------------------
         -- Get the rows from ATTR Table corresponding to the segment
         ------------------------------------------------------------
         BEGIN
        --   	fnd_file.put_line(fnd_file.log,'Value set for the segment ' || lseg_gl_segs.column_name || ' is ' ||  lc_flex_val_set_name);
            FOR c_rep_attr_cur IN rep_attr_cur(lseg_gl_segs.column_name,lc_flex_val_set_name,101) LOOP
                 -------------------------------
                 --Create corresponding segments
                 -------------------------------
                 lseg_att_new_seg:= fnd_flex_key_api.new_segment
                                                   (flexfield        =>lflx_glat_flex,
                                                    structure        =>lstr_glat_struc,
                                                    segment_name     =>c_rep_attr_cur.application_column_name,
                                                    description      =>c_rep_attr_cur.description,
                                                    column_name      =>c_rep_attr_cur.attr_segment_name,
                                                    segment_number   =>ln_seg_num,
                                                    enabled_flag     =>'Y',
                                                    displayed_flag   =>'Y',
                                                    indexed_flag     =>c_rep_attr_cur.index_flag,
                                                    value_set        =>c_rep_attr_cur.value_set_name,
                                                    default_type     =>c_rep_attr_cur.default_type,
                                                    default_value    =>c_rep_attr_cur.default_value,
                                                    required_flag    =>'Y',
                                                    security_flag    =>'Y',
                                                    range_code       =>c_rep_attr_cur.range_code,
                                                    display_size     =>c_rep_attr_cur.display_size,
                                                    description_size =>lseg_gl_segs.description_size,
                                                    concat_size      =>25,
                                                    lov_prompt       =>c_rep_attr_cur.form_above_prompt,
                                                    window_prompt    => c_rep_attr_cur.form_left_prompt);
                      --Enable SEGMENT_ATTRIBUTE columns
                      BEGIN
                      fnd_flex_key_api.enable_column
                                      (lflx_glat_flex,lseg_att_new_seg.column_name);
                      EXCEPTION WHEN no_data_found THEN
                      null;
                      END;
                 --Add the Segments
                 fnd_flex_key_api.add_segment(flexfield =>lflx_glat_flex,
                                              structure =>lstr_glat_struc,
                                              segment   =>lseg_att_new_seg);
              ln_seg_num:=ln_seg_num+1;
            END LOOP;
         END;
         --
         -- increment the counter
         --
         ln_segs_ctr:=ln_segs_ctr+1;
    END LOOP;
    -----------------------------------------
    -- Add the qualifiers for each segment
    -----------------------------------------
    BEGIN
         fnd_flex_key_api.get_segments(flexfield=>lflx_glat_flex,
                                       structure=>lstr_glat_struc,
                                       nsegments=>ln_glat_nsegs,
                                       segments=>llst_glat_seg_list);


         ln_glat_segs_ctr := 1;
         WHILE ln_glat_segs_ctr<=ln_glat_nsegs   LOOP
              lseg_glat_segs:=fnd_flex_key_api.find_segment(lflx_glat_flex,
                                                            lstr_glat_struc,
                                                            llst_glat_seg_list(ln_glat_segs_ctr));
              FOR cv_seg_attr_cur in seg_attr_cur(p_coa_id,
                                                  'GL#',
                                                  101,
                                                  lseg_glat_segs.column_name) LOOP
                  IF ln_flex_attr_flag=0 THEN
                       fnd_flex_key_api.add_flex_qualifier
                              (flexfield     =>lflx_glat_flex,
                               qualifier_name=>cv_seg_attr_cur.segment_attribute_type,
                               prompt        =>cv_seg_attr_cur.segment_prompt,
                               description   =>cv_seg_attr_cur.description,
                               global_flag   =>cv_seg_attr_cur.global_flag,
                               required_flag =>cv_seg_attr_cur.required_flag,
                               unique_flag   =>cv_seg_attr_cur.unique_flag);
                  END IF;
                  fnd_flex_key_api.assign_qualifier
                              (flexfield     =>lflx_glat_flex,
                               structure=>lstr_glat_struc,
                               segment=>lseg_glat_segs,
                               flexfield_qualifier=>cv_seg_attr_cur.segment_attribute_type,
                               enable_flag=>cv_seg_attr_cur.attribute_value);
              END LOOP;
              ln_flex_attr_flag:=1;
              ln_glat_segs_ctr := ln_glat_segs_ctr+1;
        END LOOP;
    END;

    -- Bug 3813504 .. Start

    DECLARE
	CURSOR c_other_coas IS
	   SELECT id_flex_num
	   FROM fnd_id_flex_structures_vl
	   WHERE application_id = 101
	     AND id_flex_code = 'GLAT'
	     AND id_flex_num <> p_coa_id;

    BEGIN
	fnd_file.put_line(fnd_file.log, 'Assigning flexfield qualifiers for other chart of accounts...');
	FOR coa_cntr IN c_other_coas
	LOOP
	    fnd_file.put_line(fnd_file.log, 'Processing chart of account : '||coa_cntr.id_flex_num);
	    BEGIN
	        lstr_glat_struc:=fnd_flex_key_api.find_structure
                                                (flexfield       => lflx_glat_flex,
                                                 structure_number=> coa_cntr.id_flex_num);

                fnd_flex_key_api.get_segments(flexfield=>lflx_glat_flex,
                                              structure=>lstr_glat_struc,
                                              nsegments=>ln_glat_nsegs,
                                              segments=>llst_glat_seg_list);

                ln_glat_segs_ctr := 1;
                WHILE ln_glat_segs_ctr <= ln_glat_nsegs   LOOP
                     lseg_glat_segs:=fnd_flex_key_api.find_segment(lflx_glat_flex,
                                                                   lstr_glat_struc,
                                                                   llst_glat_seg_list(ln_glat_segs_ctr));
                     FOR cv_seg_attr_cur in seg_attr_cur(coa_cntr.id_flex_num,
                                                         'GL#',
                                                         101,
                                                         lseg_glat_segs.column_name)
		     LOOP

                        fnd_flex_key_api.assign_qualifier
                                    (flexfield     =>lflx_glat_flex,
                                     structure=>lstr_glat_struc,
                                     segment=>lseg_glat_segs,
                                     flexfield_qualifier=>cv_seg_attr_cur.segment_attribute_type,
                                     enable_flag=>cv_seg_attr_cur.attribute_value);
                     END LOOP;
                     ln_flex_attr_flag:=1;
                     ln_glat_segs_ctr := ln_glat_segs_ctr+1;
                END LOOP;
	    EXCEPTION
	        WHEN OTHERS THEN
		    fnd_file.put_line(fnd_file.log,
				      'Chart of account : '||coa_cntr.id_flex_num||' qualifier assignment failed');
	    END;
	END LOOP;
    END;

    -- Bug 3813504 .. End

    -------------------
    --Log file Messages
    -------------------
    commit;
    fnd_file.put_line(FND_FILE.LOG,'Successful completion of Preparation Program');
    fnd_file.put_line(FND_FILE.LOG,'Chart Of Accounts:  '||p_coa_id );
    fnd_file.put_line(FND_FILE.LOG,'User ID          :  '||ln_userid );
    ------------------------------
    --Exception for the main Block
    ------------------------------
    EXCEPTION
        WHEN lexp_error THEN
            fnd_file.put_line(FND_FILE.LOG,'Program Completed With Error ');
            fnd_file.put_line(FND_FILE.LOG,'ERROR :'||lc_err_message);
             retcode := -1;
             errbuf := null;
        WHEN others THEN
            lc_api_message:=fnd_flex_key_api.message;
            fnd_file.put_line(FND_FILE.LOG,'Error:'||substr(lc_api_message,1,250));
            retcode := -1;
            errbuf := null;
  END gl_preparation ;

  procedure gl_history( retcode	     OUT NOCOPY    VARCHAR2,
    		        errbuf	     OUT NOCOPY     VARCHAR2,
  			p_chart_of_accounts_id 	IN NUMBER,
  		 	p_segment_name 	      	IN VARCHAR2,
  		 	p_denormalized_segment  IN VARCHAR2) is

     --
     lc_select_stmt             varchar2(2000);
     lc_sql_stmt                varchar2(10000);
     --
     lc_segment_name            varchar2(30);
     lc_p_segment_name          varchar2(30);
     lc_parent_seg_name         varchar2(30);
     lc_p_denorm_seg            varchar2(30);
     --
     ln_p_coa_id                number;
     ln_params                  number;
     li_dummy                   integer;
     li_dummy1                  integer;
     --
     ln_flex_value_set_id       number(10);
     lc_attribute_num           varchar2(30);
     ln_table_id                number(10);
     lc_attr_seg_name           varchar2(30);
     ln_segment_num             number(3);
     lc_attr_segment_name       varchar2(30);
     lc_validation_type         varchar2(1);
     li_cursor_id               integer ;
     li_cursor_id2              integer ;
     lc_application_column_name varchar2(30);
     lc_val_table_name          varchar2(30);
     lc_seg_column_val_name     varchar2(30);
     --
     lexp_error                 exception;
     lc_err_message             varchar2(200);
     --
     ln_last_updated_by         number;
     ln_userid                  number;
     lc_rep_profile             varchar2(12);
     ---------------------------
     -- For FND_INSTALLATION API
     ---------------------------
     lc_int_status       varchar2(10);
     lc_int_industry     varchar2(10);
     lc_int_schema       varchar2(10);
     ---------------------------
     --  INDUSTRY profile option
     ---------------------------
     lp_user_id	     	number;
     lp_user_resp_id 	number;
     lp_resp_appl_id 	number;
     l_defined	     	boolean;


BEGIN
     ----------------------------------------------------------------------
     --Perform the Validation to Check for the Reporting Attributes Profile
     ----------------------------------------------------------------------
     BEGIN
          fnd_profile.get('USER_ID',ln_userid);
          ln_last_updated_by := to_number(ln_userid);
          IF ln_userid is NULL THEN
              lc_err_message := 'The Value for the Profile Option: USERID is NULL ';
              RAISE lexp_error;
          END IF;
          --
          fnd_profile.get('ATTRIBUTE_REPORTING',lc_rep_profile);
          --
          IF lc_rep_profile = 'N' THEN
              lc_err_message := 'The Value for the Profile Option: ATTRIBUTE REPORTING is not set ';
              RAISE lexp_error;
          END IF;


          -- The installation info is now implemented as a profile option (INDUSTRY).

          -- Get Calling Application ID / Responsibility ID / User ID

          lp_resp_appl_id := FND_GLOBAL.RESP_APPL_ID;
          lp_user_resp_id := FND_GLOBAL.RESP_ID;
          lp_user_id      := FND_GLOBAL.USER_ID;

          FND_PROFILE.GET_SPECIFIC('INDUSTRY',
                             lp_user_id,
                             lp_user_resp_id,
                             lp_resp_appl_id,
                             lc_int_industry,
                             l_defined);

          IF not l_defined then
             IF fnd_installation.get_app_info( application_short_name=>'SQLGL'
                                          ,status=>lc_int_status
                                          ,industry=>lc_int_industry
                                          ,oracle_schema=>lc_int_schema) THEN

		IF lc_int_industry <> 'G' THEN
                    lc_err_message := 'Oracle Government Ledger is not Installed';
                    RAISE lexp_error;
                END IF;

             END IF;
          ELSE
             IF lc_int_industry <> 'G' THEN
                 lc_err_message := 'Oracle Government Ledger is not Installed';
                 RAISE lexp_error;
             END IF;

          END IF;

     END;
     ------------------------------------
     --Assign parameter to the variables
     --Check the values of the parameters
     ------------------------------------
     BEGIN
          ln_p_coa_id := p_chart_of_accounts_id;
          lc_p_segment_name := p_segment_name;
          lc_p_denorm_seg :=p_denormalized_segment;
          --
          IF (lc_p_segment_name IS NULL) AND (lc_p_denorm_seg IS NULL) THEN
              ln_params := 2;
          ELSIF (lc_p_segment_name IS NOT NULL) AND (lc_p_denorm_seg IS NOT NULL) THEN
              ln_params := 4;
          ELSE
              lc_err_message:='Incorrect number of Parameters';
              RAISE lexp_error;
          END IF;
          ----------------------------
          --Start the cursor statement
          ----------------------------

          IF ln_params = 2 THEN
             lc_select_stmt:=
                'SELECT nvl(attr.flex_value_set_id,0),
                attr.attribute_num,
                attr.table_id,
                attr.application_column_name,
                attr.segment_name,
                attr.segment_num,
                valset.validation_type,
                attr.attr_segment_name
                FROM   fnd_seg_rpt_attributes attr,
                       fnd_flex_value_sets valset
                WHERE  valset.flex_value_set_id = attr.flex_value_set_id
                AND    attr.id_flex_num        = :ln_p_coa_id ';
         ELSE
            lc_select_stmt:=
               'SELECT nvl(attr.flex_value_set_id,0),
               attr.attribute_num,
               attr.table_id,
               attr.application_column_name,
               attr.segment_name,
               attr.segment_num,
               valset.validation_type
               FROM   fnd_seg_rpt_attributes attr,
                      fnd_flex_value_sets valset
               WHERE  valset.flex_value_set_id = attr.flex_value_set_id
               AND    attr.id_flex_num        = :ln_p_coa_id '||
               'AND    attr.segment_name       = :lc_p_segment_name '||
               'AND    attr.attr_segment_name  = :lc_p_denorm_seg ';
        END IF;
     END;
     --
     BEGIN
         --------------------------------
         --Open the cursor for attributes
         --------------------------------
         li_cursor_id :=DBMS_SQL.OPEN_CURSOR;
         DBMS_SQL.PARSE(li_cursor_id,lc_select_stmt,DBMS_SQL.v7);
         dbms_sql.bind_variable(li_cursor_id, ':ln_p_coa_id',ln_p_coa_id);
         IF ln_params <> 2  THEN
           dbms_sql.bind_variable(li_cursor_id, ':lc_p_segment_name',lc_p_segment_name);
           dbms_sql.bind_variable(li_cursor_id, ':lc_p_denorm_seg',lc_p_denorm_seg);
         END IF;

         -----------------------------------------
         --Assign variables for the cursor columns
         -----------------------------------------
         IF ln_params = 2 THEN
              DBMS_SQL.DEFINE_COLUMN(li_cursor_id,1,ln_flex_value_set_id);
              DBMS_SQL.DEFINE_COLUMN(li_cursor_id,2,lc_attribute_num,30);
              DBMS_SQL.DEFINE_COLUMN(li_cursor_id,3,ln_table_id);
              DBMS_SQL.DEFINE_COLUMN(li_cursor_id,4,lc_application_column_name,30);
              DBMS_SQL.DEFINE_COLUMN(li_cursor_id,5,lc_segment_name,30);
              DBMS_SQL.DEFINE_COLUMN(li_cursor_id,6,ln_segment_num);
              DBMS_SQL.DEFINE_COLUMN(li_cursor_id,7,lc_validation_type,1);
              DBMS_SQL.DEFINE_COLUMN(li_cursor_id,8,lc_attr_segment_name,30);
         ELSE
              DBMS_SQL.DEFINE_COLUMN(li_cursor_id,1,ln_flex_value_set_id);
              DBMS_SQL.DEFINE_COLUMN(li_cursor_id,2,lc_attribute_num,30);
              DBMS_SQL.DEFINE_COLUMN(li_cursor_id,3,ln_table_id);
              DBMS_SQL.DEFINE_COLUMN(li_cursor_id,4,lc_application_column_name,30);
              DBMS_SQL.DEFINE_COLUMN(li_cursor_id,5,lc_segment_name,30);
              DBMS_SQL.DEFINE_COLUMN(li_cursor_id,6,ln_segment_num);
              DBMS_SQL.DEFINE_COLUMN(li_cursor_id,7,lc_validation_type,1);
         END IF;
         -----------------------------------
         --Execute the cursor for attributes
         -----------------------------------
         li_dummy:=DBMS_SQL.EXECUTE(li_cursor_id);
         --
         -----------------------------------------
         --Start building the the update statement
         -----------------------------------------
         lc_sql_stmt:='UPDATE gl_code_combinations glcc SET ';

         LOOP
              -------------------------------
              --Fetch each row for attributes
              -------------------------------
              IF DBMS_SQL.FETCH_ROWS(li_cursor_id) = 0 THEN
                   EXIT;
              END IF;
              IF ln_params=2 THEN
                   DBMS_SQL.COLUMN_VALUE(li_cursor_id,1,ln_flex_value_set_id);
                   DBMS_SQL.COLUMN_VALUE(li_cursor_id,2,lc_attribute_num);
                   DBMS_SQL.COLUMN_VALUE(li_cursor_id,3,ln_table_id);
                   DBMS_SQL.COLUMN_VALUE(li_cursor_id,4,lc_application_column_name);
                   DBMS_SQL.COLUMN_VALUE(li_cursor_id,5,lc_segment_name);
                   DBMS_SQL.COLUMN_VALUE(li_cursor_id,6,ln_segment_num);
                   DBMS_SQL.COLUMN_VALUE(li_cursor_id,7,lc_validation_type);
                   DBMS_SQL.COLUMN_VALUE(li_cursor_id,8,lc_attr_segment_name);
              ELSE
                   DBMS_SQL.COLUMN_VALUE(li_cursor_id,1,ln_flex_value_set_id);
                   DBMS_SQL.COLUMN_VALUE(li_cursor_id,2,lc_attribute_num);
                   DBMS_SQL.COLUMN_VALUE(li_cursor_id,3,ln_table_id);
                   DBMS_SQL.COLUMN_VALUE(li_cursor_id,4,lc_application_column_name);
                   DBMS_SQL.COLUMN_VALUE(li_cursor_id,5,lc_segment_name);
                   DBMS_SQL.COLUMN_VALUE(li_cursor_id,6,ln_segment_num);
                   DBMS_SQL.COLUMN_VALUE(li_cursor_id,7,lc_validation_type);
              END IF;

              ----------------------------------
              --If the validation is independent
              ----------------------------------
              IF (lc_validation_type = 'I' OR lc_validation_type='D') THEN
                   IF ln_params=2 THEN
                        lc_sql_stmt:=lc_sql_stmt||lc_attr_segment_name;
                   ELSE
                        lc_sql_stmt:=lc_sql_stmt||lc_p_denorm_seg;
                   END IF;
                   --
                   lc_sql_stmt :=lc_sql_stmt||'=(SELECT '|| lc_attribute_num||
                                           ' FROM fnd_flex_values ffval'||
                                           ' WHERE flex_value_set_id = ' ||ln_flex_value_set_id||
                                           ' AND  ffval.flex_value = glcc.'||lc_segment_name;
                   --
                   IF lc_validation_type = 'D' THEN
                        SELECT application_column_name
                        INTO lc_parent_seg_name
                        FROM fnd_id_flex_segments
                        WHERE id_flex_code = 'GLAT'
                          AND flex_value_set_id =
                             (SELECT parent_flex_value_set_id
                             FROM fnd_flex_value_sets
                             WHERE flex_value_set_id = ln_flex_value_set_id);
                             --
                             IF lc_parent_seg_name IS NULL THEN
                                 lc_err_message:='The Parent Seg name is null for the Dependent Value Set';
                                 RAISE lexp_error;
                             END IF;
                        --
                        lc_sql_stmt :=lc_sql_stmt||' AND ffval.parent_flex_value_low = glcc.'||lc_parent_seg_name;
                  END IF;
              END IF;
              -------------------------------------
              --If the validation is based on table
              -------------------------------------
              IF lc_validation_type = 'F' THEN
                  SELECT user_table_name
                  INTO  lc_val_table_name
                  FROM   fnd_tables
                  WHERE  application_id =  101
                  AND    table_id       = ln_table_id;
                  --
                  SELECT value_column_name
                  INTO  lc_seg_column_val_name
                  FROM  fnd_flex_validation_tables
                  WHERE flex_value_set_id = ln_flex_value_set_id;
                  --
                  IF ln_params = 2 THEN
                      lc_sql_stmt:=lc_sql_stmt||lc_attr_segment_name;
                  ELSE
                      lc_sql_stmt:=lc_sql_stmt||lc_p_denorm_seg;
                  END IF;
                  lc_sql_stmt :=lc_sql_stmt||' = (SELECT '|| lc_attr_seg_name||
                                          ' FROM '||  lc_val_table_name||
                                          ' VAL WHERE VAL.'|| lc_seg_column_val_name||
                                          '= glcc.'|| lc_segment_name;
              END IF;
              lc_sql_stmt:=lc_sql_stmt||'),';

          END LOOP;

          -----------------------------------------
          --Append who columns for update statement
          -----------------------------------------
          lc_sql_stmt := lc_sql_stmt|| 'LAST_UPDATE_DATE = sysdate,'||
                                       'LAST_UPDATED_BY  = '||ln_last_updated_by||
				       ' WHERE CHART_OF_ACCOUNTS_ID = :ln_p_coa_id ';

          ----------------------------------------------
          --Open, Parse and Execute the Update statement
          ----------------------------------------------
          li_cursor_id2:=DBMS_SQL.OPEN_CURSOR;
	  --
          DBMS_SQL.PARSE(li_cursor_id2,lc_sql_stmt,DBMS_SQL.v7);
          dbms_sql.bind_variable(li_cursor_id2, ':ln_p_coa_id',ln_p_coa_id);
          --
          li_dummy1:=DBMS_SQL.EXECUTE(li_cursor_id2);
          --
          DBMS_SQL.CLOSE_CURSOR(li_cursor_id);
          --

          COMMIT;

          --
          fnd_file.put_line(FND_FILE.LOG,'Historical Program successfully completed');
          fnd_file.put_line(FND_FILE.LOG,'User ID :'||ln_userid);
          fnd_file.put_line(FND_FILE.LOG,'Date    :'||sysdate);
          fnd_file.put_line(FND_FILE.LOG,'COA ID  :'||ln_p_coa_id);
    END;
    EXCEPTION
    WHEN lexp_error THEN
          fnd_file.put_line(FND_FILE.LOG,'Program Completed With Error ');
          fnd_file.put_line(FND_FILE.LOG,'Error : '||lc_err_message);
          retcode := -1;
          errbuf := null;
    WHEN others THEN
          fnd_file.put_line(FND_FILE.LOG,'Error : '||substr(SQLERRM,1,70));
          retcode := -1;
          errbuf := null;
 END gl_history;

END GL_REP_ATTRIBUTES;

/
