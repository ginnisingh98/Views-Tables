--------------------------------------------------------
--  DDL for Package Body CN_TABLE_MAPS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_TABLE_MAPS_PKG" AS
-- $Header: cncotmb.pls 120.5 2005/10/24 00:45:41 apink noship $
--
-- Public Procedures
--

  PROCEDURE insert_row (
	X_rowid		            OUT NOCOPY ROWID,
	X_table_map_id             IN OUT NOCOPY cn_table_maps.table_map_id%TYPE,
	X_mapping_type             cn_table_maps.mapping_type%TYPE,
	X_module_id                cn_table_maps.module_id%TYPE,
	X_source_table_id          cn_table_maps.source_table_id%TYPE,
	X_source_tbl_pkcol_id      cn_table_maps.source_tbl_pkcol_id%TYPE,
	X_destination_table_id     cn_table_maps.destination_table_id%TYPE,
	X_source_hdr_tbl_pkcol_id  cn_table_maps.source_hdr_tbl_pkcol_id%TYPE,
	X_source_tbl_hdr_fkcol_id  cn_table_maps.source_tbl_hdr_fkcol_id%TYPE,
	X_notify_where             cn_table_maps.notify_where%TYPE,
	X_collect_where            cn_table_maps.collect_where%TYPE,
	X_delete_flag              cn_table_maps.delete_flag%TYPE,
    X_creation_date            cn_table_maps.creation_date%TYPE,
    X_created_by               cn_table_maps.created_by%TYPE,
    X_org_id                   cn_table_maps.org_id%TYPE) IS

  BEGIN

    IF X_table_map_id IS NULL THEN
      SELECT cn_table_maps_s.NEXTVAL
        INTO X_table_map_id
        FROM dual;
    END IF;

    INSERT INTO cn_table_maps (
	object_version_number,
	table_map_id,
	mapping_type,
	module_id,
	source_table_id,
	source_tbl_pkcol_id,
	destination_table_id,
	source_hdr_tbl_pkcol_id,
	source_tbl_hdr_fkcol_id,
	notify_where,
	collect_where,
	delete_flag,
    org_id,     -- Modified For R12 MOAC
    creation_date, -- Modified For R12
    created_by) -- Modified For R12
      VALUES (1,
	      X_table_map_id,
	      X_mapping_type,
	      X_module_id,
	      X_source_table_id,
	      X_source_tbl_pkcol_id,
	      X_destination_table_id,
	      X_source_hdr_tbl_pkcol_id,
	      X_source_tbl_hdr_fkcol_id,
	      X_notify_where,
	      X_collect_where,
	      X_delete_flag,
          X_org_id,        -- Modified For R12 MOAC
          X_creation_date, -- Modified For R12
          X_created_by);    -- Modified For R12

    SELECT ROWID
      INTO X_rowid
      FROM cn_table_maps
     WHERE table_map_id = X_table_map_id
     AND   org_id = X_org_id;   -- Modified For R12 MOAC

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END insert_row;

PROCEDURE lock_row (
	X_table_map_id             cn_table_maps.table_map_id%TYPE,
	X_mapping_type             cn_table_maps.mapping_type%TYPE,
	X_module_id                cn_table_maps.module_id%TYPE,
	X_source_table_id          cn_table_maps.source_table_id%TYPE,
	X_source_tbl_pkcol_id      cn_table_maps.source_tbl_pkcol_id%TYPE,
	X_destination_table_id     cn_table_maps.destination_table_id%TYPE,
	X_source_hdr_tbl_pkcol_id      cn_table_maps.source_hdr_tbl_pkcol_id%TYPE,
	X_source_tbl_hdr_fkcol_id  cn_table_maps.source_tbl_hdr_fkcol_id%TYPE,
	X_notify_where             cn_table_maps.notify_where%TYPE,
	X_collect_where            cn_table_maps.collect_where%TYPE,
	X_delete_flag              cn_table_maps.delete_flag%TYPE) IS
--
  CURSOR c1 IS SELECT
	mapping_type,
	module_id,
	source_table_id,
	source_tbl_pkcol_id,
	destination_table_id,
	source_hdr_tbl_pkcol_id,
	source_tbl_hdr_fkcol_id,
	notify_where,
	collect_where,
	delete_flag
    FROM cn_table_maps
    WHERE table_map_id = x_table_map_id
    FOR UPDATE OF table_map_id NOWAIT;

  tlinfo c1%ROWTYPE;
