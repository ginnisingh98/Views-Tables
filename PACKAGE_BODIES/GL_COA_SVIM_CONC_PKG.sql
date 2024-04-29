--------------------------------------------------------
--  DDL for Package Body GL_COA_SVIM_CONC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_COA_SVIM_CONC_PKG" AS
/* $Header: GLSVICOB.pls 120.1.12010000.1 2009/12/16 11:50:41 sommukhe noship $ */
  /******************************************************************
  Created By         :Somnath Mukherjee
  Date Created By    : 01-AUG-2008
  Purpose            :
  Known limitations,
  enhancements,
  remarks            :
  Change History
  Who       When        What
  ******************************************************************/

  PROCEDURE gl_coa_svim_process(
    errbuf OUT NOCOPY VARCHAR2,
    retcode OUT NOCOPY NUMBER,
    p_batch_number IN VARCHAR2
   )
    AS
    /**********************************************************
    Created By : sommukhe
    Date Created By : 01-AUG-2008
    Purpose : For COA Segment values import
    Know limitations, enhancements or remarks

    Change History
    Who                When                 What
   (reverse chronological order - newest change first)
   ***************************************************************/

    -- Fnd Flex val  Interface Table cursor

       CURSOR c_gl_flex_values IS
         SELECT *
         FROM GL_IMP_COA_SEG_VAL_INTERFACE
	 WHERE BATCH_NUMBER = p_batch_number
	 AND STATUS = 'N'
	 ORDER BY SEG_VAL_INT_ID;

  -- Fnd Flex Val Interface Table cursor

       CURSOR c_gl_flex_values_nh IS
         SELECT *
         FROM GL_IMP_COA_NORM_HIER_INTERFACE
	 WHERE BATCH_NUMBER = p_batch_number
	 AND STATUS = 'N'
	 ORDER BY NORM_HIER_INT_ID;



    -- To  collect the statistics of the interface tables
	TYPE tabnames IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;
        tablenames_tbl tabnames;


        l_n_chld_cntr     NUMBER(7);
        l_c_return_status VARCHAR2(1);
        l_n_msg_count     NUMBER(10);
        l_c_msg_data      VARCHAR2(2000);
        l_n_msg_num       fnd_new_messages.message_number%TYPE;
        l_c_msg_txt       fnd_new_messages.message_text%TYPE;
        l_c_msg_name      fnd_new_messages.message_name%TYPE;
        l_appl_name       VARCHAR2(30);


        l_n_request_id     NUMBER(15,0);
        l_n_prog_appl_id   NUMBER(15,0);
        l_n_prog_id        NUMBER(15,0);
        l_d_prog_upd_dt    DATE;
        p_head             BOOLEAN ;
        l_ret_status       BOOLEAN ;  -- Holds return status, TRUE if all the attempted records to import result in Error.

        l_b_print_row_heading BOOLEAN ;  -- Use for logging the row_head

	v_gl_flex_values_tbl			 gl_coa_seg_val_imp_pub.gl_flex_values_tbl_type;
	v_gl_flex_values_nh_tbl			 gl_coa_seg_val_imp_pub.gl_flex_values_nh_tbl_type;

	l_gl_flex_values_status	                VARCHAR2(1);
	l_gl_flex_values_nh_status	        VARCHAR2(1);


    /* Procedure to get messages */
    PROCEDURE get_message(p_c_msg_name VARCHAR2,p_n_msg_num OUT NOCOPY NUMBER,p_c_msg_txt OUT NOCOPY VARCHAR2) AS

       CURSOR c_msg(cp_c_msg_name fnd_new_messages.message_name%TYPE ) IS
         SELECT
           message_number,
           message_text
         FROM   fnd_new_messages
         WHERE  application_id=101
	 AND    language_code = USERENV('LANG')
	 AND    message_name=cp_c_msg_name;

         rec_c_msg         c_msg%ROWTYPE;
     BEGIN
       OPEN c_msg(p_c_msg_name);
       FETCH c_msg INTO rec_c_msg;
       IF c_msg%FOUND THEN
         p_n_msg_num := rec_c_msg.message_number;
         p_c_msg_txt := rec_c_msg.message_text;
       ELSE
         p_c_msg_txt := p_c_msg_name;
       END IF;
       CLOSE c_msg;
     END get_message;

    /* Procedure to write log file */
    PROCEDURE log_file(p_c_text VARCHAR2,p_c_type VARCHAR2) AS
      /* different types are P -> fnd_file.put, L-> fnd_file.put_line,N -> fnd_file.new_line */
    BEGIN

      IF p_c_type = 'P' THEN
        fnd_file.put(fnd_file.log,p_c_text);
      ELSIF p_c_type = 'L' THEN
        fnd_file.put_line(fnd_file.log,p_c_text);
      ELSIF p_c_type = 'N' THEN
        fnd_file.new_line(fnd_file.log);
      END IF;
    END log_file;

        /* Procedure to char - n times */
    PROCEDURE print_char(p_n_count NUMBER,p_c_char VARCHAR2) AS
    BEGIN
      FOR I IN 1..p_n_count
      LOOP
        log_file(p_c_char,'P');
      END LOOP;
    END print_char;

    /* Get message from Message Stack */

    FUNCTION get_msg_from_stack(l_n_msg_count NUMBER) RETURN VARCHAR2 AS
      l_c_msg VARCHAR2(3000);
      l_c_msg_name fnd_new_messages.message_name%TYPE;
    BEGIN
      l_c_msg := FND_MSG_PUB.GET(p_msg_index => l_n_msg_count, p_encoded => 'T');
      FND_MESSAGE.SET_ENCODED (l_c_msg);
      FND_MESSAGE.PARSE_ENCODED(FND_MESSAGE.GET_ENCODED,l_appl_name, l_c_msg_name);
      RETURN l_c_msg_name;
    END get_msg_from_stack;




  BEGIN /* Main Begin */
     -- Initializing the values
     p_head                := TRUE;
     l_ret_status          := TRUE;  -- Holds return status, TRUE if the attempted records to import result in Error.
     l_b_print_row_heading := TRUE;  -- Use for logging the row_head

     -- Set the default status as success
    retcode := 0;

     /* Setting concurrent program values */

    l_n_request_id := fnd_global.conc_request_id;
    l_n_prog_appl_id := fnd_global.prog_appl_id;
    l_n_prog_id := fnd_global.conc_program_id;
    l_d_prog_upd_dt := SYSDATE;
    IF l_n_request_id = -1 THEN
      l_n_request_id := NULL;
      l_n_prog_appl_id := NULL;
      l_n_prog_id := NULL;
      l_d_prog_upd_dt := NULL;
    END IF;


    /******************Begin Fnd Flex Val **********************/

           l_n_chld_cntr :=1;

           FOR rec_c_gl_flex_values IN c_gl_flex_values
           LOOP

            --print_heading;

             v_gl_flex_values_tbl(l_n_chld_cntr).value_set_name := rec_c_gl_flex_values.value_set_name;
             v_gl_flex_values_tbl(l_n_chld_cntr).flex_value := rec_c_gl_flex_values.flex_value;
             v_gl_flex_values_tbl(l_n_chld_cntr).flex_desc := rec_c_gl_flex_values.flex_desc;
             v_gl_flex_values_tbl(l_n_chld_cntr).parent_flex_value := rec_c_gl_flex_values.parent_flex_value;
             v_gl_flex_values_tbl(l_n_chld_cntr).summary_flag := rec_c_gl_flex_values.summary_flag;
             v_gl_flex_values_tbl(l_n_chld_cntr).roll_up_group  := rec_c_gl_flex_values.roll_up_group;
             v_gl_flex_values_tbl(l_n_chld_cntr).hierarchy_level := rec_c_gl_flex_values.hierarchy_level;
             v_gl_flex_values_tbl(l_n_chld_cntr).allow_budgeting := rec_c_gl_flex_values.allow_budgeting;
	     v_gl_flex_values_tbl(l_n_chld_cntr).allow_posting := rec_c_gl_flex_values.allow_posting;
	     v_gl_flex_values_tbl(l_n_chld_cntr).account_type := rec_c_gl_flex_values.account_type;
	     v_gl_flex_values_tbl(l_n_chld_cntr).reconcile := rec_c_gl_flex_values.reconcile;
 	     v_gl_flex_values_tbl(l_n_chld_cntr).third_party_control_account := rec_c_gl_flex_values.third_party_control_account;
	     v_gl_flex_values_tbl(l_n_chld_cntr).enabled_flag := rec_c_gl_flex_values.enabled_flag;
	     v_gl_flex_values_tbl(l_n_chld_cntr).effective_from := rec_c_gl_flex_values.effective_from;
	     v_gl_flex_values_tbl(l_n_chld_cntr).effective_to := rec_c_gl_flex_values.effective_to;
	     v_gl_flex_values_tbl(l_n_chld_cntr).interface_id := rec_c_gl_flex_values.seg_val_int_id;


             l_n_chld_cntr := l_n_chld_cntr+1;

           END LOOP;

          /******************End Fnd Flex Val **********************/


          /******************Begin Fnd Flex Val norm Hierarchy******/

           l_n_chld_cntr :=1;

           FOR rec_c_gl_flex_values_nh IN c_gl_flex_values_nh
           LOOP

            --print_heading;

             v_gl_flex_values_nh_tbl(l_n_chld_cntr).value_set_name := rec_c_gl_flex_values_nh.value_set_name;
             v_gl_flex_values_nh_tbl(l_n_chld_cntr).parent_flex_value := rec_c_gl_flex_values_nh.parent_flex_value;
             v_gl_flex_values_nh_tbl(l_n_chld_cntr).range_attribute := rec_c_gl_flex_values_nh.range_attribute;
             v_gl_flex_values_nh_tbl(l_n_chld_cntr).child_flex_value_low := rec_c_gl_flex_values_nh.child_flex_value_low;
             v_gl_flex_values_nh_tbl(l_n_chld_cntr).child_flex_value_high := rec_c_gl_flex_values_nh.child_flex_value_high;
             v_gl_flex_values_nh_tbl(l_n_chld_cntr).interface_id := rec_c_gl_flex_values_nh.norm_hier_int_id;

             l_n_chld_cntr := l_n_chld_cntr+1;

           END LOOP;

          /******************End Fnd Flex Val norm Hierarchy**********************/



         /* Call to Private API  */

           gl_coa_segment_val_pvt.coa_segment_val_imp
	    (
	      p_api_version                   => 1.0,
	      p_init_msg_list                 => FND_API.G_TRUE,
	      p_commit                        => FND_API.G_TRUE,
	      p_validation_level              => FND_API.G_VALID_LEVEL_FULL,
	      x_return_status	              => l_c_return_status,
	      x_msg_count	              => l_n_msg_count,
	      x_msg_data	              => l_c_msg_data,
	      p_gl_flex_values_tbl	      => v_gl_flex_values_tbl,
	      p_gl_flex_values_nh_tbl	      => v_gl_flex_values_nh_tbl,
	      p_gl_flex_values_status	      => l_gl_flex_values_status,
	      p_gl_flex_values_nh_status      => l_gl_flex_values_nh_status
	     );
         /* -----------------------------*/

            /* Error out if none of the tables have data */

            IF l_n_msg_count = 1 THEN
              IF get_msg_from_stack(l_n_msg_count) = 'GL_COA_DATA_NOT_PASSED' THEN
                get_message('GL_COA_SVI_DATA_NOT_PASSED',l_n_msg_num,l_c_msg_txt);
                log_file(l_c_msg_txt,'L');
                retcode := 2;
                RETURN;
              END IF;
            END IF;

            IF l_ret_status AND l_c_return_status = 'S' THEN
              l_ret_status := FALSE;
            END IF;

          /* -----------------------------------------------*/


          /******************Begin Fnd Flex Val Log and Error**********************/
             l_b_print_row_heading := TRUE;
             IF v_gl_flex_values_tbl.EXISTS(1) THEN


               FOR i IN 1..v_gl_flex_values_tbl.LAST
               LOOP
                 /* Update the interface table with the status*/

                   UPDATE GL_IMP_COA_SEG_VAL_INTERFACE
                    SET status = v_gl_flex_values_tbl(i).status
                   WHERE batch_number=p_batch_number
                   AND seg_val_int_id = v_gl_flex_values_tbl(i).interface_id;

		 IF v_gl_flex_values_tbl(i).status = 'S'  THEN
                /* Write into log file */
                  NULL;
                 ELSIF v_gl_flex_values_tbl(i).status = 'E' THEN
                   NULL;
                 /* Write into log file */
                   FOR l_curr_num IN v_gl_flex_values_tbl(i).msg_from..v_gl_flex_values_tbl(i).msg_to
                   LOOP
                     l_c_msg_name := get_msg_from_stack(l_curr_num);
                     get_message(l_c_msg_name,l_n_msg_num,l_c_msg_txt);
                     l_c_msg_txt := fnd_msg_pub.get(l_curr_num,'F');

	             INSERT INTO GL_IMP_COA_ERR_INTERFACE
			      (
				err_message_id,
				int_table_name,
				interface_id,
				message_num,
				message_text,
				created_by,
				creation_date,
				last_updated_by,
				last_update_date,
				last_update_login,
				request_id,
				program_application_id,
				program_id,
				program_update_date)
			     VALUES
			      (
				gl_imp_coa_err_interface_s.nextval,
				'GL_IMP_COA_SEG_VAL_INTERFACE',
				v_gl_flex_values_tbl(i).interface_id,
				l_n_msg_num,
				l_c_msg_txt,
				NVL(fnd_global.user_id,-1),
				SYSDATE,
				NVL(fnd_global.user_id,-1),
				SYSDATE,
				NVL(fnd_global.login_id,-1),
				l_n_request_id,
				l_n_prog_appl_id,
				l_n_prog_id,
				l_d_prog_upd_dt
			      );
                    /* Write into log file */
                       log_file(RPAD(l_n_msg_num,15,' '),'P');
                       IF l_n_msg_num IS NULL THEN
                         print_char(15,' ');
                       END IF;
                       print_char(1,' ');
                       log_file(l_c_msg_txt,'L');

                   END LOOP; /* Messages loop */
                 END IF;
               END LOOP; /*  */
                     v_gl_flex_values_tbl.DELETE;
            END IF;

           /******************End Fnd Flex Val Log and Error***********************/

	   /******************Begin Fnd Flex Val Norm Hier Log and Error***********/
             l_b_print_row_heading := TRUE;
             IF v_gl_flex_values_nh_tbl.EXISTS(1) THEN


               FOR i IN 1..v_gl_flex_values_nh_tbl.LAST
               LOOP
                 /* Update the interface table with the status*/

                   UPDATE GL_IMP_COA_NORM_HIER_INTERFACE
                    SET status = v_gl_flex_values_nh_tbl(i).status
                   WHERE batch_number=p_batch_number
                   AND norm_hier_int_id = v_gl_flex_values_nh_tbl(i).interface_id;


		 IF v_gl_flex_values_nh_tbl(i).status = 'S'  THEN
                /* Write into log file */
                  NULL;

                 ELSIF v_gl_flex_values_nh_tbl(i).status = 'E' THEN
                   NULL;

                 /* Write into log file */
                   FOR l_curr_num IN v_gl_flex_values_nh_tbl(i).msg_from..v_gl_flex_values_nh_tbl(i).msg_to
                   LOOP
                     l_c_msg_name := get_msg_from_stack(l_curr_num);
                     get_message(l_c_msg_name,l_n_msg_num,l_c_msg_txt);
                     l_c_msg_txt := fnd_msg_pub.get(l_curr_num,'F');


	             INSERT INTO GL_IMP_COA_ERR_INTERFACE
			      (
				err_message_id,
				int_table_name,
				interface_id,
				message_num,
				message_text,
				created_by,
				creation_date,
				last_updated_by,
				last_update_date,
				last_update_login,
				request_id,
				program_application_id,
				program_id,
				program_update_date)
			     VALUES
			      (
				gl_imp_coa_err_interface_s.nextval,
				'GL_IMP_COA_NORM_HIER_INTERFACE',
				v_gl_flex_values_nh_tbl(i).interface_id,
				l_n_msg_num,
				l_c_msg_txt,
				NVL(fnd_global.user_id,-1),
				SYSDATE,
				NVL(fnd_global.user_id,-1),
				SYSDATE,
				NVL(fnd_global.login_id,-1),
				l_n_request_id,
				l_n_prog_appl_id,
				l_n_prog_id,
				l_d_prog_upd_dt
			      );

                    /* Write into log file */
                       log_file(RPAD(l_n_msg_num,15,' '),'P');
                       IF l_n_msg_num IS NULL THEN
                         print_char(15,' ');
                       END IF;
                       print_char(1,' ');
                       log_file(l_c_msg_txt,'L');

                   END LOOP; /* Messages loop */
                 END IF;
               END LOOP; /*  */
                     v_gl_flex_values_nh_tbl.DELETE;
            END IF;

          /******************End Fnd Flex Val Norm Hier Log and Error***********************/

 /* Delete successfully imported records */
            /* Delete from gl_imp_coa_seg_val_interface Interface Table */
            DELETE FROM gl_imp_coa_seg_val_interface
            WHERE status = 'P';

             /* Delete from gl_imp_coa_norm_hier_interface Interface Table */
            DELETE FROM gl_imp_coa_norm_hier_interface
            WHERE status = 'P';


