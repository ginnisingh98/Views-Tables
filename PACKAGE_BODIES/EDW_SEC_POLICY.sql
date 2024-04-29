--------------------------------------------------------
--  DDL for Package Body EDW_SEC_POLICY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EDW_SEC_POLICY" as
/* $Header: EDWSPLCB.pls 120.1 2006/03/28 01:47:43 rkumar noship $*/

-- This procedure associates a security policy to specified fact table

PROCEDURE attach_policy(Errbuf out NOCOPY varchar2, Retcode out NOCOPY varchar2,fact_table_name varchar2) IS

  x_object_owner		all_objects.owner%TYPE;

  v_Errorcode			number;
  v_ErrorText			varchar2(200);
  fact_short_name		varchar2(50);

  g_conc_program_id		number;

  x_object_name                 varchar2(30) := 'EDW_SEC_POLICY.ATTACH_POLICY';
  x_object_type                 varchar2(30) := 'Security Procedure';

  x_count                       number :=0;

  x_message			varchar2(2000);

  --code added for bug 3871867.. we can use fnd_installaton api to get apps schema name
  l_schema                      varchar2(32);

BEGIN

Errbuf := NULL;
Retcode := 0;

--Get the schema name bug 3871867
OPEN cApps;
FETCH cApps INTO l_schema;
CLOSE cApps;

g_conc_program_id := FND_GLOBAL.conc_request_id;

-- Get fact physical name

  select distinct fact_name into fact_short_name
  from edw_sec_fact_info_t
  where fact_long_name = fact_table_name;

-- Get object owner

-- The object will either be a view owned by APPS or a synonym pointing to a table
-- Check if the object is view

  select count(*) into x_count from user_views
  where view_name = UPPER(fact_short_name);


  IF x_count = 1 THEN   /* It is a view owned by APPS  */
	x_object_owner := l_schema;  --bug 3871867

  ELSE          /* It is a synonym  */

        select table_owner into x_object_owner
        from user_synonyms --bug#4905343
	where synonym_name = UPPER(fact_short_name);

  END IF;

-- Associate the policy with fact table

  DBMS_RLS.ADD_POLICY(x_object_owner, fact_short_name, 'edw_sec_policy', 'apps', 'edw_sec_pkg.dim_sec', 'select', TRUE);

EXCEPTION

  WHEN OTHERS THEN

	v_ErrorCode := SQLCODE;
	v_ErrorText := SUBSTR(SQLERRM, 1, 200);

--      Log error message

        x_message :=   'Oracle error occured. Fact name is : ' || fact_table_name ||
                       '. Errorcode is : ' || v_ErrorCode || ' and Errortext is : ' || v_ErrorText ;

        edw_sec_util.log_error(x_object_name, x_object_type, null, g_conc_program_id, x_message);

	Errbuf := v_ErrorText;
	Retcode := SQLCODE;

END attach_policy;


-- This procedure removes a security policy from specified fact table

PROCEDURE detach_policy(Errbuf out NOCOPY varchar2, Retcode out NOCOPY varchar2,fact_table_name varchar2) IS

  x_object_owner                all_objects.owner%TYPE;

  v_Errorcode                   number;
  v_ErrorText                   varchar2(200);
  fact_short_name               varchar2(50);

  g_conc_program_id             number;

  x_object_name                 varchar2(30) := 'EDW_SEC_POLICY.DETACH_POLICY';
  x_object_type                 varchar2(30) := 'Security Procedure';

  x_count                       number :=0;

  x_message                     varchar2(2000);

  --bug 3871867, we can not use fnd_installation api to get apps schema name
  l_schema                      varchar2(32);


BEGIN

Errbuf := NULL;
Retcode := 0;

--Get the schema name bug 3871867
OPEN cApps;
FETCH cApps INTO l_schema;
CLOSE cApps;

g_conc_program_id := FND_GLOBAL.conc_request_id;

-- Get fact physical name

  select distinct fact_name into fact_short_name
  from edw_sec_fact_info_t
  where fact_long_name = fact_table_name;

-- Get object owner

-- The object will either be a view owned by APPS or a synonym pointing to a table
-- Check if the object is view

  select count(*) into x_count from user_views
  where view_name = UPPER(fact_short_name);


  IF x_count = 1 THEN   /* It is a view owned by APPS  */
	x_object_owner := l_schema;  --- bug 3871867

  ELSE          /* It is a synonym  */

        select table_owner into x_object_owner
        from user_synonyms --bug#4905343
        where synonym_name = UPPER(fact_short_name);

  END IF;


-- Remove the policy from fact table

  DBMS_RLS.DROP_POLICY(x_object_owner, fact_short_name, 'edw_sec_policy');

EXCEPTION

  WHEN OTHERS THEN

        v_ErrorCode := SQLCODE;
        v_ErrorText := SUBSTR(SQLERRM, 1, 200);

--      Log error message

        x_message :=   'Oracle error occured. Fact name is : ' || fact_table_name ||
                       '. Errorcode is : ' || v_ErrorCode || ' and Errortext is : ' || v_ErrorText ;

        edw_sec_util.log_error(x_object_name, x_object_type, null, g_conc_program_id, x_message);

        Errbuf := v_ErrorText;
        Retcode := SQLCODE;