BEGIN
   OPEN c1;
   FETCH c1 INTO tlinfo;

   if tlinfo.mapping_type = x_mapping_type
       AND tlinfo.module_id = x_module_id
       AND tlinfo.source_table_id = x_source_table_id
       AND tlinfo.destination_table_id = x_destination_table_id
       AND (tlinfo.source_tbl_pkcol_id = x_source_tbl_pkcol_id OR
            (tlinfo.source_tbl_pkcol_id IS NULL AND x_source_tbl_pkcol_id IS NULL))
       AND (tlinfo.source_hdr_tbl_pkcol_id = x_source_hdr_tbl_pkcol_id OR
            (tlinfo.source_hdr_tbl_pkcol_id IS NULL AND x_source_hdr_tbl_pkcol_id IS NULL))
       AND (tlinfo.source_tbl_hdr_fkcol_id = x_source_tbl_hdr_fkcol_id OR
            (tlinfo.source_tbl_hdr_fkcol_id IS NULL AND x_source_tbl_hdr_fkcol_id IS NULL))
       AND (tlinfo.notify_where = x_notify_where OR
            (tlinfo.notify_where IS NULL AND x_notify_where IS NULL))
       AND (tlinfo.collect_where = x_collect_where OR
            (tlinfo.collect_where IS NULL AND x_collect_where IS NULL))
       AND (tlinfo.delete_flag = x_delete_flag OR
            (tlinfo.delete_flag IS NULL AND x_delete_flag IS NULL))
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

PROCEDURE update_row (
	X_table_map_id             cn_table_maps.table_map_id%TYPE,
	X_mapping_type             cn_table_maps.mapping_type%TYPE,
	X_module_id                cn_table_maps.module_id%TYPE,
	X_source_table_id          cn_table_maps.source_table_id%TYPE,
	X_source_tbl_pkcol_id      cn_table_maps.source_tbl_pkcol_id%TYPE,
	X_destination_table_id     cn_table_maps.destination_table_id%TYPE,
	X_source_hdr_tbl_pkcol_id      cn_table_maps.source_hdr_tbl_pkcol_id%TYPE,
	X_source_tbl_hdr_fkcol_id  cn_table_maps.source_tbl_hdr_fkcol_id%TYPE,
	X_notify_where             cn_table_maps.notify_where%TYPE,
	X_collect_where            cn_table_maps.collect_where%TYPE,
	X_delete_flag              cn_table_maps.delete_flag%TYPE,
     X_last_update_date         cn_table_maps.last_update_date%TYPE,
     X_last_updated_by          cn_table_maps.last_updated_by%TYPE,
     X_last_update_login        cn_table_maps.last_update_login%TYPE,
     x_object_version_number   NUMBER := cn_api.G_MISS_NUM,
     x_org_id       cn_table_maps.org_id%TYPE) IS


        CURSOR l_ovn_csr IS
	   SELECT object_version_number
	     FROM cn_table_maps
	     WHERE table_map_id = x_table_map_id
         AND org_id = x_org_id;

     l_ovn  NUMBER;
BEGIN

   OPEN l_ovn_csr;
   FETCH l_ovn_csr INTO l_ovn;
   CLOSE l_ovn_csr;

   SELECT DECODE(x_object_version_number, cn_api.G_MISS_NUM,
		 l_ovn,x_object_version_number)
     INTO l_ovn FROM dual;

   UPDATE cn_table_maps SET
	mapping_type = x_mapping_type,
	module_id = x_module_id,
	source_table_id = x_source_table_id,
	source_tbl_pkcol_id = x_source_tbl_pkcol_id,
	destination_table_id = x_destination_table_id,
	source_hdr_tbl_pkcol_id = x_source_hdr_tbl_pkcol_id,
	source_tbl_hdr_fkcol_id = x_source_tbl_hdr_fkcol_id,
	notify_where = x_notify_where,
	collect_where = x_collect_where,
	delete_flag = x_delete_flag,
     last_update_date = x_last_update_date,
     last_updated_by = x_last_updated_by,
     last_update_login = x_last_update_login,
        object_version_number = Nvl(l_ovn,0) + 1
  WHERE table_map_id = x_table_map_id
  AND org_id = x_org_id;

  IF (SQL%NOTFOUND) THEN
    RAISE NO_DATA_FOUND;
  END IF;
END update_row;

PROCEDURE delete_row (
  X_table_map_id IN NUMBER,
  X_org_id IN NUMBER
) IS
BEGIN
  DELETE FROM cn_table_maps
  WHERE table_map_id = x_table_map_id
  AND org_id = X_org_id;

  IF (SQL%NOTFOUND) THEN
    RAISE NO_DATA_FOUND;
  END IF;

