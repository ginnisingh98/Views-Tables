--------------------------------------------------------
--  DDL for Package Body CNDIHY_HIERARCHY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CNDIHY_HIERARCHY_PKG" as
-- $Header: cndihyab.pls 115.1 99/07/16 07:06:17 porting ship $


  --
  -- Procedure Name
  --   default_row
  -- History
  --   12/28/93         Tony Lower              Created
  --
  PROCEDURE Default_Row (X_hierarchy_id         IN OUT  number) IS

  BEGIN

  --
  -- This procedure is used to fill in the Head_Hierarchy_ID in
  -- cn_head_hierarchies with an arbitrarily generated sequence.
  -- This maintains the uniqueness of primary keys.
  --

    IF X_hierarchy_id IS NULL THEN

--      X_Hierarchy_ID := cn_head_hierarchies_s.nextval;

      SELECT cn_head_hierarchies_s.nextval
        INTO X_hierarchy_id FROM dual;

    END IF;

  END Default_Row;


  --
  -- Procedure Name
  --   default_period_row
  -- History
  --   7/18/94          Tony Lower              Created
  --
  PROCEDURE Default_Period_Row (X_hierarchy_id  IN OUT  number) IS

  BEGIN

  --
  -- This procedure is used to fill in the Dim_Hierarchy_ID in
  -- cn_dim_hierarchies with an arbitrarily generated sequence.
  -- This maintains the uniqueness of primary keys.
  --

    IF X_hierarchy_id IS NULL THEN

--      X_Hierarchy_ID := cn_dim_hierarchies_s.nextval;

      SELECT cn_dim_hierarchies_s.nextval
        INTO X_hierarchy_id FROM dual;

    END IF;

  END Default_Period_Row;


  --
  -- Procedure Name
  --   Populate_Period_Fields
  -- History
  --   12/28/93         Tony Lower              Created
  --
  PROCEDURE Populate_Period_Fields (X_start_period              number,
                                    X_start_name   IN OUT       varchar2,
                                    X_end_period                number,
                                    X_end_name     IN OUT       varchar2) IS
    BEGIN

  --
  -- This matches Period names to the period IDs that are stored in
  -- the cn_dim_hierarchies table.
  --

      IF X_start_period IS NOT NULL THEN
        SELECT  period_name
          INTO  X_start_name
          FROM  cn_periods
         WHERE  period_id = X_start_period;
      END IF;

      IF X_end_period IS NOT NULL THEN
        SELECT  period_name
          INTO  X_end_name
          FROM  cn_periods
         WHERE  period_id = X_end_period;
      END IF;

    END Populate_Period_Fields;

  --
  -- Procedure Name
  --   Populate_Value_Fields
  -- History
  --   12/28/93         Tony Lower              Created
  --
  PROCEDURE Populate_Value_Fields (X_value_id           number,
                                   X_dim_hierarchy_id   number,
                                   X_name       IN OUT  varchar2) IS
    BEGIN

  --
  -- This procedure fills in the name for a value ID in a particular
  -- dimension hierarchy.  This data is now held denormalized in the
  -- CN_HIERARCHY_NODES translation table, making obselete our previous
  -- (slow) method of searching through the base source tables for the
  -- dimension.
  --

      IF X_value_id IS NOT NULL THEN

        SELECT name INTO X_name FROM cn_hierarchy_nodes
                WHERE dim_hierarchy_id = X_dim_hierarchy_id
                  AND value_id = X_value_id;

      END IF;

    END Populate_Value_Fields;

  --
  -- Procedure Name
  --   Populate_Fields
  -- History
  --   12/28/93         Tony Lower              Created
  --
  PROCEDURE Populate_Fields (X_dimension_id             number,
                             X_hierarchy_id             number,
                             X_select_clause    IN OUT  varchar2) IS

  BEGIN

  --
  -- This creates a dynamic SQL select clause, based on the dimension and
  -- Hierarchy being worked on.  This select clause is, in turn, used to
  -- help the user choose appropriate data values for filling in the
  -- Hierarchy values in the form.
  --

    IF X_dimension_id is not null THEN

      IF X_hierarchy_id IS NOT NULL THEN

        SELECT '(SELECT '||
             decode(col.data_type,
                        'VARCHAR2', col.name,
                        'to_char('||col.name||')')||
             ' NAME, -'||pk.name||
             ' VALUE_ID FROM '||tab.name||' MINUS '||
             'SELECT name NAME, -external_id VALUE_ID FROM cn_hierarchy_nodes '||
             'WHERE dim_hierarchy_id = :periods.dim_hierarchy_id '||
             ') UNION '||
             'SELECT name NAME, value_id VALUE_ID FROM cn_hierarchy_nodes '||
             'WHERE dim_hierarchy_id = :periods.dim_hierarchy_id '||
             'ORDER BY 1'
          INTO X_select_clause
          FROM cn_obj_tables_v tab,
             cn_obj_columns_v col,
             cn_obj_columns_v pk
         WHERE tab.table_id = col.table_id
           AND tab.table_id = pk.table_id
           AND pk.dimension_id = X_dimension_id
           AND pk.primary_key = 'Y'
           AND col.user_column_name = 'Y';

      ELSE

        SELECT 'SELECT '||
             decode(col.data_type,
                        'VARCHAR2', col.name,
                        'to_char('||col.name||') ')||
             ' NAME, '||pk.name||
             ' VALUE_ID FROM '||tab.name
          INTO X_select_clause
          FROM cn_obj_tables_v tab,
             cn_obj_columns_v col,
             cn_obj_columns_v pk
         WHERE tab.table_id = col.table_id
           AND tab.table_id = pk.table_id
           AND pk.dimension_id = X_dimension_id
           AND pk.primary_key = 'Y'
           AND col.user_column_name = 'Y';

      END IF;

    END IF;

  END Populate_Fields;



  --
  -- Procedure Name
  --   root_node
  -- History
  --   12/28/93         Tony Lower              Created
  --
  PROCEDURE Root_Node ( X_hierarchy_id                  number,
                        X_value_id      IN OUT          number) IS

  BEGIN

  --
  -- This procedure returns the Root node of the hierarchy in question.
  -- If no root node exists, it searches to see whether the hierarchy
  -- is a rooted tree, and if so returns that root, otherwise, it will
  -- check whether the hierarchy is empty, and if so return a newly
  -- created root.
  --
  -- In the case where the hierarchy is already a multiply rooted forest,
  -- and no root node is specified in the Dim_Hierarchy record, the
  -- procedure returns NULL.
  --

    SELECT root_node
      INTO X_value_id
      FROM cn_dim_hierarchies
     WHERE dim_hierarchy_id = X_hierarchy_id;

    IF X_value_id IS NULL THEN

            SELECT value_id
              INTO X_value_id
              FROM cn_hierarchy_edges
             WHERE dim_hierarchy_id = X_hierarchy_id
               AND parent_value_id is NULL;

    END IF;

    EXCEPTION

      WHEN TOO_MANY_ROWS THEN
        X_value_id := NULL;

      WHEN NO_DATA_FOUND THEN

