--------------------------------------------------------
--  DDL for Package Body CN_COLUMN_MAPS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_COLUMN_MAPS_PKG" AS
-- $Header: cncocmb.pls 120.7 2005/09/21 20:51:29 sjustina noship $
--
-- Public Procedures
--
PROCEDURE insert_row (
	X_rowid	 OUT NOCOPY ROWID,
	X_column_map_id          IN OUT NOCOPY cn_column_maps.column_map_id%TYPE,
	X_destination_column_id  cn_column_maps.destination_column_id%TYPE,
	X_table_map_id           cn_column_maps.table_map_id%TYPE,
	X_expression             cn_column_maps.expression%TYPE,
	X_editable               cn_column_maps.editable%TYPE,
	X_modified               cn_column_maps.modified%TYPE,
	X_update_clause          cn_column_maps.update_clause%TYPE,
	X_calc_ext_table_id      cn_column_maps.calc_ext_table_id%TYPE,
    X_creation_date          cn_column_maps.creation_date%TYPE,
    X_created_by             cn_column_maps.created_by%TYPE,
    X_org_id                 cn_column_maps.org_id%TYPE) IS

    X_primary_key		cn_column_maps.column_map_id%TYPE;
  BEGIN

    IF x_column_map_id IS NULL THEN
      SELECT cn_column_maps_s.NEXTVAL
        INTO X_column_map_id
        FROM dual;
    END IF;

    INSERT INTO cn_column_maps
      (object_version_number,
       column_map_id,
       destination_column_id,
       table_map_id,
       expression,
       editable,
       modified,
       update_clause,
       calc_ext_table_id,
       org_id)
      VALUES
      (1,
       X_column_map_id,
       X_destination_column_id,
       X_table_map_id,
       X_expression,
       X_editable,
       X_modified,
       X_update_clause,
       X_calc_ext_table_id,
       X_org_id);

    SELECT ROWID
      INTO X_rowid
      FROM cn_column_maps
     WHERE column_map_id = X_column_map_id
     AND   org_id = X_org_id;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END insert_row;

/*
  PROCEDURE select_row (
        x_recinfo IN OUT NOCOPY cn_column_maps%ROWTYPE) IS
  BEGIN
    -- select row based on column_map_id (primary key)
    IF (x_recinfo.column_map_id IS NOT NULL) THEN

      SELECT * INTO x_recinfo
        FROM cn_column_maps ccm
        WHERE ccm.column_map_id = x_recinfo.column_map_id;

    END IF;
  END select_row;

PROCEDURE lock_row (
	X_column_map_id          cn_column_maps.column_map_id%TYPE,
	X_destination_column_id  cn_column_maps.destination_column_id%TYPE,
	X_table_map_id           cn_column_maps.table_map_id%TYPE,
	X_expression             cn_column_maps.expression%TYPE,
	X_editable               cn_column_maps.editable%TYPE,
	X_modified               cn_column_maps.modified%TYPE,
	X_update_clause          cn_column_maps.update_clause%TYPE,
	X_calc_ext_table_id      cn_column_maps.calc_ext_table_id%TYPE) IS
--
  CURSOR c1 IS SELECT
	destination_column_id,
	table_map_id,
	expression,
	editable,
	modified,
	update_clause,
	calc_ext_table_id
    FROM cn_column_maps
    WHERE column_map_id = x_column_map_id
    FOR UPDATE OF column_map_id NOWAIT;

  tlinfo c1%ROWTYPE;
BEGIN
   OPEN c1;
   FETCH c1 INTO tlinfo;

   IF  tlinfo.table_map_id = x_table_map_id
       AND tlinfo.destination_column_id = x_destination_column_id
       AND tlinfo.modified = x_modified
       AND (tlinfo.editable = x_editable OR
            (tlinfo.editable IS NULL AND x_editable IS NULL))
       AND (tlinfo.expression = x_expression OR
            (tlinfo.expression IS NULL AND x_expression IS NULL))
       AND (tlinfo.update_clause = x_update_clause OR
            (tlinfo.update_clause IS NULL AND x_update_clause IS NULL))
       AND (tlinfo.calc_ext_table_id = x_calc_ext_table_id OR
            (tlinfo.calc_ext_table_id IS NULL AND x_calc_ext_table_id IS NULL))
   THEN
     NULL;
   ELSE
     CLOSE c1;
     fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
     app_exception.raise_exception;
   END IF;
  CLOSE c1;
  RETURN;
END lock_row;
*/

