--------------------------------------------------------
--  DDL for Package Body CN_SCA_UTL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_SCA_UTL_PVT" AS
-- $Header: cnvscaub.pls 120.1 2005/09/15 14:46:56 rchenna noship $
-- +======================================================================+
-- |                Copyright (c) 1994 Oracle Corporation                 |
-- |                   Redwood Shores, California, USA                    |
-- |                        All rights reserved.                          |
-- +======================================================================+
--
-- Package Name
--   CN_SCA_UTL_PVT
-- Purpose
--   This package has utilities and being used by other Rules Engine
--   PL/SQL packages.
-- History
--   06/23/03   Rao.Chenna         Created

--+
--+ Global Variables
--+

   G_PKG_NAME		CONSTANT VARCHAR2(30) := 'CN_SCA_UTL_PVT';
   G_FILE_NAME          CONSTANT VARCHAR2(12) := 'cnvscaub.pls';
   g_cn_debug           VARCHAR2(1) := fnd_profile.value('CN_DEBUG');

PROCEDURE debugmsg(msg VARCHAR2) IS
BEGIN

    IF g_cn_debug = 'Y' THEN
        cn_message_pkg.debug(substr(msg,1,254));
    END IF;

END debugmsg;

FUNCTION get_valuset_query (l_valueset_id NUMBER) RETURN VARCHAR2 IS
    l_valueset_r   fnd_vset.valueset_r;
    l_table_r      fnd_vset.table_r;
    l_valueset_dr  fnd_vset.valueset_dr;
    l_select_stmt  VARCHAR2(4000);
    l_select       VARCHAR2(4000);
    l_from         VARCHAR2(4000);
    l_where        VARCHAR2(4000);
  BEGIN
    -- get the SQL statement for the record qroup
    fnd_vset.get_valueset(l_valueset_id, l_valueset_r, l_valueset_dr);
    l_select  := l_valueset_r.table_info.value_column_name ||' column_name, ' ||
     		      NVL(l_valueset_r.table_info.id_column_name, 'null') || ' column_id, ' ||
                  NVL(l_valueset_r.table_info.meaning_column_name, 'null') || ' column_meaning';

    l_from :=  l_valueset_r.table_info.table_name;

    IF l_valueset_r.table_info.where_clause IS NULL THEN
     l_where := ' ';
    ELSE
     l_where := l_valueset_r.table_info.where_clause;
    END IF;

   l_select_stmt := 'Select ' || l_select || ' from ' || l_from || ' ' || l_where ;

   return l_select_stmt;
END;
--
PROCEDURE manage_indexes(
        p_transaction_source    IN      	VARCHAR2,
        p_org_id		IN		NUMBER,
	x_return_status		OUT NOCOPY 	VARCHAR2) IS

--+
--+ Local Variables Section
--+

   v_statement 		VARCHAR2(2000);
   s_statement 		VARCHAR2(2000);
   l_table_tablespace  	VARCHAR2(100);
   l_idx_tablespace    	VARCHAR2(100);
   l_ora_username      	VARCHAR2(100);
   l_app_short_name    	VARCHAR2(20) := 'CN';
   l_trans_idx_name    	VARCHAR2(30);
   l_cn_schema          VARCHAR2(200);
   l_schema_return      BOOLEAN;
   l_status             VARCHAR2(2);
   l_industry           VARCHAR2(2);
   l_oracle_schema      VARCHAR2(32);


--+
--+ Cursor Definition
--+

CURSOR attr_cur IS
   SELECT /*+ ORDERED INDEX(b) */ a.src_column_name
     FROM cn_sca_rule_attributes_all_b a,
          cn_sca_conditions b
    WHERE a.sca_rule_attribute_id = b.sca_rule_attribute_id
      AND a.transaction_source = p_transaction_source
      AND a.enabled_flag = 'Y'
      AND a.org_id = p_org_id
    GROUP BY a.src_column_name;