--      X_value_id := cn_hierarchy_nodes_s.nextval;

        SELECT cn_hierarchy_nodes_s.nextval INTO X_value_id FROM dual;

        INSERT INTO cn_hierarchy_nodes (dim_hierarchy_id, value_id, name)
                VALUES (X_hierarchy_id, X_value_id, 'ALL');

        INSERT INTO cn_hierarchy_edges (dim_hierarchy_id, value_id)
                VALUES (X_hierarchy_id, X_value_id);

    END Root_Node;

  --
  -- Procedure Name
  --   Synchronize_Node
  -- History
  --   12/28/93         Tony Lower              Created
  --
  PROCEDURE Synchronize_Node (X_value_id IN OUT number,
                              X_name     IN     varchar2,
                              X_dim_hierarchy_id IN number) IS
     Temp number(15);
    BEGIN

  --
  -- This procedure creates a hierarchy node for the hierarchy value in
  -- question, if one does not exist already.
  --

      SELECT count(*) INTO Temp FROM cn_hierarchy_nodes
        WHERE external_id = X_value_id
          AND dim_hierarchy_id = X_dim_hierarchy_id;

      IF Temp = 0 THEN

        INSERT INTO cn_hierarchy_nodes (value_id, external_id, name,
                        dim_hierarchy_id)
                VALUES (cn_hierarchy_nodes_s.nextval,
                        X_value_id,
                        X_name,
                        X_dim_hierarchy_id);