END detach_policy;








-- This procedure associates a default security policy to specified fact table or view

PROCEDURE attach_default_policy(Errbuf out NOCOPY varchar2, Retcode out NOCOPY varchar2,fact_table_name varchar2) IS

  x_object_owner		all_objects.owner%TYPE;

  v_Errorcode			number;
  v_ErrorText			varchar2(200);
  fact_short_name		varchar2(50);

  g_conc_program_id		number;

  x_object_name                 varchar2(50) := 'EDW_SEC_POLICY.ATTACH_DEFAULT_POLICY';
  x_object_type                 varchar2(30) := 'Security Procedure';

  x_count			number :=0;

  x_message                     varchar2(2000);
  --bug 3871867, we can not use fnd_installation api to get apps schema name
  l_schema                      varchar2(32);

BEGIN

Errbuf := NULL;
Retcode := 0;

--Get the schema name bug 3871867
OPEN cApps;
FETCH cApps INTO l_schema;
CLOSE cApps;

g_conc_program_id := FND_GLOBAL.conc_request_id;

-- Get fact physical name

  select distinct fact_name into fact_short_name
  from edw_sec_fact_info_t
  where fact_long_name = fact_table_name;

-- Get object owner

-- The object will either be a view owned by APPS or a synonym pointing to a table
-- Check if the object is view

  select count(*) into x_count from user_views
  where view_name = UPPER(fact_short_name);


  IF x_count = 1 THEN	/* It is a view owned by APPS  */

	x_object_owner := l_schema;  --bug 3871867

  ELSE		/* It is a synonym  */

	select table_owner into x_object_owner
	from user_synonyms --bug#4905343
	where synonym_name = UPPER(fact_short_name);

  END IF;

-- Associate the policy with fact table

  DBMS_RLS.ADD_POLICY(x_object_owner, fact_short_name, 'edw_sec_default_policy', 'apps', 'edw_sec_pkg.default_sec', 'select', TRUE);

EXCEPTION

  WHEN OTHERS THEN

	v_ErrorCode := SQLCODE;
	v_ErrorText := SUBSTR(SQLERRM, 1, 200);

--      Log error message

        x_message :=   'Oracle error occured. Fact name is : ' || fact_table_name ||
                       '. Errorcode is : ' || v_ErrorCode || ' and Errortext is : ' || v_ErrorText ;

        edw_sec_util.log_error(x_object_name, x_object_type, null, g_conc_program_id, x_message);

	Errbuf := v_ErrorText;
	Retcode := SQLCODE;

END attach_default_policy;


-- This procedure removes a default security policy from specified fact table

PROCEDURE detach_default_policy(Errbuf out NOCOPY varchar2, Retcode out NOCOPY varchar2,fact_table_name varchar2) IS

  x_object_owner                all_objects.owner%TYPE;

  v_Errorcode                   number;
  v_ErrorText                   varchar2(200);
  fact_short_name               varchar2(50);

  g_conc_program_id             number;

  x_object_name                 varchar2(50) := 'EDW_SEC_POLICY.DETACH_DEFAULT_POLICY';
  x_object_type                 varchar2(30) := 'Security Procedure';

  x_count			number :=0;

  x_message                     varchar2(2000);

  --bug 3871867, as we can not use fnd_installation api to get apps schema name
  l_schema                      varchar2(32);

BEGIN

Errbuf := NULL;
Retcode := 0;

--Get the schema name  bug 3871867
OPEN cApps;
FETCH cApps INTO l_schema;
CLOSE cApps;

g_conc_program_id := FND_GLOBAL.conc_request_id;

-- Get fact physical name

  select distinct fact_name into fact_short_name
  from edw_sec_fact_info_t
  where fact_long_name = fact_table_name;


-- Get object owner

-- The object will either be a view owned by APPS or a synonym pointing to a table
-- Check if the object is view

  select count(*) into x_count from user_views
  where view_name = UPPER(fact_short_name);


  IF x_count = 1 THEN   /* It is a view owned by APPS  */

        x_object_owner := l_schema;  --bug  3871867

  ELSE          /* It is a synonym  */

        select table_owner into x_object_owner
        from user_synonyms  --bug#4905343
        where synonym_name = UPPER(fact_short_name);

  END IF;


-- Remove the policy from fact table

  DBMS_RLS.DROP_POLICY(x_object_owner, fact_short_name, 'edw_sec_default_policy');

EXCEPTION

  WHEN OTHERS THEN

        v_ErrorCode := SQLCODE;
        v_ErrorText := SUBSTR(SQLERRM, 1, 200);

--      Log error message

        x_message :=   'Oracle error occured. Fact name is : ' || fact_table_name ||
                       '. Errorcode is : ' || v_ErrorCode || ' and Errortext is : ' || v_ErrorText ;

        edw_sec_util.log_error(x_object_name, x_object_type, null, g_conc_program_id, x_message);

        Errbuf := v_ErrorText;
        Retcode := SQLCODE;


END detach_default_policy;


END edw_sec_policy;

/
