--------------------------------------------------------
--  DDL for Package Body FII_FDHM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FII_FDHM_PKG" as
/* $Header: fiifdhmb.pls 120.5 2006/08/02 23:37:44 juding noship $ */

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
	FROM	fii_dim_norm_hierarchy
	WHERE	parent_flex_value_set_id = vsid
	AND	child	BETWEEN	child_flex_value_low
			AND	child_flex_value_high
        AND     parent_flex_value_set_id = child_flex_value_set_id;

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

FUNCTION modify_range ( parent          IN      VARCHAR2,
                        child           IN      VARCHAR2,
                        range_attr      IN      VARCHAR2,
                        range_low       IN      VARCHAR2,
                        range_high      IN      VARCHAR2,
                        parent_value_set_id   IN   NUMBER,
                        child_value_set_id    IN   NUMBER) RETURN INTEGER
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
    WHERE   flex_value_set_id = child_value_set_id
    AND     summary_flag = sum_flag
    AND     flex_value BETWEEN range_low AND range_high;

    /* If range is a single valued range, the row can be removed from the
    norm hierarchy table. */
    IF ( range_size = 1 ) THEN
        DELETE  FROM FII_DIM_NORM_HIERARCHY
        WHERE   parent_flex_value_set_id = parent_value_set_id
        AND     child_flex_value_set_id = child_value_set_id
        AND     parent_flex_value = parent
        AND     range_attribute = range_attr
        AND     child_flex_value_low = range_low
        AND     child_flex_value_high = range_high;

        IF ( parent_value_set_id = child_value_set_id ) THEN
            DELETE  FND_FLEX_VALUE_NORM_HIERARCHY
            WHERE   flex_value_set_id = parent_value_set_id
            AND     parent_flex_value = parent
            AND     range_attribute = range_attr
            AND     child_flex_value_low = range_low
            AND     child_flex_value_high = range_high;
        END IF;

    ELSIF ( child = range_low ) THEN
    /* If the value to be removed from the range was the lower boundary,
    the lower boundary of the original range has to be adjusted to be
    the flex value immediately following the value to be removed.*/

        SELECT  MIN(flex_value)
        INTO    new_bound
        FROM    fnd_flex_values
        WHERE   flex_value_set_id = child_value_set_id
        AND     summary_flag = sum_flag
        AND     flex_value > child
        AND     flex_value <= range_high
        ORDER BY flex_value;

        IF ( new_bound IS NOT NULL ) THEN
            UPDATE  FII_DIM_NORM_HIERARCHY
            SET     child_flex_value_low = new_bound
            WHERE   parent_flex_value_set_id = parent_value_set_id
            AND     child_flex_value_set_id = child_value_set_id
            AND     parent_flex_value = parent
            AND     range_attribute = range_attr
            AND     child_flex_value_low = range_low
            AND     child_flex_value_high = range_high;

            IF ( parent_value_set_id = child_value_set_id ) THEN
               UPDATE  FND_FLEX_VALUE_NORM_HIERARCHY
               SET     child_flex_value_low = new_bound
               WHERE   flex_value_set_id = parent_value_set_id
               AND     parent_flex_value = parent
               AND     range_attribute = range_attr
               AND     child_flex_value_low = range_low
               AND     child_flex_value_high = range_high;
            END IF;

        END IF;
    ELSIF ( child = range_high ) THEN
    /* If the value to be removed from the range was the upper boundary,
    the upper boundary of the original range has to be adjusted to be
    the flex value immediately before the value to be removed. */
        SELECT  MAX(flex_value)
        INTO    new_bound
        FROM    fnd_flex_values
        WHERE   flex_value_set_id = child_value_set_id
        AND     summary_flag = sum_flag
        AND     flex_value >= range_low
        AND     flex_value < child
        ORDER BY flex_value;

        IF ( new_bound IS NOT NULL ) THEN
            UPDATE  FII_DIM_NORM_HIERARCHY
            SET     child_flex_value_high = new_bound
            WHERE   parent_flex_value_set_id = parent_value_set_id
            AND     child_flex_value_set_id = child_value_set_id
            AND     parent_flex_value = parent
            AND     range_attribute = range_attr
            AND     child_flex_value_low = range_low
            AND     child_flex_value_high = range_high;

            IF ( parent_value_set_id = child_value_set_id ) THEN
               UPDATE  FND_FLEX_VALUE_NORM_HIERARCHY
               SET     child_flex_value_high = new_bound
               WHERE   flex_value_set_id = parent_value_set_id
               AND     parent_flex_value = parent
               AND     range_attribute = range_attr
               AND     child_flex_value_low = range_low
               AND     child_flex_value_high = range_high;
            END IF;

        END IF;
    ELSE
    /* If the value to be removed falls somewhere between the upper and
    lower boundaries, the original range has to be removed and 2 new ranges
    will be created to exclude the value to be removed. */

        DELETE  FROM FII_DIM_NORM_HIERARCHY
        WHERE   parent_flex_value_set_id = parent_value_set_id
        AND     child_flex_value_set_id = child_value_set_id
        AND     parent_flex_value = parent
        AND     range_attribute = range_attr
        AND     child_flex_value_low = range_low
        AND     child_flex_value_high = range_high;

        IF ( parent_value_set_id = child_value_set_id ) THEN
           DELETE  FND_FLEX_VALUE_NORM_HIERARCHY
           WHERE   flex_value_set_id = parent_value_set_id
           AND     parent_flex_value = parent
           AND     range_attribute = range_attr
           AND     child_flex_value_low = range_low
           AND     child_flex_value_high = range_high;
        END IF;

        /* The lower range will contain the same lower bound as the
        original range, and the upper bound will be the flex value before
        the value to be removed. */
        SELECT  MAX(flex_value)
        INTO    new_bound
        FROM    fnd_flex_values
        WHERE   flex_value_set_id = child_value_set_id
        AND     summary_flag = sum_flag
        AND     flex_value >= range_low
        AND     flex_value < child
        ORDER BY flex_value;

        IF ( new_bound IS NOT NULL ) THEN
        /* If no 'lower' flex value can be found, no new lower range
        will be created. */
            INSERT INTO FII_DIM_NORM_HIERARCHY
            (   parent_flex_value_set_id,
                child_flex_value_set_id,
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
            (   parent_value_set_id,
                child_value_set_id,
                parent,
                range_attr,
                range_low,
                new_bound,
                SYSDATE,
                0,
                SYSDATE,
                0,
                fnd_global.login_id);

            IF ( parent_value_set_id = child_value_set_id ) THEN
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
               (   parent_value_set_id,
                   parent,
                   range_attr,
                   range_low,
                   new_bound,
                   SYSDATE,
                   0,
                   SYSDATE,
                   0,
                   fnd_global.login_id);
            END IF;

        END IF;

        /* The upper range will contain the same upper bound as the
        original range, and the lower bound will be the flex value after
        the value to be removed. */
        SELECT  MIN(flex_value)
        INTO    new_bound
        FROM    fnd_flex_values
        WHERE   flex_value_set_id = child_value_set_id
        AND     summary_flag = sum_flag
        AND     flex_value > child
        AND     flex_value <= range_high
        ORDER BY flex_value;

        IF ( new_bound IS NOT NULL ) THEN
        /* If no 'lower' flex value can be found, no new lower range
        will be created. */
            INSERT INTO FII_DIM_NORM_HIERARCHY
            (   parent_flex_value_set_id,
                child_flex_value_set_id,
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
            (   parent_value_set_id,
                child_value_set_id,
                parent,
                range_attr,
                new_bound,
                range_high,
                SYSDATE,
                0,
                SYSDATE,
                0,
                fnd_global.login_id );

            IF ( parent_value_set_id = child_value_set_id ) THEN
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
                (   parent_value_set_id,
                    parent,
                    range_attr,
                    new_bound,
                    range_high,
                    SYSDATE,
                    0,
                    SYSDATE,
                    0,
                    fnd_global.login_id);
            END IF;
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
    RETURN ('FALSE');
  ELSE
    RETURN ('TRUE');
  END IF;
END unique_flex_value;

FUNCTION lock_dim_value_sets (dim_short_name      VARCHAR2,
                   source_lgr_group_id NUMBER) RETURN VARCHAR2 is
  lkname   varchar2(128);
  lkhandle varchar2(128);
  rs_mode  constant integer := 6;  -- X mode
  timout   constant integer := 2;  -- 2 secs timeout
  expiration_secs constant integer := 864000;
  lkresult integer;
  fdvsid NUMBER;

  CURSOR find_dim_value_sets_cur IS
    SELECT flex_value_set_id1
    FROM   fii_dim_mapping_rules  r
    WHERE  r.dimension_short_name = dim_short_name
    AND flex_value_set_id1 is not null
    AND    r.chart_of_accounts_id in
         (SELECT chart_of_accounts_id
          FROM   fii_slg_assignments
          WHERE  source_ledger_group_id =source_lgr_group_id)
    UNION
	SELECT master_value_set_id flex_value_set_id1
	FROM   fii_financial_dimensions_v m
	WHERE  m.dimension_short_name = dim_short_name
    ORDER BY flex_value_set_id1;

BEGIN
  -- Disable the lock mechanism
  RETURN ('TRUE');

  OPEN find_dim_value_sets_cur;
  LOOP
  FETCH find_dim_value_sets_cur INTO fdvsid;

  IF ( find_dim_value_sets_cur%NOTFOUND ) THEN
      CLOSE find_dim_value_sets_cur;
      RETURN ('TRUE');
  ELSE
  -- generate the name for the user-defined lock
  lkname := 'FND_FLEX_AHE_VS_' || to_char(fdvsid);

  -- get Oracle-assigned lock handle
  dbms_lock.allocate_unique( lkname, lkhandle, expiration_secs );

  -- request a lock, NOT release on commit
  lkresult := dbms_lock.request( lkhandle, rs_mode, timout, false );

   if ( lkresult = 1 ) then
    -- Account Hierarchy Editor is locking out value set
    -- print out appropriate warning message
      release_value_set_lock(dim_short_name, source_lgr_group_id, fdvsid);
      -- fnd_message.set_name('FND', 'FLEX-AHE LOCKING VSET');
      CLOSE find_dim_value_sets_cur;
      -- app_exception.raise_exception;
      RETURN ('FALSE');
   elsif (lkresult <> 0 and lkresult <> 4) then
    -- lkresult = 0, locking successfully
    -- lkresult = 4, already own lock
      release_value_set_lock(dim_short_name, source_lgr_group_id, fdvsid);
      -- fnd_message.set_name('FND', 'FLEX-AHE DBMS_LOCK ERROR');
      CLOSE find_dim_value_sets_cur;
      -- app_exception.raise_exception;
      RETURN ('FALSE');
    end if;
  END IF;

  END LOOP;
  CLOSE find_dim_value_sets_cur;
  RETURN ('FALSE');

END lock_dim_value_sets;


PROCEDURE release_value_set_lock(dim_short_name VARCHAR2, source_lgr_group_id NUMBER,
                 value_set_id NUMBER)is
  lkname   varchar2(128);
  lkhandle varchar2(128);
  expiration_secs constant integer := 864000;
  lkresult integer;
  fdvsid NUMBER;

  CURSOR find_dim_value_sets_cur IS
    SELECT flex_value_set_id1
    FROM   fii_dim_mapping_rules  r
    WHERE  r.dimension_short_name = dim_short_name
    AND flex_value_set_id1 is not null
    AND    r.chart_of_accounts_id in
         (SELECT chart_of_accounts_id
          FROM   fii_slg_assignments
          WHERE  source_ledger_group_id =source_lgr_group_id)
    AND    flex_value_set_id1 < value_set_id
    UNION
    SELECT master_value_set_id flex_value_set_id1
    FROM   fii_financial_dimensions_v m
    WHERE  m.dimension_short_name = dim_short_name
    AND    master_value_set_id < value_set_id
    ORDER BY flex_value_set_id1;

BEGIN
  -- Disable the lock mechanism
  RETURN;

  OPEN find_dim_value_sets_cur;
  LOOP
  FETCH find_dim_value_sets_cur INTO fdvsid;

  IF ( find_dim_value_sets_cur%NOTFOUND ) THEN
      CLOSE find_dim_value_sets_cur;
      RETURN ;
  ELSE
  lkname := 'FND_FLEX_AHE_VS_' || to_char(fdvsid);
  dbms_lock.allocate_unique( lkname, lkhandle, expiration_secs);
  lkresult := dbms_lock.release(lkhandle);

  END IF;
  END LOOP;
  CLOSE find_dim_value_sets_cur;
  RETURN;
END release_value_set_lock;


FUNCTION release_dimension_lock(dim_short_name VARCHAR2, source_lgr_group_id NUMBER) RETURN VARCHAR2 is
  lkname   varchar2(128);
  lkhandle varchar2(128);
  expiration_secs constant integer := 864000;
  lkresult integer;
  fdvsid NUMBER;
  success boolean;

  CURSOR find_dim_value_sets_cur IS
    SELECT flex_value_set_id1
    FROM   fii_dim_mapping_rules  r
    WHERE  r.dimension_short_name = dim_short_name
    AND flex_value_set_id1 is not null
    AND    r.chart_of_accounts_id in
         (SELECT chart_of_accounts_id
          FROM   fii_slg_assignments
          WHERE  source_ledger_group_id =source_lgr_group_id)
    UNION
    SELECT master_value_set_id flex_value_set_id1
    FROM   fii_financial_dimensions_v m
    WHERE  m.dimension_short_name = dim_short_name
    ORDER BY flex_value_set_id1;

BEGIN
  -- Disable the lock mechanism
  RETURN ('TRUE');

  success := true;

  OPEN find_dim_value_sets_cur;
  LOOP
  FETCH find_dim_value_sets_cur INTO fdvsid;

  IF ( find_dim_value_sets_cur%NOTFOUND ) THEN
      CLOSE find_dim_value_sets_cur;

	  if (success) then
		RETURN ('TRUE');
	  else
		RETURN ('FALSE');
	  end if;
  ELSE
  lkname := 'FND_FLEX_AHE_VS_' || to_char(fdvsid);

  dbms_lock.allocate_unique( lkname, lkhandle, expiration_secs );

  lkresult := dbms_lock.release(lkhandle);

  if (lkresult <> 0 ) then
      success := false;
  end if;

  END IF;
  END LOOP;
  CLOSE find_dim_value_sets_cur;
  RETURN ('FALSE');

END release_dimension_lock;


PROCEDURE insert_dim_value_sets (dim_short_name VARCHAR2,  source_lgr_group_id NUMBER)
IS
BEGIN
   INSERT INTO FII_DIM_NORM_HIERARCHY
              (parent_flex_value_set_id,
               child_flex_value_set_id,
               parent_flex_value,
               range_attribute,
               child_flex_value_low,
               child_flex_value_high,
               last_update_date,
               last_updated_by,
               creation_date,
               created_by,
               last_update_login )
/*
    SELECT     distinct flex_value_set_id,
               flex_value_set_id,
               parent_flex_value,
               range_attribute,
               child_flex_value_low,
               child_flex_value_high,
               last_update_date,
               last_updated_by,
               creation_date,
               created_by,
               last_update_login
     FROM      FND_FLEX_VALUE_NORM_HIERARCHY
     WHERE     flex_value_set_id in
               (SELECT r.flex_value_set_id1
                FROM   fii_dim_mapping_rules  r
                WHERE  r.dimension_short_name = dim_short_name
                AND    r.chart_of_accounts_id in
                      (SELECT chart_of_accounts_id
                       FROM   fii_slg_assignments
                       WHERE  source_ledger_group_id =source_lgr_group_id))
        OR      flex_value_set_id =
                      (SELECT master_value_set_id
                       FROM   fii_financial_dimensions_v m
                       WHERE  m.dimension_short_name= dim_short_name);
*/
    SELECT     flex_value_set_id,
               flex_value_set_id,
               parent_flex_value,
               range_attribute,
               child_flex_value_low,
               child_flex_value_high,
               last_update_date,
               last_updated_by,
               creation_date,
               created_by,
               last_update_login
     FROM      FND_FLEX_VALUE_NORM_HIERARCHY,
               (
                 SELECT  r.flex_value_set_id1 vs_id
                   FROM  fii_dim_mapping_rules r,
                         (SELECT distinct chart_of_accounts_id
                            FROM fii_slg_assignments
                           WHERE source_ledger_group_id = source_lgr_group_id) s
                  WHERE  r.dimension_short_name = dim_short_name
                    AND  r.chart_of_accounts_id = s.chart_of_accounts_id
                 union
                 SELECT  master_value_set_id vs_id
                   FROM  fii_financial_dimensions m
                  WHERE  m.dimension_short_name = dim_short_name
               )
    WHERE     flex_value_set_id = vs_id;

END insert_dim_value_sets;


FUNCTION flatten_hierarchy (dim_short_name     VARCHAR2,
                            source_lgr_group_id NUMBER,
                            user_id    IN      NUMBER,
                            resp_id    IN      NUMBER,
                            appl_id    IN      NUMBER)  RETURN VARCHAR2
is
  fdvsid NUMBER;
  req_id integer;
  success boolean :=true;

  CURSOR find_dim_value_sets_cur IS
    SELECT flex_value_set_id1
    FROM   fii_dim_mapping_rules  r
    WHERE  r.dimension_short_name = dim_short_name
    AND    r.chart_of_accounts_id in
         (SELECT chart_of_accounts_id
          FROM   fii_slg_assignments
          WHERE  source_ledger_group_id =source_lgr_group_id)
    OR    flex_value_set_id1 in
         (SELECT master_value_set_id
          FROM   fii_financial_dimensions_v m
          WHERE  m.dimension_short_name= r.dimension_short_name);
sid number;
BEGIN
  FND_GLOBAL.APPS_INITIALIZE(user_id, resp_id, appl_id);

  OPEN find_dim_value_sets_cur;
  LOOP
  FETCH find_dim_value_sets_cur INTO fdvsid;

  EXIT WHEN find_dim_value_sets_cur%NOTFOUND;

  req_id := fnd_request.submit_request(
                application => 'FND',
                program     => 'FDFCHY',
                argument1   => TO_CHAR(fdvsid)
                );

  if (req_id=0) then
     success := false;
  end if;

  END LOOP;
  CLOSE find_dim_value_sets_cur;

  if (success) then
    return ('TRUE');
  else
    return ('FALSE');
  end if;

END flatten_hierarchy;


PROCEDURE insert_tl_records is

  cursor installed_lang_cursor is
    select LANGUAGE_CODE from FND_LANGUAGES
    where INSTALLED_FLAG in ('B', 'I');

  lang_code VARCHAR(4);

BEGIN

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
           t1.FLEX_VALUE_ID,
           t1.LAST_UPDATE_DATE,
           t1.LAST_UPDATED_BY,
           t1.CREATION_DATE,
           t1.CREATED_BY,
           t1.LAST_UPDATE_LOGIN,
           t1.DESCRIPTION,
           t1.FLEX_VALUE_MEANING,
           lang_code,
           t1.SOURCE_LANG
         from fnd_flex_values_tl t1 left outer join
	      fnd_flex_values_tl t2
	   on t1.flex_value_id = t2.flex_value_id
	  and t2.language = lang_code
         where t1.language = userenv('LANG')
	 and   t2.flex_value_id is NULL
        );

    END IF;
  END LOOP;

END insert_tl_records;

PROCEDURE insert_tl_records_for_id(value_id number) is
BEGIN

    insert into FND_FLEX_VALUES_TL(
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
    select
        t1.FLEX_VALUE_ID,
        t1.LAST_UPDATE_DATE,
        t1.LAST_UPDATED_BY,
        t1.CREATION_DATE,
        t1.CREATED_BY,
        t1.LAST_UPDATE_LOGIN,
        t1.DESCRIPTION,
        t1.FLEX_VALUE_MEANING,
        ls.LANGUAGE_CODE,
        t1.SOURCE_LANG
    from fnd_flex_values_tl t1, FND_LANGUAGES ls
    where t1.flex_value_id = value_id
    and t1.language = userenv('LANG')
    and ls.INSTALLED_FLAG in ('B', 'I')
    and ls.LANGUAGE_CODE <> userenv('LANG');

END insert_tl_records_for_id;

PROCEDURE delete_tl_records_for_id(value_id number) is
BEGIN

    delete from FND_FLEX_VALUES_TL
    where flex_value_id = value_id
    and language <> userenv('LANG');

END delete_tl_records_for_id;

FUNCTION get_compiled_value_attr(value_set_id NUMBER) RETURN VARCHAR2 is
dvalue	VARCHAR2(30);
cvalue  VARCHAR2(2000);
ct   NUMBER :=0;
CURSOR find_value_attr_cur IS
  SELECT tp.default_value
  FROM   fnd_flex_validation_qualifiers qf,
         fnd_value_attribute_types tp
  WHERE  flex_value_set_id = value_set_id
  AND    qf.value_attribute_type =tp.value_attribute_type
  AND    qf.segment_attribute_type = tp.segment_attribute_type
  AND    qf.id_flex_code = tp.id_flex_code
  AND    qf.id_flex_application_id = tp.application_id
  ORDER BY  qf.assignment_date, qf.value_attribute_type;

BEGIN
  OPEN find_value_attr_cur;
  LOOP
    FETCH find_value_attr_cur INTO dvalue;
      IF ( find_value_attr_cur%NOTFOUND ) THEN
	  CLOSE find_value_attr_cur;
	  RETURN cvalue;
      ELSIF (ct=0) then
          cvalue := dvalue;
      ELSE
          cvalue := cvalue||fnd_global.newline||dvalue;
      END IF;
      ct:= ct+1;
  END LOOP;
  CLOSE find_value_attr_cur;

  RETURN cvalue;

END get_compiled_value_attr;


PROCEDURE launch( dim_short_name         IN VARCHAR2,
                  source_ledger_group_id IN NUMBER) IS

  sessionCookie VARCHAR2(128) := ICX_CALL.ENCRYPT3(ICX_SEC.getSessionCookie());
  lang          VARCHAR2(128) := ICX_SEC.g_language_code;
  -- need to escape slash characters in host argument
  tcfHost       VARCHAR2(128) := wfa_html.conv_special_url_chars(
                                        FND_PROFILE.VALUE('TCF:HOST'));
  tcfPort       VARCHAR2(128) := FND_PROFILE.VALUE('TCF:PORT');
  dbc_file      VARCHAR2(128) := fnd_web_config.database_id;

  error         VARCHAR2(250) := 'You do not have the required security privileges to launch Financial Dimension Hierarchy Manager. Please contact your System Administrator.';

BEGIN

if (icx_sec.validateSession) then

  if (access_test = 'FALSE') then
      htp.p(error);
  else

      fnd_applet_launcher.launch(
        applet_class       => 'oracle.apps.fii.fdhm.client.FinDimHierMgr',

        archive_list       => 'oracle/apps/fii/jar/fiifdhm.jar'
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
                              '&gp7=slgId&gv7=' ||
                                source_ledger_group_id ||
                              '&gp8=dim&gv8=' ||
                                dim_short_name ||
                              '',

        title_app          => 'SQLGL',
        title_msg          => 'GL_FDHM_PAGE_TITLE',
        cache              => 'off'
      );
  end if;

end if;

END launch;

PROCEDURE delete_dim_value_sets(dim_short_name VARCHAR2,
                     source_lgr_group_id NUMBER)
IS
BEGIN
   DELETE FROM fii_dim_norm_hierarchy
   WHERE       parent_flex_value_set_id = child_flex_value_set_id
   AND (       child_flex_value_set_id in
        (SELECT r.flex_value_set_id1
         FROM   fii_dim_mapping_rules  r
         WHERE  r.dimension_short_name = dim_short_name
         AND    r.chart_of_accounts_id in
               (SELECT  chart_of_accounts_id
                FROM    fii_slg_assignments
                WHERE   source_ledger_group_id =source_lgr_group_id))
   OR  child_flex_value_set_id =
            (SELECT  master_value_set_id
             FROM    fii_financial_dimensions_v m
             WHERE   m.dimension_short_name= dim_short_name) );

END delete_dim_value_sets;


PROCEDURE insert_fnd_norm_hier_rec(
                        parent          IN      VARCHAR2,
                        child           IN      VARCHAR2,
                        range_attr      IN      VARCHAR2,
                        range_low       IN      VARCHAR2,
                        range_high      IN      VARCHAR2,
                        value_set_id    IN   NUMBER)
IS
BEGIN
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
                   range_high,
                   SYSDATE,
                   0,
                   SYSDATE,
                   0,
                   fnd_global.login_id);

END insert_fnd_norm_hier_rec;


PROCEDURE delete_fnd_norm_hier_rec(
                        parent          IN      VARCHAR2,
                        child           IN      VARCHAR2,
                        range_attr      IN      VARCHAR2,
                        range_low       IN      VARCHAR2,
                        range_high      IN      VARCHAR2,
                        value_set_id    IN   NUMBER)
IS
BEGIN
     DELETE FROM FND_FLEX_VALUE_NORM_HIERARCHY
     WHERE       flex_value_set_id = value_set_id
     AND         parent_flex_value=parent
     AND         range_attribute= range_attr
     AND         child_flex_value_low= range_low
     AND         child_flex_value_high =  range_high;

END delete_fnd_norm_hier_rec;

FUNCTION access_test RETURN VARCHAR2
IS
BEGIN

  if(fnd_function.test('FII_DIM_FDHM')) then
    RETURN('TRUE');
  else
    RETURN('FALSE');
  end if;
END access_test;

END FII_FDHM_PKG;

/
