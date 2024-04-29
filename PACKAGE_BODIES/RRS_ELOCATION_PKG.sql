--------------------------------------------------------
--  DDL for Package Body RRS_ELOCATION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."RRS_ELOCATION_PKG" AS
/*$Header: RRSELOCB.pls 120.0 2006/01/19 07:51:53 swbhatna noship $*/

--------------------------------------
  -- PUBLIC PROCEDURE rebuild_spatial_indexes
  -- DESCRIPTION
  --   Rebuilds the spatial index on RRS_SITE_TMP.GEOMETRY and RRS_TRADE_AREAS.GEOMETRY.
  --   Rebuilding the spatial index is required so that the index performs adequately,
  --   queries can accurately extract the spatial data and Spatial functions can be called
  --   on these columns
  -- ARGUMENTS
  --   OUT:
  --     errbuf                         Standard AOL concurrent program error buffer.
  --     retcode                        Standard AOL concurrent program return code.
  -- MODIFICATION HISTORY
  --   18/01/2006 swbhatna              Created.
  --------------------------------------
  PROCEDURE rebuild_spatial_indexes (
    errbuf              OUT NOCOPY VARCHAR2,
    retcode             OUT NOCOPY VARCHAR2
  )
  IS
   CURSOR c_index(x_index_name IN VARCHAR2) IS
           SELECT status, domidx_opstatus
           FROM   sys.all_indexes
           WHERE  owner = 'RRS' and index_name = x_index_name;
   l_status                    sys.all_indexes.status%type;
   l_domidx_opstatus           sys.all_indexes.DOMIDX_OPSTATUS%type;
   l_index_name                varchar2(50);
   l_commit_interval	       varchar2(5) := '1000';
   x_drop_index                varchar2(255);
   x_rebuild_string            VARCHAR2(100);
  BEGIN
  l_index_name := 'RRS_SITE_TMP_N1';
  open c_index(l_index_name);
    FETCH c_index into l_status,l_domidx_opstatus;
     IF c_index%NOTFOUND THEN  /* Index is Missing */
	  -- Delete existing and Insert new metadata
	  Update_Index_Metadata(l_index_name);
          -- Create Index
          Create_Index(l_index_name);
     ELSIF c_index%FOUND THEN
         IF nvl(l_status,'NONE') <> 'VALID' OR nvl(l_domidx_opstatus,'NONE') <> 'VALID' THEN  /* Index Is Invalid */
            -- Drop Index
            x_drop_index := 'drop index RRS.'||l_index_name||' force';
            EXECUTE IMMEDIATE x_drop_index;
   	    -- Delete existing and Insert new metadata
  	    Update_Index_Metadata(l_index_name);
            -- Create Index
            Create_Index(l_index_name);
         ELSE /* Index Exists and is Valid */
            -- Initialize the return code
            retcode := '0';
            x_rebuild_string :=  'ALTER INDEX RRS.' || l_index_name || ' REBUILD ' ||
                                 'PARAMETERS(''sdo_commit_interval=' ||
                                 l_commit_interval || ''')';
	    EXECUTE IMMEDIATE x_rebuild_string;
         END IF;   /* Index Is Invalid */
     END IF;    /* Index is Missing */
  close c_index;
  l_index_name := 'RRS_TRADE_AREAS_N1';
  open c_index(l_index_name);
    FETCH c_index into l_status,l_domidx_opstatus;
     IF c_index%NOTFOUND THEN  /* Index is Missing */
	  -- Delete existing and Insert new metadata
	  Update_Index_Metadata(l_index_name);
          -- Create Index
          Create_Index(l_index_name);
     ELSIF c_index%FOUND THEN
         IF nvl(l_status,'') <> 'VALID' OR nvl(l_domidx_opstatus,'') <> 'VALID' THEN  /* Index Is Invalid */
            -- Drop Index
            x_drop_index := 'drop index RRS.'||l_index_name||' force';
            EXECUTE IMMEDIATE x_drop_index;
   	    -- Delete existing and Insert new metadata
  	    Update_Index_Metadata(l_index_name);
            -- Create Index
            Create_Index(l_index_name);
         ELSE /* Index Exists and is Valid */
            -- Initialize the return code
            retcode := '0';
            x_rebuild_string :=  'ALTER INDEX RRS.' || l_index_name || ' REBUILD ' ||
                                 'PARAMETERS(''sdo_commit_interval=' ||
                                 l_commit_interval || ''')';
	    EXECUTE IMMEDIATE x_rebuild_string;
         END IF;   /* Index Is Invalid */
     END IF;    /* Index is Missing */
  close c_index;