PROCEDURE update_row (
	X_column_map_id          cn_column_maps.column_map_id%TYPE,
	X_destination_column_id  cn_column_maps.destination_column_id%TYPE,
	X_table_map_id           cn_column_maps.table_map_id%TYPE,
	X_expression             cn_column_maps.expression%TYPE,
	X_editable               cn_column_maps.editable%TYPE,
	X_modified               cn_column_maps.modified%TYPE,
	X_update_clause          cn_column_maps.update_clause%TYPE,
	X_calc_ext_table_id      cn_column_maps.calc_ext_table_id%TYPE,
    X_last_update_date       cn_column_maps.last_update_date%TYPE,
    X_last_updated_by        cn_column_maps.last_updated_by%TYPE,
    X_last_update_login      cn_column_maps.last_update_login%TYPE,
	X_object_version_number  IN OUT NOCOPY NUMBER ,
    x_org_id                 IN NUMBER) IS

	   CURSOR l_ovn_csr IS
	      SELECT object_version_number
		FROM cn_column_maps
		WHERE column_map_id = x_column_map_id
		and org_id = x_org_id;

	   l_ovn  NUMBER;

BEGIN

   OPEN l_ovn_csr;
   FETCH l_ovn_csr INTO l_ovn;
   CLOSE l_ovn_csr;

   SELECT DECODE(x_object_version_number, cn_api.G_MISS_NUM,
		 l_ovn,x_object_version_number)
     INTO l_ovn FROM dual;

  UPDATE cn_column_maps set
    destination_column_id = x_destination_column_id,
    table_map_id = x_table_map_id,
    expression = x_expression,
    editable = x_editable,
    modified = x_modified,
    update_clause = x_update_clause,
    calc_ext_table_id = x_calc_ext_table_id,
    last_update_date = x_last_update_date,
    last_updated_by = x_last_updated_by,
    last_update_login = x_last_update_login,
    object_version_number = Nvl(l_ovn,0) + 1
  WHERE column_map_id = x_column_map_id
  AND org_id = x_org_id;

  X_object_version_number := l_ovn;

  IF (SQL%NOTFOUND) THEN
    RAISE NO_DATA_FOUND;
  END IF;
END update_row;

PROCEDURE delete_row (
  X_column_map_id IN NUMBER,
  x_org_id        IN NUMBER
) IS
BEGIN
  DELETE FROM cn_column_maps
  WHERE column_map_id = x_column_map_id
  AND  org_id = x_org_id;

  IF (SQL%NOTFOUND) THEN
    RAISE NO_DATA_FOUND;
  END IF;

END delete_row;

PROCEDURE load_row(x_COLUMN_MAP_ID in varchar2,
                   x_DESTINATION_COLUMN_ID in varchar2,
                   x_TABLE_MAP_ID in varchar2,
                   x_LAST_UPDATE_DATE in varchar2,
                   x_LAST_UPDATED_BY in varchar2,
                   x_CREATION_DATE in varchar2,
                   x_CREATED_BY in varchar2,
                   x_LAST_UPDATE_LOGIN in varchar2,
                   x_SOURCE_COLUMN_ID in varchar2,
                   x_DRIVING_COLUMN_ID in varchar2,
                   x_EXPRESSION in varchar2,
                   x_AGGREGATE_FUNCTION in varchar2,
                   x_SEED_COLUMN_MAP_ID in varchar2,
                   x_GROUP_BY_FLAG in varchar2,
                   x_UNIQUE_FLAG in varchar2,
                   x_ORG_ID in varchar2,
                   x_UPDATE_CLAUSE in varchar2,
                   x_MODIFIED in varchar2,
                   x_EDITABLE in varchar2,
                   x_CALC_EXT_TABLE_ID in varchar2,
                   x_OBJECT_VERSION_NUMBER in varchar2,
                   x_SECURITY_GROUP_ID in varchar2,
                   x_APPLICATION_SHORT_NAME in varchar2,
                   x_OWNER in varchar2)
