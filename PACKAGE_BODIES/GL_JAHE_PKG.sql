--------------------------------------------------------
--  DDL for Package Body GL_JAHE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_JAHE_PKG" as
/* $Header: glajaheb.pls 120.29 2006/01/19 10:51:38 knag noship $ */


--
-- PUBLIC PROCEDURES
--
FUNCTION has_loop (     source          IN      VARCHAR2,
                        target          IN      VARCHAR2,
                        value_set_id    IN      NUMBER) RETURN VARCHAR2
IS
parent	VARCHAR2(60);
CURSOR find_parent_cursor (child VARCHAR2, vsid NUMBER) IS
	SELECT 	parent_flex_value
	FROM	fnd_flex_value_norm_hierarchy
	WHERE	flex_value_set_id = vsid
	AND	range_attribute = 'P'
	AND	child	BETWEEN	child_flex_value_low
			AND	child_flex_value_high;
BEGIN
  OPEN find_parent_cursor(target, value_set_id);
  LOOP
	FETCH find_parent_cursor INTO parent;
	IF ( find_parent_cursor%NOTFOUND ) THEN
	  CLOSE find_parent_cursor;
	  RETURN('FALSE');
	ELSIF ( parent = source ) THEN
	  CLOSE find_parent_cursor;
	  RETURN('TRUE');
	ELSIF ( has_loop(source, parent, value_set_id) = 'TRUE' ) THEN
	  CLOSE find_parent_cursor;
	  RETURN('TRUE');
	END IF;
  END LOOP;
  CLOSE find_parent_cursor;
  RETURN('FALSE');
END has_loop;


FUNCTION access_test RETURN VARCHAR2
IS
BEGIN

  if(fnd_function.test('GLJAHE')) then
    RETURN('TRUE');
  elsif (fnd_function.test('GLJAHESUPER')) then
    RETURN('TRUE');
  else
    RETURN('FALSE');
  end if;
END access_test;

FUNCTION modify_range ( parent          IN      VARCHAR2,
                        child           IN      VARCHAR2,
                        range_attr      IN      VARCHAR2,
                        range_low       IN      VARCHAR2,
                        range_high      IN      VARCHAR2,
                        value_set_id    IN      NUMBER) RETURN INTEGER
