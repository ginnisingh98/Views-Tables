--------------------------------------------------------
--  DDL for Package Body GMF_VALIDATE_ACCOUNT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMF_VALIDATE_ACCOUNT" AS
/* $Header: gmfactvb.pls 120.1 2006/07/11 19:30:08 rseshadr noship $ */


    -- Function to log error message
    FUNCTION msg_log(
          p_message_name IN VARCHAR2,
          p_value1       IN VARCHAR2,
          p_value2       IN VARCHAR2,
          p_value3       IN VARCHAR2,
          p_value4       IN VARCHAR2,
          p_value5       IN VARCHAR2
          )
    RETURN VARCHAR2;


    -- Constant to identify from where cross-validation routine is called.
    CONC_PROGRAM		CONSTANT VARCHAR2(2) := 'C' ;


  /*#######################################################################
  #  NAME
  #    validate_segments
  #
  #  DESCRIPTION
  #    Procedure to Cross-Validate concatenated segments of Acctg Unit and
  #    Account segments of OPM.
  #
  #  NOTES
  #
  #  DEPENDENCIES
  #
  #  USAGE
  #    This procedure will be called from Subledger update program
  #    directly and from wrapper in this package.
  #
  #  HISTORY
  #    10-Jun-2002  Uday Moogala  Bug 2468906 - Created.
  #    11-Jul-2006 rseshadr Bug 5384550 - use GL# explicitly in queries
  #      against fnd_id_flex_structures
  ########################################################################*/

  PROCEDURE validate_segments(
		p_co_code		IN		gl_plcy_mst.co_code%TYPE,
		p_acctg_unit_id		IN		gl_accu_mst.acctg_unit_id%TYPE,
		p_acct_id		IN		gl_acct_mst.acct_id%TYPE,
		p_acctg_unit_no		IN		gl_accu_mst.acctg_unit_no%TYPE,
		p_acct_no		IN		gl_acct_mst.acct_no%TYPE,
		p_create_combination	IN		VARCHAR2 DEFAULT 'N',
		x_ccid			OUT NOCOPY	NUMBER,
		x_concat_seg		OUT NOCOPY	VARCHAR2,
		x_status		OUT NOCOPY	VARCHAR2,
		x_errmsg		OUT NOCOPY	VARCHAR2
		)
  IS

	--
	-- Selecting delimiter from plcy mst and flex struct as there is a chance that delimiter
	-- can be different at these two place. Using plcy delimiter to parse the concatenated
	-- segments and flex struct delimiter to pass to FND cross-validation routine.
	--

	/**
	 * rs Bug 5384550 - use GL# explicitly
	 **/
	CURSOR c_struct_dtls (p_co_code		gl_plcy_mst.co_code%TYPE)
	IS
		SELECT
			flex.application_id,
		       	flex.id_flex_code,
			flex.id_flex_num,
			plcy.segment_delimiter,
			flex.CONCATENATED_SEGMENT_DELIMITER,
			sob.chart_of_accounts_id
  		  FROM
			fnd_id_flex_structures flex,
		       	gl_sets_of_books sob,
			gl_plcy_mst plcy
 		 WHERE
		   	flex.id_flex_num	= sob.chart_of_accounts_id
		   AND 	sob.set_of_books_id 	= plcy.sob_id
		   AND 	plcy.co_code	   	= p_co_code
		   AND  flex.id_flex_code       = 'GL#'
	;

	l_acctg_unit_no			gl_accu_mst.acctg_unit_no%TYPE;
	l_acct_no			gl_acct_mst.acct_no%TYPE;
	l_coa_id			gl_sets_of_books.chart_of_accounts_id%TYPE;

	l_concat_segs			VARCHAR2(4000);
	l_concat_segs1			VARCHAR2(4000);
	l_seg_delimiter			gl_plcy_mst.segment_delimiter%TYPE;
	l_Segment_array			fnd_flex_ext.SegmentArray;
	l_segment_count			PLS_INTEGER; -- Bug xxx

	l_appl_id			fnd_application.application_id%TYPE;
	l_id_flex_code			fnd_id_flex_structures.id_flex_code%TYPE;
	l_id_flex_num			fnd_id_flex_structures.id_flex_num%TYPE;
	l_flexDelimiter			gl_plcy_mst.segment_delimiter%TYPE;

	l_ccid				NUMBER := -1;
	e_acctg_unit_not_found		EXCEPTION;
	e_acct_not_found		EXCEPTION;
	e_validation_error		EXCEPTION;

	l_operation			VARCHAR2(100);

	l_of_segments			GMF_GET_MAPPINGS.A_segment;
  BEGIN

	-- uncomment the call below to write to a local file
        -- FND_FILE.PUT_NAMES('gmfactmx.log','gmfactmx.out','/sqlcom/log/opm115m');

        --  Initialize API return status to success
        x_status := FND_API.G_RET_STS_SUCCESS;

	-- gmf_util.trace( 'Now processing Company : ' || p_co_code || '  Accu Id : ' || p_acctg_unit_id ||
			-- '  Acct Id : ' || p_acct_id, 1 );

	-- Get structure details
	OPEN c_struct_dtls(p_co_code);
	FETCH c_struct_dtls INTO l_appl_id,
				 l_id_flex_code,
				 l_id_flex_num,
				 l_seg_delimiter,
				 l_flexDelimiter,
				 l_coa_id
	;
	CLOSE c_struct_dtls;

	/*
	gmf_util.trace( '  Appl Short Name : '	|| 'SQLGL'	 	||
			'  Appl Id : ' 		|| l_appl_id 		||
                        '  Flex Code : ' 	|| l_id_flex_code 	||
                        '  Struct No : ' 	|| l_id_flex_num 	||
                        '  Seg Delimiter : ' 	|| l_seg_delimiter 	||
                        '  COA Id : ' 		|| l_coa_id, 3)
	; */

	IF (p_acctg_unit_no IS NOT NULL) THEN
		l_acctg_unit_no := p_acctg_unit_no;
	ELSE
		-- Get Accouting Unit No
		l_acctg_unit_no := get_acctg_unit_no (p_co_code, p_acctg_unit_id);

		IF (l_acctg_unit_no IS NULL) THEN
			raise e_acctg_unit_not_found;
		END IF;
	END IF;


	IF (p_acct_no IS NOT NULL) THEN
		l_acct_no := p_acct_no;
	ELSE
		-- Get Account No
		l_acct_no	:= get_acct_no (p_co_code, p_acct_id);

		IF (l_acct_no IS NULL) THEN
			raise e_acct_not_found;
		END IF;
	END IF;


	-- Concatenate segments
	l_concat_segs := l_acctg_unit_no || l_seg_delimiter || l_acct_no;

	-- gmf_util.trace( '  Concatenated Segments before parsing : ' || l_concat_segs, 2 );

	-- Parse the OPM account to set the segments based on the segment
        -- mapping of OPM and Oracle Financials
	/* Bug 2696526: replace with the next call
        *GML_ACCT_GENERATE.parse_account(
	*			v_co_code	=> p_co_code,
	*			v_account	=> l_concat_segs,	-- Concatenated segments
	*			v_type		=> 2,			-- Type of segment
	*			v_offset	=> 0,			-- offset
	*			v_segment	=> l_Segment_array, 	-- parsed segments
	*			v_no_of_seg	=> l_segment_count)	-- # of segments
	*;
	*/

        GMF_GET_MAPPINGS.parse_account(p_co_code, l_concat_segs, l_of_segments);

	for i in 1..l_of_segments.count loop
	  IF  l_of_segments(i) IS NOT NULL THEN
	    l_Segment_array(i) :=  l_of_segments(i) ;
	  END IF;
	end loop;

	-- Concatenate the values in segment array to pass it for validation

	l_concat_segs1 := FND_FLEX_EXT.concatenate_segments(
				n_segments	=> l_Segment_array.count, -- l_segment_count, Bug 2696526
				segments	=> l_Segment_array,       -- l_Segment_array, Bug 2696526
				delimiter	=> l_flexDelimiter
			  );

	-- gmf_util.trace( '  Concatenated Segments after parsing : ' || l_concat_segs1, 2 );

	--
	-- Set which operation to do. Operation should be one of these:
	--   'FIND_COMBINATION'		- Combination must already exist.
	--   'CREATE_COMBINATION'	- Combination is created if doesn't exist.
	--   'CHECK_COMBINATION'	- Checks if combination valid, doesn't create.
	--   'DEFAULT_COMBINATION'	- Returns minimal default combination.
	--   'CHECK_SEGMENTS'		- Validates segments individually.
	-- Right now we are doing following two operations.
	--

	IF (p_create_combination = 'N') THEN
		l_operation := 'CHECK_COMBINATION';
	ELSIF (p_create_combination = 'Y') THEN
		l_operation := 'CREATE_COMBINATION';
	END IF;


	-- Now call fnd function to do cross validation

	IF (FND_FLEX_KEYVAL.validate_segs(
				operation       	=> l_operation,
				appl_short_name 	=> 'SQLGL',
				key_flex_code   	=> l_id_flex_code,
				structure_number	=> l_coa_id,
				concat_segments 	=> l_concat_segs1,
				values_or_ids   	=> 'V',
				validation_date 	=> SYSDATE)
	   )
	THEN

		l_ccid := FND_FLEX_KEYVAL.combination_id;
	ELSE
		raise e_validation_error;
	END IF;


	-- Populate output variables

	x_ccid := l_ccid;

  EXCEPTION
	WHEN e_acctg_unit_not_found THEN
		x_status	:= FND_API.G_RET_STS_ERROR;
		x_errmsg	:= msg_log('GMF_CROSSVAL_ACCU_ERROR', p_acctg_unit_id, p_co_code,'','','');
	WHEN e_acct_not_found THEN
		x_status	:= FND_API.G_RET_STS_ERROR;
		x_errmsg	:= msg_log('GMF_CROSSVAL_ACCT_ERROR', p_acct_id, p_co_code,'','','');
	WHEN e_validation_error THEN
      		x_status 	:= FND_API.G_RET_STS_ERROR;
		x_concat_seg	:= substrb(l_concat_segs, 1, 240);
		x_errmsg 	:= substrb(FND_FLEX_KEYVAL.error_message, 1, 240);
		-- gmf_util.trace('  INVALID.  Message = ' || FND_FLEX_KEYVAL.error_message, 2);
  END validate_segments;


  /*#######################################################################
  #  NAME
  #    cross_validate
  #
  #  DESCRIPTION
  #    This procedure calls above Cross-Validation engine for each
  #    combination of Acctg Unit and Account segments.
  #
  #  NOTES
  #
  #  DEPENDENCIES
  #
  #  USAGE
  #    This procedure will be called from Account Mapping form and/or from
  #    Concurrent process. In case of invalid combinations, error_messages
  #    PL/sql table will be populated with error messages. Its the respon-
  #    of the calling program to fetch and display these error messages.
  #
  #  HISTORY
  #    10-Jun-2002  Uday Moogala  Bug 2468906 - Created.
  #    14-Nov-2002  Uday Moogala  Bug xxx
  #    	 Modified cursors query to go against gl_accu_map table to get the
  #	 acctg_unit_id/no. Also passing acctg_unit_no to validate procedure
  #	 to avoid call to get_accu_no function.
  #    05-Aug-2003  Venkat Chukkapalli  Bug 3080232
  #	  Added additional parameter p_acct_no to the procedure.
  ########################################################################*/

  PROCEDURE cross_validate
  (
	p_co_code		IN		gl_plcy_mst.co_code%TYPE,
	p_acct_id		IN		gl_acct_mst.acct_id%TYPE,
	p_called_from		IN		VARCHAR2,
	x_status		OUT NOCOPY	VARCHAR2,
	p_acct_no		IN		gl_acct_mst.acct_no%TYPE DEFAULT NULL
  )
  IS

	CURSOR acctg_unit (p_co_code	gl_accu_mst.co_code%TYPE)
	IS
		SELECT DISTINCT mst.acctg_unit_id, mst.acctg_unit_no   -- Bug xxx
		  FROM gl_accu_mst mst, gl_accu_map map
 		 WHERE mst.acctg_unit_id = map.acctg_unit_id
		   AND map.co_code = p_co_code
		   AND map.delete_mark = 0
		   AND mst.delete_mark = 0 ;

	l_errmsg 		VARCHAR2(4000);
	l_status 		VARCHAR2(2);

	l_concat_segs		VARCHAR2(4000);
        l_msg_text      	VARCHAR2(2000);
	l_index	 		PLS_INTEGER DEFAULT 0;	-- Bug xxx

	l_acctg_unit_no		gl_accu_mst.acctg_unit_no%TYPE;
	l_acct_no		gl_acct_mst.acct_no%TYPE;

  	error_stack		error_messages_RecType; -- will be used in concurrent program
	empty_acct_combination	acct_combination_TabType;
	empty_error_messages	error_messages_TabType;

	l_ccid			NUMBER; -- variable to hold Code Combination Id

  BEGIN

	-- uncomment the call below to write to a local file
        -- FND_FILE.PUT_NAMES('gmfactmx.log','gmfactmx.out','/sqlcom/log/opm115m');

	--  Initialize API return status to success
	x_status := FND_API.G_RET_STS_SUCCESS;

	-- remove old rows and release memory.
	errors.acct_combination := empty_acct_combination;
	errors.error_messages	:= empty_error_messages;

  	-- gmf_util.trace(msg_log('GMF_CROSSVAL_BEGIN', p_co_code, get_acct_no(p_co_code, p_acct_id)), 1, 2);

	FOR cur in acctg_unit (p_co_code)
	LOOP

		-- Bug 3080232. Changed NULL to p_acct_no for argument p_acct_no
		GMF_VALIDATE_ACCOUNT.validate_segments(
			p_co_code		=> p_co_code,
			p_acctg_unit_id		=> cur.acctg_unit_id,
			p_acct_id		=> p_acct_id,
			p_acctg_unit_no		=> cur.acctg_unit_no,
			p_acct_no		=> p_acct_no,
			p_create_combination	=> 'N',
			x_ccid			=> l_ccid,
			x_concat_seg		=> l_concat_segs,
			x_status		=> l_status,
			x_errmsg		=> l_errmsg
		);

		-- Invalid combination
		IF (l_status <> FND_API.G_RET_STS_SUCCESS) THEN 	-- Bug xxx

			-- Index for message table
			l_index := l_index + 1;

			-- Set status and load message into plsql record
			x_status 			 := l_status;
			errors.acct_combination(l_index) := l_concat_segs;
			errors.error_messages(l_index) 	 := msg_log('GMF_CROSSVAL_ERROR', l_errmsg,'','','','');

			-- print messages to stack to print it later in one shot to output file
			/* used if concurrent process is used
			* IF (p_called_from = CONC_PROGRAM) THEN
			*	error_stack.acct_combination(l_index)	:= l_concat_segs;
			*	error_stack.error_messages(l_index) 	:= l_msg_text;
			* END IF;
			*/

		END IF;

	END LOOP;

	-- Now print messages from message stack into output file
	/* used if concurrent process is used
	* IF (p_called_from = CONC_PROGRAM) THEN
	*	FOR i in 1..error_stack.error_messages.count LOOP
  	*		gmf_util.trace( error_stack.acct_combination(i) || ' ' ||
	*				error_stack.error_messages(i), 1, 2 );
	*	END LOOP;
	* END IF;
	*/

  END cross_validate;

  /*#######################################################################
  #  NAME
  #    get_accu_acct_ids
  #
  #  DESCRIPTION
  #
  #    Procedure to validate the accu and acct combination.
  #    If combination or accu/acct ids exits then returns respective ids. Otherwise,
  #    if p_create_acct = 'Y', then tries to create code combination in GL tables and
  #    creates the accu and acct in OPM tables (gl_accu_mst and gl_acct_mst)
  #    and returns accu_id and acct_id.
  #
  #  Assumptions
  #    Code Combination will be created only if dynamic inserts is ON.
  #
  #  DEPENDENCIES
  #
  #  USAGE
  #
  #  HISTORY
  #    10-Jun-2002  Uday Moogala  Bug 2468906 - Created.
  #    12-Nov-2002  Uday Moogala  Bug xxx
  #	  1. changes to return proper error messages.
  #	  2. Calling parse_ccid routine only if p_create_acct = Y and
  #	     ccid is valid.
  ########################################################################*/

  PROCEDURE get_accu_acct_ids
  (
		p_co_code		IN		gl_plcy_mst.co_code%TYPE,
		p_acctg_unit_no		IN		gl_accu_mst.acctg_unit_no%TYPE,
		p_acct_no		IN		gl_acct_mst.acct_no%TYPE,
		p_create_acct		IN		VARCHAR2 DEFAULT 'N',
		x_acctg_unit_id		OUT NOCOPY	gl_accu_mst.acctg_unit_id%TYPE,
		x_acct_id		OUT NOCOPY	gl_acct_mst.acct_id%TYPE,
		x_ccid			OUT NOCOPY	NUMBER,
		x_status		OUT NOCOPY	VARCHAR2,
		x_errmsg		OUT NOCOPY	VARCHAR2
  )
  IS

	l_errmsg 		VARCHAR2(4000);
	l_status 		VARCHAR2(2);

	l_concat_segs		VARCHAR2(4000);
	l_ccid			NUMBER; 			-- variable to hold Code Combination Id

	l_create_acct		PLS_INTEGER;

	l_opm_account		GMF_GET_MAPPINGS.opm_account;	-- pl/sql to hold accu and acct ids

	e_validation_error	EXCEPTION;
	e_invalid_combination	EXCEPTION;	-- Bug xxx
	e_invalid_parameters	EXCEPTION;	-- Bug xxx

  BEGIN

	--  Initialize API return status to success
	x_status := FND_API.G_RET_STS_SUCCESS;

	IF (p_co_code IS NULL) OR (p_acctg_unit_no IS NULL) OR (p_acct_no IS NULL) THEN
		raise e_invalid_parameters;	-- Bug xxx
	END IF;	-- Bug xxx: removed else block which was for the normal processing.

	--
	-- validate the segments and
	-- if p_create_acct = 'Y', then create the code combination in GL and
	-- return ccid
	--
	GMF_VALIDATE_ACCOUNT.validate_segments(
		p_co_code		=> p_co_code,
		p_acctg_unit_id		=> '',
		p_acct_id		=> '',
		p_acctg_unit_no		=> p_acctg_unit_no,
		p_acct_no		=> p_acct_no,
		p_create_combination	=> p_create_acct,
		x_ccid			=> l_ccid,
		x_concat_seg		=> l_concat_segs,
		x_status		=> l_status,
		x_errmsg		=> l_errmsg
	);

	-- Invalid combination
	IF (l_status <> FND_API.G_RET_STS_SUCCESS) THEN		-- Bug xxx
		raise e_validation_error;
	END IF;

	/* Replaced the following sql with the if condition -- Bug xxx
	* SELECT decode(p_create_acct, 'Y', 1, 0)
	* INTO   l_create_acct
	* FROM   dual;
	*/

	IF p_create_acct = 'Y' THEN
		l_create_acct := 1;
	ELSE
		l_create_acct := 0;
	END IF;

	--
	-- Use the l_ccid to get accu and acct ids if exists in OPM.
	-- if p_create_acct = 'Y', then create accu and acct in OPM and
	-- return ids.
	--
	IF (l_ccid > 0 and l_create_acct = 1) THEN	-- Bug xxx
		l_opm_account :=  GMF_GET_MAPPINGS.parse_ccid(
					pi_co_code 		=> p_co_code,
					pi_code_combination_id 	=> l_ccid,
					pi_create_acct 		=> l_create_acct
				  );


		x_acctg_unit_id := l_opm_account.acctg_unit_id;
		x_acct_id 	:= l_opm_account.acct_id;
		x_ccid		:= l_ccid;

		IF (l_opm_account.acctg_unit_id = -1) OR (l_opm_account.acct_id = -1) THEN
			raise e_invalid_combination;
		END IF;
	ELSIF (l_ccid <= 0 and l_create_acct = 1) THEN
		raise e_invalid_combination;
	END IF;

  EXCEPTION
	WHEN e_validation_error THEN
		x_acctg_unit_id := -1;
		x_acct_id 	:= -1;
		x_ccid		:= -1;
		x_status	:= l_status;
		x_errmsg	:= msg_log('GMF_CROSSVAL_ERROR', l_errmsg,'','','','');
	WHEN e_invalid_combination THEN
		x_status 	:= FND_API.G_RET_STS_ERROR;
		x_errmsg 	:= msg_log('GMF_CROSSVAL_INVALID_COMB', p_acct_no, p_acctg_unit_no, p_co_code,'','' );
	WHEN e_invalid_parameters THEN	-- Bug xxx
		x_status 	:= FND_API.G_RET_STS_ERROR;
		x_errmsg 	:= msg_log('GMF_CROSSVAL_INVALID_PARAMS', '', '', '', '', '');
  END get_accu_acct_ids;


  /*#######################################################################
  #  NAME
  #    get_acct_no
  #
  #  DESCRIPTION
  #    Fetches the account no for the acct id passed.
  #
  #  NOTES
  #
  #  DEPENDENCIES
  #
  #  USAGE
  #
  #  HISTORY
  #    10-Jun-2002  Uday Moogala  Bug 2468906 - Created.
  ########################################################################*/

  FUNCTION get_acct_no
  (
	p_co_code	gl_acct_mst.co_code%TYPE,
	p_acct_id	gl_acct_mst.acct_id%TYPE
  )
  RETURN VARCHAR2
  IS

	CURSOR acct_no 	(p_co_code	gl_acct_mst.co_code%TYPE,
			 p_acct_id	gl_accu_mst.acctg_unit_id%TYPE)
	IS
		SELECT
			acct_no
		  FROM
			gl_acct_mst
		 WHERE
			acct_id = p_acct_id
		   AND  co_code = p_co_code
	;

	l_acct_no	gl_acct_mst.acct_no%TYPE;

  BEGIN
	OPEN acct_no (p_co_code, p_acct_id);
	FETCH acct_no INTO l_acct_no;
	CLOSE acct_no;

	RETURN l_acct_no;

  END get_acct_no;

  /*#######################################################################
  #  NAME
  #    get_acctg_unit_no
  #
  #  DESCRIPTION
  #    Fetches the acctg unit no for the acctg unit id passed.
  #
  #  NOTES
  #
  #  DEPENDENCIES
  #
  #  USAGE
  #
  #  HISTORY
  #    10-Jun-2002  Uday Moogala  Bug 2468906 - Created.
  ########################################################################*/

  FUNCTION get_acctg_unit_no
  (
	p_co_code	gl_accu_mst.co_code%TYPE,
	p_acctg_unit_id	gl_accu_mst.acctg_unit_id%TYPE
  )
  RETURN VARCHAR2
  IS

	CURSOR accu_no 	(p_co_code		gl_accu_mst.co_code%TYPE,
			 p_acctg_unit_id	gl_accu_mst.acctg_unit_id%TYPE)
	IS
		SELECT
			acctg_unit_no
		  FROM
			gl_accu_mst
		 WHERE
			acctg_unit_id	= p_acctg_unit_id
		   AND  co_code		= p_co_code
	;

	l_acctg_unit_no	gl_accu_mst.acctg_unit_no%TYPE;

  BEGIN

	OPEN accu_no (p_co_code, p_acctg_unit_id);
	FETCH accu_no INTO l_acctg_unit_no;
	CLOSE accu_no;

	RETURN l_acctg_unit_no;

  END get_acctg_unit_no;

  /*#######################################################################
  #  NAME
  #    get_error_messages
  #
  #  DESCRIPTION
  #    Returns error message to forms, if any.
  #
  #  NOTES
  #
  #  DEPENDENCIES
  #
  #  USAGE
  #
  #  HISTORY
  #    10-Jun-2002  Uday Moogala  Bug 2468906 - Created.
  ########################################################################*/

  FUNCTION get_error_messages RETURN error_messages_RecType
  IS
  BEGIN

	IF (GMF_VALIDATE_ACCOUNT.errors.error_messages.count > 0) THEN
		RETURN (GMF_VALIDATE_ACCOUNT.errors);
	END IF;

  END get_error_messages;

  /*#######################################################################
  #  NAME
  #    msg_log
  #
  #  DESCRIPTION
  #    Retrieves the message from msg dictionary and substitutes the tokens
  #    with the non-null values passed.
  #
  #  NOTES
  #
  #  DEPENDENCIES
  #
  #  USAGE
  #
  #  HISTORY
  #    10-Jun-2002  Uday Moogala  Bug 2468906 - Created.
  ########################################################################*/

  FUNCTION msg_log(
          p_message_name IN VARCHAR2,
          p_value1       IN VARCHAR2,
          p_value2       IN VARCHAR2,
          p_value3       IN VARCHAR2,
          p_value4       IN VARCHAR2,
          p_value5       IN VARCHAR2
          )
  RETURN VARCHAR2
  IS

  BEGIN

          FND_MESSAGE.SET_NAME( 'GMF', p_message_name );

          IF( p_value1 IS NOT NULL ) THEN
                  FND_MESSAGE.SET_TOKEN( 'S1', p_value1 );
          END IF;

          IF( p_value2 IS NOT NULL ) THEN
                  FND_MESSAGE.SET_TOKEN( 'S2', p_value2 );
          END IF;

          IF( p_value3 IS NOT NULL ) THEN
                  FND_MESSAGE.SET_TOKEN( 'S3', p_value3 );
          END IF;

          IF( p_value4 IS NOT NULL ) THEN
                  FND_MESSAGE.SET_TOKEN( 'S4', p_value4 );
          END IF;

          IF( p_value5 IS NOT NULL ) THEN
                  FND_MESSAGE.SET_TOKEN( 'S5', p_value5 );
          END IF;

          RETURN (FND_MESSAGE.GET);

  END msg_log;

END gmf_validate_account;

/