IS
	USER_ID NUMBER;
BEGIN
    if (x_COLUMN_MAP_ID is NOT NULL) then

		-- Check whether SEED Data or Custom Data you are uploading
		IF (X_OWNER IS NOT NULL) AND (X_OWNER = 'SEED') THEN
      			USER_ID := 1;
    		ELSE
      			USER_ID := 0;
   		END IF;

   		update cn_column_maps_all set
   		  DESTINATION_COLUMN_ID = to_number(x_DESTINATION_COLUMN_ID),
   		  TABLE_MAP_ID          = to_number(x_TABLE_MAP_ID),
   		  LAST_UPDATE_DATE      = to_date(x_LAST_UPDATE_DATE, 'DD-MM-YYYY'),
   		  LAST_UPDATED_BY       = to_number(x_LAST_UPDATED_BY),
   		  CREATION_DATE         = to_date(x_CREATION_DATE, 'DD-MM-YYYY'),
   		  CREATED_BY            = to_number(x_CREATED_BY),
   		  LAST_UPDATE_LOGIN     = to_number(x_LAST_UPDATE_LOGIN),
   		  SOURCE_COLUMN_ID      = to_number(x_SOURCE_COLUMN_ID),
   		  DRIVING_COLUMN_ID     = to_number(x_DRIVING_COLUMN_ID),
   		  EXPRESSION            = x_EXPRESSION,
   		  AGGREGATE_FUNCTION    = x_AGGREGATE_FUNCTION,
   		  SEED_COLUMN_MAP_ID    = to_number(x_SEED_COLUMN_MAP_ID),
   		  GROUP_BY_FLAG         = x_GROUP_BY_FLAG,
   		  UNIQUE_FLAG           = x_UNIQUE_FLAG,
   		  ORG_ID                = to_number(x_ORG_ID),
   		  UPDATE_CLAUSE         = x_UPDATE_CLAUSE,
   		  MODIFIED              = x_MODIFIED,
   		  EDITABLE              = x_EDITABLE,
   		  CALC_EXT_TABLE_ID     = to_number(x_CALC_EXT_TABLE_ID),
   		  OBJECT_VERSION_NUMBER = to_number(x_OBJECT_VERSION_NUMBER),
   		  SECURITY_GROUP_ID     = to_number(x_SECURITY_GROUP_ID)
 		where COLUMN_MAP_ID = x_COLUMN_MAP_ID
 		  and ORG_ID = x_ORG_ID;

	    IF (SQL%NOTFOUND)  THEN
     			-- Insert new record to CN_OBJECTS_TABLE table
			insert into cn_column_maps_all
			(COLUMN_MAP_ID,
             DESTINATION_COLUMN_ID,
             TABLE_MAP_ID,
             LAST_UPDATE_DATE,
             LAST_UPDATED_BY,
             CREATION_DATE,
             CREATED_BY,
             LAST_UPDATE_LOGIN,
             SOURCE_COLUMN_ID,
             DRIVING_COLUMN_ID,
             EXPRESSION,
             AGGREGATE_FUNCTION,
             SEED_COLUMN_MAP_ID,
             GROUP_BY_FLAG,
             UNIQUE_FLAG,
             ORG_ID,
             UPDATE_CLAUSE,
             MODIFIED,
             EDITABLE,
             CALC_EXT_TABLE_ID,
             OBJECT_VERSION_NUMBER,
             SECURITY_GROUP_ID
			)
			values
			(to_number(x_COLUMN_MAP_ID),
			 to_number(x_DESTINATION_COLUMN_ID),
             to_number(x_TABLE_MAP_ID),
             to_date(x_LAST_UPDATE_DATE, 'DD-MM-YYYY'),
             to_number(x_LAST_UPDATED_BY),
             to_date(x_CREATION_DATE, 'DD-MM-YYYY'),
             to_number(x_CREATED_BY),
             to_number(x_LAST_UPDATE_LOGIN),
             to_number(x_SOURCE_COLUMN_ID),
             to_number(x_DRIVING_COLUMN_ID),
             x_EXPRESSION,
             x_AGGREGATE_FUNCTION,
             to_number(x_SEED_COLUMN_MAP_ID),
             x_GROUP_BY_FLAG,
             x_UNIQUE_FLAG,
             to_number(x_ORG_ID),
             x_UPDATE_CLAUSE,
             x_MODIFIED,
             x_EDITABLE,
             to_number(x_CALC_EXT_TABLE_ID),
             to_number(x_OBJECT_VERSION_NUMBER),
             to_number(x_SECURITY_GROUP_ID)
			);
		end if;
    end if;
