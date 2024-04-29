--------------------------------------------------------
--  DDL for Package Body GCS_LEX_MAP_GL_APPLY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GCS_LEX_MAP_GL_APPLY_PKG" AS
/* $Header: gcsgllxb.pls 115.9 2003/11/06 04:50:25 mikeward noship $ */


  --
  -- Exceptions
  --
  GCS_LEX_MAP_GL_FAILED		EXCEPTION;

  PROCEDURE Apply_Transformation(	x_errbuf	OUT NOCOPY VARCHAR2,
					x_retcode	OUT NOCOPY VARCHAR2,
					p_rule_set_id		NUMBER,
					p_source		VARCHAR2,
					p_group_id		NUMBER,
					p_auto_ji		VARCHAR2,
					p_create_sum_jou	VARCHAR2,
					p_import_dff		VARCHAR2) IS
    return_status	VARCHAR2(1);
    msg_count		NUMBER;
    msg_data		VARCHAR2(2000);

    interface_table	VARCHAR2(30);

    -- Information used for running Journal Import
    inter_run_id	NUMBER;
    sob_id		VARCHAR2(30);
    req_id		NUMBER;

    -- Cursor to get info from the gl_interface_control table concerning
    -- this run.
    CURSOR	interface_table_c IS
    SELECT	nvl(glic.interface_table_name, 'GL_INTERFACE'),
		glic.interface_run_id
    FROM	gl_interface_control glic,
		gl_je_sources src
    WHERE	glic.group_id = p_group_id
    AND		glic.je_source_name = src.je_source_name
    AND		src.user_je_source_name = p_source
    ORDER BY	glic.rowid;

    -- Cursor to check whether the Journal Import request has finished or not.
    CURSOR	ji_check_c(c_req_id NUMBER) IS
    SELECT	1
    FROM	fnd_concurrent_requests cr
    WHERE	cr.request_id = c_req_id
    AND		cr.phase_code = 'C';

    dummy	NUMBER;

    debug_mode	VARCHAR2(30);

    req_data	VARCHAR2(10); -- Used for child process control
  BEGIN
    -- Get the request data. If this is not the original run, then just
    -- exit out successfully.
    req_data := fnd_conc_global.request_data;
    IF req_data IS NOT NULL THEN
      return;
    END IF;

    FND_PROFILE.get('GL_SET_OF_BKS_ID', sob_id);
    FND_PROFILE.get('GL_DEBUG_MODE', debug_mode);

    -- Fetch the row with the given source/group_id combination.
    OPEN interface_table_c;
    FETCH interface_table_c INTO interface_table, inter_run_id;
    IF interface_table_c%NOTFOUND THEN
      CLOSE interface_table_c;
      interface_table := 'GL_INTERFACE';
      inter_run_id := null;

      -- Insert a row for this IDT and Journal Import run into the
      -- gl_interface_control table.
      INSERT INTO gl_interface_control(je_source_name, status, group_id, set_of_books_id)
      SELECT	src.je_source_name, 'S', p_group_id, sob_id
      FROM	gl_je_sources src
      WHERE	src.user_je_source_name = p_source;
    ELSE
      CLOSE interface_table_c;
    END IF;

    -- Call the IDT API to perform the transformation.
    GCS_LEX_MAP_API_PKG.apply_map(
	p_api_version		=> 1.0,
	x_return_status		=> return_status,
	x_msg_count		=> msg_count,
	x_msg_data		=> msg_data,
	p_rule_set_id		=> p_rule_set_id,
	p_staging_table_name	=> interface_table,
	p_debug_mode		=> debug_mode,
	p_filter_column_name1	=> 'GROUP_ID',
	p_filter_column_value1	=> p_group_id,
	p_filter_column_name2	=> 'USER_JE_SOURCE_NAME',
	p_filter_column_value2	=> p_source);

    -- If this failed, then update gl_interface_control so that the errored
    -- rows will show up in the JI Correction form.
    IF return_status <> FND_API.G_RET_STS_SUCCESS THEN
      UPDATE	gl_interface_control glic
      SET	glic.status = 'I'
      WHERE	rowid = (SELECT	min(rowid)
                         FROM	gl_interface_control glic2
                         WHERE	glic2.je_source_name = glic.je_source_name
                         AND	glic2.group_id = glic.group_id)
      AND	glic.je_source_name =
		(SELECT	src.je_source_name
		 FROM	gl_je_sources src
		 WHERE	src.user_je_source_name = p_source)
      AND	glic.group_id = p_group_id;
      raise gcs_lex_map_gl_failed;
    END IF;

    -- If the automatic JI option is on, then run journal import.
    IF p_auto_ji = 'Y' THEN

      -- If no interface run id has been specified, get one and insert it
      -- into gl_interface_control.
      IF inter_run_id IS NULL THEN
        SELECT	gl_journal_import_s.nextval
        INTO	inter_run_id
        FROM	dual;

        UPDATE	gl_interface_control glic
        SET	glic.interface_run_id = inter_run_id
        WHERE	rowid = (SELECT	min(rowid)
                         FROM	gl_interface_control glic2
                         WHERE	glic2.je_source_name = glic.je_source_name
                         AND	glic2.group_id = glic.group_id)
        AND	glic.je_source_name =
		(SELECT	src.je_source_name
		 FROM	gl_je_sources src
		 WHERE	src.user_je_source_name = p_source)
        AND	glic.group_id = p_group_id;
      END IF;

      -- Run Journal Import here.
      req_id := FND_REQUEST.submit_request(
        'SQLGL', 'GLLEZL', null, null, TRUE,
        to_char(inter_run_id), sob_id,
        'N', null, null, p_create_sum_jou, p_import_dff, chr(0), null, null,
        null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null
      );

      -- If the request was submitted successfully, then update the request id
      -- to be that of the journal import request.
      IF req_id <= 0 THEN
        x_errbuf := FND_MESSAGE.get;
        x_retcode := '2';
      ELSE
        -- Pause the parent so that the child can go through.
        fnd_conc_global.set_req_globals(conc_status => 'PAUSED',
					request_data => 'Y');
      END IF;
    END IF;

    return;
  EXCEPTION
    WHEN gcs_lex_map_gl_failed THEN
      FND_MESSAGE.set_name('GCS', 'GCS_IDT_GL_FAILURE');
      x_errbuf := FND_MESSAGE.get;
      x_retcode := '2';
    WHEN OTHERS THEN
      FND_MESSAGE.set_name('GCS', 'GCS_IDT_GL_UNEXPECTED');
      x_errbuf := FND_MESSAGE.get;
      x_retcode := '2';
  END Apply_Transformation;

END GCS_LEX_MAP_GL_APPLY_PKG;

/
