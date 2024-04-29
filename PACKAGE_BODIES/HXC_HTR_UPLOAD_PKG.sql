--------------------------------------------------------
--  DDL for Package Body HXC_HTR_UPLOAD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_HTR_UPLOAD_PKG" AS
/* $Header: hxchtrupl.pkb 120.0 2005/05/29 05:43:55 appldev noship $ */
PROCEDURE load_time_recipient_row (
          p_name                            IN VARCHAR2
	, p_owner		            IN VARCHAR2
	, p_application_name	            IN VARCHAR2
	, p_custom_mode		            IN VARCHAR2
        , p_appl_retrieval_function         IN VARCHAR2
        , p_appl_update_process             IN VARCHAR2
        , p_appl_validation_process         IN VARCHAR2
        , p_appl_period_function            IN VARCHAR2
        , p_appl_dyn_template_process       IN VARCHAR2
        , p_extension_function1             IN VARCHAR2
        , p_extension_function2             IN VARCHAR2
	, p_last_update_date                IN VARCHAR2 DEFAULT NULL) IS

l_time_recipient_id	hxc_time_recipients.time_recipient_id%TYPE;
l_application_id	hxc_time_recipients.application_id%TYPE;
l_ovn			hxc_time_recipients.object_version_number%TYPE;
l_owner			VARCHAR2(6);

l_appl_retrieval_function 	hxc_time_recipients.application_retrieval_function%TYPE := NULL;
l_appl_update_process    	hxc_time_recipients.application_update_process%TYPE := NULL;
l_appl_validation_process 	hxc_time_recipients.appl_validation_process%TYPE := NULL;
l_appl_period_function   	hxc_time_recipients.application_period_function%TYPE := NULL;
l_appl_dyn_template_process 	hxc_time_recipients.appl_dynamic_template_process%TYPE := NULL;
l_extension_function1 		hxc_time_recipients.extension_function1%TYPE := NULL;
l_extension_function2 		hxc_time_recipients.extension_function2%TYPE := NULL;
l_last_update_date_db           hxc_time_recipients.last_update_date%TYPE;
l_last_updated_by_db            hxc_time_recipients.last_updated_by%TYPE;
l_last_updated_by_f             hxc_time_recipients.last_updated_by%TYPE;
l_last_update_date_f            hxc_time_recipients.last_update_date%TYPE;
--

FUNCTION chk_schema_exists RETURN BOOLEAN IS

l_exists BOOLEAN := FALSE;
l_dummy  NUMBER(1);

CURSOR	csr_chk_tab (p_hxc_schema in varchar2) IS
SELECT	1
FROM	dual
WHERE EXISTS (
SELECT	1
FROM	all_tables
WHERE	owner = p_hxc_schema
AND	table_name = 'HXC_TIME_RECIPIENTS' );

l_result 	boolean;
l_prod_status   varchar2(1);
l_industry      varchar2(1);
l_hxc_schema    varchar2(30);


BEGIN

-- get hxc schema name
l_result := fnd_installation.get_app_info ('HXC', l_prod_status, l_industry, l_hxc_schema );


OPEN  csr_chk_tab(l_hxc_schema);
FETCH csr_chk_tab INTO l_dummy;

IF csr_chk_tab%FOUND
THEN
	l_exists := TRUE;
END IF;

CLOSE csr_chk_tab;

RETURN l_exists;

END chk_Schema_exists;


FUNCTION chk_process_exists ( p_process_name VARCHAR2 ) RETURN BOOLEAN IS

l_exists	BOOLEAN := FALSE;
l_dummy 	NUMBER(1);
l_process	VARCHAR2(30);

CURSOR csr_chk_process ( p_process VARCHAR2 ) IS
SELECT	1
FROM	dual
WHERE EXISTS (
SELECT  1
FROM	user_objects
WHERE	object_name	= p_process
AND	object_type	= 'PACKAGE BODY'
);

BEGIN

l_process := SUBSTR(p_process_name, 1, (INSTR(p_process_name, '.', 1, 1)-1));

OPEN  csr_chk_process ( l_process );
FETCH csr_chk_process INTO l_dummy;

IF csr_chk_process%FOUND
THEN
	l_exists := TRUE;
END IF;

CLOSE csr_chk_process;

RETURN l_exists;

END chk_process_exists;

FUNCTION get_application_id ( p_application_name VARCHAR2 ) RETURN NUMBER IS

l_application_id	hxc_time_recipients.application_id%TYPE;

CURSOR	csr_get_app_id IS
SELECT	app.application_id
FROM	fnd_application app
WHERE	app.application_short_name = p_application_name;

