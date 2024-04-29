--------------------------------------------------------
--  DDL for Package Body CN_DIM_HIERARCHIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_DIM_HIERARCHIES_PKG" AS
--$Header: cndidhb.pls 120.4 2005/12/14 00:26:17 hanaraya ship $

-- Procedure Name
--   insert_row
-- Purpose
--   Insert row into cn_dim_hierarchies
-- History
--   18-MAY-2001  mblum          Created
--
PROCEDURE insert_row
  (x_header_dim_hierarchy_id   IN CN_DIM_HIERARCHIES.HEADER_DIM_HIERARCHY_ID%TYPE,
   x_start_date                IN CN_DIM_HIERARCHIES.START_DATE%TYPE,
   x_end_date                  IN CN_DIM_HIERARCHIES.END_DATE%TYPE,
   x_root_node                OUT NOCOPY CN_DIM_HIERARCHIES.ROOT_NODE%TYPE,
   x_dim_hierarchy_id         OUT NOCOPY CN_DIM_HIERARCHIES.DIM_HIERARCHY_ID%TYPE,
   x_org_id                     IN CN_DIM_HIERARCHIES.ORG_ID%TYPE) IS

BEGIN
   -- get the next pk from sequence
   SELECT cn_dim_hierarchies_s.nextval
     INTO x_dim_hierarchy_id
     FROM dual;

   SELECT cn_hierarchy_nodes_s.nextval
     INTO x_root_node
     FROM dual;



   -- create hierarchy
   INSERT into cn_dim_hierarchies
     (dim_hierarchy_id,
     org_id, --MOAC
      start_date,
      end_date,
      root_node,
      header_dim_hierarchy_id,
      last_update_date,
      last_updated_by,
      last_update_login,
      creation_date,
      created_by,
      object_version_number)
     VALUES
     (x_dim_hierarchy_id,
     x_org_id, --MOAC
      x_start_date,
      x_end_date,
      null,
      x_header_dim_hierarchy_id,
      sysdate,
      fnd_global.user_id,
      fnd_global.login_id,
      sysdate,
      fnd_global.user_id,
      1);

         -- create new root node
   INSERT INTO cn_hierarchy_nodes
     (dim_hierarchy_id, org_id,value_id, name,
      created_by, creation_date,
      last_updated_by, last_update_date, last_update_login)
     VALUES
     (X_dim_hierarchy_id,x_org_id, X_root_node,   -- MOAC Change
      fnd_message.get_string('CN', 'CN_BASE_NODE'),
      fnd_global.user_id, sysdate,
      fnd_global.user_id, sysdate, fnd_global.login_id);

   -- create base node
   CN_DIHY_TWO_API_PKG.Insert_Edge
     (X_name                => fnd_message.get_string('CN', 'CN_BASE_NODE'),
      X_dim_hierarchy_id    => x_dim_hierarchy_id,
      X_value_id            => x_root_node,
      X_parent_value_id     => null,
      X_external_id         => null,
      X_hierarchy_api_id    => NULL, -- not used
      x_org_id              => x_org_id);

      Update cn_dim_hierarchies
      Set root_node = x_root_node
      Where dim_hierarchy_id = x_dim_hierarchy_id;


END Insert_Row;

--
-- Procedure Name
--   update_row
-- Purpose
--   Update a row in cn_dim_hierarchies
-- History
--   18-MAY-2001  mblum          Created
--
PROCEDURE update_row
  (x_dim_hierarchy_id          IN CN_DIM_HIERARCHIES.DIM_HIERARCHY_ID%TYPE,
   x_header_dim_hierarchy_id   IN CN_DIM_HIERARCHIES.HEADER_DIM_HIERARCHY_ID%TYPE,
   x_start_date                IN CN_DIM_HIERARCHIES.START_DATE%TYPE,
   x_end_date                  IN CN_DIM_HIERARCHIES.END_DATE%TYPE,
   x_root_node                 IN CN_DIM_HIERARCHIES.ROOT_NODE%TYPE,
   x_object_version_number     IN OUT NOCOPY CN_DIM_HIERARCHIES.OBJECT_VERSION_NUMBER%TYPE,
   x_org_id                     IN CN_DIM_HIERARCHIES.ORG_ID%TYPE) IS
BEGIN
    x_object_version_number := x_object_version_number + 1;
   update cn_dim_hierarchies set
     start_date               = x_start_date,
     end_date                 = x_end_date,
     root_node                = x_root_node,
     header_dim_hierarchy_id  = x_header_dim_hierarchy_id,
     last_update_date         = sysdate,
     last_updated_by          = fnd_global.user_id,
     last_update_login        = fnd_global.login_id,
     object_version_number    = x_object_version_number
    where dim_hierarchy_id    = x_dim_hierarchy_id;
END Update_Row;


--
-- Procedure Name
--   delete_row
-- Purpose
--   Delete a row from cn_dim_hierarchies
-- History
--   18-MAY-2001  mblum          Created
--
PROCEDURE delete_row
  (x_dim_hierarchy_id          IN CN_DIM_HIERARCHIES.DIM_HIERARCHY_ID%TYPE) IS
BEGIN
   DELETE from cn_dim_hierarchies
     WHERE dim_hierarchy_id = x_dim_hierarchy_id;
   if (sql%notfound) then
      fnd_message.set_name('CN', 'CN_RECORD_DELETED');
      fnd_msg_pub.add;
      raise fnd_api.g_exc_error;
   end if;

   -- remove dangling edges and nodes
   delete from cn_hierarchy_nodes e where
     dim_hierarchy_id = x_dim_hierarchy_id;
   delete from cn_hierarchy_edges e where
     dim_hierarchy_id = x_dim_hierarchy_id;

END Delete_Row;


END CN_DIM_HIERARCHIES_PKG;

/
