--------------------------------------------------------
--  DDL for Package Body XNP_MSG_SCHEMA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XNP_MSG_SCHEMA" AS
/* $Header: XNPMBLVB.pls 120.2 2006/02/13 07:51:31 dputhiye ship $ */

PROCEDURE check_source(p_element_id IN NUMBER,
		p_element_name IN VARCHAR2,
		p_source_type IN VARCHAR2,
		p_data_source IN VARCHAR2,
		p_data_ref IN VARCHAR2,
		x_error_code OUT NOCOPY NUMBER,
		x_error_message OUT NOCOPY VARCHAR2);

FUNCTION check_exists(p_msg_code IN VARCHAR2 ) RETURN NUMBER;

FUNCTION check_parameter_pool
	(p_element_name IN VARCHAR2,
	p_reference IN VARCHAR2) RETURN NUMBER;

FUNCTION check_if_parent(p_element_id NUMBER) RETURN NUMBER;

PROCEDURE validate (
	p_msg_code IN VARCHAR2,
	x_error_code OUT NOCOPY NUMBER,
	x_error_message OUT NOCOPY VARCHAR2
)

IS

	CURSOR get_msg_data IS
		SELECT met.name,
			met.msg_element_id,
			met.parameter_flag,
			mse.data_source,
			mse.data_source_type,
			mse.data_source_reference
		FROM xnp_msg_elements met, xnp_msg_structures mse
		WHERE met.msg_code = mse.msg_code
		AND met.msg_code = p_msg_code
                -- skilaru 03/27/2001
		-- AND met.msg_element_id IN( mse.child_element_id);
		AND met.msg_element_id = mse.child_element_id;



	l_exists NUMBER;
	l_parent NUMBER;

BEGIN

	x_error_code := 0;
	x_error_message := NULL;

	--check to see if a database object exists with the
	--same name as the message code

	l_exists := check_exists(p_msg_code) ;

	IF (l_exists <> 0) THEN
		fnd_message.set_name('XNP', 'DUPLICATE_OBJECT');
		fnd_message.set_token('NAME',p_msg_code);
		x_error_message := fnd_message.get ;
		x_error_code := xnp_errors.g_duplicate_object;
		RETURN ;
	END IF ;

	FOR rec IN get_msg_data LOOP

	-- check if the element has a parameter
	-- or alternate data source

		IF ((rec.parameter_flag = 'N') AND
			(rec.data_source_type IS NULL) AND
			(rec.data_source IS NULL) AND
			(rec.data_source_reference IS NULL))
		THEN


			l_parent := 0;

			l_parent := check_if_parent(rec.msg_element_id) ;

			IF (l_parent = 0) THEN

	--  No data source has been defined for the leaf element
	--  But the Message code element is an exception

			IF (rec.name <> p_msg_code) THEN
				fnd_message.set_name ('XNP','NO_DATA_SOURCE') ;
				fnd_message.set_token ('NAME',rec.name) ;
				x_error_message := fnd_message.get;
				x_error_code := xnp_errors.g_no_data_source;
				RETURN;
			END IF;

			END IF;

		ELSE
			IF (rec.parameter_flag = 'N') THEN
				check_source(p_element_id=>rec.msg_element_id,
					p_element_name=>rec.name,
					p_source_type => rec.data_source_type,
					p_data_source => rec.data_source,
					p_data_ref => rec.data_source_reference,
					x_error_code => x_error_code,
					x_error_message => x_error_message);
				IF (x_error_code <> 0) THEN
					RETURN;
				END IF;
			END IF;

		END IF;

	END LOOP;

	EXCEPTION
		WHEN OTHERS THEN
			x_error_code := SQLCODE;
			x_error_message := SQLERRM;


END validate;

/***********************************************************************/

PROCEDURE check_source(p_element_id IN NUMBER,
		p_element_name IN VARCHAR2,
		p_source_type IN VARCHAR2,
		p_data_source IN VARCHAR2,
		p_data_ref IN VARCHAR2,
		x_error_code OUT NOCOPY NUMBER,
		x_error_message OUT NOCOPY VARCHAR2)

IS

	l_exists NUMBER;
	l_parent NUMBER;
	l_data_source VARCHAR2(4000) ;