END delete_row;

PROCEDURE load_row(x_TABLE_MAP_ID in varchar2,
                   x_MAPPING_TYPE in varchar2,
                   x_SOURCE_TABLE_ID in varchar2,
                   x_DESTINATION_TABLE_ID in varchar2,
                   x_MODULE_ID in varchar2,
                   x_LAST_UPDATE_DATE in varchar2,
                   x_LAST_UPDATED_BY in varchar2,
                   x_CREATION_DATE in varchar2,
                   x_CREATED_BY in varchar2,
                   x_DESCRIPTION in varchar2,
                   x_SEED_TABLE_MAP_ID in varchar2,
                   x_ORG_ID in varchar2,
                   x_LAST_UPDATE_LOGIN in varchar2,
                   x_SOURCE_TBL_PKCOL_ID in varchar2,
                   x_DELETE_FLAG in varchar2,
                   x_SOURCE_HDR_TBL_PKCOL_ID in varchar2,
                   x_SOURCE_TBL_HDR_FKCOL_ID in varchar2,
                   x_NOTIFY_WHERE in varchar2,
                   x_COLLECT_WHERE in varchar2,
                   x_OBJECT_VERSION_NUMBER in varchar2,
                   x_SECURITY_GROUP_ID in varchar2,
                   x_FILTER in varchar2,
                   x_APPLICATION_SHORT_NAME in varchar2,
                   x_OWNER in varchar2)
IS
	USER_ID NUMBER;
BEGIN
    if (x_TABLE_MAP_ID is NOT NULL) then

		-- Check whether SEED Data or Custom Data you are uploading
		IF (X_OWNER IS NOT NULL) AND (X_OWNER = 'SEED') THEN
      			USER_ID := 1;
    		ELSE
      			USER_ID := 0;
   		END IF;

   		update cn_table_maps_all set
   		  MAPPING_TYPE            = x_MAPPING_TYPE,
   		  SOURCE_TABLE_ID         = to_number(x_SOURCE_TABLE_ID),
   		  DESTINATION_TABLE_ID    = to_number(x_DESTINATION_TABLE_ID),
   		  MODULE_ID               = to_number(x_MODULE_ID),
   		  LAST_UPDATE_DATE        = to_date(x_LAST_UPDATE_DATE, 'DD-MM-YYYY'),
   		  LAST_UPDATED_BY         = to_number(x_LAST_UPDATED_BY),
   		  CREATION_DATE           = to_date(x_CREATION_DATE, 'DD-MM-YYYY'),
   		  CREATED_BY              = to_number(x_CREATED_BY),
   		  DESCRIPTION             = x_DESCRIPTION,
   		  SEED_TABLE_MAP_ID       = to_number(x_SEED_TABLE_MAP_ID),
   		  ORG_ID                  = to_number(x_ORG_ID),
   		  LAST_UPDATE_LOGIN       = to_number(x_LAST_UPDATE_LOGIN),
   		  SOURCE_TBL_PKCOL_ID     = to_number(x_SOURCE_TBL_PKCOL_ID),
   		  DELETE_FLAG             = x_DELETE_FLAG,
   		  SOURCE_HDR_TBL_PKCOL_ID = to_number(x_SOURCE_HDR_TBL_PKCOL_ID),
   		  SOURCE_TBL_HDR_FKCOL_ID = to_number(x_SOURCE_TBL_HDR_FKCOL_ID),
   		  NOTIFY_WHERE            = x_NOTIFY_WHERE,
   		  COLLECT_WHERE           = x_COLLECT_WHERE,
   		  OBJECT_VERSION_NUMBER   = to_number(x_OBJECT_VERSION_NUMBER),
   		  SECURITY_GROUP_ID       = to_number(x_SECURITY_GROUP_ID),
   		  FILTER                  = x_FILTER
 		where TABLE_MAP_ID = x_TABLE_MAP_ID
 		  and ORG_ID = x_ORG_ID;

	    IF (SQL%NOTFOUND)  THEN
     			-- Insert new record to CN_OBJECTS_TABLE table
			insert into cn_table_maps_all
			(TABLE_MAP_ID,
             MAPPING_TYPE,
             SOURCE_TABLE_ID,
             DESTINATION_TABLE_ID,
             MODULE_ID,
             LAST_UPDATE_DATE,
             LAST_UPDATED_BY,
             CREATION_DATE,
             CREATED_BY,
             DESCRIPTION,
             SEED_TABLE_MAP_ID,
             ORG_ID,
             LAST_UPDATE_LOGIN,
             SOURCE_TBL_PKCOL_ID,
             DELETE_FLAG,
             SOURCE_HDR_TBL_PKCOL_ID,
             SOURCE_TBL_HDR_FKCOL_ID,
             NOTIFY_WHERE,
             COLLECT_WHERE,
             OBJECT_VERSION_NUMBER,
             SECURITY_GROUP_ID,
             FILTER
			)
			values
			(to_number(x_TABLE_MAP_ID),
             x_MAPPING_TYPE,
             to_number(x_SOURCE_TABLE_ID),
             to_number(x_DESTINATION_TABLE_ID),
             to_number(x_MODULE_ID),
             to_date(x_LAST_UPDATE_DATE, 'DD-MM-YYYY'),
             to_number(x_LAST_UPDATED_BY),
             to_date(x_CREATION_DATE, 'DD-MM-YYYY'),
             to_number(x_CREATED_BY),
             x_DESCRIPTION,
             to_number(x_SEED_TABLE_MAP_ID),
             to_number(x_ORG_ID),
             to_number(x_LAST_UPDATE_LOGIN),
             to_number(x_SOURCE_TBL_PKCOL_ID),
             x_DELETE_FLAG,
             to_number(x_SOURCE_HDR_TBL_PKCOL_ID),
             to_number(x_SOURCE_TBL_HDR_FKCOL_ID),
             x_NOTIFY_WHERE,
             x_COLLECT_WHERE,
             to_number(x_OBJECT_VERSION_NUMBER),
             to_number(x_SECURITY_GROUP_ID),
             x_FILTER
			);
		end if;
    end if;