IS
range_size  NUMBER := 0;
sum_flag    VARCHAR2(1);
new_bound   VARCHAR2(150);
BEGIN
    IF ( range_attr = 'P') THEN
        sum_flag := 'Y';
    ELSE
        sum_flag := 'N';
    END IF;

    SELECT  COUNT(*)
    INTO    range_size
    FROM    FND_FLEX_VALUES
    WHERE   flex_value_set_id = value_set_id
    AND     summary_flag = sum_flag
    AND     flex_value BETWEEN range_low AND range_high;

    /* If range is a single valued range, the row can be removed from the
    norm hierarchy table. */
    IF ( range_size = 1 ) THEN
        DELETE  FND_FLEX_VALUE_NORM_HIERARCHY
        WHERE   flex_value_set_id = value_set_id
        AND     parent_flex_value = parent
        AND     range_attribute = range_attr
        AND     child_flex_value_low = range_low
        AND     child_flex_value_high = range_high;
    ELSIF ( child = range_low ) THEN
    /* If the value to be removed from the range was the lower boundary,
    the lower boundary of the original range has to be adjusted to be
    the flex value immediately following the value to be removed.*/

        SELECT  MIN(flex_value)
        INTO    new_bound
        FROM    fnd_flex_values
        WHERE   flex_value_set_id = value_set_id
        AND     summary_flag = sum_flag
        AND     flex_value > child
        AND     flex_value <= range_high
        ORDER BY flex_value;

        IF ( new_bound IS NOT NULL ) THEN
            UPDATE  FND_FLEX_VALUE_NORM_HIERARCHY
            SET     child_flex_value_low = new_bound
            WHERE   flex_value_set_id = value_set_id
            AND     parent_flex_value = parent
            AND     range_attribute = range_attr
            AND     child_flex_value_low = range_low
            AND     child_flex_value_high = range_high;
        END IF;
    ELSIF ( child = range_high ) THEN
    /* If the value to be removed from the range was the upper boundary,
    the upper boundary of the original range has to be adjusted to be
    the flex value immediately before the value to be removed. */
        SELECT  MAX(flex_value)
        INTO    new_bound
        FROM    fnd_flex_values
        WHERE   flex_value_set_id = value_set_id
        AND     summary_flag = sum_flag
        AND     flex_value >= range_low
        AND     flex_value < child
        ORDER BY flex_value;

        IF ( new_bound IS NOT NULL ) THEN
            UPDATE  FND_FLEX_VALUE_NORM_HIERARCHY
            SET     child_flex_value_high = new_bound
            WHERE   flex_value_set_id = value_set_id
            AND     parent_flex_value = parent
            AND     range_attribute = range_attr
            AND     child_flex_value_low = range_low
            AND     child_flex_value_high = range_high;
        END IF;
    ELSE
    /* If the value to be removed falls somewhere between the upper and
    lower boundaries, the original range has to be removed and 2 new ranges
    will be created to exclude the value to be removed. */

        DELETE  FND_FLEX_VALUE_NORM_HIERARCHY
        WHERE   flex_value_set_id = value_set_id
        AND     parent_flex_value = parent
        AND     range_attribute = range_attr
        AND     child_flex_value_low = range_low
        AND     child_flex_value_high = range_high;

        /* The lower range will contain the same lower bound as the
        original range, and the upper bound will be the flex value before
        the value to be removed. */
        SELECT  MAX(flex_value)
        INTO    new_bound
        FROM    fnd_flex_values
        WHERE   flex_value_set_id = value_set_id
        AND     summary_flag = sum_flag
        AND     flex_value >= range_low
        AND     flex_value < child
        ORDER BY flex_value;

        IF ( new_bound IS NOT NULL ) THEN
        /* If no 'lower' flex value can be found, no new lower range
        will be created. */
            INSERT INTO FND_FLEX_VALUE_NORM_HIERARCHY
            (   flex_value_set_id,
                parent_flex_value,
                range_attribute,
                child_flex_value_low,
                child_flex_value_high,
                last_update_date,
                last_updated_by,
                creation_date,
                created_by,
                last_update_login )
            VALUES
            (   value_set_id,
                parent,
                range_attr,
                range_low,
                new_bound,
                SYSDATE,
                0,
                SYSDATE,
                0,
                0 );
        END IF;

        /* The upper range will contain the same upper bound as the
        original range, and the lower bound will be the flex value after
        the value to be removed. */
        SELECT  MIN(flex_value)
        INTO    new_bound
        FROM    fnd_flex_values
        WHERE   flex_value_set_id = value_set_id
        AND     summary_flag = sum_flag
        AND     flex_value > child
        AND     flex_value <= range_high
        ORDER BY flex_value;

        IF ( new_bound IS NOT NULL ) THEN
        /* If no 'lower' flex value can be found, no new lower range
        will be created. */
            INSERT INTO FND_FLEX_VALUE_NORM_HIERARCHY
            (   flex_value_set_id,
                parent_flex_value,
                range_attribute,
                child_flex_value_low,
                child_flex_value_high,
                last_update_date,
                last_updated_by,
                creation_date,
                created_by,
                last_update_login )
            VALUES
            (   value_set_id,
                parent,
                range_attr,
                new_bound,
                range_high,
                SYSDATE,
                0,
                SYSDATE,
                0,
                0 );
        END IF;
    END IF;
    RETURN (1);
EXCEPTION
    WHEN OTHERS THEN
        RETURN (0);
END modify_range;

FUNCTION has_loop_in_range (    parent          IN      VARCHAR2,
                                low             IN      VARCHAR2,
                                high            IN      VARCHAR2,
                                value_set_id    IN      NUMBER) RETURN VARCHAR2
IS
child	VARCHAR2(60);
CURSOR find_children_cursor (low VARCHAR2, high VARCHAR2, vsid NUMBER) IS
	SELECT 	flex_value
	FROM	fnd_flex_values
	WHERE	flex_value_set_id = vsid
	AND	summary_flag = 'Y'
	AND	flex_value BETWEEN low AND high
    	ORDER	by flex_value;