CURSOR index_cur(l_table_owner VARCHAR2) IS
   SELECT aidx.owner, aidx.index_name
     FROM all_indexes aidx
    WHERE aidx.table_name = 'CN_SCA_HEADERS_INTERFACE_ALL'
      AND aidx.table_owner = l_table_owner
      AND aidx.index_name LIKE 'CN_SCA_HEADERS_INTERFACE_A%';

BEGIN

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   SELECT application_short_name
     INTO l_cn_schema
     FROM fnd_application
    WHERE application_id = 283;

   l_schema_return := fnd_installation.get_app_info(
                         l_cn_schema,
                         l_status,
                         l_industry,
                         l_oracle_schema);
   debugmsg('l_oracle_schema value: '||l_oracle_schema);

   --+
   --+ Delete existing indexes from cn_sca_headers_interface_all table based
   --+ on the cursor.
   --+

   debugmsg('dropping existing indexes ...');

   BEGIN

      FOR idx IN index_cur(l_oracle_schema)
      LOOP

         EXECUTE IMMEDIATE 'DROP INDEX '||idx.owner||'.'|| idx.index_name;

	 debugmsg('Dropped index :'||idx.index_name);

      END LOOP;

   EXCEPTION
      WHEN OTHERS THEN
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	 debugmsg('Error while dropping the existing indexes');
	 debugmsg('Oracle Error: '||SQLERRM);
	 RAISE;
   END;

   debugmsg('Dropped all indexes ...');

   --+
   --+ Creating new indexes based on the Rule Attributes used in a given
   --+ Transaction Source
   --+

   SELECT i.tablespace, i.index_tablespace, u.oracle_username
     INTO l_table_tablespace, l_idx_tablespace, l_ora_username
     FROM fnd_product_installations i, fnd_application a, fnd_oracle_userid u
    WHERE a.application_short_name = l_cn_schema
      AND a.application_id = i.application_id
      AND u.oracle_id = i.oracle_id;

   s_statement := s_statement || ' TABLESPACE ' ||  l_idx_tablespace ;
   s_statement := s_statement || ' STORAGE(INITIAL 1M NEXT 1M MINEXTENTS 1 MAXEXTENTS UNLIMITED ';
   s_statement := s_statement || ' PCTINCREASE 0 FREELISTS 4 FREELIST GROUPS 4 BUFFER_POOL DEFAULT) ';
   s_statement := s_statement || ' PCTFREE 10 INITRANS 10 MAXTRANS 255 NOLOGGING PARALLEL ';
   s_statement := s_statement || ' COMPUTE STATISTICS ';

   debugmsg('Creating new indexes ... ');
   debugmsg('Schema Name: '||l_ora_username);

   BEGIN
      FOR rec IN attr_cur
      LOOP

         l_trans_idx_name := 'CN_SCA_HEADERS_INTERFACE_A'||SUBSTR(rec.src_column_name,10);
         v_statement := ' CREATE INDEX '||l_ora_username||'.'||l_trans_idx_name ||
	                ' ON CN_SCA_HEADERS_INTERFACE_ALL('||rec.src_column_name||') ';
         v_statement := v_statement || s_statement;

         EXECUTE IMMEDIATE v_statement;

	 EXECUTE IMMEDIATE 'ALTER INDEX '||l_ora_username||'.'||l_trans_idx_name||' LOGGING NOPARALLEL';

	 debugmsg('Created index :'||l_trans_idx_name);

      END LOOP;

      debugmsg('Created new indexes ... ');

   EXCEPTION
      WHEN OTHERS THEN
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	 debugmsg('Error while creating new indexes on Attribute columns');
	 debugmsg('Oracle Error :'||SQLERRM);
	 RAISE;
   END;

   --+
   --+ Analyze CN_SCA_HEADERS_INTERFACE_ALL table and associated indexes
   --+

EXCEPTION
   WHEN OTHERS THEN
      debugmsg('Error in manage_indexes subprogram');
END;
--
END CN_SCA_UTL_PVT;

/