BEGIN

OPEN  csr_get_app_id;
FETCH csr_get_app_id INTO l_application_id;
CLOSE csr_get_app_id;

RETURN l_application_id;

END get_application_id;


BEGIN -- load_time_recipient_row

IF ( chk_schema_exists )
THEN

l_application_id := get_application_id ( p_application_name );

-- make sure that the validation processes exist

IF ( ( p_appl_retrieval_function IS NOT NULL ) AND ( INSTR(p_appl_retrieval_function,'.',1,1) <> 0 ))
THEN
	IF ( chk_process_exists ( p_appl_retrieval_function ) )
	THEN
		l_appl_retrieval_function := p_appl_retrieval_function;
	END IF;

ELSIF ( p_appl_retrieval_function IS NOT NULL )
THEN

	l_appl_retrieval_function := p_appl_retrieval_function;

END IF;

IF ( p_appl_update_process IS NOT NULL )
THEN
	IF ( chk_process_exists ( p_appl_update_process ) )
	THEN
		l_appl_update_process := p_appl_update_process;
	END IF;
END IF;

IF ( p_appl_validation_process IS NOT NULL )
THEN
	IF ( chk_process_exists ( p_appl_validation_process ) )
	THEN
		l_appl_validation_process := p_appl_validation_process;
	END IF;
END IF;

IF ( p_appl_period_function IS NOT NULL )
THEN
	IF ( chk_process_exists ( p_appl_period_function ) )
	THEN
		l_appl_period_function := p_appl_period_function;
	END IF;
END IF;

IF ( p_extension_function1 IS NOT NULL )
THEN
        IF ( chk_process_exists ( p_extension_function1 ) )
        THEN
                l_extension_function1 := p_extension_function1;
        END IF;
END IF;

IF ( p_extension_function2 IS NOT NULL )
THEN
        IF ( chk_process_exists ( p_extension_function2 ) )
        THEN
                l_extension_function2 := p_extension_function2;
        END IF;
END IF;

IF ( p_appl_dyn_template_process IS NOT NULL )
THEN
	IF ( chk_process_exists ( p_appl_dyn_template_process ) )
	THEN
		l_appl_dyn_template_process := p_appl_dyn_template_process;
	END IF;
END IF;

l_last_updated_by_f := fnd_load_util.owner_id(p_owner);
l_last_update_date_f := nvl(to_date(p_last_update_date, 'YYYY/MM/DD'), sysdate);
	SELECT	tr.time_recipient_id
	,	tr.object_version_number
	,tr.last_update_date
			,tr.last_updated_by
	INTO	l_time_recipient_id
	,	l_ovn
	,l_last_update_date_db
                        ,l_last_updated_by_db
	FROM	hxc_time_recipients tr
	WHERE	tr.name	= P_NAME;

	IF (fnd_load_util.upload_test(	l_last_updated_by_f,
					l_last_update_date_f,
	                        	 l_last_updated_by_db,
					l_last_update_date_db ,
					 p_custom_mode))
	THEN
		hxc_time_recipient_api.update_time_recipient (
	   p_time_recipient_id         => l_time_recipient_id
	 , p_application_id	       => l_application_id
	 , p_object_version_number     => l_ovn
	 , p_name                      => p_name
         , p_appl_retrieval_function   => l_appl_retrieval_function
         , p_appl_update_process       => l_appl_update_process
         , p_appl_validation_process   => l_appl_validation_process
         , p_appl_period_function      => l_appl_period_function
         , p_appl_dyn_template_process => l_appl_dyn_template_process
         , p_extension_function1       => l_extension_function1
         , p_extension_function2       => l_extension_function2);

	END IF;

END IF; -- chk_Schema_Exists


EXCEPTION WHEN NO_DATA_FOUND
THEN

	hxc_time_recipient_api.create_time_recipient (
	   p_time_recipient_id         => l_time_recipient_id
	 , p_application_id	       => l_application_id
	 , p_object_version_number     => l_ovn
	 , p_name                      => p_name
         , p_appl_retrieval_function   => l_appl_retrieval_function
         , p_appl_update_process       => l_appl_update_process
         , p_appl_validation_process   => l_appl_validation_process
         , p_appl_period_function      => l_appl_period_function
         , p_appl_dyn_template_process => l_appl_dyn_template_process
         , p_extension_function1       => l_extension_function1
         , p_extension_function2       => l_extension_function2);

END load_time_recipient_row;


END hxc_htr_upload_pkg;

/