BEGIN
  -- 1. if parent is within the range, it has loop
  if (parent>=low and parent<=high) then
    return (parent);
  end if;

  -- 2. if any children inside the range has the parent as children,
  --    it has loop
  OPEN find_children_cursor(low, high, value_set_id);
  LOOP
	FETCH find_children_cursor INTO child;
	IF ( find_children_cursor%NOTFOUND ) THEN
	  CLOSE find_children_cursor;
	  RETURN('');
	ELSIF ( has_loop(child, parent, value_set_id) = 'TRUE' ) THEN
	  CLOSE find_children_cursor;
	  RETURN(child);
	END IF;
  END LOOP;
  CLOSE find_children_cursor;
  RETURN('');
END has_loop_in_range;

PROCEDURE merge_range (
                        parent          IN      VARCHAR2,
                        value_set_id    IN      NUMBER) IS
low             VARCHAR2(60);		-- low of current range
high            VARCHAR2(60);		-- high of current range
merged_low      VARCHAR2(60) := null;	-- low of merged range
merged_high	VARCHAR2(60) := null;	-- high of merged range
has_value       NUMBER := null;		-- 1 if there are flex values between ranges
-- cursor for fetching current ranges
CURSOR child_range (parent VARCHAR2) IS
	SELECT 	child_flex_value_low, child_flex_value_high
    	from    gl_ahe_detail_ranges_gt
    	where   parent_flex_value = parent
    	and     status = 'C'
	order by child_flex_value_low, child_flex_value_high;
BEGIN
  OPEN child_range(parent);
  FETCH child_range INTO merged_low, merged_high;
  IF (not child_range%NOTFOUND) THEN
    LOOP
  	FETCH child_range INTO low, high;
	EXIT WHEN child_range%NOTFOUND;
        -- if overlap with previous range, merge it
        IF (low <= merged_high) THEN
          merged_high := high;
        ELSE
	-- if non-overlap, merge if no flex values between ranges
          begin
            -- ACHI 12/20/2001
            -- we can use a exists clause here also, but as
            -- a stable quick fix a rownum limiter is used instead
            SELECT  1
            INTO    has_value
            FROM    fnd_flex_values
            WHERE   flex_value_set_id = value_set_id
            AND     summary_flag = 'N'
            AND     flex_value > merged_high
            AND     flex_value < low
            AND     rownum <= 1;

            -- no exception => found values in between => end of merge
            INSERT INTO gl_ahe_detail_ranges_gt
            (parent_flex_value,
             child_flex_value_low,
             child_flex_value_high,
             status)
            values (parent, merged_low, merged_high, 'M');

            merged_low := low;
            merged_high := high;
          exception
	    -- no values found => merge
            when no_data_found then
              merged_high := high;
          end;
          has_value := null;
        END IF;
    END LOOP;
    INSERT INTO gl_ahe_detail_ranges_gt
    (parent_flex_value,
     child_flex_value_low,
     child_flex_value_high,
     status)
    values (parent, merged_low, merged_high, 'M');
  END IF;
  CLOSE child_range;

END merge_range;

FUNCTION unique_flex_value (
                        f_value         IN      VARCHAR2,
                        parent_low      IN      VARCHAR2,
                        value_set_id    IN      NUMBER) RETURN VARCHAR2
IS
row_count number := 0;
BEGIN
  -- try to find another flex value that is the same as the current one
  SELECT count(*)
  INTO row_count
  FROM fnd_flex_values
  WHERE flex_value_set_id = value_set_id
  AND flex_value = f_value
  AND ((parent_low IS null) OR
       (parent_flex_value_low = parent_low));
  IF ( row_count > 0 ) THEN
    RETURN('FALSE');
  ELSE
    RETURN('TRUE');
  END IF;
END unique_flex_value;

FUNCTION getCOAClause(  user_id    IN      NUMBER,
                        resp_id    IN      NUMBER,
                        appl_id    IN      NUMBER) RETURN VARCHAR2
IS

CURSOR resp (uid number) IS
  select responsibility_id, responsibility_application_id
  from fnd_user_resp_groups
  where user_id = uid
--  and responsibility_application_id = 101
  and (start_date is null or start_date < sysdate)
  and (end_date is null or end_date > sysdate);

rid    number(15);
coaid  number(15);
result varchar2(200);
sobid  varchar2(15);
appid  number(15);
accsetid varchar2(15);