END load_row;

PROCEDURE load_seed_row(x_UPLOAD_MODE in varchar2,
                        x_COLUMN_MAP_ID in varchar2,
                        x_DESTINATION_COLUMN_ID in varchar2,
                        x_TABLE_MAP_ID in varchar2,
                        x_LAST_UPDATE_DATE in varchar2,
                        x_LAST_UPDATED_BY in varchar2,
                        x_CREATION_DATE in varchar2,
                        x_CREATED_BY in varchar2,
                        x_LAST_UPDATE_LOGIN in varchar2,
                        x_SOURCE_COLUMN_ID in varchar2,
                        x_DRIVING_COLUMN_ID in varchar2,
                        x_EXPRESSION in varchar2,
                        x_AGGREGATE_FUNCTION in varchar2,
                        x_SEED_COLUMN_MAP_ID in varchar2,
                        x_GROUP_BY_FLAG in varchar2,
                        x_UNIQUE_FLAG in varchar2,
                        x_ORG_ID in varchar2,
                        x_UPDATE_CLAUSE in varchar2,
                        x_MODIFIED in varchar2,
                        x_EDITABLE in varchar2,
                        x_CALC_EXT_TABLE_ID in varchar2,
                        x_OBJECT_VERSION_NUMBER in varchar2,
                        x_SECURITY_GROUP_ID in varchar2,
                        x_APPLICATION_SHORT_NAME in varchar2,
                        x_OWNER in varchar2)
IS
BEGIN
     if (x_upload_mode = 'NLS') then
       --CN_COLUMN_MAPS_PKG.TRANSLATE_ROW(x_owner);
       -- As this ldt is not required to loaded translated data, you could leave it blank.
	    null;
     else
         CN_COLUMN_MAPS_PKG.load_row(x_COLUMN_MAP_ID,
                        x_DESTINATION_COLUMN_ID,
                        x_TABLE_MAP_ID,
                        x_LAST_UPDATE_DATE,
                        x_LAST_UPDATED_BY,
                        x_CREATION_DATE,
                        x_CREATED_BY,
                        x_LAST_UPDATE_LOGIN,
                        x_SOURCE_COLUMN_ID,
                        x_DRIVING_COLUMN_ID,
                        x_EXPRESSION,
                        x_AGGREGATE_FUNCTION,
                        x_SEED_COLUMN_MAP_ID,
                        x_GROUP_BY_FLAG,
                        x_UNIQUE_FLAG,
                        x_ORG_ID,
                        x_UPDATE_CLAUSE,
                        x_MODIFIED,
                        x_EDITABLE,
                        x_CALC_EXT_TABLE_ID,
                        x_OBJECT_VERSION_NUMBER,
                        x_SECURITY_GROUP_ID,
                        x_APPLICATION_SHORT_NAME,
                        x_OWNER);
         null;
     end if;
END load_seed_row;


END cn_column_maps_pkg;

/