END load_row;

PROCEDURE load_seed_row(x_UPLOAD_MODE in varchar2,
                        x_TABLE_MAP_ID in varchar2,
                        x_MAPPING_TYPE in varchar2,
                        x_SOURCE_TABLE_ID in varchar2,
                        x_DESTINATION_TABLE_ID in varchar2,
                        x_MODULE_ID in varchar2,
                        x_LAST_UPDATE_DATE in varchar2,
                        x_LAST_UPDATED_BY in varchar2,
                        x_CREATION_DATE in varchar2,
                        x_CREATED_BY in varchar2,
                        x_DESCRIPTION in varchar2,
                        x_SEED_TABLE_MAP_ID in varchar2,
                        x_ORG_ID in varchar2,
                        x_LAST_UPDATE_LOGIN in varchar2,
                        x_SOURCE_TBL_PKCOL_ID in varchar2,
                        x_DELETE_FLAG in varchar2,
                        x_SOURCE_HDR_TBL_PKCOL_ID in varchar2,
                        x_SOURCE_TBL_HDR_FKCOL_ID in varchar2,
                        x_NOTIFY_WHERE in varchar2,
                        x_COLLECT_WHERE in varchar2,
                        x_OBJECT_VERSION_NUMBER in varchar2,
                        x_SECURITY_GROUP_ID in varchar2,
                        x_FILTER in varchar2,
                        x_APPLICATION_SHORT_NAME in varchar2,
                        x_OWNER in varchar2)
IS
BEGIN
     if (x_upload_mode = 'NLS') then
       --CN_TABLE_MAPS_PKG.TRANSLATE_ROW(x_owner);
       -- As this ldt is not required to loaded translated data, you could leave it blank.
	    null;
     else
         CN_TABLE_MAPS_PKG.load_row(x_TABLE_MAP_ID,
                        x_MAPPING_TYPE,
                        x_SOURCE_TABLE_ID,
                        x_DESTINATION_TABLE_ID,
                        x_MODULE_ID,
                        x_LAST_UPDATE_DATE,
                        x_LAST_UPDATED_BY,
                        x_CREATION_DATE,
                        x_CREATED_BY,
                        x_DESCRIPTION,
                        x_SEED_TABLE_MAP_ID,
                        x_ORG_ID,
                        x_LAST_UPDATE_LOGIN,
                        x_SOURCE_TBL_PKCOL_ID,
                        x_DELETE_FLAG,
                        x_SOURCE_HDR_TBL_PKCOL_ID,
                        x_SOURCE_TBL_HDR_FKCOL_ID,
                        x_NOTIFY_WHERE,
                        x_COLLECT_WHERE,
                        x_OBJECT_VERSION_NUMBER,
                        x_SECURITY_GROUP_ID,
                        x_FILTER,
                        x_APPLICATION_SHORT_NAME,
                        x_OWNER);
         null;
     end if;
END load_seed_row;

END cn_table_maps_pkg;

/