BEGIN

	x_error_code := 0;
	x_error_message := NULL;

	IF (p_source_type = 'SQL') THEN
		IF (p_data_source IS NULL) THEN
			fnd_message.set_name('XNP', 'NULL_SQL_SOURCE');
			fnd_message.set_token('NAME', p_element_name);
			x_error_message := fnd_message.get ;
			x_error_code := xnp_errors.g_null_sql_source;
			RETURN;
		END IF;

		--check for semicolon

		l_data_source := RTRIM(p_data_source) ;

		l_exists := INSTR(l_data_source, ';') ;

		IF (l_exists <> 0) THEN
			fnd_message.set_name('XNP', 'SEMI_COLON_ERROR');
			x_error_message := fnd_message.get ;
			x_error_code := xnp_errors.g_semi_colon_error;
			RETURN;
		END IF;

	-- check if leaf element and see if there is a data reference

		l_parent := check_if_parent(p_element_id) ;

		IF (l_parent = 0) AND (p_data_ref IS NULL) THEN
			fnd_message.set_name('XNP', 'NO_DATA_REFERENCE');
			fnd_message.set_token('NAME',p_element_name) ;
			x_error_message := fnd_message.get ;
			x_error_code := xnp_errors.g_no_data_reference;
			RETURN;
		END IF;

	END IF;

	IF (p_source_type = 'PROCEDURE') THEN

	-- check if procedure name is defined

		IF (p_data_ref IS NULL) THEN
			fnd_message.set_name('XNP', 'UNDEFINED_FUNCTION');
			fnd_message.set_token('NAME', p_element_name);
			x_error_message := fnd_message.get ;
			x_error_code := xnp_errors.g_undefined_function;
			RETURN;
		END IF;

	END IF;

	IF (p_source_type = 'SDP_WI') THEN

	-- check if parameter exists in parameter pool

		l_exists := check_parameter_pool(
			p_element_name => p_element_name,
			p_reference => p_data_ref) ;

		IF (l_exists = 0) THEN
			fnd_message.set_name('XNP', 'UNDEFINED_WI_PARAMETER');
			IF (p_data_ref IS NULL) THEN
				fnd_message.set_token('NAME',p_element_name);
			ELSE
				fnd_message.set_token('NAME',p_data_ref);
			END IF;
			x_error_message := fnd_message.get ;
			x_error_code := xnp_errors.g_undefined_wi_parameter;
			RETURN;
		END IF;

	END IF;


	IF (p_source_type = 'ORDER') THEN
        -- rnyberg, 09/26/2001. Removed check for Order Parameters in pool
        -- by putting section below within comments.
        -- Order Parameters do not have to exist in a pool.
        NULL;
 /*

	-- check if parameter exists in parameter pool

		l_exists := check_parameter_pool(
			p_element_name => p_element_name,
			p_reference => p_data_ref) ;

		IF (l_exists = 0) THEN
			fnd_message.set_name('XNP', 'UNDEFINED_ORDER_PARAMETER');
			IF (p_data_ref IS NULL) THEN
				fnd_message.set_token('NAME',p_element_name);
			ELSE
				fnd_message.set_token('NAME',p_data_ref);
			END IF;
			x_error_message := fnd_message.get ;
			x_error_code := xnp_errors.g_undefined_order_parameter;
			RETURN;
		END IF;
 */
	END IF;

	IF (p_source_type = 'SDP_FA') THEN

        -- rnyberg, 09/26/2001. Removed check for FA Parameters in pool
        -- by putting section below within comments.
        -- As of R11.5.6, FA Parameters are not stored in a pool.
        NULL;
 /*
	-- check if parameter exists in parameter pool

		l_exists := check_parameter_pool(
			p_element_name => p_element_name,
			p_reference => p_data_ref) ;

		IF (l_exists = 0) THEN
			fnd_message.set_name('XNP', 'UNDEFINED_FA_PARAMETER');
			IF (p_data_ref IS NULL) THEN
				fnd_message.set_token('NAME',p_element_name);
			ELSE
				fnd_message.set_token('NAME',p_data_ref);
			END IF;
			x_error_message := fnd_message.get ;
			x_error_code := xnp_errors.g_undefined_fa_parameter;
			RETURN;
		END IF;
 */
	END IF;

	EXCEPTION
		WHEN OTHERS THEN
			x_error_code := SQLCODE;
			x_error_message := SQLERRM;

END check_source;

/*******************************************************************/



FUNCTION check_exists(p_msg_code IN VARCHAR2 ) RETURN NUMBER

IS

	CURSOR get_object IS
		SELECT object_name FROM user_objects
		WHERE object_name = p_msg_code
		AND OBJECT_TYPE <> 'SYNONYM';

	l_object_name VARCHAR2(128);

BEGIN

	OPEN get_object;
	FETCH get_object INTO l_object_name;

	IF (get_object%NOTFOUND) THEN
		CLOSE get_object;
		RETURN 0;

	ELSE
		CLOSE get_object;
		RETURN 1;
	END IF ;

END check_exists ;

/***********************************************************************/

FUNCTION check_if_parent(p_element_id NUMBER) RETURN NUMBER

IS

	CURSOR get_parent IS
                --skilaru 03/27/2001
		--SELECT * FROM xnp_msg_structures
		SELECT 'Y' FROM xnp_msg_structures
		WHERE parent_element_id = p_element_id ;
        --skilaru 03/27/2001
	--l_row xnp_msg_structures%ROWTYPE ;
	l_row VARCHAR2(1) ;

BEGIN

	OPEN get_parent;
	FETCH get_parent INTO l_row;

	IF (get_parent%NOTFOUND) THEN
		CLOSE get_parent;
		RETURN 0;

	ELSE
		CLOSE get_parent;
		RETURN 1;
	END IF ;

END check_if_parent ;


/***********************************************************************/

FUNCTION check_parameter_pool
	(p_element_name IN VARCHAR2,
	 p_reference IN VARCHAR2) RETURN NUMBER

IS

        -- rnyberg, 09/26/2001. Replaced CSI_EXT_ with CSI_EXTEND_
        --          Also replaced FND_LOOKUPS with CSI_LOOKUPS
	CURSOR get_parameter (l_parameter_name IN VARCHAR2) IS
		SELECT lookup_code FROM CSI_LOOKUPS
		WHERE lookup_code = l_parameter_name
                AND lookup_type = 'CSI_EXTEND_ATTRIB_POOL';

	l_parameter VARCHAR2(80);

BEGIN

	IF (p_reference IS NOT NULL) THEN
		OPEN get_parameter(p_reference) ;
	ELSE
		OPEN get_parameter(p_element_name) ;
	END IF;

	FETCH get_parameter INTO l_parameter;

	IF (get_parameter%NOTFOUND) THEN
		CLOSE get_parameter;
		RETURN 0;

	ELSE
		CLOSE get_parameter;
		RETURN 1;
	END IF ;

END check_parameter_pool ;


END xnp_msg_schema;

/