BEGIN

  FND_GLOBAL.APPS_INITIALIZE(user_id, resp_id, appl_id);
  if (FND_FUNCTION.TEST('GLJAHESUPER')) then
    return 'ALL';
  else
    open resp(user_id);
    result := ',';

    LOOP
      fetch resp into rid, appid;
      exit when resp%NOTFOUND;
/*
      sobid := fnd_profile.value_specific('GL_SET_OF_BKS_ID',
                   user_id, rid, appid);

      if (sobid is not null) then
        select chart_of_accounts_id into coaid
        from gl_sets_of_books
        where set_of_books_id = to_number(sobid);
*/
      accsetid := fnd_profile.value_specific('GL_ACCESS_SET_ID',
                   user_id, rid, appid);

      if (accsetid is not null) then
        select chart_of_accounts_id into coaid
        from gl_access_sets
        where access_set_id = to_number(accsetid);

        if (instr(result, ','||to_char(coaid)||',') = 0) then
          result := result || to_char(coaid) || ',';
        end if;
      end if;
    end loop;

    if (length(result) > 1) then
      result := substr(result, 2, length(result)-2);
      return result;
    else
      return '-1';
    end if;

  end if;

END;

PROCEDURE lock_flex_value_set (fvsid NUMBER) is
  lkname   varchar2(128);
  lkhandle varchar2(128);
  rs_mode  constant integer := 5;
  timout   constant integer := 2;  -- 2 secs timeout
  expiration_secs constant integer := 864000;
  lkresult integer;
begin
  -- generate the name for the user-defined lock
  lkname := 'FND_FLEX_AHE_VS_' || to_char(fvsid);

  -- get Oracle-assigned lock handle
  dbms_lock.allocate_unique( lkname, lkhandle, expiration_secs );

  -- request a lock in the ROW SHARE mode
  lkresult := dbms_lock.request( lkhandle, rs_mode, timout, TRUE );

  if ( lkresult = 0 ) then
    -- locking was successful
    return;
  elsif ( lkresult = 1 ) then
    -- Account Hierarchy Editor is locking out value set
    -- print out appropriate warning message
    fnd_message.set_name('FND', 'FLEX-AHE LOCKING VSET');
    app_exception.raise_exception;
  else
    fnd_message.set_name('FND', 'FLEX-AHE DBMS_LOCK ERROR');
    app_exception.raise_exception;
  end if;


END lock_flex_value_set;

PROCEDURE flatten_hierarchy (fvsid NUMBER) is

  req_id integer;

begin

  req_id := fnd_request.submit_request(
                application => 'FND',
                program     => 'FDFCHY',
                argument1   => TO_CHAR(fvsid)
                );
  COMMIT;

END flatten_hierarchy;

PROCEDURE insert_tl_records (fvsid NUMBER DEFAULT NULL) is

  cursor installed_lang_cursor is
    select LANGUAGE_CODE from FND_LANGUAGES
    where INSTALLED_FLAG in ('B', 'I');

  lang_code VARCHAR(4);

BEGIN

  IF (fvsid IS NOT NULL) THEN

    OPEN installed_lang_cursor;
    LOOP
      FETCH installed_lang_cursor INTO lang_code;
      IF ( installed_lang_cursor%NOTFOUND ) THEN
        CLOSE installed_lang_cursor;
        RETURN;
      ELSIF ( lang_code <>  userenv('LANG') ) THEN
        insert into FND_FLEX_VALUES_TL (
          FLEX_VALUE_ID,
          LAST_UPDATE_DATE,
          LAST_UPDATED_BY,
          CREATION_DATE,
          CREATED_BY,
          LAST_UPDATE_LOGIN,
          DESCRIPTION,
          FLEX_VALUE_MEANING,
          LANGUAGE,
          SOURCE_LANG
       )
          (select
             T1.FLEX_VALUE_ID,
             T1.LAST_UPDATE_DATE,
             T1.LAST_UPDATED_BY,
             T1.CREATION_DATE,
             T1.CREATED_BY,
             T1.LAST_UPDATE_LOGIN,
             T1.DESCRIPTION,
             T1.FLEX_VALUE_MEANING,
             lang_code,
             T1.SOURCE_LANG
           from fnd_flex_values_tl T1
           -- Bug 4775405, add join
               ,fnd_flex_values B
           where language = userenv('LANG')
           and not exists  (select NULL
                           from fnd_flex_values_tl T2
                           where T2.language = lang_code
                           and T2.flex_value_id = T1.flex_value_id)
           -- Bug 4775405, add filter
           and T1.flex_value_id = B.flex_value_id
           and B.flex_value_set_id = fvsid
          );

        insert into FND_FLEX_HIERARCHIES_TL (
          FLEX_VALUE_SET_ID,
          HIERARCHY_ID,
          HIERARCHY_NAME,
          LANGUAGE,
          LAST_UPDATE_DATE,
          LAST_UPDATED_BY,
          CREATION_DATE,
          CREATED_BY,
          LAST_UPDATE_LOGIN,
          DESCRIPTION,
          SOURCE_LANG
        )
          (select
             flex_value_set_id,
             hierarchy_id,
             hierarchy_name,
             lang_code,
             last_update_date,
             last_updated_by,
             creation_date,
             created_by,
             last_update_login,
             description,
             source_lang
           from fnd_flex_hierarchies_tl T1
           where language = userenv('LANG')
           and not exists (select NULL
                          from fnd_flex_hierarchies_tl T2
                          where T2.language = lang_code
                          and T2.hierarchy_id = T1.hierarchy_id
                          -- Bug 4775405, add filter
                          and T2.flex_value_set_id = T1.flex_value_set_id)
           -- Bug 4775405, add filter
           and T1.flex_value_set_id = fvsid
          );

      END IF;
    END LOOP;

  END IF;

