--------------------------------------------------------
--  DDL for Package Body CN_DIHY_TWO_API_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_DIHY_TWO_API_PKG" AS
-- $Header: cndihy2b.pls 120.3 2005/12/13 01:52:38 hanaraya ship $

G_PKG_NAME                  CONSTANT VARCHAR2(30) := 'CN_DIHY_TWO_API_PKG';
G_FILE_NAME                 CONSTANT VARCHAR2(12) := 'cndihy2b.pls';


  PROCEDURE Insert_Edge ( X_name		IN VARCHAR2,
			  X_dim_hierarchy_id	IN NUMBER,
			  X_value_id	    IN OUT  NOCOPY NUMBER,
			  X_parent_value_id	IN NUMBER,
			  X_external_id		IN NUMBER,
			  X_hierarchy_api_id    IN NUMBER,
	                 --R12 MOAC Changes--Start
                     X_org_id IN NUMBER) IS
                     --R12 MOAC Changes--End
	Dummy NUMBER(15);

    BEGIN

      IF (X_value_id IS NULL) OR (X_value_id = -1) THEN

	SELECT count(*)
	  INTO Dummy
	  FROM cn_hierarchy_nodes
	 WHERE external_id = X_external_id
	   AND dim_hierarchy_id = X_dim_hierarchy_id;

	IF (Dummy = 0) THEN

 	    SELECT cn_hierarchy_nodes_s.nextval INTO X_value_id
	      FROM dual;

	    INSERT INTO cn_hierarchy_nodes
	      (value_id, name, dim_hierarchy_id, external_id,
	       CREATED_BY, CREATION_DATE,
	       LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,ORG_ID)
	    VALUES
	      (X_value_id, X_name, X_dim_hierarchy_id, X_external_id,
	       fnd_global.user_id, sysdate,
	       fnd_global.user_id, sysdate, fnd_global.login_id,X_org_id);

	ELSE

	  SELECT value_id
	    INTO X_value_id
	    FROM cn_hierarchy_nodes
	   WHERE dim_hierarchy_id = X_dim_hierarchy_id
	     AND external_id = X_external_id;

	  UPDATE cn_hierarchy_nodes
	     SET name = x_name
	   WHERE value_id = x_value_id;

	END IF;

      END IF;

      INSERT INTO cn_hierarchy_edges
	(dim_hierarchy_id,
         value_id,
         parent_value_id,
         hierarchy_api_id,
	 CREATED_BY,
	 CREATION_DATE,
	 LAST_UPDATE_LOGIN,
	 LAST_UPDATE_DATE,
	 LAST_UPDATED_BY,ORG_ID)
      VALUES
	(X_dim_hierarchy_id,
         X_value_id,
         X_parent_value_id,
         x_hierarchy_api_id,
	 fnd_global.user_id,
	 sysdate,
	 fnd_global.login_id,
	 sysdate,
	 fnd_global.user_id,X_org_id);

      IF (X_parent_value_id IS NOT NULL) THEN

	DELETE cn_hierarchy_edges
	 WHERE dim_hierarchy_id = X_dim_hierarchy_id
	   AND value_id = X_value_id
	   AND parent_value_id IS NULL
	   --R12 MOAC Changes--Start
	   AND org_id = X_org_id;
	   --R12 MOAC Changes--End

      ELSE

	DELETE cn_hierarchy_edges
	 WHERE dim_hierarchy_id = X_dim_hierarchy_id
	   AND value_id = X_value_id
	   AND parent_value_id IS NOT NULL
	   --R12 MOAC Changes--Start
	   AND org_id = X_org_id;
	   --R12 MOAC Changes--End

      END IF;

    END Insert_Edge;




  PROCEDURE Insert_Dimension (X_dimension_id		NUMBER,
			      X_name			VARCHAR2,
			      X_base_table_id		NUMBER,
			      X_primary_key_id		NUMBER,
			      X_user_column_name_id	NUMBER,
                    --R12 MOAC Changes--Start
                  X_org_id NUMBER) IS
                  --R12 MOAC Changes--End
	CountVal NUMBER(15);
    BEGIN


    UPDATE cn_objects SET user_column_name = 'Y',
           dimension_id = X_dimension_id,
           primary_key = 'N',
           last_updated_by = fnd_global.user_id,
           last_update_date = sysdate,
           last_update_login = fnd_global.login_id
	WHERE object_id = X_user_column_name_id
    --R12 MOAC Changes--Start
    and org_id = X_org_id;
	--R12 MOAC Changes--End

    UPDATE cn_objects SET primary_key = 'Y',
           dimension_id = X_dimension_id,
		   last_updated_by = fnd_global.user_id,
           last_update_date = sysdate,
           last_update_login = fnd_global.login_id
	WHERE object_id = X_primary_key_id
    --R12 MOAC Changes--Start
    and org_id = X_org_id;
    --R12 MOAC Changes--End



    END Insert_Dimension;

  --+
  -- Procedure Name
  --   Cascade_Delete
  -- History
  --   8/02/95          Tony Lower              Created
  --+
  PROCEDURE Cascade_Delete(X_value_id              number,
                           X_parent_value_id       number,
                           X_dim_hierarchy_id      number,
                           --R12 MOAC Changes--Start
				            X_org_id 	 NUMBER) IS
				           --R12 MOAC Changes--End

      Cursor Children IS SELECT *
                           FROM cn_hierarchy_edges
                          WHERE parent_value_id = X_value_id
                            AND dim_hierarchy_id = X_dim_hierarchy_id;

      X_refcount number(15);

    BEGIN

  --+
  -- This deletes a node from the graph, and also deletes all nodes
  -- beneath it (if they are not part of the graph by way of some other
  -- parent).
  --+

      IF X_parent_value_id IS NULL THEN

        DELETE cn_hierarchy_edges WHERE value_id = X_value_id
                                  AND parent_value_id IS NULL
                                  AND dim_hierarchy_id = X_dim_hierarchy_id;

      ELSE

        DELETE cn_hierarchy_edges WHERE value_id = X_value_id
                                  AND parent_value_id = X_parent_value_id
                                  AND dim_hierarchy_id = X_dim_hierarchy_id;

     END IF;

      SELECT ref_count INTO X_refcount FROM cn_hierarchy_nodes
                WHERE value_id = X_value_id
                  AND dim_hierarchy_id = X_dim_hierarchy_id;

      IF X_refcount = 0 THEN

        FOR c IN Children LOOP

          Cascade_Delete(c.value_id, X_value_id,
                         X_dim_hierarchy_id,
                         --R12 MOAC Changes--Start
                         X_org_id);
                         --R12 MOAC Changes--End


        END LOOP;

      END IF;

/*      delete cn_hierarchy_nodes WHERE value_id = X_value_id
		AND dim_hierarchy_id = X_dim_hierarchy_id;*/

    END Cascade_Delete;

END CN_DIHY_TWO_API_PKG;

/