--      X_value_id := cn_hierarchy_nodes_s.currval;

        SELECT cn_hierarchy_nodes_s.currval INTO X_value_id FROM dual;

      END IF;

    END Synchronize_Node;

  --
  -- Procedure Name
  --   Shift_Parent
  -- History
  --   12/28/93         Tony Lower              Created
  --
  PROCEDURE Shift_Parent( X_parent_value_id             number,
                          X_dim_hierarchy_id            number,
                          X_central_root_node           number,
                          X_central_value_id    IN OUT  number,
                          X_central_parent_id   IN OUT  number) IS
    BEGIN

  --
  -- This procedure handles the mechanics behind shifting the focus of
  -- the hierarchy viewer one record _up_.  It feeds back into the
  -- control fields of the hierarchy viewer, and is followed by a
  -- programmatic query which pulls in the appropriate data.
  --

      SELECT parent_value_id
                INTO X_central_parent_id
                FROM cndihy_parents_v
                WHERE value_id = X_parent_value_id
                  AND dim_hierarchy_id = X_dim_hierarchy_id
                  AND root_node = X_central_root_node;

      X_central_value_id := NULL;

      IF X_central_parent_id IS NULL THEN

            X_central_value_id  := X_parent_value_id;
            X_central_parent_id := NULL;

      END IF;

    EXCEPTION

      WHEN NO_DATA_FOUND THEN

            X_central_value_id  := X_parent_value_id;
            X_central_parent_id := NULL;

    END Shift_Parent;

  --
  -- Procedure Name
  --   Cascade_Number
  -- History
  --   7/19/93          Tony Lower              Created
  --
  PROCEDURE Cascade_Number(X_value_id              number,
                           X_dim_hierarchy_id      number,
                           X_cascade_number IN OUT number) IS
    BEGIN

  --
  -- This procedure calculates how many nodes are in danger of deletion
  -- from a cascade delete.  It is used to give the user information in
  -- making the decision whether to cascade delete.
  --

      SELECT count(*) INTO X_cascade_number FROM cn_dim_explosion
        WHERE ancestor_id = X_value_id
          AND dim_hierarchy_id = X_dim_hierarchy_id;

    END Cascade_Number;

  --
  -- Procedure Name
  --   Cascade_Delete
  -- History
  --   7/19/93          Tony Lower              Created
  --
  PROCEDURE Cascade_Delete(X_value_id              number,
                           X_parent_value_id       number,
                           X_dim_hierarchy_id      number) IS

      Cursor Children IS SELECT *
                           FROM cn_hierarchy_edges
                          WHERE parent_value_id = X_value_id
                            AND dim_hierarchy_id = X_dim_hierarchy_id;

      X_refcount number(15);

    BEGIN

  --
  -- This deletes a node from the graph, and also deletes all nodes
  -- beneath it (if they are not part of the graph by way of some other
  -- parent).
  --

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
                         X_dim_hierarchy_id);

        END LOOP;

      END IF;

    END Cascade_Delete;

  --
  -- Procedure Name
  --   Insert_Row
  -- History
  --   7/19/93          Tony Lower              Created
  --
  PROCEDURE Insert_Row(X_value_id                  number,
                       X_parent_Value_id           number,
                       X_dim_hierarchy_id          number) IS
    BEGIN

  --
  --  This procedure inserts an edge into the Hierarchy, making sure
  -- to delete any edges to NULL (which would be made obsolete by the
  -- occurence of an active edge).
  --

      DELETE cn_hierarchy_edges WHERE
                parent_value_id IS NULL
            AND value_id = X_value_id
            AND dim_hierarchy_id = X_dim_hierarchy_id;

      INSERT INTO cn_hierarchy_edges (value_id, parent_value_id,
                                      dim_hierarchy_id)
                          VALUES     (X_value_id, X_parent_Value_id,
                                      X_dim_hierarchy_id);

    END Insert_Row;

  --
  -- Procedure Name
  --   Insert_Root
  -- History
  --   7/25/93          Tony Lower              Created
  --
  PROCEDURE Insert_Root(X_value_id                 number,
                        X_dim_hierarchy_id         number) IS
    BEGIN

      INSERT INTO cn_hierarchy_edges (value_id, parent_value_id,
                                      dim_hierarchy_id)
                (SELECT X_value_id, NULL, X_dim_hierarchy_id
                   FROM dual
                  WHERE NOT EXISTS (SELECT * FROM cn_hierarchy_edges
                                            WHERE value_id = X_value_id
                                              AND dim_hierarchy_id =
                                                        X_dim_hierarchy_id));

    END Insert_Root;

  --
  -- Procedure Name
  --   Fetch_Row_counts
  -- History
  --   7/25/93          Tony Lower              Created
  --
  PROCEDURE Fetch_Row_Counts (X_parent_value_id         number,
                              X_value_id                number,
                              X_dim_hierarchy_id        number,
                              X_parent_rows      IN OUT number,
                              X_child_rows       IN OUT number) IS
    BEGIN

        SELECT count(*) INTO X_parent_rows
                        FROM cn_hierarchy_edges
                       WHERE parent_value_id = X_parent_value_id
                         AND dim_hierarchy_id = X_dim_hierarchy_id;

        SELECT count(*) INTO X_child_rows
                        FROM cn_hierarchy_edges
                       WHERE parent_value_id = X_value_id
                         AND dim_hierarchy_id = X_dim_hierarchy_id;

    END Fetch_Row_counts;

  --
  -- Procedure Name
  --   Fetch_Row_counts
  -- History
  --   7/26/93          Tony Lower              Created
  --
  PROCEDURE Create_Dummy_Node (X_value_id       IN OUT number,
                               X_name                  varchar2,
                               X_dim_hierarchy_id      number) IS
    BEGIN

      SELECT cn_hierarchy_nodes_s.nextval
                INTO X_value_id
                FROM dual;

      INSERT INTO cn_hierarchy_nodes
                (dim_hierarchy_id, name, value_id)
         VALUES (X_dim_hierarchy_id, X_name, X_value_id);

    END Create_Dummy_Node;

END CNDIHY_Hierarchy_PKG;

/