/*  If none of the interface tables has not appropriate data that is to be processed, then set the message and error out */
        IF l_c_return_status IS NULL THEN
          get_message('GL_COA_SVI_DATA_NOT_PASSED',l_n_msg_num,l_c_msg_txt);
          log_file(l_c_msg_txt,'L');
          retcode := 2;
          RETURN;
	ELSE
	      print_char(80,'=');
        END IF;

        -- Set the concurrent program status to Error if the API return status is Error for all the attempted records
	COMMIT WORK;
        IF l_ret_status THEN
          retcode:=2;
        END IF;

/*Raise the Import process Completion Business event*/
	gl_business_events.raise(
	p_event_name =>'oracle.apps.gl.ChartOfAccounts.SegmentValues.completeImport',
	p_event_key => 'The Chart of Accounts Segment Values Import Program is completed',
	p_parameter_name1 => 'BATCH_NUMBER',
	p_parameter_value1 => p_batch_number,
	p_parameter_name2 => 'COMPLETION_STATUS',
	p_parameter_value2 => l_c_return_status);


     -- End of Procedure
  EXCEPTION
     WHEN OTHERS THEN
       ROLLBACK;
       retcode:=2;
       fnd_file.put_line(fnd_file.log,sqlerrm);
       errbuf := fnd_message.get_string('SQLGL','GL_COA_SVI_UNH_EXCEPTION') ;
       gl_business_events.raise(
	p_event_name =>'oracle.apps.gl.ChartOfAccounts.SegmentValues.completeImport',
	p_event_key => 'The Chart of Accounts Segment Values Import Program is completed',
	p_parameter_name1 => 'BATCH_NUMBER',
	p_parameter_value1 => p_batch_number,
	p_parameter_name2 => 'EXCEPTION',
	p_parameter_value2 => sqlerrm);

  END gl_coa_svim_process;

END gl_coa_svim_conc_pkg;

/