END insert_tl_records;

PROCEDURE launch IS
/*
  sessionCookie VARCHAR2(128) := ICX_CALL.ENCRYPT3(ICX_SEC.getSessionCookie());
  lang          VARCHAR2(128) := ICX_SEC.g_language_code;
  -- need to escape slash characters in host argument
  tcfHost       VARCHAR2(128) := wfa_html.conv_special_url_chars(
                                        FND_PROFILE.VALUE('TCF:HOST'));
  tcfPort       VARCHAR2(128) := FND_PROFILE.VALUE('TCF:PORT');
  dbc_file      VARCHAR2(128) := fnd_web_config.database_id;

  error         VARCHAR2(250) := 'You do not have the required security privileges to launch Account Hierarchy Manager.  Please contact your System Administrator';
*/
BEGIN
  -- Stubbed out for bug 4467175
  NULL;
/*
if(access_test = 'FALSE') then
  htp.p(error);
elsif (icx_sec.validateSession ) then

      fnd_applet_launcher.launch(
        applet_class       => 'oracle.apps.gl.jahe.javaui.client.Jahe',

        archive_list       => 'oracle/apps/gl/jar/glahelcl.jar'
                              ||',jbodatum111.jar'
                              ||',oracle/apps/fnd/jar/fndtcf.jar'
                              ||',oracle/apps/fnd/jar/fndaroraclnt.jar'
                              ||',oracle/apps/fnd/jar/fndconnectionmanager.jar'
                              ||',oracle/apps/fnd/jar/fndjewtall.jar'
                              ||',oracle/apps/fnd/jar/fndjndi.jar'
                              ||',oracle/apps/fnd/jar/fndswingall.jar'
                              ||',oracle/apps/fnd/jar/jbodomorcl.jar'
                              ||',oracle/apps/fnd/jar/jdev-rt.jar'
                              ||',oracle/apps/fnd/jar/fwk_client.jar'
                              ||',oracle/apps/fnd/jar/jboremote.jar'
                              ||',oracle/apps/fnd/jar/fndctx.jar'
                              ||',oracle/apps/fnd/jar/fndcollections.jar'
                              ||'',

        user_args          => '&gp1=host&gv1=' ||
                                tcfHost ||
                              '&gp2=port&gv2=' ||
                                tcfPort ||
                              '&gp3=dbc_file&gv3=' ||
                                dbc_file ||
                              '&gp4=debug&gv4=' ||
                                'N' ||
	-- SessionCookie and Language should be removed
	-- after full migration to TCF
       	                      '&gp5=sessionCookie&gv5=' ||
                                sessionCookie ||
                              '&gp6=language&gv6=' ||
                                lang ||
                              '',

        title_app          => 'SQLGL',
        title_msg          => 'GL_JAHE_PAGE_TITLE',
        cache              => 'off'
      );

END IF;
*/
END launch;

END GL_JAHE_PKG;

/