EXCEPTION
    WHEN OTHERS THEN
      retcode := '1';
      errbuf := SQLERRM;
END rebuild_spatial_indexes;

PROCEDURE Update_Index_Metadata (
p_index_name   IN  VARCHAR2
)
IS
  x_del_meta                  varchar2(255);
  x_ins_meta                  varchar2(2000);
  l_table_name                varchar2(100);
BEGIN
  IF p_index_name= 'RRS_SITE_TMP_N1' THEN
	  l_table_name := 'RRS_SITE_TMP';
  ELSIF p_index_name= 'RRS_TRADE_AREAS_N1' THEN
	  l_table_name := 'RRS_TRADE_AREAS';
  END IF;
  -- Delete Meta Data
  x_del_meta :=  'Delete from user_sdo_geom_metadata
		  Where  table_name = ''' || l_table_name ||
		  ''' and  column_name= ''GEOMETRY''';
  EXECUTE IMMEDIATE x_del_meta;
  -- Create Meta Data
  x_ins_meta :=  'INSERT INTO user_sdo_geom_metadata (
		  table_name, column_name, diminfo, srid ) VALUES (
		 '''|| l_table_name ||''', ''GEOMETRY'',
		   mdsys.sdo_dim_array(
		   mdsys.sdo_dim_element(''longitude'', -180, 180, 0.00005),
		   mdsys.sdo_dim_element(''latitude'', -90, 90, 0.00005)), 8307 )';
  EXECUTE IMMEDIATE x_ins_meta;
END Update_Index_Metadata;

PROCEDURE Create_Index (
p_index_name   IN  VARCHAR2
)
IS
  object_exists         EXCEPTION;
  column_not_found      EXCEPTION;
  domainobj_exists      EXCEPTION;
  no_metadata_found     EXCEPTION;

  PRAGMA EXCEPTION_INIT(object_exists, -955);
  PRAGMA EXCEPTION_INIT(column_not_found, -904);
  PRAGMA EXCEPTION_INIT(domainobj_exists, -29879);
  PRAGMA EXCEPTION_INIT(no_metadata_found, -13203);

  l_exec_string        VARCHAR2(1000);
  l_table_name         varchar2(100);
  x_dummy              BOOLEAN;
  x_status             varchar2(30);
  x_ind                varchar2(30);
  x_index_owner        varchar2(50);
  check_tspace_exist   varchar2(100);
  physical_tspace_name varchar2(100);

BEGIN
  x_dummy := fnd_installation.GET_APP_INFO('RRS',x_status,x_ind,x_index_owner);
  AD_TSPACE_UTIL.get_tablespace_name('RRS','TRANSACTION_INDEXES','Y',check_tspace_exist,physical_tspace_name);

  IF p_index_name= 'RRS_SITE_TMP_N1' THEN
	  l_table_name := 'RRS_SITE_TMP';
  ELSIF p_index_name= 'RRS_TRADE_AREAS_N1' THEN
	  l_table_name := 'RRS_TRADE_AREAS';
  END IF;
  l_exec_string := 'CREATE INDEX RRS.' || p_index_name ||' ON RRS.'||
                 l_table_name ||'(geometry) INDEXTYPE IS mdsys.spatial_index parameters(''TABLESPACE='||
                 physical_tspace_name||''')';
  -- create the index
  IF(check_tspace_exist = 'Y') THEN
      EXECUTE IMMEDIATE l_exec_string;
  END IF;
EXCEPTION
    WHEN column_not_found THEN
      NULL;
    WHEN object_exists THEN
      NULL;
    WHEN domainobj_exists THEN
      NULL;
    WHEN no_metadata_found THEN
      NULL;
END Create_Index;

END rrs_elocation_pkg;

/
