--------------------------------------------------------
--  DDL for Package Body CSI_II_RELATIONSHIPS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSI_II_RELATIONSHIPS_PVT" AS
/* $Header: csiviirb.pls 120.12.12010000.6 2009/09/15 23:05:25 devijay ship $ */
-- start of comments
-- package name     : csi_ii_relationships_pvt
-- purpose          :
-- history          :
-- note             :
-- END of comments


g_pkg_name  CONSTANT VARCHAR2(30) := 'csi_ii_relationships_pvt';
g_file_name CONSTANT VARCHAR2(12) := 'csiviirb.pls';
p_rel_glbl_tbl   csi_datastructures_pub.ii_relationship_tbl;
p_glbl_ctr       NUMBER := 0;

/* Cyclic Relationships */

/* TYPE instance_rec IS RECORD
( instance_id  NUMBER,
  hop          NUMBER );

TYPE instance_tbl IS TABLE OF instance_rec
INDEX BY BINARY_INTEGER ;
*/
PROCEDURE get_cyclic_relationships
 (
     p_api_version               IN  NUMBER,
     p_commit                    IN  VARCHAR2,
     p_init_msg_list             IN  VARCHAR2,
     p_validation_level          IN  NUMBER,
     p_instance_id               IN  NUMBER ,
     p_depth                     IN  NUMBER,
     p_time_stamp                IN  DATE,
     p_active_relationship_only  IN  VARCHAR2,
     x_relationship_tbl          OUT NOCOPY csi_datastructures_pub.ii_relationship_tbl,
     x_return_status             OUT NOCOPY VARCHAR2,
     x_msg_count                 OUT NOCOPY NUMBER,
     x_msg_data                  OUT NOCOPY VARCHAR2
 )
IS
   l_neighbor_inst_tbl        instance_tbl;
   l_visited_tbl              instance_tbl;
   l_visited_index            INTEGER;
   l_non_visited_tbl          instance_tbl;
   l_non_visited_index        INTEGER;
   l_cur_instance_id          NUMBER;
   l_in_visited_tbl           BOOLEAN;
   l_in_non_visited_tbl       BOOLEAN;
   l_pass_number              NUMBER := 0;
   l_first_non_vis_ind        INTEGER;

   l_non_visited_tbl_cnt      NUMBER ;
   l_start_time               VARCHAR2(60);
   l_end_time                 VARCHAR2(60);
   l_non_vis_start            NUMBER ;
   l_api_name                 CONSTANT VARCHAR2(50) := 'get_cyclic_relationships';
   l_api_version              CONSTANT NUMBER        := 1.0;
   l_return_status_full       VARCHAR2(1);
   l_debug_level              NUMBER;
   l_cur_hop                  NUMBER;
BEGIN
   -- standard start of api savepoint
   --SAVEPOINT get_cylic_relationships_pvt;

   -- standard call to check for call compatibility.
   IF NOT fnd_api.compatible_api_call ( l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        g_pkg_name)
   THEN
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;

   -- initialize message list if p_init_msg_list is set to true.
   IF fnd_api.to_boolean( p_init_msg_list )
   THEN
      fnd_msg_pub.initialize;
   END IF;

   -- initialize api return status to success
   x_return_status := fnd_api.g_ret_sts_success;
   l_debug_level   := fnd_profile.value('CSI_DEBUG_LEVEL');

   IF (l_debug_level > 0) THEN
       CSI_gen_utility_pvt.put_line( 'get_cyclic_relationships');
   END IF;

   IF (l_debug_level > 1) THEN
       CSI_gen_utility_pvt.put_line(
                            p_api_version             ||'-'||
                            p_commit                  ||'-'||
                            p_init_msg_list           ||'-'||
                            p_validation_level        ||'-'||
                            p_instance_id             ||'-'||
                            p_time_stamp              ||'-'||
                            p_active_relationship_only );

   END IF;

   --
   -- API BODY
   --
   -- ******************************************************************
   -- validate environment
   -- ******************************************************************

   IF p_instance_id IS NULL
   THEN
       fnd_message.set_name('CSI', 'CSI_INVALID_PARAMETERS');
       fnd_msg_pub.add;
       x_return_status := fnd_api.g_ret_sts_error;
       RAISE fnd_api.g_exc_error;
   END IF;

   select to_char(sysdate,'YY-MON-DD HH:MI:SS')
   into   l_start_time
   from dual ;

   -- Initialize the given instance to non-visited table

   l_non_visited_tbl(1).instance_id := p_instance_id ;
   l_non_visited_tbl(1).hop := 0 ;
   l_pass_number  := 0;
   l_non_visited_tbl_cnt := 1 ;
   l_non_vis_start := 0 ;

   WHILE l_non_visited_tbl.COUNT > 0
   LOOP
      -- Get the first element from Non-Visited table, Note that this may not
      -- be having index of 1, it may have 5, 1, 10 etc.

      l_non_visited_index := l_non_visited_tbl.FIRST;
      l_cur_instance_id := l_non_visited_tbl(l_non_visited_index).instance_id ;
      l_cur_hop := l_non_visited_tbl(l_non_visited_index).hop ;

      -- Now delete this instance from Non-visited table

      l_non_visited_tbl.DELETE(l_non_visited_index);
      l_non_vis_start := l_non_vis_start + 1 ;

      --  Get All the Relationships for l_cur_instance_id and populate it in x_relationship_tbl,
      --  If that relationship does not exists. get_rel_for_instance will populate the relationship
      --  for l_cur_instance_id only if it does not already exists in x_relationship_tbl

      IF p_depth IS NOT NULL
      THEN
         IF l_cur_hop+1 <= p_depth
         THEN
            get_rel_for_instance(
                     l_cur_instance_id,
                     p_time_stamp,
                     p_active_relationship_only ,
                     x_relationship_tbl);
         END IF ;
      ELSE
        -- p_depth is null so get all the relations
         get_rel_for_instance(l_cur_instance_id,
                  p_time_stamp,
                  p_active_relationship_only,
                  x_relationship_tbl);
      END IF ;

      --  Now Push this Instance into Visited table.
      l_visited_index := NVL(l_visited_tbl.LAST,0) + 1 ;
      l_visited_tbl(l_visited_index).instance_id := l_cur_instance_id ;

      --  Get neighbor Instances for l_cur_instance_id
      get_neighbors_for_instance(l_cur_instance_id ,
                                 l_cur_hop ,
                                 p_depth ,
                                 p_time_stamp ,
                                 p_active_relationship_only ,
                                 l_neighbor_inst_tbl);

      FOR i IN 1..l_neighbor_inst_tbl.COUNT
      LOOP
         l_in_visited_tbl := FALSE ;
         l_in_non_visited_tbl := FALSE ;

         --  Check if this instance is in Visited Table
         FOR j IN 1..l_visited_tbl.COUNT
         LOOP
            IF l_neighbor_inst_tbl(i).instance_id = l_visited_tbl(j).instance_id
            THEN
               l_in_visited_tbl := TRUE ;
               EXIT ;
            END IF ;
         END LOOP ;

         --  Check if this instance is in Non Visited Table
         IF NOT l_in_visited_tbl
         THEN
            FOR k IN l_non_vis_start..l_non_visited_tbl_cnt
            LOOP
               BEGIN
                  IF l_neighbor_inst_tbl(i).instance_id = l_non_visited_tbl(k).instance_id
                  THEN
                     l_in_non_visited_tbl := TRUE ;
                     EXIT ;
                  END IF ;
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     -- There is a gap in the range so ignore and go ahead
                     NULL ;
               END ;
           END LOOP ; --l_non_vis_start..l_non_visited_tbl_cnt
        END IF ;

        IF NOT (l_in_visited_tbl OR l_in_non_visited_tbl)
        THEN
           -- As this instance is neither in Visited Table nor in Non-Visited Table,
           --  Push this Instance into Non Visited table.

           l_non_visited_index := NVL(l_non_visited_tbl.LAST,0) + 1 ;
           l_non_visited_tbl(l_non_visited_index).instance_id := l_neighbor_inst_tbl(i).instance_id ;
           l_non_visited_tbl(l_non_visited_index).hop := l_neighbor_inst_tbl(i).
hop ;
           l_non_visited_tbl_cnt := l_non_visited_tbl_cnt+1 ;

         END IF ;
      END LOOP ;  -- l_neighbor_inst_tbl.COUNT;
      l_pass_number := l_pass_number+1 ;

   END LOOP ; -- l_non_visited_tbl.COUNT > 0

   select to_char(sysdate,'YY-MON-DD HH:MI:SS')
   into   l_end_time
   from   dual ;

EXCEPTION
   WHEN fnd_api.g_exc_unexpected_error THEN
      --ROLLBACK TO get_cylic_relationships_pvt;
      x_return_status := fnd_api.g_ret_sts_unexp_error ;
      fnd_msg_pub.count_AND_get
           (p_count => x_msg_count ,
            p_data => x_msg_data);

   WHEN OTHERS THEN
      --ROLLBACK TO get_cylic_relationships_pvt;
      x_return_status := fnd_api.g_ret_sts_unexp_error ;
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
      THEN
         fnd_msg_pub.add_exc_msg(g_pkg_name ,l_api_name);
      END IF;
      fnd_msg_pub.count_AND_get
         (p_count => x_msg_count ,
          p_data => x_msg_data);
END get_cyclic_relationships;

PROCEDURE get_rel_for_instance
       (p_instance_id IN NUMBER,
        p_time_stamp IN DATE,
        p_active_relationship_only IN VARCHAR2,
        x_relationship_tbl IN OUT NOCOPY csi_datastructures_pub.ii_relationship_tbl)
IS

l_cur_instance_id          NUMBER;
i                          NUMBER;
l_relation_exists          BOOLEAN;
l_sysdate                  DATE;
l_time_stamp               DATE;


-- x_relationship_tbl may be already populated with instances.
-- This procedure gets all the relationships for the given instance and populates it in
-- x_relationship_tbl if it already does not exists.

   CURSOR relations_cur (c_sysdate IN DATE) IS
   SELECT relationship_id ,
          relationship_type_code ,
          object_id ,
          subject_id ,
          position_reference ,
          active_start_date  ,
          active_end_date ,
          display_order ,
          mandatory_flag ,
          context ,
          attribute1 ,
          attribute2 ,
          attribute3 ,
          attribute4 ,
          attribute5 ,
          attribute6 ,
          attribute7 ,
          attribute8 ,
          attribute9 ,
          attribute10,
          attribute11,
          attribute12,
          attribute13,
          attribute14,
          attribute15,
          object_version_number
    FROM  csi_ii_relationships
    WHERE (subject_id = p_instance_id OR object_id = p_instance_id )
    AND   relationship_type_code = 'CONNECTED-TO'
    AND   nvl(active_start_date,creation_date) <= NVL(l_time_stamp,nvl(active_start_date,creation_date))
    AND   DECODE(p_active_relationship_only,FND_API.G_TRUE,NVL((active_end_date),c_sysdate+1),c_sysdate+1) > NVL((l_time_stamp),c_sysdate) ;

BEGIN
   i:= 0;
   SELECT SYSDATE
   INTO   l_sysdate
   FROM   dual;
   --
   -- srramakr Bug # 2882876
   IF p_time_stamp = FND_API.G_MISS_DATE THEN
      l_time_stamp := null;
   ELSE
      l_time_stamp := p_time_stamp;
   END IF;
   --
   FOR relations_rec IN relations_cur(l_sysdate)
   LOOP
      l_relation_exists := FALSE ;
      IF x_relationship_tbl.COUNT = 0 THEN
         x_relationship_tbl(1).relationship_id  := relations_rec.relationship_id ;
         x_relationship_tbl(1).relationship_type_code := relations_rec.relationship_type_code ;
         x_relationship_tbl(1).object_id := relations_rec.object_id ;
         x_relationship_tbl(1).subject_id := relations_rec.subject_id ;
         x_relationship_tbl(1).position_reference := relations_rec.position_reference ;
         x_relationship_tbl(1).active_start_date  := relations_rec.active_start_date ;
         x_relationship_tbl(1).active_end_date := relations_rec.active_end_date  ;
         x_relationship_tbl(1).display_order := relations_rec.display_order;
         x_relationship_tbl(1).mandatory_flag := relations_rec.mandatory_flag ;
         x_relationship_tbl(1).context := relations_rec.context ;
         x_relationship_tbl(1).attribute1 := relations_rec.attribute1 ;
         x_relationship_tbl(1).attribute2 := relations_rec.attribute2 ;
         x_relationship_tbl(1).attribute3 := relations_rec.attribute3 ;
         x_relationship_tbl(1).attribute4 := relations_rec.attribute4 ;
         x_relationship_tbl(1).attribute5 := relations_rec.attribute5 ;
         x_relationship_tbl(1).attribute6 := relations_rec.attribute6 ;
         x_relationship_tbl(1).attribute7 := relations_rec.attribute7 ;
         x_relationship_tbl(1).attribute8 := relations_rec.attribute8 ;
         x_relationship_tbl(1).attribute9 := relations_rec.attribute9 ;
         x_relationship_tbl(1).attribute10:= relations_rec.attribute10 ;
         x_relationship_tbl(1).attribute11:= relations_rec.attribute11;
         x_relationship_tbl(1).attribute12:= relations_rec.attribute12;
         x_relationship_tbl(1).attribute13:= relations_rec.attribute13;
         x_relationship_tbl(1).attribute14:= relations_rec.attribute14 ;
         x_relationship_tbl(1).attribute15:= relations_rec.attribute15;
         x_relationship_tbl(1).object_version_number:= relations_rec.object_version_number; -- Porting fix for Bug 4243513
      ELSE
         FOR j IN 1..x_relationship_tbl.COUNT
         LOOP
            IF x_relationship_tbl(j).relationship_id = relations_rec.relationship_id
            THEN
               l_relation_exists := TRUE ;
               EXIT ;
            END IF ;
         END LOOP ;

         IF NOT l_relation_exists THEN
            i := NVL(x_relationship_tbl.LAST,0) + 1 ;
            x_relationship_tbl(i).relationship_id  := relations_rec.relationship_id ;
            x_relationship_tbl(i).relationship_type_code := relations_rec.relationship_type_code ;
            x_relationship_tbl(i).object_id := relations_rec.object_id ;
            x_relationship_tbl(i).subject_id := relations_rec.subject_id ;
            x_relationship_tbl(i).position_reference := relations_rec.position_reference;
            x_relationship_tbl(i).active_start_date  := relations_rec.active_start_date;
            x_relationship_tbl(i).active_end_date := relations_rec.active_end_date;
            x_relationship_tbl(i).display_order := relations_rec.display_order;
            x_relationship_tbl(i).mandatory_flag := relations_rec.mandatory_flag;
            x_relationship_tbl(i).context := relations_rec.context ;
            x_relationship_tbl(i).attribute1 := relations_rec.attribute1 ;
            x_relationship_tbl(i).attribute2 := relations_rec.attribute2 ;
            x_relationship_tbl(i).attribute3 := relations_rec.attribute3 ;
            x_relationship_tbl(i).attribute4 := relations_rec.attribute4 ;
            x_relationship_tbl(i).attribute5 := relations_rec.attribute5 ;
            x_relationship_tbl(i).attribute6 := relations_rec.attribute6 ;
            x_relationship_tbl(i).attribute7 := relations_rec.attribute7 ;
            x_relationship_tbl(i).attribute8 := relations_rec.attribute8 ;
            x_relationship_tbl(i).attribute9 := relations_rec.attribute9 ;
            x_relationship_tbl(i).attribute10:= relations_rec.attribute10;
            x_relationship_tbl(i).attribute11:= relations_rec.attribute11;
            x_relationship_tbl(i).attribute12:= relations_rec.attribute12;
            x_relationship_tbl(i).attribute13:= relations_rec.attribute13;
            x_relationship_tbl(i).attribute14:= relations_rec.attribute14;
            x_relationship_tbl(i).attribute15:= relations_rec.attribute15;
            x_relationship_tbl(i).object_version_number:= relations_rec.object_version_number; -- Porting fix for Bug 4243513
         END IF ;
       END IF ;
    END LOOP ;
END get_rel_for_instance ;

PROCEDURE get_neighbors_for_instance(p_instance_id IN NUMBER ,
                                     p_hop  IN NUMBER,
                                     p_depth IN NUMBER,
                                     p_time_stamp IN DATE,
                                     p_active_relationship_only IN VARCHAR2,
                                     x_neighbor_inst_tbl OUT NOCOPY instance_tbl )
IS

   i           NUMBER ;
   l_sysdate   DATE ;
   l_time_stamp DATE;

   CURSOR neighbor_cur (p_instance_id IN NUMBER,
                        c_sysdate IN DATE )
   IS
      SELECT subject_id instance_id
      FROM   csi_ii_relationships
      WHERE  (subject_id = p_instance_id OR object_id = p_instance_id)
      AND    relationship_type_code = 'CONNECTED-TO'
      AND    nvl(active_start_date,creation_date) <= NVL(l_time_stamp,nvl(active_start_date,creation_date))
      AND    DECODE(p_active_relationship_only,FND_API.G_TRUE,NVL((active_end_date),c_sysdate+1),c_sysdate+1) > NVL((l_time_stamp),c_sysdate)
      UNION ALL
      SELECT object_id instance_id
      FROM   csi_ii_relationships
      WHERE  (subject_id = p_instance_id OR object_id = p_instance_id)
      AND    relationship_type_code = 'CONNECTED-TO'
      AND    nvl(active_start_date,creation_date) <= NVL(l_time_stamp,nvl(active_start_date,creation_date))
      AND    DECODE(p_active_relationship_only,FND_API.G_TRUE,NVL((active_end_date),c_sysdate+1),c_sysdate+1) > NVL((l_time_stamp),c_sysdate)  ;

BEGIN
   SELECT SYSDATE
   INTO   l_sysdate
   FROM  DUAL;
   --
   -- srramakr Bug # 2882876
   IF p_time_stamp = FND_API.G_MISS_DATE THEN
      l_time_stamp := null;
   ELSE
      l_time_stamp := p_time_stamp;
   END IF;
   --
   i:= 0;
   x_neighbor_inst_tbl.DELETE ;

   FOR neighbor_rec IN neighbor_cur (p_instance_id, l_sysdate)
   LOOP
      IF neighbor_rec.instance_id <> p_instance_id
      THEN
         i := i+1;
         IF p_depth IS NOT NULL
         THEN
            IF p_hop+1 <= p_depth
            THEN
               x_neighbor_inst_tbl(i).instance_id := neighbor_rec.instance_id ;
               x_neighbor_inst_tbl(i).hop := p_hop+1 ;
            END IF ;
         ELSE
            x_neighbor_inst_tbl(i).instance_id := neighbor_rec.instance_id;
            x_neighbor_inst_tbl(i).hop := p_hop+1 ;
         END IF ; --p_depth IS NOT NULL
      END IF ;
   END LOOP;
END get_neighbors_for_instance ;

/* End of Cyclic Relationships */

PROCEDURE validate_ii_relationships(
    p_init_msg_list              IN   VARCHAR2     := fnd_api.g_false,
    p_validation_level           IN   NUMBER       := fnd_api.g_valid_level_full,
    p_validation_mode            IN   VARCHAR2,
    p_ii_relationship_tbl        IN   csi_datastructures_pub.ii_relationship_tbl,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2
    );

PROCEDURE validate_relationship_id (
    p_init_msg_list              IN   VARCHAR2     := fnd_api.g_false,
    p_validation_mode            IN   VARCHAR2,
    p_relationship_id            IN   NUMBER,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2
    );

PROCEDURE validate_rel_type_code (
    p_init_msg_list              IN   VARCHAR2     := fnd_api.g_false,
    p_validation_mode            IN   VARCHAR2,
    p_relationship_type_code     IN   VARCHAR2,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2
    );


PROCEDURE validate_object_id (
    p_init_msg_list              IN   VARCHAR2     := fnd_api.g_false,
    p_validation_mode            IN   VARCHAR2,
    p_object_id                  IN   NUMBER,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2
    );


PROCEDURE validate_subject_id (
    p_init_msg_list              IN   VARCHAR2     := fnd_api.g_false,
    p_validation_mode            IN   VARCHAR2,
    p_subject_id                 IN   NUMBER,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2
    );


PROCEDURE validate_active_end_date (
    p_init_msg_list              IN   VARCHAR2     := fnd_api.g_false,
    p_validation_mode            IN   VARCHAR2,
    p_active_end_date            IN   DATE,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2
    );


PROCEDURE define_columns(
p_relations_rec                IN   csi_datastructures_pub.ii_relationship_rec,
p_cur_get_relations            IN   NUMBER
)
IS
BEGIN


      DBMS_SQL.DEFINE_COLUMN(p_cur_get_relations, 1, p_relations_rec.relationship_id);
      DBMS_SQL.DEFINE_COLUMN(p_cur_get_relations, 2, p_relations_rec.relationship_type_code,30);
      DBMS_SQL.DEFINE_COLUMN(p_cur_get_relations, 3, p_relations_rec.object_id);
      DBMS_SQL.DEFINE_COLUMN(p_cur_get_relations, 4, p_relations_rec.subject_id);
      DBMS_SQL.DEFINE_COLUMN(p_cur_get_relations, 5, p_relations_rec.subject_has_child,1);
      DBMS_SQL.DEFINE_COLUMN(p_cur_get_relations, 6, p_relations_rec.position_reference,30);
      DBMS_SQL.DEFINE_COLUMN(p_cur_get_relations, 7, p_relations_rec.active_start_date);
      DBMS_SQL.DEFINE_COLUMN(p_cur_get_relations, 8, p_relations_rec.active_end_date);
      DBMS_SQL.DEFINE_COLUMN(p_cur_get_relations, 9, p_relations_rec.display_order);
      DBMS_SQL.DEFINE_COLUMN(p_cur_get_relations, 10, p_relations_rec.mandatory_flag,1);
      DBMS_SQL.DEFINE_COLUMN(p_cur_get_relations, 11, p_relations_rec.context,30);
      DBMS_SQL.DEFINE_COLUMN(p_cur_get_relations, 12, p_relations_rec.attribute1,150);
      DBMS_SQL.DEFINE_COLUMN(p_cur_get_relations, 13, p_relations_rec.attribute2,150);
      DBMS_SQL.DEFINE_COLUMN(p_cur_get_relations, 14, p_relations_rec.attribute3,150);
      DBMS_SQL.DEFINE_COLUMN(p_cur_get_relations, 15, p_relations_rec.attribute4,150);
      DBMS_SQL.DEFINE_COLUMN(p_cur_get_relations, 16, p_relations_rec.attribute5,150);
      DBMS_SQL.DEFINE_COLUMN(p_cur_get_relations, 17, p_relations_rec.attribute6,150);
      DBMS_SQL.DEFINE_COLUMN(p_cur_get_relations, 18, p_relations_rec.attribute7,150);
      DBMS_SQL.DEFINE_COLUMN(p_cur_get_relations, 19, p_relations_rec.attribute8,150);
      DBMS_SQL.DEFINE_COLUMN(p_cur_get_relations, 20, p_relations_rec.attribute9,150);
      DBMS_SQL.DEFINE_COLUMN(p_cur_get_relations, 21, p_relations_rec.attribute10,150);
      DBMS_SQL.DEFINE_COLUMN(p_cur_get_relations, 22, p_relations_rec.attribute11,150);
      DBMS_SQL.DEFINE_COLUMN(p_cur_get_relations, 23, p_relations_rec.attribute12,150);
      DBMS_SQL.DEFINE_COLUMN(p_cur_get_relations, 24, p_relations_rec.attribute13,150);
      DBMS_SQL.DEFINE_COLUMN(p_cur_get_relations, 25, p_relations_rec.attribute14,150);
      DBMS_SQL.DEFINE_COLUMN(p_cur_get_relations, 26, p_relations_rec.attribute15,150);
      DBMS_SQL.DEFINE_COLUMN(p_cur_get_relations, 27, p_relations_rec.object_version_number);


END define_columns;


PROCEDURE get_column_values(
    p_cur_get_relations      IN   NUMBER,
    x_rel_rec                OUT NOCOPY  csi_datastructures_pub.ii_relationship_rec
)
IS
BEGIN
      DBMS_SQL.COLUMN_VALUE(p_cur_get_relations, 1, x_rel_rec.relationship_id);
      DBMS_SQL.COLUMN_VALUE(p_cur_get_relations, 2, x_rel_rec.relationship_type_code);
      DBMS_SQL.COLUMN_VALUE(p_cur_get_relations, 3, x_rel_rec.object_id);
      DBMS_SQL.COLUMN_VALUE(p_cur_get_relations, 4, x_rel_rec.subject_id);
      DBMS_SQL.COLUMN_VALUE(p_cur_get_relations, 5, x_rel_rec.subject_has_child);
      DBMS_SQL.COLUMN_VALUE(p_cur_get_relations, 6, x_rel_rec.position_reference);
      DBMS_SQL.COLUMN_VALUE(p_cur_get_relations, 7, x_rel_rec.active_start_date);
      DBMS_SQL.COLUMN_VALUE(p_cur_get_relations, 8, x_rel_rec.active_end_date);
      DBMS_SQL.COLUMN_VALUE(p_cur_get_relations, 9, x_rel_rec.display_order);
      DBMS_SQL.COLUMN_VALUE(p_cur_get_relations, 10, x_rel_rec.mandatory_flag);
      DBMS_SQL.COLUMN_VALUE(p_cur_get_relations, 11, x_rel_rec.context);
      DBMS_SQL.COLUMN_VALUE(p_cur_get_relations, 12, x_rel_rec.attribute1);
      DBMS_SQL.COLUMN_VALUE(p_cur_get_relations, 13, x_rel_rec.attribute2);
      DBMS_SQL.COLUMN_VALUE(p_cur_get_relations, 14, x_rel_rec.attribute3);
      DBMS_SQL.COLUMN_VALUE(p_cur_get_relations, 15, x_rel_rec.attribute4);
      DBMS_SQL.COLUMN_VALUE(p_cur_get_relations, 16, x_rel_rec.attribute5);
      DBMS_SQL.COLUMN_VALUE(p_cur_get_relations, 17, x_rel_rec.attribute6);
      DBMS_SQL.COLUMN_VALUE(p_cur_get_relations, 18, x_rel_rec.attribute7);
      DBMS_SQL.COLUMN_VALUE(p_cur_get_relations, 19, x_rel_rec.attribute8);
      DBMS_SQL.COLUMN_VALUE(p_cur_get_relations, 20, x_rel_rec.attribute9);
      DBMS_SQL.COLUMN_VALUE(p_cur_get_relations, 21, x_rel_rec.attribute10);
      DBMS_SQL.COLUMN_VALUE(p_cur_get_relations, 22, x_rel_rec.attribute11);
      DBMS_SQL.COLUMN_VALUE(p_cur_get_relations, 23, x_rel_rec.attribute12);
      DBMS_SQL.COLUMN_VALUE(p_cur_get_relations, 24, x_rel_rec.attribute13);
      DBMS_SQL.COLUMN_VALUE(p_cur_get_relations, 25, x_rel_rec.attribute14);
      DBMS_SQL.COLUMN_VALUE(p_cur_get_relations, 26, x_rel_rec.attribute15);
      DBMS_SQL.COLUMN_VALUE(p_cur_get_relations, 27, x_rel_rec.object_version_number);

END get_column_values;


PROCEDURE bind(
    p_relationship_query_rec            IN   csi_datastructures_pub.relationship_query_rec,
    p_cur_get_relations                 IN   NUMBER
)
IS
BEGIN

      IF( (p_relationship_query_rec.relationship_id IS NOT NULL) AND (p_relationship_query_rec.relationship_id <> fnd_api.g_miss_num) )
      THEN
          dbms_sql.bind_variable(p_cur_get_relations, 'relationship_id', p_relationship_query_rec.relationship_id);
      END IF;

      IF( (p_relationship_query_rec.relationship_type_code IS NOT NULL) AND (p_relationship_query_rec.relationship_type_code <> fnd_api.g_miss_char) )
      THEN
          dbms_sql.bind_variable(p_cur_get_relations, 'relationship_type_code', p_relationship_query_rec.relationship_type_code);
      END IF;

      IF( (p_relationship_query_rec.object_id IS NOT NULL) AND (p_relationship_query_rec.object_id <> fnd_api.g_miss_num) )
      THEN
          dbms_sql.bind_variable(p_cur_get_relations, 'object_id', p_relationship_query_rec.object_id);
      END IF;

      IF( (p_relationship_query_rec.subject_id IS NOT NULL) AND (p_relationship_query_rec.subject_id <> fnd_api.g_miss_num) )
      THEN
          dbms_sql.bind_variable(p_cur_get_relations, 'subject_id', p_relationship_query_rec.subject_id);
      END IF;


END bind;


PROCEDURE gen_select(
    p_relship_query_rec               IN    csi_datastructures_pub.relationship_query_rec,
    x_select_cl                       OUT NOCOPY   VARCHAR2
)
IS
l_table_name                                VARCHAR2(30);
BEGIN

 x_select_cl := 'SELECT relationship_id,relationship_type_code,object_id,subject_id'
                ||',nvl((select '||'''Y'''|| ' from csi_ii_relationships where object_id = ciir.subject_id and relationship_type_code = ciir.relationship_type_code and rownum=1), '||'''N'''||') subject_has_child,'
                ||'position_reference,active_start_date,active_end_date,display_order,mandatory_flag,context,attribute1,attribute2,attribute3,attribute4,attribute5,attribute6,attribute7,'
                ||'attribute8,attribute9,attribute10,attribute11,attribute12,attribute13,attribute14'
                ||',attribute15,object_version_number FROM csi_ii_relationships ciir';


END gen_select;

PROCEDURE gen_relations_where(
    p_relship_query_rec               IN    csi_datastructures_pub.relationship_query_rec,
    p_active_relationship_only        IN    VARCHAR2,
    p_depth                           IN    NUMBER,
    x_relations_where                 OUT NOCOPY   VARCHAR2
)
IS
CURSOR c_chk_str1(p_rec_item VARCHAR2) IS
    SELECT instr(p_rec_item, '%', 1, 1)
    FROM dual;
CURSOR c_chk_str2(p_rec_item VARCHAR2) IS
    SELECT instr(p_rec_item, '_', 1, 1)
    FROM dual;

-- return values from cursors
str_csr1   NUMBER;
str_csr2   NUMBER;
i          NUMBER;
l_operator VARCHAR2(10);
l_cnt      NUMBER :=0;

BEGIN


      IF( (p_relship_query_rec.relationship_id IS NOT NULL) AND (p_relship_query_rec.relationship_id <> fnd_api.g_miss_num) )
      THEN
         l_cnt:=l_cnt+1;
          IF(x_relations_where IS NULL) THEN
              x_relations_where := ' WHERE ';
          ELSE
              x_relations_where := x_relations_where || ' AND ';
          END IF;
          x_relations_where := x_relations_where || 'relationship_id = :relationship_id';
      END IF;

   /*** COMMENTED   IF  p_active_relationship_only = 'T' THEN
      l_cnt:=l_cnt+1;
          IF(x_relations_where IS NULL) THEN
             x_relations_where := ' WHERE ';
          ELSE
             x_relations_where := x_relations_where ||' AND ';
          END IF;
             x_relations_where := x_relations_where ||' ( active_end_date is null or active_end_date >= SYSDATE ) ';
      END IF; **** END OF COMMENT ****/

      IF( (p_relship_query_rec.subject_id IS NOT NULL) AND (p_relship_query_rec.subject_id <> fnd_api.g_miss_num) )
      THEN
        l_cnt:=l_cnt+1;
          IF(x_relations_where IS NULL) THEN
              x_relations_where := ' WHERE ';
          ELSE
              x_relations_where := x_relations_where || ' AND ';
          END IF;
          x_relations_where := x_relations_where || 'subject_id = :subject_id';
      END IF;

      IF( (p_relship_query_rec.relationship_type_code IS NOT NULL) AND (p_relship_query_rec.relationship_type_code <> fnd_api.g_miss_char) )
      THEN
      l_cnt:=l_cnt+1;
      i:=0;
          -- check IF item value contains '%' wildcard
            OPEN c_chk_str1(p_relship_query_rec.relationship_type_code);
            FETCH c_chk_str1 INTO str_csr1;
            CLOSE c_chk_str1;
            IF(str_csr1 <> 0) THEN
              l_operator := ' like ';
              i:=1;
            ELSE
              l_operator := ' = ';
            END IF;
            IF i=0 THEN
          -- check if item value contains '_' wildcard
            OPEN c_chk_str2(p_relship_query_rec.relationship_type_code);
            FETCH c_chk_str2 INTO str_csr2;
            CLOSE c_chk_str2;
            IF(str_csr2 <> 0) THEN
              l_operator := ' like ';
            ELSE
              l_operator := ' = ';
            END IF;
            END IF;
            IF(x_relations_where IS NULL) THEN
              x_relations_where := ' WHERE ';
            ELSE
              x_relations_where := x_relations_where || ' AND ';
            END IF;
              x_relations_where := x_relations_where || 'relationship_type_code ' || l_operator || ' :relationship_type_code';
      END IF;

      IF( (p_relship_query_rec.object_id IS NOT NULL) AND (p_relship_query_rec.object_id <> fnd_api.g_miss_num) )
      THEN
          IF(x_relations_where IS NULL) THEN
              x_relations_where := ' WHERE ';
          ELSE
              IF l_cnt>1 THEN
              x_relations_where := x_relations_where || ' AND ';
              ELSE
              x_relations_where := x_relations_where || ' START WITH ';
              END IF;
          END IF;
          IF l_cnt>1 THEN
             x_relations_where := x_relations_where || 'object_id = :object_id ';
          ELSE
             x_relations_where := x_relations_where || 'object_id = :object_id ' ||'CONNECT BY object_id = PRIOR subject_id' ;
             IF ( (p_depth IS NOT NULL) AND (p_depth <> fnd_api.g_miss_num) ) THEN
                x_relations_where := x_relations_where || ' AND level <= '||p_depth;
             END IF;
          END IF;
      END IF;


END gen_relations_where;

/*--------------------------------------------------------------------------------------------------------------+
|                        <-- csi_ii_relationships_h -->                                                         |
|full_dump_flag                                                                                                 |
|       y             y             y              y              y             y                               |
|   c   |----------------------------------------------------------------------------                c          |
|   a   |             |             |              |              |             |    | 11-may-01     a          |
|   s   01-may-01     03-may-01     05-may-01      07-may-01      09-may-01     10-may-01            s          |
|   e                                                                                                e          |
|   1    <------------------------------------case 3--------------------------------->               2          |
|                                                                                                               |
|   case 1: If the passed time stamp (p_time_stamp) falls before the first full_dump_flag(ex:30-apr-01) then    |
|           we have to skip the retreived record.                                                               |
|   case 2: If the passed time stamp (p_time_stamp) falls after the last transaction_date(ex:12-may-01) then    |
|           we have to add the retreived record for display.                                                    |
|   case 3: If the passed time stamp (p_time_stamp say 06-may-01)falls in between 01-may-01 and 11-may-01 then  |
|           we need to find the maximum of the minimum record where the full_dump_flag='Y' (05-may-01 in        |
|           this case) and start building the history record for display.                                       |
+---------------------------------------------------------------------------------------------------------------*/

PROCEDURE from_to_tran( p_relationship_id    IN  NUMBER,
                        p_time_stamp         IN  DATE,
                        from_time_stamp      OUT NOCOPY VARCHAR2,
                        to_time_stamp        OUT NOCOPY VARCHAR2)
IS
l_f_date        VARCHAR2(25)    := fnd_api.g_miss_char;
l_t_date        VARCHAR2(25)    := fnd_api.g_miss_char;
BEGIN

             SELECT max(min(to_char(a.transaction_date,'dd-mon-rr hh24:mi:ss')))
             INTO   l_f_date
             FROM   csi_transactions a,csi_ii_relationships b,csi_ii_relationships_h c
             WHERE  b.relationship_id   =  c.relationship_id
             AND    c.transaction_id    =  a.transaction_id
             AND    c.full_dump_flag    =  'Y'
             AND    a.transaction_date <=  p_time_stamp
             AND    c.relationship_id   =  p_relationship_id
             GROUP BY  to_char(a.transaction_date,'dd-mon-rr hh24:mi:ss');
             IF l_f_date IS NULL THEN
             FROM_time_stamp:=NULL;
             to_time_stamp:=l_t_date;
             ELSE
             FROM_time_stamp:=l_f_date;
             BEGIN
                  SELECT max(min(to_char(a.transaction_date,'dd-mon-rr hh24:mi:ss')))
                  INTO   l_t_date
                  FROM   csi_transactions a,csi_ii_relationships b,csi_ii_relationships_h c
                  WHERE  b.relationship_id  = c.relationship_id
                  AND    c.transaction_id   = a.transaction_id
                  AND    a.transaction_date<= p_time_stamp
                  AND    c.relationship_id  = p_relationship_id
                  GROUP BY  to_char(a.transaction_date,'dd-mon-rr hh24:mi:ss');

                  IF l_t_date IS NULL THEN
                  to_time_stamp:=NULL;
                  ELSE
                  to_time_stamp:=l_t_date;
                  END IF;
             END;
             END IF;
END;


PROCEDURE get_history( p_rel_rec    IN   csi_datastructures_pub.ii_relationship_rec
                      ,p_new_rec    OUT NOCOPY  csi_datastructures_pub.ii_relationship_rec
                      ,p_flag       OUT NOCOPY  VARCHAR2
                      ,p_time_stamp IN   DATE
                      )
IS
CURSOR hist_csr (p_relationship_id    IN NUMBER,
                 p_f_time_stamp       IN VARCHAR2,
                 p_t_time_stamp       IN VARCHAR2)
     IS
       SELECT  c.old_subject_id
              ,c.new_subject_id
              ,c.old_position_reference
              ,c.new_position_reference
              ,c.old_active_start_date
              ,c.new_active_start_date
              ,c.old_active_end_date
              ,c.new_active_end_date
              ,c.old_mandatory_flag
              ,c.new_mandatory_flag
              ,c.old_context
              ,c.new_context
              ,c.old_attribute1
              ,c.new_attribute1
              ,c.old_attribute2
              ,c.new_attribute2
              ,c.old_attribute3
              ,c.new_attribute3
              ,c.old_attribute4
              ,c.new_attribute4
              ,c.old_attribute5
              ,c.new_attribute5
              ,c.old_attribute6
              ,c.new_attribute6
              ,c.old_attribute7
              ,c.new_attribute7
              ,c.old_attribute8
              ,c.new_attribute8
              ,c.old_attribute9
              ,c.new_attribute9
              ,c.old_attribute10
              ,c.new_attribute10
              ,c.old_attribute11
              ,c.new_attribute11
              ,c.old_attribute12
              ,c.new_attribute12
              ,c.old_attribute13
              ,c.new_attribute13
              ,c.old_attribute14
              ,c.new_attribute14
              ,c.old_attribute15
              ,c.new_attribute15
              ,c.full_dump_flag
       FROM   csi_transactions a,csi_ii_relationships b,csi_ii_relationships_h c
       WHERE  b.relationship_id = c.relationship_id
       AND    c.transaction_id  = a.transaction_id
       AND    c.relationship_id = p_relationship_id
       -- AND    a.transaction_date BETWEEN fnd_date.canonical_to_date(p_f_time_stamp) --to_date(p_f_time_stamp,'dd-mon-rr hh24:mi:ss')
         --                         AND     fnd_date.canonical_to_date(p_t_time_stamp) --to_date(p_t_time_stamp,'dd-mon-rr hh24:mi:ss')
       AND    a.transaction_date BETWEEN to_date(p_f_time_stamp,'dd/mm/rr hh24:mi:ss')
                                 AND     to_date(p_t_time_stamp,'dd/mm/rr hh24:mi:ss')
       ORDER BY to_char(a.transaction_date,'dd-mon-rr hh24:mi:ss') ;

l_f_time_stamp      VARCHAR2(25)    :=fnd_api.g_miss_char;
l_t_time_stamp      VARCHAR2(25)    :=fnd_api.g_miss_char;
l_to_date           VARCHAR2(25);
BEGIN
      FROM_to_tran(p_relationship_id     =>  p_rel_rec.relationship_id,
                   p_time_stamp          =>  p_time_stamp,
                   FROM_time_stamp       =>  l_f_time_stamp,
                   to_time_stamp         =>  l_t_time_stamp);

     SELECT max(to_char(a.transaction_date,'dd-mon-rr hh24:mi:ss'))
     INTO   l_to_date
     FROM   csi_transactions a,csi_ii_relationships_h b
     WHERE  a.transaction_id=b.transaction_id
     AND    b.relationship_id=p_rel_rec.relationship_id;

       -- IF ( (l_f_time_stamp IS NOT NULL) AND (p_time_stamp>fnd_date.canonical_to_date(l_to_date) ) )-- to_date(l_to_date,'dd-mon-rr hh24:mi:ss')) ) THEN
       IF ( (l_f_time_stamp IS NOT NULL) AND (p_time_stamp > to_date(l_to_date,'dd/mm/rr hh24:mi:ss')) )THEN
      -- +-------------------------------------------------------------------------------------------+
      -- | we have entered into case 2 which we just add the retreived record for display            |
      -- +-------------------------------------------------------------------------------------------+


            p_new_rec := p_rel_rec;
            p_flag   := 'ADD';
       ELSIF (l_f_time_stamp IS NULL) THEN
       -- +-------------------------------------------------------------------------------------------+
       -- | we have entered into case 1 which we have to skip the record.                             |
       -- +-------------------------------------------------------------------------------------------+

           p_flag   := 'SKIP';
       ELSE
       -- +-------------------------------------------------------------------------------------------+
       -- |we have entered into case 3 where we have to compare the record and return flag with 'add'.|
       -- +-------------------------------------------------------------------------------------------+

          FOR get_csr IN hist_csr(p_rel_rec.relationship_id,l_f_time_stamp,l_t_time_stamp) LOOP

             p_new_rec.relationship_id:=p_rel_rec.relationship_id;
             p_new_rec.relationship_type_code:=p_rel_rec.relationship_type_code;
             p_new_rec.object_id:=p_rel_rec.object_id;
             p_new_rec.display_order:=p_rel_rec.display_order;

             IF get_csr.new_subject_id IS NOT NULL THEN
                p_new_rec.subject_id := get_csr.new_subject_id;
             ELSIF get_csr.full_dump_flag='Y' THEN
                p_new_rec.subject_id := get_csr.old_subject_id;
             END IF;

             IF get_csr.new_position_reference IS NOT NULL THEN
                p_new_rec.position_reference := get_csr.new_position_reference;
             ELSIF get_csr.full_dump_flag='Y' THEN
                p_new_rec.position_reference := get_csr.old_position_reference;
             END IF;

             IF get_csr.new_active_start_date IS NOT NULL THEN
                p_new_rec.active_start_date := get_csr.new_active_start_date;
             ELSIF get_csr.full_dump_flag='Y' THEN
                p_new_rec.active_start_date := get_csr.old_active_start_date;
             END IF;

             IF get_csr.new_active_end_date IS NOT NULL THEN
                p_new_rec.active_end_date := get_csr.new_active_end_date;
             ELSIF get_csr.full_dump_flag='Y' THEN
                p_new_rec.active_end_date := get_csr.old_active_end_date;
             END IF;

             IF get_csr.new_mandatory_flag IS NOT NULL THEN
                p_new_rec.mandatory_flag := get_csr.new_mandatory_flag;
             ELSIF get_csr.full_dump_flag='Y' THEN
                p_new_rec.mandatory_flag := get_csr.old_mandatory_flag;
             END IF;

             IF get_csr.new_context IS NOT NULL THEN
                p_new_rec.context := get_csr.new_context;
             ELSIF get_csr.full_dump_flag='Y' THEN
                p_new_rec.context := get_csr.old_context;
             END IF;

             IF get_csr.new_attribute1 IS NOT NULL THEN
                p_new_rec.attribute1 := get_csr.new_attribute1;
             ELSIF get_csr.full_dump_flag='Y' THEN
                p_new_rec.attribute1 := get_csr.old_attribute1;
             END IF;

             IF get_csr.new_attribute2 IS NOT NULL THEN
                p_new_rec.attribute2 := get_csr.new_attribute2;
             ELSIF get_csr.full_dump_flag='Y' THEN
                p_new_rec.attribute2 := get_csr.old_attribute2;
             END IF;

             IF get_csr.new_attribute3 IS NOT NULL THEN
                p_new_rec.attribute3 := get_csr.new_attribute3;
             ELSIF get_csr.full_dump_flag='Y' THEN
                p_new_rec.attribute3 := get_csr.old_attribute3;
             END IF;

             IF get_csr.new_attribute4 IS NOT NULL THEN
                p_new_rec.attribute4 := get_csr.new_attribute4;
             ELSIF get_csr.full_dump_flag='Y' THEN
                p_new_rec.attribute4 := get_csr.old_attribute4;
             END IF;

             IF get_csr.new_attribute5 IS NOT NULL THEN
                p_new_rec.attribute5 := get_csr.new_attribute5;
             ELSIF get_csr.full_dump_flag='Y' THEN
                p_new_rec.attribute5 := get_csr.old_attribute5;
             END IF;

             IF get_csr.new_attribute6 IS NOT NULL THEN
                p_new_rec.attribute6 := get_csr.new_attribute6;
             ELSIF get_csr.full_dump_flag='Y' THEN
                p_new_rec.attribute6 := get_csr.old_attribute6;
             END IF;

             IF get_csr.new_attribute7 IS NOT NULL THEN
                p_new_rec.attribute7 := get_csr.new_attribute7;
             ELSIF get_csr.full_dump_flag='Y' THEN
                p_new_rec.attribute7 := get_csr.old_attribute7;
             END IF;

             IF get_csr.new_attribute8 IS NOT NULL THEN
                p_new_rec.attribute8 := get_csr.new_attribute8;
             ELSIF get_csr.full_dump_flag='Y' THEN
                p_new_rec.attribute8 := get_csr.old_attribute8;
             END IF;

             IF  get_csr.new_attribute9 IS NOT NULL THEN
                p_new_rec.attribute9 := get_csr.new_attribute9;
             ELSIF get_csr.full_dump_flag='Y' THEN
                p_new_rec.attribute9 := get_csr.old_attribute9;
             END IF;

             IF get_csr.new_attribute10 IS NOT NULL THEN
                p_new_rec.attribute10 := get_csr.new_attribute10;
             ELSIF get_csr.full_dump_flag='Y' THEN
                p_new_rec.attribute10 := get_csr.old_attribute10;
             END IF;

             IF get_csr.new_attribute11 IS NOT NULL THEN
                p_new_rec.attribute11 := get_csr.new_attribute11;
             ELSIF get_csr.full_dump_flag='Y' THEN
                p_new_rec.attribute11 := get_csr.old_attribute11;
             END IF;

             IF  get_csr.new_attribute12 IS NOT NULL THEN
                p_new_rec.attribute12 := get_csr.new_attribute12;
             ELSIF get_csr.full_dump_flag='Y' THEN
                p_new_rec.attribute12 := get_csr.old_attribute12;
             END IF;

             IF get_csr.new_attribute13 IS NOT NULL THEN
                p_new_rec.attribute13 := get_csr.new_attribute13;
             ELSIF get_csr.full_dump_flag='Y' THEN
                p_new_rec.attribute13 := get_csr.old_attribute13;
             END IF;

             IF  get_csr.new_attribute14 IS NOT NULL THEN
                p_new_rec.attribute14 := get_csr.new_attribute14;
             ELSIF get_csr.full_dump_flag='Y' THEN
                p_new_rec.attribute14 := get_csr.old_attribute14;
             END IF;

             IF  get_csr.new_attribute15 IS NOT NULL THEN
                p_new_rec.attribute15 := get_csr.new_attribute15;
             ELSIF get_csr.full_dump_flag='Y' THEN
                p_new_rec.attribute15 := get_csr.old_attribute15;
             END IF;

          END LOOP;
             IF  p_new_rec.display_order = fnd_api.g_miss_num THEN
                 p_new_rec.display_order := NULL;
             END IF;

             IF p_new_rec.subject_id = fnd_api.g_miss_num THEN
                p_new_rec.subject_id := NULL;
             END IF;

             IF p_new_rec.position_reference = fnd_api.g_miss_char THEN
                 p_new_rec.position_reference := NULL;
             END IF;

             IF p_new_rec.active_start_date = fnd_api.g_miss_date THEN
                 p_new_rec.active_start_date := NULL;
             END IF;

             IF p_new_rec.active_end_date = fnd_api.g_miss_date THEN
                p_new_rec.active_end_date := NULL;
             END IF;

             IF p_new_rec.mandatory_flag = fnd_api.g_miss_char THEN
                p_new_rec.mandatory_flag := NULL;
             END IF;

             IF p_new_rec.context = fnd_api.g_miss_char THEN
                p_new_rec.context := NULL;
             END IF;

             IF p_new_rec.attribute1 = fnd_api.g_miss_char THEN
                p_new_rec.attribute1 := NULL;
             END IF;

             IF p_new_rec.attribute2 = fnd_api.g_miss_char THEN
                p_new_rec.attribute2 := NULL;
             END IF;

             IF p_new_rec.attribute3 = fnd_api.g_miss_char THEN
                p_new_rec.attribute3 := NULL;
             END IF;

             IF p_new_rec.attribute4 = fnd_api.g_miss_char THEN
                p_new_rec.attribute4 := NULL;
             END IF;

             IF p_new_rec.attribute5 = fnd_api.g_miss_char THEN
                p_new_rec.attribute5 := NULL;
             END IF;

             IF p_new_rec.attribute6 = fnd_api.g_miss_char THEN
                p_new_rec.attribute6 := NULL;
             END IF;

             IF p_new_rec.attribute7 =fnd_api.g_miss_char THEN
                p_new_rec.attribute7 := NULL;
             END IF;

             IF p_new_rec.attribute8 = fnd_api.g_miss_char THEN
                p_new_rec.attribute8 := NULL;
             END IF;

             IF p_new_rec.attribute9 = fnd_api.g_miss_char THEN
                p_new_rec.attribute9 := NULL;
             END IF;

             IF p_new_rec.attribute10 = fnd_api.g_miss_char THEN
                p_new_rec.attribute10 := NULL;
             END IF;

             IF p_new_rec.attribute11 = fnd_api.g_miss_char THEN
                p_new_rec.attribute11 := NULL;
             END IF;

             IF p_new_rec.attribute12 = fnd_api.g_miss_char THEN
                p_new_rec.attribute12 := NULL;
             END IF;

             IF p_new_rec.attribute13 = fnd_api.g_miss_char THEN
                p_new_rec.attribute13 := NULL;
             END IF;

             IF p_new_rec.attribute14 =fnd_api.g_miss_char THEN
                p_new_rec.attribute14 := NULL;
             END IF;

             IF p_new_rec.attribute15 = fnd_api.g_miss_char THEN
                p_new_rec.attribute15 := NULL;
             END IF;

           p_flag :='ADD';
        END IF;
END;

PROCEDURE Get_Next_Level
    (p_object_id                 IN  NUMBER,
     p_rel_tbl                   OUT NOCOPY csi_datastructures_pub.ii_relationship_tbl
    ) IS
    --
    CURSOR REL_CUR IS
     select relationship_id,relationship_type_code,object_id,subject_id,position_reference,
            active_start_date,active_end_date,display_order,mandatory_flag,context,
            attribute1,attribute2,attribute3,attribute4,attribute5,attribute6,attribute7,attribute8,
            attribute9,attribute10,attribute11,attribute12,attribute13,attribute14,attribute15,
            object_version_number
     from CSI_II_RELATIONSHIPS cir
     where cir.object_id = p_object_id;
     --
     l_ctr      NUMBER := 0;
  BEGIN
     FOR rel in REL_CUR LOOP
        l_ctr := l_ctr + 1;
        p_rel_tbl(l_ctr).relationship_id := rel.relationship_id;
        p_rel_tbl(l_ctr).relationship_type_code := rel.relationship_type_code;
        p_rel_tbl(l_ctr).object_id := rel.object_id;
        p_rel_tbl(l_ctr).subject_id := rel.subject_id;
        p_rel_tbl(l_ctr).position_reference := rel.position_reference;
        p_rel_tbl(l_ctr).active_start_date := rel.active_start_date;
        p_rel_tbl(l_ctr).active_end_date := rel.active_end_date;
        p_rel_tbl(l_ctr).display_order := rel.display_order;
        p_rel_tbl(l_ctr).mandatory_flag := rel.mandatory_flag;
        p_rel_tbl(l_ctr).context := rel.context;
        p_rel_tbl(l_ctr).attribute1 := rel.attribute1;
        p_rel_tbl(l_ctr).attribute2 := rel.attribute2;
        p_rel_tbl(l_ctr).attribute3 := rel.attribute3;
        p_rel_tbl(l_ctr).attribute4 := rel.attribute4;
        p_rel_tbl(l_ctr).attribute5 := rel.attribute5;
        p_rel_tbl(l_ctr).attribute6 := rel.attribute6;
        p_rel_tbl(l_ctr).attribute7 := rel.attribute7;
        p_rel_tbl(l_ctr).attribute8 := rel.attribute8;
        p_rel_tbl(l_ctr).attribute9 := rel.attribute9;
        p_rel_tbl(l_ctr).attribute10 := rel.attribute10;
        p_rel_tbl(l_ctr).attribute11 := rel.attribute11;
        p_rel_tbl(l_ctr).attribute12 := rel.attribute12;
        p_rel_tbl(l_ctr).attribute13 := rel.attribute13;
        p_rel_tbl(l_ctr).attribute14 := rel.attribute14;
        p_rel_tbl(l_ctr).attribute15 := rel.attribute15;
        p_rel_tbl(l_ctr).object_version_number := rel.object_version_number;
     END LOOP;
  END Get_Next_Level;


  PROCEDURE Get_Children
    (p_object_id     IN  NUMBER,
     p_rel_tbl       OUT NOCOPY csi_datastructures_pub.ii_relationship_tbl
    ) IS
    --
    l_rel_tbl                 csi_datastructures_pub.ii_relationship_tbl;
    l_rel_tbl_next_lvl        csi_datastructures_pub.ii_relationship_tbl;
    l_rel_tbl_temp            csi_datastructures_pub.ii_relationship_tbl;
    l_rel_tbl_final           csi_datastructures_pub.ii_relationship_tbl;
    l_next_ind                NUMBER := 0;
    l_final_ind               NUMBER := 0;
    l_ctr                     NUMBER := 0;
    l_found                   NUMBER;
  BEGIN
     Get_Next_Level
       ( p_object_id                 => p_object_id,
         p_rel_tbl                   => l_rel_tbl
       );

     <<Next_Level>>

     l_rel_tbl_next_lvl.delete;
     l_next_ind := 0;
     --
     IF l_rel_tbl.count > 0 THEN
        FOR l_ind IN l_rel_tbl.FIRST .. l_rel_tbl.LAST LOOP
           l_final_ind := l_final_ind + 1;
           l_rel_tbl_final(l_final_ind) := l_rel_tbl(l_ind);
           /* get the next level using this Subject ID as the parent */
           Get_Next_Level
             ( p_object_id                 => l_rel_tbl(l_ind).subject_id,
               p_rel_tbl                   => l_rel_tbl_temp
             );
           --
           IF l_rel_tbl_temp.count > 0 THEN
              FOR l_temp_ind IN l_rel_tbl_temp.FIRST .. l_rel_tbl_temp.LAST LOOP
                 IF l_rel_tbl_final.count > 0 THEN
                    l_found := 0;
                    FOR i IN l_rel_tbl_final.FIRST .. l_rel_tbl_final.LAST LOOP
                       IF l_rel_tbl_final(i).object_id = l_rel_tbl_temp(l_temp_ind).object_id THEN
                          l_found := 1;
                          exit;
                       END IF;
                    END LOOP;
                 END IF;
                 IF l_found = 0 THEN
                    l_next_ind := l_next_ind + 1;
                    l_rel_tbl_next_lvl(l_next_ind) := l_rel_tbl_temp(l_temp_ind);
                 END IF;
              END LOOP;
           END IF;
        END LOOP;
        --
        IF l_rel_tbl_next_lvl.count > 0 THEN
           l_rel_tbl.DELETE;
           l_rel_tbl := l_rel_tbl_next_lvl;
           --
           goto Next_Level;
        END IF;
     END IF;
     --
     p_rel_tbl := l_rel_tbl_final;
     --
     -- The output of l_rel_tbl_final will be Breadth first search Order.
  END Get_Children;
  --
  FUNCTION Parent_of
     ( p_subject_id      IN  NUMBER,
       p_rel_tbl         IN  csi_datastructures_pub.ii_relationship_tbl
     ) RETURN NUMBER IS
     l_return_value    NUMBER := -9999;
  BEGIN
     IF p_rel_tbl.count = 0 OR
	p_subject_id IS NULL THEN
	RETURN -9999;
     END IF;
     FOR i in p_rel_tbl.FIRST ..p_rel_tbl.LAST LOOP
	IF p_rel_tbl(i).subject_id = p_subject_id THEN
	   l_return_value := p_rel_tbl(i).object_id;
	   exit;
	END IF;
     END LOOP;
     RETURN l_return_value;
  END Parent_of;
  --
  PROCEDURE Get_Next_Level
    (p_object_id                 IN  NUMBER,
     p_relationship_id           IN  NUMBER,
     p_subject_id                IN  NUMBER,
     p_rel_tbl                   OUT NOCOPY csi_datastructures_pub.ii_relationship_tbl,
     p_rel_type_code             IN  VARCHAR2,
     p_time_stamp                IN  DATE,
     p_active_relationship_only  IN  VARCHAR2,
     p_active_instances_only     IN  VARCHAR2,
     p_config_only               IN  VARCHAR2
    ) IS
    --
    l_active_relationship_only   VARCHAR2(1) := p_active_relationship_only;
    l_active_instances_only      VARCHAR2(1) := p_active_instances_only;
    --
     CURSOR OBJECT_CUR(c_sysdate IN DATE) IS -- Used when Object ID and Rel Type are passed
     select relationship_id,relationship_type_code,object_id,subject_id,position_reference,
            active_start_date,active_end_date,display_order,mandatory_flag,context,
            attribute1,attribute2,attribute3,attribute4,attribute5,attribute6,attribute7,attribute8,
            attribute9,attribute10,attribute11,attribute12,attribute13,attribute14,attribute15,
            object_version_number
     from CSI_II_RELATIONSHIPS cir
     where cir.object_id = p_object_id
     and   cir.relationship_type_code = p_rel_type_code
     and   DECODE(l_active_relationship_only,FND_API.G_TRUE,NVL((cir.active_end_date),c_sysdate+1),c_sysdate+1) > sysdate
     and   EXISTS (select 'x'
                   from CSI_ITEM_INSTANCES csi
                   where csi.instance_id = cir.subject_id
                   and   DECODE(l_active_instances_only,FND_API.G_TRUE,NVL((csi.active_end_date),c_sysdate+1),c_sysdate+1) > sysdate);
     --
     CURSOR OBJECT_CUR1(c_sysdate IN DATE) IS -- Used when Object ID and Rel Type are passed
     select relationship_id,relationship_type_code,object_id,subject_id,position_reference,
            active_start_date,active_end_date,display_order,mandatory_flag,context,
            attribute1,attribute2,attribute3,attribute4,attribute5,attribute6,attribute7,attribute8,
            attribute9,attribute10,attribute11,attribute12,attribute13,attribute14,attribute15,
            object_version_number
     from CSI_II_RELATIONSHIPS cir
     where cir.object_id = p_object_id
     and   cir.relationship_type_code = p_rel_type_code
     and   DECODE(l_active_relationship_only,FND_API.G_TRUE,NVL((cir.active_end_date),c_sysdate+1),c_sysdate+1) > sysdate
     and   EXISTS (select 'x'
                   from CSI_ITEM_INSTANCES csi
                   where csi.instance_id = cir.subject_id
                   and   csi.config_inst_hdr_id is not null
                   and   csi.config_inst_item_id is not null
                   and   csi.config_inst_rev_num is not null
                   and   DECODE(l_active_instances_only,FND_API.G_TRUE,NVL((csi.active_end_date),c_sysdate+1),c_sysdate+1) > sysdate);
     --
     CURSOR OBJECT_ONLY_CUR(c_sysdate IN DATE) IS -- Used when only Object ID is passed
     select relationship_id,relationship_type_code,object_id,subject_id,position_reference,
            active_start_date,active_end_date,display_order,mandatory_flag,context,
            attribute1,attribute2,attribute3,attribute4,attribute5,attribute6,attribute7,attribute8,
            attribute9,attribute10,attribute11,attribute12,attribute13,attribute14,attribute15,
            object_version_number
     from CSI_II_RELATIONSHIPS cir
     where cir.object_id = p_object_id
     and   DECODE(l_active_relationship_only,FND_API.G_TRUE,NVL((cir.active_end_date),c_sysdate+1),c_sysdate+1) > sysdate
     and   EXISTS (select 'x'
                   from CSI_ITEM_INSTANCES csi
                   where csi.instance_id = cir.subject_id
                   and   DECODE(l_active_instances_only,FND_API.G_TRUE,NVL((csi.active_end_date),c_sysdate+1),c_sysdate+1) > sysdate);
     --
     CURSOR SUBJECT_CUR(c_sysdate IN DATE) IS --Used when subject ID and Rel type are passed
     select relationship_id,relationship_type_code,object_id,subject_id,position_reference,
            active_start_date,active_end_date,display_order,mandatory_flag,context,
            attribute1,attribute2,attribute3,attribute4,attribute5,attribute6,attribute7,attribute8,
            attribute9,attribute10,attribute11,attribute12,attribute13,attribute14,attribute15,
            object_version_number
     from CSI_II_RELATIONSHIPS cir
     where cir.subject_id = p_subject_id
     and   cir.relationship_type_code = p_rel_type_code
     and   DECODE(l_active_relationship_only,FND_API.G_TRUE,NVL((cir.active_end_date),c_sysdate+1),c_sysdate+1) > sysdate
     and   EXISTS (select 'x'
                   from CSI_ITEM_INSTANCES csi
                   where csi.instance_id = cir.subject_id
                   and   DECODE(l_active_instances_only,FND_API.G_TRUE,NVL((csi.active_end_date),c_sysdate+1),c_sysdate+1) > sysdate);
     --
     CURSOR REL_ID_CUR(c_sysdate IN DATE) IS -- Used when only relationship_id is passed
     select relationship_id,relationship_type_code,object_id,subject_id,position_reference,
            active_start_date,active_end_date,display_order,mandatory_flag,context,
            attribute1,attribute2,attribute3,attribute4,attribute5,attribute6,attribute7,attribute8,
            attribute9,attribute10,attribute11,attribute12,attribute13,attribute14,attribute15,
            object_version_number
     from CSI_II_RELATIONSHIPS cir
     where cir.relationship_id = p_relationship_id
     and   DECODE(l_active_relationship_only,FND_API.G_TRUE,NVL((cir.active_end_date),c_sysdate+1),c_sysdate+1) > sysdate
     and   EXISTS (select 'x'
                   from CSI_ITEM_INSTANCES csi
                   where csi.instance_id = cir.subject_id
                   and   DECODE(l_active_instances_only,FND_API.G_TRUE,NVL((csi.active_end_date),c_sysdate+1),c_sysdate+1) > sysdate);
     --
     CURSOR OTHER_PARAM_CUR(c_sysdate IN DATE) IS
     select relationship_id,relationship_type_code,object_id,subject_id,position_reference,
            active_start_date,active_end_date,display_order,mandatory_flag,context,
            attribute1,attribute2,attribute3,attribute4,attribute5,attribute6,attribute7,attribute8,
            attribute9,attribute10,attribute11,attribute12,attribute13,attribute14,attribute15,
            object_version_number
     from CSI_II_RELATIONSHIPS cir
     where cir.relationship_id = NVL(p_relationship_id,cir.relationship_id)
     and   cir.object_id = NVL(p_object_id,cir.object_id)
     and   cir.relationship_type_code = NVL(p_rel_type_code,cir.relationship_type_code)
     and   cir.subject_id = NVL(p_subject_id,cir.subject_id)
     and   DECODE(l_active_relationship_only,FND_API.G_TRUE,NVL((cir.active_end_date),c_sysdate+1),c_sysdate+1) > sysdate
     and   EXISTS (select 'x'
                   from CSI_ITEM_INSTANCES csi
                   where csi.instance_id = cir.subject_id
                   and   DECODE(l_active_instances_only,FND_API.G_TRUE,NVL((csi.active_end_date),c_sysdate+1),c_sysdate+1) > sysdate);
     --
     l_ctr      NUMBER := 0;
     l_sysdate  DATE;
     COMP_EXCEP EXCEPTION;
  BEGIN
     select sysdate
     into l_sysdate
     from dual;
     --
     IF p_time_stamp IS NOT NULL THEN
        l_active_instances_only := FND_API.G_FALSE;
        l_active_relationship_only := FND_API.G_FALSE;
     ELSE
        l_active_relationship_only  := p_active_relationship_only;
        l_active_instances_only     := p_active_instances_only;
     END IF;
     --
    IF p_object_id IS NOT NULL AND
	   p_rel_type_code IS NOT NULL AND
	   p_subject_id IS NULL AND
	   p_relationship_id IS NULL
    THEN
    IF p_config_only IS NULL OR
       p_config_only = fnd_api.g_false
    THEN
	FOR rel IN OBJECT_CUR(l_sysdate) LOOP
	   l_ctr := l_ctr + 1;
	   p_rel_tbl(l_ctr).relationship_id := rel.relationship_id;
	   p_rel_tbl(l_ctr).relationship_type_code := rel.relationship_type_code;
	   p_rel_tbl(l_ctr).object_id := rel.object_id;
	   p_rel_tbl(l_ctr).subject_id := rel.subject_id;
	   p_rel_tbl(l_ctr).position_reference := rel.position_reference;
	   p_rel_tbl(l_ctr).active_start_date := rel.active_start_date;
	   p_rel_tbl(l_ctr).active_end_date := rel.active_end_date;
	   p_rel_tbl(l_ctr).display_order := rel.display_order;
	   p_rel_tbl(l_ctr).mandatory_flag := rel.mandatory_flag;
	   p_rel_tbl(l_ctr).context := rel.context;
	   p_rel_tbl(l_ctr).attribute1 := rel.attribute1;
	   p_rel_tbl(l_ctr).attribute2 := rel.attribute2;
	   p_rel_tbl(l_ctr).attribute3 := rel.attribute3;
	   p_rel_tbl(l_ctr).attribute4 := rel.attribute4;
	   p_rel_tbl(l_ctr).attribute5 := rel.attribute5;
	   p_rel_tbl(l_ctr).attribute6 := rel.attribute6;
	   p_rel_tbl(l_ctr).attribute7 := rel.attribute7;
	   p_rel_tbl(l_ctr).attribute8 := rel.attribute8;
	   p_rel_tbl(l_ctr).attribute9 := rel.attribute9;
	   p_rel_tbl(l_ctr).attribute10 := rel.attribute10;
	   p_rel_tbl(l_ctr).attribute11 := rel.attribute11;
	   p_rel_tbl(l_ctr).attribute12 := rel.attribute12;
	   p_rel_tbl(l_ctr).attribute13 := rel.attribute13;
	   p_rel_tbl(l_ctr).attribute14 := rel.attribute14;
	   p_rel_tbl(l_ctr).attribute15 := rel.attribute15;
	   p_rel_tbl(l_ctr).object_version_number := rel.object_version_number;
	   --
	   Begin
	      select 'Y'
	      into p_rel_tbl(l_ctr).subject_has_child
	      from CSI_II_RELATIONSHIPS
	      where object_id = rel.subject_id
	      and   relationship_type_code = rel.relationship_type_code
	      and   rownum = 1;
	   Exception
	      when no_data_found then
		 p_rel_tbl(l_ctr).subject_has_child := 'N';
	   End;
	END LOOP;
    ELSIF p_config_only IS NOT NULL AND
          p_config_only = fnd_api.g_true
    THEN
	FOR rel IN OBJECT_CUR1(l_sysdate) LOOP
	   l_ctr := l_ctr + 1;
	   p_rel_tbl(l_ctr).relationship_id := rel.relationship_id;
	   p_rel_tbl(l_ctr).relationship_type_code := rel.relationship_type_code;
	   p_rel_tbl(l_ctr).object_id := rel.object_id;
	   p_rel_tbl(l_ctr).subject_id := rel.subject_id;
	   p_rel_tbl(l_ctr).position_reference := rel.position_reference;
	   p_rel_tbl(l_ctr).active_start_date := rel.active_start_date;
	   p_rel_tbl(l_ctr).active_end_date := rel.active_end_date;
	   p_rel_tbl(l_ctr).display_order := rel.display_order;
	   p_rel_tbl(l_ctr).mandatory_flag := rel.mandatory_flag;
	   p_rel_tbl(l_ctr).context := rel.context;
	   p_rel_tbl(l_ctr).attribute1 := rel.attribute1;
	   p_rel_tbl(l_ctr).attribute2 := rel.attribute2;
	   p_rel_tbl(l_ctr).attribute3 := rel.attribute3;
	   p_rel_tbl(l_ctr).attribute4 := rel.attribute4;
	   p_rel_tbl(l_ctr).attribute5 := rel.attribute5;
	   p_rel_tbl(l_ctr).attribute6 := rel.attribute6;
	   p_rel_tbl(l_ctr).attribute7 := rel.attribute7;
	   p_rel_tbl(l_ctr).attribute8 := rel.attribute8;
	   p_rel_tbl(l_ctr).attribute9 := rel.attribute9;
	   p_rel_tbl(l_ctr).attribute10 := rel.attribute10;
	   p_rel_tbl(l_ctr).attribute11 := rel.attribute11;
	   p_rel_tbl(l_ctr).attribute12 := rel.attribute12;
	   p_rel_tbl(l_ctr).attribute13 := rel.attribute13;
	   p_rel_tbl(l_ctr).attribute14 := rel.attribute14;
	   p_rel_tbl(l_ctr).attribute15 := rel.attribute15;
	   p_rel_tbl(l_ctr).object_version_number := rel.object_version_number;
	   --
	   Begin
	      select 'Y'
	      into p_rel_tbl(l_ctr).subject_has_child
	      from CSI_II_RELATIONSHIPS
	      where object_id = rel.subject_id
	      and   relationship_type_code = rel.relationship_type_code
	      and   rownum = 1;
	   Exception
	      when no_data_found then
		 p_rel_tbl(l_ctr).subject_has_child := 'N';
	   End;
	END LOOP;

    END IF;
	RAISE COMP_EXCEP;
     END IF;
     --
     IF p_object_id IS NOT NULL AND
	p_rel_type_code IS NULL AND
	p_subject_id IS NULL AND
	p_relationship_id IS NULL THEN
	FOR rel IN OBJECT_ONLY_CUR(l_sysdate) LOOP
	   l_ctr := l_ctr + 1;
	   p_rel_tbl(l_ctr).relationship_id := rel.relationship_id;
	   p_rel_tbl(l_ctr).relationship_type_code := rel.relationship_type_code;
	   p_rel_tbl(l_ctr).object_id := rel.object_id;
	   p_rel_tbl(l_ctr).subject_id := rel.subject_id;
	   p_rel_tbl(l_ctr).position_reference := rel.position_reference;
	   p_rel_tbl(l_ctr).active_start_date := rel.active_start_date;
	   p_rel_tbl(l_ctr).active_end_date := rel.active_end_date;
	   p_rel_tbl(l_ctr).display_order := rel.display_order;
	   p_rel_tbl(l_ctr).mandatory_flag := rel.mandatory_flag;
	   p_rel_tbl(l_ctr).context := rel.context;
	   p_rel_tbl(l_ctr).attribute1 := rel.attribute1;
	   p_rel_tbl(l_ctr).attribute2 := rel.attribute2;
	   p_rel_tbl(l_ctr).attribute3 := rel.attribute3;
	   p_rel_tbl(l_ctr).attribute4 := rel.attribute4;
	   p_rel_tbl(l_ctr).attribute5 := rel.attribute5;
	   p_rel_tbl(l_ctr).attribute6 := rel.attribute6;
	   p_rel_tbl(l_ctr).attribute7 := rel.attribute7;
	   p_rel_tbl(l_ctr).attribute8 := rel.attribute8;
	   p_rel_tbl(l_ctr).attribute9 := rel.attribute9;
	   p_rel_tbl(l_ctr).attribute10 := rel.attribute10;
	   p_rel_tbl(l_ctr).attribute11 := rel.attribute11;
	   p_rel_tbl(l_ctr).attribute12 := rel.attribute12;
	   p_rel_tbl(l_ctr).attribute13 := rel.attribute13;
	   p_rel_tbl(l_ctr).attribute14 := rel.attribute14;
	   p_rel_tbl(l_ctr).attribute15 := rel.attribute15;
	   p_rel_tbl(l_ctr).object_version_number := rel.object_version_number;
	   --
	   Begin
	      select 'Y'
	      into p_rel_tbl(l_ctr).subject_has_child
	      from CSI_II_RELATIONSHIPS
	      where object_id = rel.subject_id
	      and   relationship_type_code = rel.relationship_type_code
	      and   rownum = 1;
	   Exception
	      when no_data_found then
		 p_rel_tbl(l_ctr).subject_has_child := 'N';
	   End;
	END LOOP;
	RAISE COMP_EXCEP;
     END IF;
     --
     IF p_subject_id IS NOT NULL AND
	p_rel_type_code IS NOT NULL AND
	p_object_id IS NULL AND
	p_relationship_id IS NULL THEN
	FOR rel IN SUBJECT_CUR(l_sysdate) LOOP
	   l_ctr := l_ctr + 1;
	   p_rel_tbl(l_ctr).relationship_id := rel.relationship_id;
	   p_rel_tbl(l_ctr).relationship_type_code := rel.relationship_type_code;
	   p_rel_tbl(l_ctr).object_id := rel.object_id;
	   p_rel_tbl(l_ctr).subject_id := rel.subject_id;
	   p_rel_tbl(l_ctr).position_reference := rel.position_reference;
	   p_rel_tbl(l_ctr).active_start_date := rel.active_start_date;
	   p_rel_tbl(l_ctr).active_end_date := rel.active_end_date;
	   p_rel_tbl(l_ctr).display_order := rel.display_order;
	   p_rel_tbl(l_ctr).mandatory_flag := rel.mandatory_flag;
	   p_rel_tbl(l_ctr).context := rel.context;
	   p_rel_tbl(l_ctr).attribute1 := rel.attribute1;
	   p_rel_tbl(l_ctr).attribute2 := rel.attribute2;
	   p_rel_tbl(l_ctr).attribute3 := rel.attribute3;
	   p_rel_tbl(l_ctr).attribute4 := rel.attribute4;
	   p_rel_tbl(l_ctr).attribute5 := rel.attribute5;
	   p_rel_tbl(l_ctr).attribute6 := rel.attribute6;
	   p_rel_tbl(l_ctr).attribute7 := rel.attribute7;
	   p_rel_tbl(l_ctr).attribute8 := rel.attribute8;
	   p_rel_tbl(l_ctr).attribute9 := rel.attribute9;
	   p_rel_tbl(l_ctr).attribute10 := rel.attribute10;
	   p_rel_tbl(l_ctr).attribute11 := rel.attribute11;
	   p_rel_tbl(l_ctr).attribute12 := rel.attribute12;
	   p_rel_tbl(l_ctr).attribute13 := rel.attribute13;
	   p_rel_tbl(l_ctr).attribute14 := rel.attribute14;
	   p_rel_tbl(l_ctr).attribute15 := rel.attribute15;
	   p_rel_tbl(l_ctr).object_version_number := rel.object_version_number;
	   --
	   Begin
	      select 'Y'
	      into p_rel_tbl(l_ctr).subject_has_child
	      from CSI_II_RELATIONSHIPS
	      where object_id = rel.subject_id
	      and   relationship_type_code = rel.relationship_type_code
	      and   rownum = 1;
	   Exception
	      when no_data_found then
		 p_rel_tbl(l_ctr).subject_has_child := 'N';
	   End;
	END LOOP;
	RAISE COMP_EXCEP;
     END IF;
     --
     IF p_relationship_id IS NOT NULL AND
        p_rel_type_code IS NULL AND
        p_subject_id IS NULL AND
        p_object_id IS NULL THEN
        FOR rel IN REL_ID_CUR(l_sysdate) LOOP
	   l_ctr := l_ctr + 1;
	   p_rel_tbl(l_ctr).relationship_id := rel.relationship_id;
	   p_rel_tbl(l_ctr).relationship_type_code := rel.relationship_type_code;
	   p_rel_tbl(l_ctr).object_id := rel.object_id;
	   p_rel_tbl(l_ctr).subject_id := rel.subject_id;
	   p_rel_tbl(l_ctr).position_reference := rel.position_reference;
	   p_rel_tbl(l_ctr).active_start_date := rel.active_start_date;
	   p_rel_tbl(l_ctr).active_end_date := rel.active_end_date;
	   p_rel_tbl(l_ctr).display_order := rel.display_order;
	   p_rel_tbl(l_ctr).mandatory_flag := rel.mandatory_flag;
	   p_rel_tbl(l_ctr).context := rel.context;
	   p_rel_tbl(l_ctr).attribute1 := rel.attribute1;
	   p_rel_tbl(l_ctr).attribute2 := rel.attribute2;
	   p_rel_tbl(l_ctr).attribute3 := rel.attribute3;
	   p_rel_tbl(l_ctr).attribute4 := rel.attribute4;
	   p_rel_tbl(l_ctr).attribute5 := rel.attribute5;
	   p_rel_tbl(l_ctr).attribute6 := rel.attribute6;
	   p_rel_tbl(l_ctr).attribute7 := rel.attribute7;
	   p_rel_tbl(l_ctr).attribute8 := rel.attribute8;
	   p_rel_tbl(l_ctr).attribute9 := rel.attribute9;
	   p_rel_tbl(l_ctr).attribute10 := rel.attribute10;
	   p_rel_tbl(l_ctr).attribute11 := rel.attribute11;
	   p_rel_tbl(l_ctr).attribute12 := rel.attribute12;
	   p_rel_tbl(l_ctr).attribute13 := rel.attribute13;
	   p_rel_tbl(l_ctr).attribute14 := rel.attribute14;
	   p_rel_tbl(l_ctr).attribute15 := rel.attribute15;
	   p_rel_tbl(l_ctr).object_version_number := rel.object_version_number;
	   --
	   Begin
	      select 'Y'
	      into p_rel_tbl(l_ctr).subject_has_child
	      from CSI_II_RELATIONSHIPS
	      where object_id = rel.subject_id
	      and   relationship_type_code = rel.relationship_type_code
	      and   rownum = 1;
	   Exception
	      when no_data_found then
		 p_rel_tbl(l_ctr).subject_has_child := 'N';
	   End;
        END LOOP;
	RAISE COMP_EXCEP;
     END IF;
     -- If other parameters are used then following cursor will be used.
     FOR rel in OTHER_PARAM_CUR(l_sysdate) LOOP
	l_ctr := l_ctr + 1;
	p_rel_tbl(l_ctr).relationship_id := rel.relationship_id;
	p_rel_tbl(l_ctr).relationship_type_code := rel.relationship_type_code;
	p_rel_tbl(l_ctr).object_id := rel.object_id;
	p_rel_tbl(l_ctr).subject_id := rel.subject_id;
	p_rel_tbl(l_ctr).position_reference := rel.position_reference;
	p_rel_tbl(l_ctr).active_start_date := rel.active_start_date;
	p_rel_tbl(l_ctr).active_end_date := rel.active_end_date;
	p_rel_tbl(l_ctr).display_order := rel.display_order;
	p_rel_tbl(l_ctr).mandatory_flag := rel.mandatory_flag;
	p_rel_tbl(l_ctr).context := rel.context;
	p_rel_tbl(l_ctr).attribute1 := rel.attribute1;
	p_rel_tbl(l_ctr).attribute2 := rel.attribute2;
	p_rel_tbl(l_ctr).attribute3 := rel.attribute3;
	p_rel_tbl(l_ctr).attribute4 := rel.attribute4;
	p_rel_tbl(l_ctr).attribute5 := rel.attribute5;
	p_rel_tbl(l_ctr).attribute6 := rel.attribute6;
	p_rel_tbl(l_ctr).attribute7 := rel.attribute7;
	p_rel_tbl(l_ctr).attribute8 := rel.attribute8;
	p_rel_tbl(l_ctr).attribute9 := rel.attribute9;
	p_rel_tbl(l_ctr).attribute10 := rel.attribute10;
	p_rel_tbl(l_ctr).attribute11 := rel.attribute11;
	p_rel_tbl(l_ctr).attribute12 := rel.attribute12;
	p_rel_tbl(l_ctr).attribute13 := rel.attribute13;
	p_rel_tbl(l_ctr).attribute14 := rel.attribute14;
	p_rel_tbl(l_ctr).attribute15 := rel.attribute15;
	p_rel_tbl(l_ctr).object_version_number := rel.object_version_number;
	--
	Begin
	   select 'Y'
	   into p_rel_tbl(l_ctr).subject_has_child
	   from CSI_II_RELATIONSHIPS
	   where object_id = rel.subject_id
	   and   relationship_type_code = rel.relationship_type_code
	   and   rownum = 1;
	Exception
	   when no_data_found then
	      p_rel_tbl(l_ctr).subject_has_child := 'N';
	End;
     END LOOP;
  EXCEPTION
     WHEN COMP_EXCEP THEN
        NULL;
  END Get_Next_Level;
  --

  PROCEDURE DFS
    (p_relationship_rec    IN  csi_datastructures_pub.ii_relationship_rec,
     p_active_relationship_only  IN  VARCHAR2,
     p_active_instances_only     IN  VARCHAR2,
     p_config_only               IN  VARCHAR2
    ) IS
    l_rel_tbl_temp            csi_datastructures_pub.ii_relationship_tbl;
    l_time_stamp              DATE;
  BEGIN
        p_glbl_ctr := p_glbl_ctr + 1;

        p_rel_glbl_tbl(p_glbl_ctr).relationship_id := p_relationship_rec.relationship_id;
        p_rel_glbl_tbl(p_glbl_ctr).relationship_type_code := p_relationship_rec.relationship_type_code;
        p_rel_glbl_tbl(p_glbl_ctr).object_id := p_relationship_rec.object_id;
        p_rel_glbl_tbl(p_glbl_ctr).subject_id := p_relationship_rec.subject_id;
        p_rel_glbl_tbl(p_glbl_ctr).position_reference := p_relationship_rec.position_reference;
        p_rel_glbl_tbl(p_glbl_ctr).active_start_date := p_relationship_rec.active_start_date;
        p_rel_glbl_tbl(p_glbl_ctr).active_end_date := p_relationship_rec.active_end_date;
        p_rel_glbl_tbl(p_glbl_ctr).display_order := p_relationship_rec.display_order;
        p_rel_glbl_tbl(p_glbl_ctr).mandatory_flag := p_relationship_rec.mandatory_flag;
        p_rel_glbl_tbl(p_glbl_ctr).context := p_relationship_rec.context;
        p_rel_glbl_tbl(p_glbl_ctr).attribute1 := p_relationship_rec.attribute1;
	p_rel_glbl_tbl(p_glbl_ctr).attribute2 := p_relationship_rec.attribute2;
	p_rel_glbl_tbl(p_glbl_ctr).attribute3 := p_relationship_rec.attribute3;
	p_rel_glbl_tbl(p_glbl_ctr).attribute4 := p_relationship_rec.attribute4;
	p_rel_glbl_tbl(p_glbl_ctr).attribute5 := p_relationship_rec.attribute5;
	p_rel_glbl_tbl(p_glbl_ctr).attribute6 := p_relationship_rec.attribute6;
	p_rel_glbl_tbl(p_glbl_ctr).attribute7 := p_relationship_rec.attribute7;
	p_rel_glbl_tbl(p_glbl_ctr).attribute8 := p_relationship_rec.attribute8;
	p_rel_glbl_tbl(p_glbl_ctr).attribute9 := p_relationship_rec.attribute9;
	p_rel_glbl_tbl(p_glbl_ctr).attribute10 := p_relationship_rec.attribute10;
	p_rel_glbl_tbl(p_glbl_ctr).attribute11 := p_relationship_rec.attribute11;
	p_rel_glbl_tbl(p_glbl_ctr).attribute12 := p_relationship_rec.attribute12;
	p_rel_glbl_tbl(p_glbl_ctr).attribute13 := p_relationship_rec.attribute13;
	p_rel_glbl_tbl(p_glbl_ctr).attribute14 := p_relationship_rec.attribute14;
	p_rel_glbl_tbl(p_glbl_ctr).attribute15 := p_relationship_rec.attribute15;
        p_rel_glbl_tbl(p_glbl_ctr).object_version_number := p_relationship_rec.object_version_number;

        Get_Next_Level
		( p_object_id                 => p_relationship_rec.subject_id,
		  p_relationship_id           => null,
		  p_subject_id                => null,
		  p_rel_tbl                   => l_rel_tbl_temp,
		  p_rel_type_code             => p_relationship_rec.relationship_type_code,
		  p_time_stamp                => l_time_stamp,
		  p_active_relationship_only  => p_active_relationship_only,
		  p_active_instances_only     => p_active_instances_only,
                  p_config_only               => p_config_only
		);
        IF l_rel_tbl_temp.count > 0 THEN
		 FOR l_temp_ind IN l_rel_tbl_temp.FIRST .. l_rel_tbl_temp.LAST LOOP
                    DFS(l_rel_tbl_temp(l_temp_ind), p_active_relationship_only, p_active_instances_only, p_config_only);
                 END LOOP;
        END IF;
  EXCEPTION
        WHEN OTHERS THEN
        NULL;
  END DFS;


  PROCEDURE Get_Children
    (p_relationship_query_rec    IN  csi_datastructures_pub.relationship_query_rec,
     p_rel_tbl                   OUT NOCOPY csi_datastructures_pub.ii_relationship_tbl,
     p_depth                     IN  NUMBER,
     p_active_relationship_only  IN  VARCHAR2,
     p_active_instances_only     IN  VARCHAR2,
     p_config_only               IN  VARCHAR2, -- if true will retrieve instances with config keys
     p_time_stamp                IN  DATE,
     p_get_dfs                   IN  VARCHAR2,
     p_ii_relationship_level_tbl OUT NOCOPY csi_ii_relationships_pvt.ii_relationship_level_tbl,
     x_return_status             OUT NOCOPY VARCHAR2,
     x_msg_count                 OUT NOCOPY NUMBER,
     x_msg_data                  OUT NOCOPY VARCHAR2
    ) IS
    --
    l_api_name                CONSTANT VARCHAR2(30)    := 'get_children';
    l_api_version             CONSTANT NUMBER          := 1.0;
    l_rel_tbl                 csi_datastructures_pub.ii_relationship_tbl;
    l_rel_tbl_next_lvl        csi_datastructures_pub.ii_relationship_tbl;
    l_rel_tbl_temp            csi_datastructures_pub.ii_relationship_tbl;
    l_rel_tbl_final           csi_datastructures_pub.ii_relationship_tbl;
    l_next_ind                NUMBER := 0;
    l_final_ind               NUMBER := 0;
    l_ctr                     NUMBER := 0;
    l_temp_id                 NUMBER;
    l_prev_id                 NUMBER;
    l_found                   NUMBER;
    l_rel_found               NUMBER;
    l_depth                   NUMBER := p_depth;
    l_level                   NUMBER := 1;
    l_rel_type_code           VARCHAR2(30);
    l_object_id               NUMBER;
    l_subject_id              NUMBER;
    l_relationship_id         NUMBER;
    l_time_stamp              DATE;
    l_max_count               NUMBER;
  BEGIN
     x_return_status := FND_API.G_RET_STS_SUCCESS;
     --savepoint Get_Children;
     IF l_depth IS NULL OR
        l_depth = FND_API.G_MISS_NUM OR
        l_depth <= 0 THEN
        l_depth := 9999999;
     END IF;
     --
     IF p_relationship_query_rec.object_id IS NULL OR
        p_relationship_query_rec.object_id = FND_API.G_MISS_NUM THEN
        l_object_id := null;
     ELSE
        l_object_id := p_relationship_query_rec.object_id;
     END IF;
     --
     IF p_relationship_query_rec.subject_id IS NULL OR
        p_relationship_query_rec.subject_id = FND_API.G_MISS_NUM THEN
        l_subject_id := null;
     ELSE
        l_subject_id := p_relationship_query_rec.subject_id;
     END IF;
     --
     IF p_relationship_query_rec.relationship_id IS NULL OR
        p_relationship_query_rec.relationship_id = FND_API.G_MISS_NUM THEN
        l_relationship_id := null;
     ELSE
        l_relationship_id := p_relationship_query_rec.relationship_id;
     END IF;
     --
     IF p_relationship_query_rec.relationship_type_code IS NULL OR
        p_relationship_query_rec.relationship_type_code = FND_API.G_MISS_CHAR THEN
        l_rel_type_code := null;
     ELSE
        l_rel_type_code := p_relationship_query_rec.relationship_type_code;
     END IF;
     --
     IF l_object_id IS NULL AND
        l_subject_id IS NULL AND
        l_relationship_id IS NULL AND
        l_rel_type_code IS NULL THEN
        fnd_message.set_name('CSI', 'CSI_INVALID_PARAMETERS');
        fnd_msg_pub.add;
        x_return_status := fnd_api.g_ret_sts_error;
        RAISE fnd_api.g_exc_error;
     END IF;
     --
     IF p_time_stamp IS NULL OR
        p_time_stamp = FND_API.G_MISS_DATE THEN
        l_time_stamp := NULL;
     ELSE
        l_time_stamp := p_time_stamp;
     END IF;
     --
     /* Added IF lakmohan Bug 7503134 ; forward port by Derek Chang*/
     IF p_get_dfs = FND_API.G_FALSE OR
        l_object_id IS NULL AND
        l_subject_id IS NOT NULL AND
        l_relationship_id IS NULL THEN
     Get_Next_Level
       ( p_object_id                 => l_object_id,
         p_relationship_id           => l_relationship_id,
         p_subject_id                => l_subject_id,
         p_rel_tbl                   => l_rel_tbl,
         p_rel_type_code             => l_rel_type_code,
         p_time_stamp                => l_time_stamp,
         p_active_relationship_only  => p_active_relationship_only,
         p_active_instances_only     => p_active_instances_only,
         p_config_only               => p_config_only
       );

     <<Next_Level>>

     l_rel_tbl_next_lvl.delete;
     l_next_ind := 0;
     --
     IF l_rel_tbl.count > 0 THEN
	FOR l_ind IN l_rel_tbl.FIRST .. l_rel_tbl.LAST LOOP
	   l_final_ind := l_final_ind + 1;
	   l_rel_tbl_final(l_final_ind) := l_rel_tbl(l_ind);
           p_ii_relationship_level_tbl(l_final_ind).relationship_id := l_rel_tbl(l_ind).relationship_id;
           p_ii_relationship_level_tbl(l_final_ind).current_level := l_level;
	   /* get the next level using this line ID as the parent */
           IF l_object_id IS NOT NULL AND -- Need to Explode if Object ID alone is passed
              l_subject_id IS NULL AND
              l_relationship_id IS NULL THEN
	      Get_Next_Level
		( p_object_id                 => l_rel_tbl(l_ind).subject_id,
		  p_relationship_id           => null,
		  p_subject_id                => null,
		  p_rel_tbl                   => l_rel_tbl_temp,
		  p_rel_type_code             => l_rel_type_code,
		  p_time_stamp                => l_time_stamp,
		  p_active_relationship_only  => p_active_relationship_only,
		  p_active_instances_only     => p_active_instances_only,
          p_config_only               => p_config_only
		);
	      --
	      IF l_rel_tbl_temp.count > 0 THEN
		 FOR l_temp_ind IN l_rel_tbl_temp.FIRST .. l_rel_tbl_temp.LAST LOOP
		    IF l_rel_tbl_final.count > 0 THEN
		       l_found := 0;
		       FOR i IN l_rel_tbl_final.FIRST .. l_rel_tbl_final.LAST LOOP
			  IF l_rel_tbl_final(i).object_id = l_rel_tbl_temp(l_temp_ind).object_id THEN
			     l_found := 1;
			     exit;
			  END IF;
		       END LOOP;
		    END IF;
		    IF l_found = 0 THEN
		       l_next_ind := l_next_ind + 1;
		       l_rel_tbl_next_lvl(l_next_ind) := l_rel_tbl_temp(l_temp_ind);
		    END IF;
		 END LOOP;
	      END IF;
           END IF; -- Object_id check
	END LOOP;
	--
	IF l_rel_tbl_next_lvl.count > 0 THEN
	   l_rel_tbl.DELETE;
	   l_rel_tbl := l_rel_tbl_next_lvl;
	   --
           l_level := l_level + 1;
           IF l_level <= l_depth THEN
	      goto Next_Level;
           END IF;
	END IF;
     END IF;
     --
     p_rel_tbl := l_rel_tbl_final;
     --

	-- The output of l_rel_tbl_final will be Breadth first search Order.
	-- This needs to be converted to depth-first-search order.
	-- The following LOOP does this.
	ELSIF nvl(p_get_dfs,FND_API.G_TRUE) = FND_API.G_TRUE AND  -- Need to Sort if Object_id alone is passed
        l_object_id IS NOT NULL AND
        l_subject_id IS NULL AND
        l_relationship_id IS NULL THEN
	p_rel_tbl.DELETE;
	l_ctr := 0;
	--
	-- The output of l_rel_tbl_final will be Breadth first search Order.
	-- This needs to be converted to depth-first-search order.
	-- The following LOOP does this.
	--

        Get_Next_Level
       ( p_object_id                 => l_object_id,
         p_relationship_id           => l_relationship_id,
         p_subject_id                => l_subject_id,
         p_rel_tbl                   => l_rel_tbl,
         p_rel_type_code             => l_rel_type_code,
         p_time_stamp                => l_time_stamp,
         p_active_relationship_only  => p_active_relationship_only,
         p_active_instances_only     => p_active_instances_only,
         p_config_only               => p_config_only
       );
       IF l_rel_tbl.COUNT > 0 THEN
           FOR l_ind IN l_rel_tbl.FIRST .. l_rel_tbl.LAST LOOP
               DFS (p_relationship_rec => l_rel_tbl(l_ind),
                    p_active_relationship_only  => p_active_relationship_only,
                    p_active_instances_only     => p_active_instances_only,
                    p_config_only => p_config_only);
           END LOOP;
       END IF;

/*	IF l_rel_tbl_final.count > 0 THEN
           l_max_count := l_rel_tbl_final.count;
	   l_ctr := l_ctr + 1;
	   p_rel_tbl(l_ctr) := l_rel_tbl_final(1);
	   l_temp_id := l_rel_tbl_final(1).subject_id;
           l_rel_tbl_final.DELETE(1);
	   LOOP
	      IF p_rel_tbl.count = l_max_count OR
                 l_rel_tbl_final.count = 0 THEN
		 exit;
	      END IF;
	      FOR rel IN l_rel_tbl_final.FIRST .. l_rel_tbl_final.LAST LOOP
		 l_found := 0;
                 IF l_rel_tbl_final.EXISTS(rel) THEN
		    IF l_rel_tbl_final(rel).object_id = l_temp_id THEN
		       l_found := 1;
		       l_ctr := l_ctr + 1;
		       p_rel_tbl(l_ctr) := l_rel_tbl_final(rel);
		       l_temp_id := l_rel_tbl_final(rel).subject_id;
                       l_rel_tbl_final.DELETE(rel);
		       exit;
		    END IF;
                 END IF;
	      END LOOP;
	      IF l_found = 0 THEN -- If No more component then go back
		 -- To get the parent, do not pass l_rel_tbl_final. This may go in an infinite loop.
		 -- Always better to pass the p_rel_tbl which is for sure has the relationship created.
		 -- This is because, same subject can exist under two parents with different relationship_type.
		 l_prev_id := l_temp_id;
		 l_temp_id := Parent_of(p_subject_id    => l_temp_id,
					p_rel_tbl       => p_rel_tbl);
	      END IF;
	   END LOOP;
	END IF; */

        p_rel_tbl := p_rel_glbl_tbl;
		p_rel_glbl_tbl.delete;
     END IF; -- p_get_dfs check
  EXCEPTION
     WHEN fnd_api.g_exc_error THEN
	 --  ROLLBACK TO Get_Children;
	   x_return_status := fnd_api.g_ret_sts_error ;
	   fnd_msg_pub.count_AND_get
		    (p_count => x_msg_count ,
		     p_data => x_msg_data
		    );

      WHEN fnd_api.g_exc_unexpected_error THEN
	  --  ROLLBACK TO Get_Children;
	    x_return_status := fnd_api.g_ret_sts_unexp_error ;
	    fnd_msg_pub.count_AND_get
		     (p_count => x_msg_count ,
		      p_data => x_msg_data
		     );

      WHEN OTHERS THEN
	  --  ROLLBACK TO Get_Children;
	    x_return_status := fnd_api.g_ret_sts_unexp_error ;
	      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
		     fnd_msg_pub.add_exc_msg('csi_relationships_pvt' ,l_api_name);
	      END IF;
	    fnd_msg_pub.count_AND_get
		     (p_count => x_msg_count ,
		      p_data => x_msg_data
		     );
  END Get_Children;
  --
  PROCEDURE Get_Top_Most_Parent
     ( p_subject_id      IN  NUMBER,
       p_rel_type_code   IN  VARCHAR2,
       p_object_id       OUT NOCOPY NUMBER
     ) IS
     l_object_id       NUMBER;
  BEGIN
     IF p_rel_type_code IS NULL OR
	p_subject_id IS NULL THEN
        l_object_id := -9999;
        p_object_id := l_object_id;
	RETURN;
     END IF;
     l_object_id := p_subject_id;
     Begin
        select object_id
        into l_object_id
        from CSI_II_RELATIONSHIPS
        where subject_id = p_subject_id
        and   relationship_type_code = p_rel_type_code
        and   ((active_end_date is null) or (active_end_date > sysdate));
     Exception
        when no_data_found then
           p_object_id := p_subject_id;
           RETURN;
     End;
     -- Call Recursively for prior parent
     Get_Top_Most_Parent
          (p_subject_id      => l_object_id,
           p_rel_type_code   => p_rel_type_code,
           p_object_id       => p_object_id
          );
  END Get_Top_Most_Parent;

  PROCEDURE Get_Immediate_Parents
    ( p_subject_id       IN NUMBER,
      p_rel_type_code    IN VARCHAR2,
      p_rel_tbl          OUT NOCOPY csi_datastructures_pub.ii_relationship_tbl
    ) IS
     l_ctr         NUMBER := 0;
     l_object_id   NUMBER;
     l_subject_id  NUMBER;
     l_exists      VARCHAR2(1);
  BEGIN
     IF p_subject_id IS NULL OR
        p_subject_id = FND_API.G_MISS_NUM THEN
        Return;
     END IF;
     --
     l_subject_id := p_subject_id;
     --
     LOOP
        Begin
           select object_id
           into l_object_id
           from CSI_II_RELATIONSHIPS
           where subject_id = l_subject_id
           and   relationship_type_code = p_rel_type_code
           and   ((active_end_date is null) or (active_end_date > sysdate));
           --
           l_ctr := l_ctr + 1;
           p_rel_tbl(l_ctr).subject_id := l_subject_id;
           p_rel_tbl(l_ctr).object_id := l_object_id;
           p_rel_tbl(l_ctr).relationship_type_code := p_rel_type_code;
           --
           l_exists := 'N';
           IF p_rel_tbl.count > 0 THEN
              FOR j in p_rel_tbl.FIRST .. p_rel_tbl.LAST Loop
                 IF l_object_id = p_rel_tbl(j).subject_id THEN
                    l_exists := 'Y';
                    exit;
                 END IF;
              End Loop;
           END IF;
           --
           IF l_exists = 'Y' THEN
              exit;
           END IF;
           --
           l_subject_id := l_object_id;
        Exception
           when no_data_found then
              exit;
        End;
     END LOOP;
  END Get_Immediate_Parents;
  --


PROCEDURE get_relationships
 (
     p_api_version               IN  NUMBER,
     p_commit                    IN  VARCHAR2,
     p_init_msg_list             IN  VARCHAR2,
     p_validation_level          IN  NUMBER,
     p_relationship_query_rec    IN  csi_datastructures_pub.relationship_query_rec,
     p_depth                     IN  NUMBER,
     p_time_stamp                IN  DATE,
     p_active_relationship_only  IN  VARCHAR2,
     p_recursive_flag            IN  VARCHAR2,
     x_relationship_tbl          OUT NOCOPY csi_datastructures_pub.ii_relationship_tbl,
     x_return_status             OUT NOCOPY VARCHAR2,
     x_msg_count                 OUT NOCOPY NUMBER,
     x_msg_data                  OUT NOCOPY VARCHAR2
 )
 IS
 CURSOR config_csr (instance_id NUMBER) IS
        SELECT * FROM csi_ii_relationships
        WHERE object_id=instance_id;

l_api_name                 CONSTANT VARCHAR2(30)    := 'get_relationships';
l_api_version              CONSTANT NUMBER          := 1.0;
l_return_status_full                VARCHAR2(1);
l_access_flag                       VARCHAR2(1);
i                                   NUMBER          := 1;
l_instance_id                       NUMBER;
l_returned_rec_count                NUMBER          := 0;
l_rel_rec                           csi_datastructures_pub.ii_relationship_rec;
l_debug_level                       NUMBER;
l_new_rec                           csi_datastructures_pub.ii_relationship_rec;
l_flag                              VARCHAR2(4);
l_active_relationship_only          VARCHAR2(1)     := p_active_relationship_only;
l_depth                             NUMBER;
l_found                             VARCHAR2(1);  -- Added by sguthiva for bug 2373109
xc_relationship_tbl                 csi_datastructures_pub.ii_relationship_tbl ;
l_relationship_tbl                  csi_datastructures_pub.ii_relationship_tbl ;
l_ins_child_tbl                     csi_datastructures_pub.ii_relationship_tbl ;
l_rel_count                         NUMBER := 0;
l_temp_relationship_tbl             csi_datastructures_pub.ii_relationship_tbl;
l_rel_tbl                           csi_datastructures_pub.ii_relationship_tbl;
l_ctr                               NUMBER;
l_exists                            VARCHAR2(1);
l_exists_flag                       VARCHAR2(1);
l_msg_index                         NUMBER;
l_msg_count                         NUMBER;
l_last_purge_date                   DATE;
TYPE NUMLIST IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
l_exp_inst_tbl                      NUMLIST;
--
l_instance_rec       CSI_DATASTRUCTURES_PUB.INSTANCE_HEADER_REC;
l_party_header_tbl   CSI_DATASTRUCTURES_PUB.PARTY_HEADER_TBL;
l_account_header_tbl CSI_DATASTRUCTURES_PUB.PARTY_ACCOUNT_HEADER_TBL;
l_org_header_tbl     CSI_DATASTRUCTURES_PUB.ORG_UNITS_HEADER_TBL;
l_pricing_attrib_tbl CSI_DATASTRUCTURES_PUB.PRICING_ATTRIBS_TBL;
l_ext_attrib_tbl     CSI_DATASTRUCTURES_PUB.EXTEND_ATTRIB_VALUES_TBL;
l_ext_attrib_def_tbl CSI_DATASTRUCTURES_PUB.EXTEND_ATTRIB_TBL;
l_asset_header_tbl   CSI_DATASTRUCTURES_PUB.INSTANCE_ASSET_HEADER_TBL;
--
/*
CURSOR CHILD_CUR(p_instance_id IN NUMBER) IS
SELECT subject_id
from csi_ii_relationships
connect by prior subject_id = object_id
start with subject_id = p_instance_id;
*/
-- Added for bug 2999353
/*
CURSOR expired_cur (p_object_id IN number) IS
SELECT relationship_id
      ,active_end_date
FROM  csi_ii_relationships
WHERE relationship_type_code='COMPONENT-OF'
START WITH object_id = p_object_id
CONNECT BY object_id = PRIOR subject_id;
*/
l_fin_count   NUMBER;
l_fin_count1  NUMBER;
l_exp_tbl     csi_datastructures_pub.ii_relationship_tbl;
l_temp_tbl    csi_datastructures_pub.ii_relationship_tbl;
l_exp_act_tbl csi_datastructures_pub.ii_relationship_tbl;
l_found1      BOOLEAN;
l_found2      BOOLEAN;
l_expire      BOOLEAN;
l_exp_count   NUMBER:=0;
l_relationship_query_rec   csi_datastructures_pub.relationship_query_rec;
l_ii_relationship_level_tbl csi_ii_relationships_pvt.ii_relationship_level_tbl;

 BEGIN
      -- standard start of api savepoint
    --  SAVEPOINT get_relationships_pvt;

      -- standard call to check for call compatibility.
      IF NOT fnd_api.compatible_api_call ( l_api_version,
                                           p_api_version,
                                           l_api_name,
                                           g_pkg_name)
      THEN
          RAISE fnd_api.g_exc_unexpected_error;
      END IF;


      -- initialize message list if p_init_msg_list is set to true.
      IF fnd_api.to_boolean( p_init_msg_list )
      THEN
          fnd_msg_pub.initialize;
      END IF;




      -- initialize api return status to success
      x_return_status := fnd_api.g_ret_sts_success;


      l_debug_level:=fnd_profile.value('CSI_DEBUG_LEVEL');
    IF (l_debug_level > 0) THEN
          CSI_gen_utility_pvt.put_line( 'get_relationships');
    END IF;

    IF (l_debug_level > 1) THEN
             CSI_gen_utility_pvt.put_line(
                            p_api_version             ||'-'||
                            p_commit                  ||'-'||
                            p_init_msg_list           ||'-'||
                            p_validation_level        ||'-'||
                            p_depth                   ||'_'||
                            p_time_stamp              );

         csi_gen_utility_pvt.dump_rel_query_rec(p_relationship_query_rec);
    END IF;


      --
      -- API BODY
      --
      -- ******************************************************************
      -- validate environment
      -- ******************************************************************

      IF
      ( ((p_relationship_query_rec.relationship_id IS NULL)         OR (p_relationship_query_rec.relationship_id = fnd_api.g_miss_num))
    AND ((p_relationship_query_rec.relationship_type_code IS NULL)  OR (p_relationship_query_rec.relationship_type_code = fnd_api.g_miss_char))
    AND ((p_relationship_query_rec.object_id IS NULL)               OR (p_relationship_query_rec.object_id  = fnd_api.g_miss_num))
    AND ((p_relationship_query_rec.subject_id IS NULL)              OR (p_relationship_query_rec.subject_id  = fnd_api.g_miss_num))
      )
      THEN
       fnd_message.set_name('CSI', 'CSI_INVALID_PARAMETERS');
       fnd_msg_pub.add;
       x_return_status := fnd_api.g_ret_sts_error;
       RAISE fnd_api.g_exc_error;
      END IF;

      /* Cyclic Relationships */
  IF   (p_relationship_query_rec.relationship_type_code = 'CONNECTED-TO')
  THEN
         IF ((p_relationship_query_rec.subject_id IS NULL
               AND p_relationship_query_rec.object_id IS NULL)
            OR ((p_relationship_query_rec.subject_id IS NOT NULL
               AND p_relationship_query_rec.subject_id <> fnd_api.g_miss_num)
            AND (p_relationship_query_rec.object_id IS NOT NULL
               AND p_relationship_query_rec.object_id <> fnd_api.g_miss_num)))
         THEN
            fnd_message.set_name('CSI', 'CSI_INVALID_PARAMETERS');
            fnd_msg_pub.add;
            x_return_status := fnd_api.g_ret_sts_error;
            RAISE fnd_api.g_exc_error;
         ELSIF ((p_relationship_query_rec.subject_id IS NOT NULL
                  AND p_relationship_query_rec.subject_id <> fnd_api.g_miss_num))
                OR (p_relationship_query_rec.object_id IS NOT NULL
                  AND p_relationship_query_rec.object_id <> fnd_api.g_miss_num)
         THEN
            IF p_relationship_query_rec.subject_id IS NOT NULL
               AND p_relationship_query_rec.subject_id <> fnd_api.g_miss_num
            THEN
               l_instance_id :=  p_relationship_query_rec.subject_id;
            ELSIF p_relationship_query_rec.object_id IS NOT NULL
               AND p_relationship_query_rec.object_id <> fnd_api.g_miss_num
            THEN
               l_instance_id := p_relationship_query_rec.object_id;
            END IF;
         END IF;

         csi_ii_relationships_pvt.get_cyclic_relationships(
            p_api_version                => p_api_version,
            p_commit                     => fnd_api.g_false,
            p_init_msg_list              => p_init_msg_list,
            p_validation_level           => p_validation_level,
            p_instance_id                => l_instance_id,
            p_depth                      => p_depth ,
            p_time_stamp                 => p_time_stamp,
            p_active_relationship_only   => p_active_relationship_only,
            x_relationship_tbl           => xc_relationship_tbl,
            x_return_status              => x_return_status,
            x_msg_count                  => x_msg_count,
            x_msg_data                   => x_msg_data
            );

       -- x_relationship_tbl.DELETE ;
       --
       -- Get the last purge date from csi_item_instances table
       --
       BEGIN
         SELECT last_purge_date
         INTO   l_last_purge_date
         FROM   CSI_ITEM_INSTANCES
         WHERE  rownum < 2;
       EXCEPTION
         WHEN no_data_found THEN
           NULL;
         WHEN others THEN
           NULL;
       END;
       --
       IF xc_relationship_tbl.COUNT > 0 THEN
          FOR  i IN xc_relationship_tbl.FIRST..xc_relationship_tbl.LAST
          LOOP
             l_rel_rec := null ;
             l_rel_rec :=  xc_relationship_tbl(i);

             IF ((p_time_stamp IS NOT NULL) AND (p_time_stamp <> FND_API.G_MISS_DATE))
             THEN
                  IF ((l_last_purge_date IS NOT NULL) AND (p_time_stamp <= l_last_purge_date))
                  THEN
                       csi_gen_utility_pvt.put_line('Warning! History for this entity has already been purged for the datetime stamp passed. ' ||
                       'Please provide a valid datetime stamp.');
                       FND_MESSAGE.Set_Name('CSI', 'CSI_API_HIST_AFTER_PURGE_REQ');
                       FND_MSG_PUB.ADD;
                  ELSE
                       get_history( p_rel_rec         => l_rel_rec
                                   ,p_new_rec         => l_new_rec
                                   ,p_flag            => l_flag
                                   ,p_time_stamp      => p_time_stamp);

                              IF l_flag='ADD'
                              THEN
                                 l_relationship_tbl(i) := l_new_rec;
                              END IF;
                  END IF;
             ELSE
                l_relationship_tbl(i) := l_rel_rec;
             END IF;
	     --
         IF ( (p_time_stamp IS NOT NULL) AND (p_time_stamp <> fnd_api.g_miss_date) )THEN
          IF l_relationship_tbl.count > 0
          THEN
            BEGIN
		      SELECT 'Y'
		      INTO l_relationship_tbl(i).subject_has_child
		      FROM CSI_II_RELATIONSHIPS
		      WHERE OBJECT_ID = l_relationship_tbl(i).subject_id
		      AND   CREATION_DATE <= p_time_stamp
		      AND   (ACTIVE_END_DATE IS NULL OR ACTIVE_END_DATE >= p_time_stamp)
		      AND   ROWNUM < 2;
		    EXCEPTION
		      WHEN OTHERS THEN
		        --l_relationship_tbl(i).subject_has_child := 'N';
               IF   (l_relationship_tbl(i).relationship_id IS NOT NULL --Added for bug 2999353
                 AND l_relationship_tbl(i).relationship_id <> fnd_api.g_miss_num) --Added for bug 2999353
               THEN
                    l_relationship_tbl(i).subject_has_child := 'N';
               END IF;
		    END;
           END IF; -- l_relationship_tbl.count > 0
          END IF;
         END LOOP;
       END IF;
        --
        l_exp_inst_tbl.DELETE;
        IF l_relationship_tbl.count > 0 THEN
           FOR rel_row in l_relationship_tbl.FIRST .. l_relationship_tbl.LAST LOOP
              IF l_relationship_tbl.EXISTS(rel_row) THEN
		 l_exists_flag := 'N';
		 IF l_exp_inst_tbl.count > 0 THEN
		    FOR exp_rec in l_exp_inst_tbl.FIRST .. l_exp_inst_tbl.LAST LOOP
		       IF l_exp_inst_tbl(exp_rec) = l_relationship_tbl(rel_row).subject_id OR
                          l_exp_inst_tbl(exp_rec) = l_relationship_tbl(rel_row).object_id THEN
			  l_exists_flag := 'Y';
			  exit;
		       END IF;
		    END LOOP;
		 END IF;
                 --
		 IF l_exists_flag <> 'Y' THEN
		    IF ( (p_time_stamp IS NOT NULL) AND (p_time_stamp <> fnd_api.g_miss_date)
             AND (l_relationship_tbl(rel_row).relationship_id IS NOT NULL   --Added for bug 2999353
             AND  l_relationship_tbl(rel_row).relationship_id <> fnd_api.g_miss_num))--Added for bug 2999353
            THEN
		       l_instance_rec.instance_id := l_relationship_tbl(rel_row).subject_id;
		       CSI_ITEM_INSTANCE_PUB.Get_item_instance_details(
			     1.0,
			    'F',
			    'T',
			    1,
			    l_instance_rec,
			    'F',
			    l_party_header_tbl,
			    'F',
			    l_account_header_tbl,
			    'F',
			    l_org_header_tbl,
			    'F',
			    l_pricing_attrib_tbl,
			    'F',
			    l_ext_attrib_tbl,
			    l_ext_attrib_def_tbl,
			    'F',
			    l_asset_header_tbl,
			    'F',
			    p_time_stamp,
			    x_return_status,
			    x_msg_count,
			    x_msg_data
			);
		       --
		       IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
			  l_msg_index := 1;
			  l_msg_count := x_msg_count;
			  WHILE l_msg_count > 0 LOOP
			     x_msg_data := FND_MSG_PUB.GET
					      (  l_msg_index,
						 FND_API.G_FALSE );
			     csi_gen_utility_pvt.put_line( ' Error from Get_Item_Instance_Details.. ');
			     csi_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
			     l_msg_index := l_msg_index + 1;
			     l_msg_count := l_msg_count - 1;
			  END LOOP;
			  RAISE FND_API.G_EXC_ERROR;
		       END IF;
		       IF nvl(l_instance_rec.active_end_date,(sysdate+1)) < sysdate THEN
			  l_ctr := l_exp_inst_tbl.count;
			  l_ctr := l_ctr + 1;
			  l_exp_inst_tbl(l_ctr) := l_relationship_tbl(rel_row).subject_id;
		       ELSE
			  l_rel_count := l_rel_count + 1;
			  l_temp_relationship_tbl(l_rel_count) := l_relationship_tbl(rel_row);
		       END IF;
		    ELSE -- p_time_stamp is not passed
		       Begin
			  Select 'x'
			  into l_exists
			  from CSI_ITEM_INSTANCES
			  where instance_id = l_relationship_tbl(rel_row).subject_id
			  and   nvl(active_end_date,(sysdate+1)) < sysdate;
			  l_ctr := l_exp_inst_tbl.count;
			  l_ctr := l_ctr + 1;
			  l_exp_inst_tbl(l_ctr) := l_relationship_tbl(rel_row).subject_id;
		       Exception
			  when no_data_found then -- Active Instance
			     l_rel_count := l_rel_count + 1;
			     l_temp_relationship_tbl(l_rel_count) := l_relationship_tbl(rel_row);
		       End;
		    END IF;
		 END IF;
              END IF;
           END LOOP;
        END IF;
    -- Added by sguthiva for 2562028 fix
      l_rel_count := 0;
      IF p_active_relationship_only = 'T' THEN
         IF l_temp_relationship_tbl.count > 0 THEN
            FOR rel_row in l_temp_relationship_tbl.FIRST .. l_temp_relationship_tbl.LAST
            LOOP
               IF l_temp_relationship_tbl.EXISTS(rel_row) THEN
                  IF l_temp_relationship_tbl(rel_row).active_end_date IS NULL OR
                     l_temp_relationship_tbl(rel_row).active_end_date > SYSDATE THEN
                     l_rel_count := l_rel_count + 1;
                     x_relationship_tbl(l_rel_count) := l_temp_relationship_tbl(rel_row);
                  END IF;
               END IF;
            END LOOP;
         END IF;
      ELSE
         x_relationship_tbl := l_temp_relationship_tbl;
      END IF;

    -- End addition by sguthiva
  ELSE  ---if not CONNECTED-TO
      --gen_select(l_crit_relations_rec,l_select_cl);
      IF ( ((p_relationship_query_rec.relationship_id IS NULL) OR (p_relationship_query_rec.relationship_id = fnd_api.g_miss_num))
      AND  ((p_relationship_query_rec.subject_id IS NULL) OR (p_relationship_query_rec.subject_id = fnd_api.g_miss_num))
      AND  ((p_relationship_query_rec.relationship_type_code IS NULL) OR (p_relationship_query_rec.relationship_type_code = fnd_api.g_miss_char)) )
      THEN
         IF( (p_relationship_query_rec.object_id IS NOT NULL) AND (p_relationship_query_rec.object_id <> fnd_api.g_miss_num) )
         THEN
           IF( (p_relationship_query_rec.relationship_type_code IS NULL) OR (p_relationship_query_rec.relationship_type_code = fnd_api.g_miss_char) )
           THEN
                   fnd_message.set_name('CSI','CSI_NO_RELCODE_PASSED');
                   fnd_msg_pub.add;
                   RAISE fnd_api.g_exc_error;
           END IF;
         END IF;
       END IF;
/*
      gen_relations_where(l_crit_relations_rec,l_active_relationship_only,l_depth,l_relations_where);
          IF dbms_sql.is_open(l_cur_get_relations) THEN
          dbms_sql.close_CURSOR(l_cur_get_relations);
          END IF;

       l_cur_get_relations := dbms_sql.open_CURSOR;

       dbms_sql.parse(l_cur_get_relations, l_select_cl||l_relations_where , dbms_sql.native);

       bind(l_crit_relations_rec, l_cur_get_relations);

       define_columns(l_def_relations_rec, l_cur_get_relations);

       l_ignore := dbms_sql.execute(l_cur_get_relations);
*/
        -- Bug 8904684 Modified p_get_dfs to take
        -- fnd_api.g_false
        Get_Children
           (p_relationship_query_rec    => p_relationship_query_rec,
            p_rel_tbl                   => l_rel_tbl,
            p_depth                     => p_depth,
            p_active_relationship_only  => p_active_relationship_only,
            p_time_stamp                => p_time_stamp,
            p_get_dfs                   => fnd_api.g_false,
            p_ii_relationship_level_tbl => l_ii_relationship_level_tbl,
            x_return_status             => x_return_status,
            x_msg_count                 => x_msg_count,
            x_msg_data                  => x_msg_data
           );
         IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS)
         THEN
            l_msg_index := 1;
            l_msg_count := x_msg_count;
           WHILE l_msg_count > 0
           LOOP
               x_msg_data := FND_MSG_PUB.GET
                          (  l_msg_index,
                             FND_API.G_FALSE );
                csi_gen_utility_pvt.put_line( ' Error from Get_Chidren.. ');
                csi_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
                l_msg_index := l_msg_index + 1;
                l_msg_count := l_msg_count - 1;
           END LOOP;
              RAISE FND_API.G_EXC_ERROR;
         END IF;

     --
     -- Get the last purge date from csi_item_instances table
     --
     BEGIN
       SELECT last_purge_date
       INTO   l_last_purge_date
       FROM   CSI_ITEM_INSTANCES
       WHERE  rownum < 2;
     EXCEPTION
       WHEN no_data_found THEN
         NULL;
       WHEN others THEN
         NULL;
     END;
     --
   IF p_time_stamp IS NULL OR p_time_stamp = fnd_api.g_miss_date
   THEN
        x_relationship_tbl:=l_rel_tbl;
   ELSIF l_rel_tbl.COUNT >0
   THEN
     FOR p_time_csr IN l_rel_tbl.FIRST .. l_rel_tbl.LAST
     LOOP
         IF l_rel_tbl.EXISTS(p_time_csr)
         THEN
                      l_new_rec:=NULL;
                      l_returned_rec_count:=l_returned_rec_count+1;

                       IF ((l_last_purge_date IS NOT NULL) AND (p_time_stamp <= l_last_purge_date))
                       THEN
                           csi_gen_utility_pvt.put_line('Warning! History for this entity has already been purged for the datetime stamp passed. ' ||
                           'Please provide a valid datetime stamp.');
                           FND_MESSAGE.Set_Name('CSI', 'CSI_API_HIST_AFTER_PURGE_REQ');
                           FND_MSG_PUB.ADD;
                       ELSE
                             get_history( p_rel_rec         => l_rel_tbl(p_time_csr)
                                         ,p_new_rec         => l_new_rec
                                         ,p_flag            => l_flag
                                         ,p_time_stamp      => p_time_stamp);
                       END IF;
                       -- Added by sguthiva for bug 2373109
                          IF l_new_rec.relationship_id IS NOT NULL AND
                             l_new_rec.relationship_id <> fnd_api.g_miss_num
                          THEN
                            IF l_flag='ADD' THEN
                               l_relationship_tbl(l_returned_rec_count) :=l_new_rec;
                       -- Added for bug 2999353
                              IF  l_relationship_tbl(l_returned_rec_count).subject_id <>l_rel_tbl(p_time_csr).subject_id
                              THEN
                               l_relationship_query_rec:=p_relationship_query_rec;
                               --
                                  l_depth:=0;
                                  IF l_ii_relationship_level_tbl.COUNT > 0 AND
                                     p_depth IS NOT NULL AND
                                     p_depth <> fnd_api.g_miss_num AND
                                     p_depth >0
                                  THEN
                                    FOR l_lvl_csr IN l_ii_relationship_level_tbl.FIRST .. l_ii_relationship_level_tbl.LAST
                                    LOOP
                                      IF l_ii_relationship_level_tbl.EXISTS(l_lvl_csr)
                                      THEN
                                        IF l_ii_relationship_level_tbl(l_lvl_csr).relationship_id  IS NOT NULL AND
                                           l_ii_relationship_level_tbl(l_lvl_csr).relationship_id <> fnd_api.g_miss_num AND
                                           l_ii_relationship_level_tbl(l_lvl_csr).relationship_id =l_relationship_tbl(l_returned_rec_count).relationship_id
                                        THEN
                                           l_depth:=p_depth-l_ii_relationship_level_tbl(l_lvl_csr).current_level;
                                           EXIT;
                                        END IF;
                                      END IF;
                                    END LOOP;
                                  END IF;
                               IF l_depth>0 OR
                                  p_depth IS NULL
                               THEN
                                     l_relationship_query_rec.object_id:=l_relationship_tbl(l_returned_rec_count).subject_id;
                                     l_relationship_query_rec.subject_id:=fnd_api.g_miss_num;
                                     csi_gen_utility_pvt.put_line('Into recurrsive call for get_relationships. ');
                                     csi_ii_relationships_pvt.get_relationships
                                     (  p_api_version               => p_api_version
                                       ,p_commit                    => p_commit
                                       ,p_init_msg_list             => p_init_msg_list
                                       ,p_validation_level          => p_validation_level
                                       ,p_relationship_query_rec    => l_relationship_query_rec
                                       ,p_depth                     => l_depth
                                       ,p_time_stamp                => p_time_stamp
                                       ,p_active_relationship_only  => p_active_relationship_only
                                       ,p_recursive_flag            => fnd_api.g_true
                                       ,x_relationship_tbl          => x_relationship_tbl
                                       ,x_return_status             => x_return_status
                                       ,x_msg_count                 => x_msg_count
                                       ,x_msg_data                  => x_msg_data
                                     );

                                  IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS)
                                  THEN
                                       l_msg_index := 1;
                                       l_msg_count := x_msg_count;
                                     WHILE l_msg_count > 0
                                     LOOP
                                         x_msg_data := FND_MSG_PUB.GET
                                                      (  l_msg_index,
                                                         FND_API.G_FALSE );
                                         csi_gen_utility_pvt.put_line( ' Error from recursive Get_relationships.. ');
                                         csi_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
                                         l_msg_index := l_msg_index + 1;
                                         l_msg_count := l_msg_count - 1;
                                     END LOOP;
                                       RAISE FND_API.G_EXC_ERROR;
                                  END IF;

                                    IF x_relationship_tbl.count > 0
                                    THEN
                                      FOR i IN x_relationship_tbl.FIRST .. x_relationship_tbl.LAST
                                      LOOP
                                        IF x_relationship_tbl.EXISTS(i)
                                        THEN
                                          IF x_relationship_tbl(i).relationship_id  IS NOT NULL AND
                                             x_relationship_tbl(i).relationship_id <> fnd_api.g_miss_num
                                          THEN
                                             l_returned_rec_count := l_returned_rec_count + 1;
                                             l_relationship_tbl(l_returned_rec_count):=x_relationship_tbl(i);
                                          END IF;
                                        END IF;
                                      END LOOP;
                                    END IF;
                               END IF;
                              END IF;
                       -- End May29 Addition
                            END IF;
                          ELSE
                            -- Do not add the current record by default
                            BEGIN
                              SELECT 'x'
                              INTO   l_found
                              FROM   csi_ii_relationships_h
                              WHERE  relationship_id=l_rel_tbl(p_time_csr).relationship_id;
                            EXCEPTION
                             WHEN NO_DATA_FOUND THEN
                              l_relationship_tbl(l_returned_rec_count) :=l_rel_tbl(p_time_csr);
                             WHEN OTHERS THEN
                              NULL;
                            END;
                          END IF;
                       -- End addition by sguthiva for bug 2373109

                    --
                    IF ( (p_time_stamp IS NOT NULL) AND (p_time_stamp <> fnd_api.g_miss_date) )THEN
                     IF l_relationship_tbl.count > 0
                     THEN
                       BEGIN
                          SELECT 'Y'
                          INTO l_relationship_tbl(l_returned_rec_count).subject_has_child
                          FROM CSI_II_RELATIONSHIPS
                          WHERE OBJECT_ID = l_relationship_tbl(l_returned_rec_count).subject_id
                          AND   CREATION_DATE <= p_time_stamp
                          AND   (ACTIVE_END_DATE IS NULL OR ACTIVE_END_DATE >= p_time_stamp)
                          AND   ROWNUM < 2;
                       EXCEPTION
                          WHEN OTHERS THEN
                             --l_relationship_tbl(l_returned_rec_count).subject_has_child := 'N';
                             IF (l_relationship_tbl(l_returned_rec_count).relationship_id IS NOT NULL --Added for bug 2999353
                             AND l_relationship_tbl(l_returned_rec_count).relationship_id <> fnd_api.g_miss_num) --Added for bug 2999353
                             THEN
                                 l_relationship_tbl(l_returned_rec_count).subject_has_child := 'N';
                             END IF;
                       END;
                     END IF; -- l_relationship_tbl.count > 0
                    END IF;
              --END IF;
         ELSE
            EXIT;
         END IF;
      END LOOP;
      --
      l_exp_inst_tbl.DELETE;
      IF l_relationship_tbl.count > 0 THEN
         FOR rel_row in l_relationship_tbl.FIRST .. l_relationship_tbl.LAST
         LOOP
            IF l_relationship_tbl.EXISTS(rel_row) THEN
               l_exists_flag := 'N';
               IF l_exp_inst_tbl.count > 0 THEN
                  FOR exp_rec in l_exp_inst_tbl.FIRST .. l_exp_inst_tbl.LAST LOOP
                     IF l_exp_inst_tbl(exp_rec) = l_relationship_tbl(rel_row).subject_id THEN
                        l_exists_flag := 'Y';
                        exit;
                     END IF;
                  END LOOP;
               END IF;
               --
               IF l_exists_flag <> 'Y' THEN
                  IF ( (p_time_stamp IS NOT NULL) AND (p_time_stamp <> fnd_api.g_miss_date)
                   AND (l_relationship_tbl(rel_row).relationship_id IS NOT NULL   --Added for bug 2999353
                   AND l_relationship_tbl(rel_row).relationship_id <> fnd_api.g_miss_num))--Added for bug 2999353
                  THEN
                     IF p_recursive_flag=fnd_api.g_false
                     THEN
                           l_instance_rec.instance_id := l_relationship_tbl(rel_row).subject_id;
                               CSI_ITEM_INSTANCE_PUB.Get_item_instance_details(
                                                                               1.0,
                                                                               'F',
                                                                               'T',
                                                                                1,
                                                                               l_instance_rec,
                                                                               'F',
                                                                               l_party_header_tbl,
                                                                               'F',
                                                                               l_account_header_tbl,
                                                                               'F',
                                                                               l_org_header_tbl,
                                                                               'F',
                                                                               l_pricing_attrib_tbl,
                                                                               'F',
                                                                               l_ext_attrib_tbl,
                                                                               l_ext_attrib_def_tbl,
                                                                               'F',
                                                                               l_asset_header_tbl,
                                                                               'F',
                                                                               p_time_stamp,
                                                                               x_return_status,
                                                                               x_msg_count,
                                                                               x_msg_data
                                                                                );
                     ELSE
                       l_instance_rec.instance_id := l_relationship_tbl(rel_row).subject_id;
                       l_instance_rec.active_end_date := NULL;
                     END IF;
                     --
                     IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
                        l_msg_index := 1;
                        l_msg_count := x_msg_count;
                        WHILE l_msg_count > 0 LOOP
                           x_msg_data := FND_MSG_PUB.GET
                                            (  l_msg_index,
                                               FND_API.G_FALSE );
                           csi_gen_utility_pvt.put_line( ' Error from Get_Item_Instance_Details.. ');
                           csi_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
                           l_msg_index := l_msg_index + 1;
                           l_msg_count := l_msg_count - 1;
                        END LOOP;
                        RAISE FND_API.G_EXC_ERROR;
                     END IF;
                     IF nvl(l_instance_rec.active_end_date,(sysdate+1)) < sysdate THEN
                        l_ctr := l_exp_inst_tbl.count;
                        l_ctr := l_ctr + 1;
                        l_exp_inst_tbl(l_ctr) := l_relationship_tbl(rel_row).subject_id;
                        Get_Children
                        (p_object_id => l_relationship_tbl(rel_row).subject_id,
                         p_rel_tbl   => l_ins_child_tbl
                         );
                        -- Modified for bug 2999353
                       IF l_ins_child_tbl.COUNT >0
                       THEN
                           FOR v_rec in l_ins_child_tbl.first .. l_ins_child_tbl.last
                           LOOP
                             IF l_ins_child_tbl.EXISTS(v_rec)
                             THEN
                                l_ctr := l_ctr + 1;
                                l_exp_inst_tbl(l_ctr) := l_ins_child_tbl(v_rec).subject_id;
                             END IF;
                           END LOOP;
                       END IF;
                       -- End modification for bug 2999353
                     ELSE
                        l_rel_count := l_rel_count + 1;
                        l_temp_relationship_tbl(l_rel_count) := l_relationship_tbl(rel_row);
                     END IF;
                 /*
                  ELSE -- p_time_stamp is not passed
                     Begin
                        Select 'x'
                        into l_exists
                        from CSI_ITEM_INSTANCES
                        where instance_id = l_relationship_tbl(rel_row).subject_id
                        and   nvl(active_end_date,(sysdate+1)) < sysdate;
                        l_ctr := l_exp_inst_tbl.count;
                        FOR v_rec in CHILD_CUR(l_relationship_tbl(rel_row).subject_id) LOOP
                           l_ctr := l_ctr + 1;
                           l_exp_inst_tbl(l_ctr) := v_rec.subject_id;
                        END LOOP;
                     Exception
                        when no_data_found then -- Active Instance
                           l_rel_count := l_rel_count + 1;
                           l_temp_relationship_tbl(l_rel_count) := l_relationship_tbl(rel_row);
                     End;
                   */
                  END IF;
               END IF;
            END IF;
         END LOOP;
      END IF;
      --
      l_rel_count := 0;
      IF p_active_relationship_only = 'T' THEN
         IF l_temp_relationship_tbl.count > 0 THEN
            FOR rel_row in l_temp_relationship_tbl.FIRST .. l_temp_relationship_tbl.LAST
            LOOP
               IF l_temp_relationship_tbl.EXISTS(rel_row) THEN
                  IF l_temp_relationship_tbl(rel_row).active_end_date IS NULL OR
                     l_temp_relationship_tbl(rel_row).active_end_date > SYSDATE THEN
                     l_rel_count := l_rel_count + 1;
                     x_relationship_tbl(l_rel_count) := l_temp_relationship_tbl(rel_row);
-- Added for bug 2999353
                   ELSIF ( l_temp_relationship_tbl(rel_row).active_end_date IS NOT NULL AND
                           l_temp_relationship_tbl(rel_row).active_end_date < SYSDATE ) OR
                         ( l_temp_relationship_tbl(rel_row).relationship_type_code<>'COMPONENT-OF' )
                   THEN
-- Here we capture expired relationship records to use them later down in the program to
-- eliminate all its child components.
                     l_exp_count:=l_exp_count + 1;
                     l_exp_tbl(l_exp_count) := l_temp_relationship_tbl(rel_row);
-- End addition for bug 2999353
                  END IF;
               END IF;
            END LOOP;
         END IF;
      ELSE
-- Added for bug 2999353
         IF l_temp_relationship_tbl.count > 0 THEN
            FOR l_csr IN l_temp_relationship_tbl.FIRST .. l_temp_relationship_tbl.LAST
            LOOP
               IF l_temp_relationship_tbl.EXISTS(l_csr)
               THEN
                   IF l_temp_relationship_tbl(l_csr).relationship_id IS NOT NULL AND
                      l_temp_relationship_tbl(l_csr).relationship_id<> fnd_api.g_miss_num
                   THEN
                     IF l_temp_relationship_tbl(l_csr).relationship_type_code<>'COMPONENT-OF'
                     THEN
                        l_exp_count:=l_exp_count + 1;
                        l_exp_tbl(l_exp_count) := l_temp_relationship_tbl(l_csr);
                     END IF;
                    l_found2:=FALSE;
                    IF x_relationship_tbl.COUNT>0
                    THEN
                       FOR i IN x_relationship_tbl.FIRST..x_relationship_tbl.LAST
                       LOOP
                          IF x_relationship_tbl.EXISTS(i)
                          THEN
                            IF x_relationship_tbl(i).relationship_id=l_temp_relationship_tbl(l_csr).relationship_id
                            THEN
                              l_found2:=TRUE;
                              EXIT;
                            END IF;
                          END IF;
                       END LOOP;
                       IF NOT(l_found2)
                       THEN
                         x_relationship_tbl(x_relationship_tbl.count+1) := l_temp_relationship_tbl(l_csr);
                       END IF;
                    ELSE
                        x_relationship_tbl(x_relationship_tbl.count+1) := l_temp_relationship_tbl(l_csr);
-- End addition bug 2999353
                    END IF;
                   END IF;
               END IF;
            END LOOP;
         END IF;
      END IF;

-- sguthiva added the following code for bug 2999353
-- The following code has been added to eliminate all the child components of an expired relationship record.
      IF p_active_relationship_only = 'T'
      THEN
            l_fin_count:=0;
            l_temp_relationship_tbl.DELETE;
            l_temp_relationship_tbl:=x_relationship_tbl;
         IF l_exp_tbl.COUNT > 0
         THEN
            FOR l_exp_csr IN l_exp_tbl.FIRST .. l_exp_tbl.LAST
            LOOP
               IF l_exp_tbl.EXISTS(l_exp_csr)
               THEN
                  IF l_exp_tbl(l_exp_csr).relationship_id IS NOT NULL AND
                     l_exp_tbl(l_exp_csr).relationship_id <> fnd_api.g_miss_num AND
                     nvl(l_exp_tbl(l_exp_csr).attribute1,'NOT-EXPIRED')<>'EXPIRED'
                  THEN
                    l_exp_act_tbl.delete;
                    -- Used the following procedure instead of a cursor which use
                    -- connect by select statement.
                     Get_Children
                        (p_object_id => l_exp_tbl(l_exp_csr).subject_id,
                         p_rel_tbl   => l_exp_act_tbl
                         );
                   IF l_exp_act_tbl.count >0 --Added for bug 3228702
                   THEN
                     FOR l_active_csr IN l_exp_act_tbl.first .. l_exp_act_tbl.last --expired_cur(l_exp_tbl(l_exp_csr).subject_id)
                     LOOP
                      IF l_exp_act_tbl.EXISTS(l_active_csr)
                      THEN
                       l_expire:=TRUE;
                       l_fin_count:=l_fin_count+1;
                         IF l_exp_act_tbl(l_active_csr).active_end_date IS NULL OR
                            l_exp_act_tbl(l_active_csr).active_end_date > SYSDATE AND
                            l_exp_act_tbl(l_active_csr).relationship_type_code='COMPONENT-OF'
                         THEN
                            l_temp_tbl(l_fin_count).relationship_id := l_exp_act_tbl(l_active_csr).relationship_id;
                         ELSIF l_exp_act_tbl(l_active_csr).relationship_type_code='COMPONENT-OF'
                         THEN
                            FOR l_end_date_csr IN l_exp_tbl.FIRST .. l_exp_tbl.LAST
                            LOOP
                              IF l_exp_act_tbl(l_active_csr).relationship_id=l_exp_tbl(l_end_date_csr).relationship_id
                              THEN
                            -- Since this record is expired which is a child of an expired record and should
                            -- not be picked while looping for active records.
                                l_exp_tbl(l_end_date_csr).attribute1:='EXPIRED';
                              END IF;
                            END LOOP;
                         END IF;
                      END IF;
                     END LOOP; -- End loop for expired_cur
                   END IF;

                  END IF; -- End if for 'EXPIRED' check
               END IF;
            END LOOP; -- End loop for exprired records captured in table l_exp_tbl.
         END IF;

-- Since there are active relationship records for an expired relationship record
-- so delete all the records from output table x_relationship_tbl.
         IF l_expire
         THEN
           x_relationship_tbl.DELETE;
         END IF;

-- Here we build x_relationship_tbl which consists of only active records.

         l_fin_count1:=0;
         IF l_temp_relationship_tbl.COUNT > 0
         THEN
            FOR l_tot_csr IN l_temp_relationship_tbl.FIRST .. l_temp_relationship_tbl.LAST
            LOOP
              l_found1:=FALSE;
                 IF l_temp_relationship_tbl.EXISTS(l_tot_csr)
                 THEN
                   IF l_temp_tbl.COUNT > 0
                   THEN
                      FOR l_exp_cld_csr IN l_temp_tbl.FIRST .. l_temp_tbl.LAST
                      LOOP
                       IF l_temp_tbl.EXISTS(l_exp_cld_csr)
                       THEN
                         IF l_temp_tbl(l_exp_cld_csr).relationship_id = l_temp_relationship_tbl(l_tot_csr).relationship_id
                         THEN
                           l_found1:=TRUE;
                         END IF;
                       END IF;
                      END LOOP;
                   END IF;
                 END IF;

                 IF NOT(l_found1)
                 THEN
                    l_fin_count1 :=l_fin_count1+1;
                    IF l_temp_relationship_tbl(l_tot_csr).relationship_id IS NOT NULL AND
                       l_temp_relationship_tbl(l_tot_csr).relationship_id <> fnd_api.g_miss_num
                    THEN
                      x_relationship_tbl(l_fin_count1):=l_temp_relationship_tbl(l_tot_csr);
                    END IF;
                 END IF;

            END LOOP;
         END IF;


      END IF; -- This end if is for p_active_relationship_only
              -- sk End addition
   END IF;
  END IF;

      --
      -- end of API body
      --
      -- standard call to get message count and if count is 1, get message info.
      fnd_msg_pub.count_AND_get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
      EXCEPTION
         WHEN fnd_api.g_exc_error THEN
             --  ROLLBACK TO get_relationships_pvt;
               x_return_status := fnd_api.g_ret_sts_error ;
               fnd_msg_pub.count_AND_get
                        (p_count => x_msg_count ,
                         p_data => x_msg_data
                        );

          WHEN fnd_api.g_exc_unexpected_error THEN
             --   ROLLBACK TO get_relationships_pvt;
                x_return_status := fnd_api.g_ret_sts_unexp_error ;
                fnd_msg_pub.count_AND_get
                         (p_count => x_msg_count ,
                          p_data => x_msg_data
                         );

          WHEN OTHERS THEN
              --  ROLLBACK TO get_relationships_pvt;
                x_return_status := fnd_api.g_ret_sts_unexp_error ;
                  IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
                         fnd_msg_pub.add_exc_msg(g_pkg_name ,l_api_name);
                  END IF;
                fnd_msg_pub.count_AND_get
                         (p_count => x_msg_count ,
                          p_data => x_msg_data
                         );
END get_relationships;
/* End of Cyclic Relationships */

/* Start of Cyclic Relationships */
FUNCTION valid_in_parameters
(   p_relship_id           IN      VARCHAR2,
    p_object_id            IN      NUMBER,
    p_subject_id           IN      NUMBER
 ) RETURN BOOLEAN IS

BEGIN
   IF p_relship_id is not null AND  P_relship_id <> fnd_api.g_miss_num
   THEN
      IF ((p_object_id is  null OR p_object_id = fnd_api.g_miss_num)
         AND (p_subject_id is  null OR p_subject_id = fnd_api.g_miss_num))
      THEN
         RETURN TRUE;
      ELSIF ((p_object_id is  null OR p_object_id = fnd_api.g_miss_num)
         AND (p_subject_id is not null AND  p_subject_id <> fnd_api.g_miss_num))
      THEN
         RETURN FALSE;
      ELSIF ((p_object_id is not null AND p_object_id <> fnd_api.g_miss_num)
           AND (p_subject_id is  null OR p_subject_id = fnd_api.g_miss_num))
      THEN
         RETURN TRUE;
      ELSIF  ((p_object_id is not null AND p_object_id <> fnd_api.g_miss_num)
         AND (p_subject_id is not null AND p_subject_id <> fnd_api.g_miss_num))
      THEN
         RETURN TRUE;
      END IF;
   END IF;
EXCEPTION
   WHEN OTHERS THEN
      RETURN FALSE;
END valid_in_parameters;

FUNCTION config_set(p_relationship_id IN NUMBER)
RETURN BOOLEAN IS

   l_configurator_id   NUMBER;
BEGIN
  /* SELECT configurator_id
   INTO   l_configurator_id
   FROM   csi_ii_relationships
   WHERE  relationship_id=p_relationship_id;
*/
   IF l_configurator_id is not null
   THEN
      fnd_message.set_name('CSI','CSI_CONFIG_SET');
      fnd_message.set_token('relationship_id',p_relationship_id);
      fnd_msg_pub.add;
      RETURN TRUE;
   ELSE
      RETURN FALSE;
   END IF;
EXCEPTION
   WHEN NO_DATA_FOUND THEN
      RETURN TRUE;
END config_set;

--   This function is used for 'CONNECTED-TO' relationship type.It checks whether 'CONNECTED-TO'
-- relation exists in the reverse direction for the given subject and object

FUNCTION relationship_not_exists
  ( p_subject_id           IN      NUMBER,
    p_object_id            IN      NUMBER,
    p_relship_type_code    IN      VARCHAR2,
    p_mode                 IN      VARCHAR2,
    p_relationship_id      IN      NUMBER
  ) RETURN BOOLEAN IS

   l_object_id                    NUMBER;
   l_subject_id                   NUMBER;
   l_relship_type_code            VARCHAR2(30);
   l_dummy                        VARCHAR2(1) :=NULL;
BEGIN
 IF p_mode='CREATE'
 THEN
   SELECT 'x'
   INTO   l_dummy
   FROM   csi_ii_relationships
   WHERE  (( subject_id=p_object_id AND object_id=p_subject_id)
   OR       (subject_id=p_subject_id AND object_id=p_object_id))
   AND    relationship_type_code = p_relship_type_code
   AND    (active_end_date IS NULL OR active_end_date > SYSDATE)
   AND   ROWNUM = 1  ;
   IF SQL%FOUND THEN
      fnd_message.set_name('CSI','CSI_RELATIONSHIP_EXISTS');
      fnd_message.set_token('relationship_type',p_relship_type_code);
      fnd_message.set_token('subject_id',p_subject_id);
      fnd_message.set_token('object_id',p_object_id);
      fnd_msg_pub.add;
      RETURN FALSE;
   ELSE
      RETURN TRUE;
   END IF;
 ELSIF p_mode='UPDATE'
 THEN
   SELECT 'x'
   INTO   l_dummy
   FROM   csi_ii_relationships
   WHERE  (( subject_id=p_object_id AND object_id=p_subject_id)
   OR       (subject_id=p_subject_id AND object_id=p_object_id))
   AND    relationship_type_code = p_relship_type_code
   AND    (active_end_date IS NULL OR active_end_date > SYSDATE)
   AND    relationship_id<>p_relationship_id
   AND   ROWNUM = 1  ;
   IF SQL%FOUND THEN
      fnd_message.set_name('CSI','CSI_RELATIONSHIP_EXISTS');
      fnd_message.set_token('relationship_type',p_relship_type_code);
      fnd_message.set_token('subject_id',p_subject_id);
      fnd_message.set_token('object_id',p_object_id);
      fnd_msg_pub.add;
      RETURN FALSE;
   ELSE
      RETURN TRUE;
   END IF;
 END IF;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
      RETURN TRUE;
END relationship_not_exists;

/* End of Cyclic Relationships */

-- Start of att enhancements by sguthiva
-- This function to make sure that an object or subject instance can participate
-- atmost 2 'CONNECTED-TO' relationships.


FUNCTION relationship_for_link
  ( p_instance_id          IN      NUMBER,
    p_mode                 IN      VARCHAR2,
    p_relationship_id      IN      NUMBER
  ) RETURN BOOLEAN IS
   l_count                        NUMBER :=0;
BEGIN

   IF p_mode='CREATE'
   THEN
        SELECT COUNT(*)
        INTO   l_count
        FROM   csi_ii_relationships
        WHERE  (subject_id=p_instance_id OR object_id=p_instance_id)
        AND    relationship_type_code = 'CONNECTED-TO'
        AND    (active_end_date IS NULL OR active_end_date > SYSDATE);
   ELSIF p_mode='UPDATE'
   THEN
   -- Code for update will check other than itself
   -- and during unexpiring of an expired relationship.
        SELECT COUNT(*)
        INTO   l_count
        FROM   csi_ii_relationships
        WHERE  (subject_id=p_instance_id OR object_id=p_instance_id)
        AND    relationship_type_code = 'CONNECTED-TO'
        AND    relationship_id <> p_relationship_id
        AND    (active_end_date IS NULL OR active_end_date > SYSDATE);
   END IF;


   IF l_count >= 2
   THEN
      RETURN TRUE;
   ELSE
      RETURN FALSE;
   END IF;
EXCEPTION
   WHEN OTHERS THEN
      RETURN FALSE;
END relationship_for_link;

-- This function to find it the instance is of type link
FUNCTION Is_link_type
  ( p_instance_id          IN      NUMBER
  ) RETURN BOOLEAN IS
   l_link                        VARCHAR2(30);
   l_class                       VARCHAR2(30) := 'LINK';
   --
BEGIN
   SELECT msi.ib_item_instance_class
   INTO   l_link
   FROM   csi_item_instances cii
         ,mtl_system_items_b msi
   WHERE  cii.instance_id = p_instance_id
   AND    msi.inventory_item_id=cii.inventory_item_id
   AND    msi.organization_id=cii.last_vld_organization_id
   AND    msi.ib_item_instance_class = l_class;
   RETURN TRUE;
EXCEPTION
   WHEN NO_DATA_FOUND THEN
      RETURN FALSE;
END Is_link_type;

-- End of att enhancements by sguthiva
/* ------------------------------------------------------------------------------------------------------*/
/* during creation/updation of a relationship check for a record for passed subject_id and               */
/* relationship_type_code                                                                                */
/*   1. If exists then return an error message and return false else return true                         */
/*                         a      sub: b ,rel code: component-of                                         */
/*                        /  \    passed (b,component-of) --return false                                 */
/*                       b    c   passed (b,member-of)    --return true                                  */
/* ------------------------------------------------------------------------------------------------------*/

FUNCTION subject_exists
(       p_subject_id           IN      NUMBER,
        p_relship_type_code    IN      VARCHAR2,
        p_relationship_id      IN      NUMBER,
        p_mode                 IN      VARCHAR2
 ) RETURN BOOLEAN IS

 l_subject_id         NUMBER;
 l_relship_type_code  VARCHAR2(30);
 l_dummy              VARCHAR2(1) :=NULL;
 l_return_value       BOOLEAN := TRUE;
     BEGIN
      IF p_mode='CREATE'
      THEN
       BEGIN
        SELECT 'x'
        INTO   l_dummy
        FROM   csi_ii_relationships
        WHERE  subject_id=p_subject_id
        AND    relationship_type_code = p_relship_type_code
        AND   (active_end_date IS NULL OR active_end_date > SYSDATE)
        --AND   (SYSDATE BETWEEN NVL(active_start_date, SYSDATE) AND NVL(active_end_date, SYSDATE))
        AND    ROWNUM=1;
        IF SQL%FOUND THEN

                   fnd_message.set_name('CSI','CSI_SUB_RELCODE_EXIST');
                   fnd_message.set_token('relationship_type_code',p_relship_type_code);
                   fnd_message.set_token('SUBJECT_ID',p_subject_id);
                   fnd_msg_pub.add;
           RETURN FALSE;
        END IF;
       EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN TRUE;
       END;
      ELSIF p_mode='UPDATE'
      THEN

       BEGIN
        SELECT 'x'
        INTO   l_dummy
        FROM   csi_ii_relationships
        WHERE  subject_id=p_subject_id
        AND    relationship_type_code = p_relship_type_code
        AND    relationship_id <> p_relationship_id
        AND   (active_end_date IS NULL OR active_end_date > SYSDATE)
        --AND   (SYSDATE BETWEEN NVL(active_start_date, SYSDATE) AND NVL(active_end_date, SYSDATE))
        AND    ROWNUM=1;
        IF SQL%FOUND THEN

                   fnd_message.set_name('CSI','CSI_SUB_RELCODE_EXIST');
                   fnd_message.set_token('relationship_type_code',p_relship_type_code);
                   fnd_message.set_token('SUBJECT_ID',p_subject_id);
                   fnd_msg_pub.add;
           RETURN FALSE;
        END IF;
       EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN TRUE;
       END;
      END IF;
END subject_exists;

/* Cyclic Relationships */
/* This function checks whether the subject already exist for the relation
ship */
FUNCTION subject_relship_exists
(   p_relationship_id       IN      NUMBER,
    p_subject_id            IN      NUMBER,
    p_relship_type_code     IN      VARCHAR2
 ) RETURN BOOLEAN IS
    l_subject_id                    NUMBER;
    l_relship_type_code            VARCHAR2(30);
    l_dummy                        VARCHAR2(1) :=NULL;
BEGIN
    IF p_relationship_id is not null
       AND(p_subject_id  is null OR p_subject_id= fnd_api.g_miss_num)
    THEN
       RETURN TRUE;
    ELSE
       SELECT subject_id,relationship_type_code
       INTO   l_subject_id,l_relship_type_code
       FROM   csi_ii_relationships
       WHERE  relationship_id=p_relationship_id
       AND    subject_id     =p_subject_id;

       IF SQL%FOUND THEN
          RETURN TRUE;
       ELSE
          RETURN FALSE;
       END IF;
    END IF;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
       RETURN FALSE;
END subject_relship_exists;

/* ---------------------------------------------------------------------------------------------- */
/* during updating a relationship check for the existence of object_id or relationship_type_code  */
/*  For the passed relationship_id                                                                */
/*   example - relid -reltype-object-sub-TRUE                                                     */
/*               1- componentof-i10-i12-exist record                                              */
/*               1- componentof-i20-i13-FALSE                                                     */
/*               1- memberof   -i10-i13-FALSE                                                     */
/*               1- componentof-i10-i13-TRUE                                                      */
/* ---------------------------------------------------------------------------------------------- */

FUNCTION object_relship_exists
(   p_relationship_id      IN      NUMBER,
    p_object_id            IN      NUMBER,
    p_relship_type_code    IN      VARCHAR2
 ) RETURN BOOLEAN IS
    l_object_id                    NUMBER;
    l_relship_type_code            VARCHAR2(30);
    l_dummy                        VARCHAR2(1) :=NULL;
BEGIN
    SELECT object_id,relationship_type_code
    INTO   l_object_id,l_relship_type_code
    FROM   csi_ii_relationships
    WHERE  relationship_id=p_relationship_id;

    IF SQL%FOUND THEN
       IF ( (l_object_id<>p_object_id) OR (l_relship_type_code<>p_relship_type_code) ) THEN
          fnd_message.set_name('CSI','CSI_CANNOT_UPDATE');
          fnd_message.set_token('object_id',p_object_id);
          fnd_message.set_token('relationship_type_code',p_relship_type_code);
          fnd_msg_pub.add;
          RETURN FALSE;
       ELSE
          RETURN TRUE;
       END IF;
    END IF;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
       RETURN TRUE;
END object_relship_exists;

/* ----------------------------------------------------------------------------------------------- */
/* This procedure(during creation)is used to check if the received subject is already an object    */
/*  If found then raise error else success                                                         */
/*                      a                                                                          */
/*                     / \                                                                         */
/*                    b   c                                                                        */
/*                    / \                                                                          */
/*                   d   a -> Not allowed                                                          */
/* ----------------------------------------------------------------------------------------------- */

PROCEDURE check_for_object
(   p_subject_id             IN      NUMBER,
    p_object_id              IN      NUMBER,
    p_relationship_type_code IN      VARCHAR2,
    x_return_status          OUT NOCOPY     VARCHAR2,
    x_msg_count              OUT NOCOPY     NUMBER,
    x_msg_data               OUT NOCOPY     VARCHAR2
 )
IS
 l_rel_tbl        csi_datastructures_pub.ii_relationship_tbl;
 p_relationship_query_rec csi_datastructures_pub.relationship_query_rec;
 l_ii_relationship_level_tbl csi_ii_relationships_pvt.ii_relationship_level_tbl;
/* CURSOR chk_obj_csr IS
          SELECT 'x'
          FROM   csi_ii_relationships
          WHERE  subject_id = p_object_id
          AND    relationship_type_code = p_relationship_type_code
          START WITH object_id = p_subject_id
          CONNECT BY object_id = PRIOR subject_id;
  l_dummy VARCHAR2(1); */

  BEGIN
     x_return_status := fnd_api.g_ret_sts_success;
     IF p_subject_id IS NULL OR
        p_subject_id = FND_API.G_MISS_NUM OR
        p_object_id IS NULL OR
        p_object_id = FND_API.G_MISS_NUM THEN
        fnd_message.set_name('CSI', 'CSI_PARENT_CHILD_INVALID');
        fnd_msg_pub.add;
        x_return_status := fnd_api.g_ret_sts_error;
        RETURN;
     END IF;
     --
     p_relationship_query_rec.object_id := p_subject_id; -- To check for Loop
     p_relationship_query_rec.relationship_type_code := p_relationship_type_code;
     --
     IF p_subject_id <> p_object_id THEN
        csi_ii_relationships_pvt.Get_Children
           ( p_relationship_query_rec      => p_relationship_query_rec,
             p_rel_tbl                     => l_rel_tbl,
             p_depth                       => NULL,
             p_active_relationship_only    => FND_API.G_TRUE,
             p_active_instances_only       => FND_API.G_FALSE,
             p_time_stamp                  => FND_API.G_MISS_DATE,
             p_get_dfs                     => FND_API.G_FALSE,
             p_ii_relationship_level_tbl   => l_ii_relationship_level_tbl,
             x_return_status               => x_return_status,
             x_msg_count                   => x_msg_count,
             x_msg_data                    => x_msg_data
           );
        --
        IF x_return_status = FND_API.G_RET_STS_SUCCESS AND
           l_rel_tbl.count > 0 THEN
           FOR j in l_rel_tbl.FIRST .. l_rel_tbl.LAST LOOP
              IF l_rel_tbl(j).subject_id = p_object_id THEN
                 fnd_message.set_name('CSI','CSI_CHILD_PARENT_REL_LOOP');
                 fnd_msg_pub.add;
                 x_return_status := fnd_api.g_ret_sts_error;
                 exit;
              END IF;
           END LOOP;
        END IF;
     ELSE
        fnd_message.set_name('CSI', 'CSI_PARENT_CHILD_INVALID');
        fnd_msg_pub.add;
        x_return_status := fnd_api.g_ret_sts_error;
     END IF;
END check_for_object;

PROCEDURE validate_history(p_old_relship_rec IN   csi_datastructures_pub.ii_relationship_rec,
                           p_new_relship_rec IN   csi_datastructures_pub.ii_relationship_rec,
                           p_transaction_id  IN   NUMBER,
                           p_flag            IN   VARCHAR2,
                           p_sysdate         IN   DATE,
                           x_return_status   OUT NOCOPY  VARCHAR2,
                           x_msg_count       OUT NOCOPY  NUMBER,
                           x_msg_data        OUT NOCOPY  VARCHAR2)
IS
l_old_relship_rec       csi_datastructures_pub.ii_relationship_rec :=p_old_relship_rec;
l_new_relship_rec       csi_datastructures_pub.ii_relationship_rec :=p_new_relship_rec;
l_transaction_id        NUMBER := p_transaction_id;
l_full_dump             NUMBER;
l_relship_hist_rec      csi_datastructures_pub.relationship_history_rec;

CURSOR rel_hist_csr (p_rel_hist_id NUMBER) IS
SELECT  relationship_history_id
       ,relationship_id
       ,transaction_id
       ,old_subject_id
       ,new_subject_id
       ,old_position_reference
       ,new_position_reference
       ,old_active_start_date
       ,new_active_start_date
       ,old_active_end_date
       ,new_active_end_date
       ,old_mandatory_flag
       ,new_mandatory_flag
       ,old_context
       ,new_context
       ,old_attribute1
       ,new_attribute1
       ,old_attribute2
       ,new_attribute2
       ,old_attribute3
       ,new_attribute3
       ,old_attribute4
       ,new_attribute4
       ,old_attribute5
       ,new_attribute5
       ,old_attribute6
       ,new_attribute6
       ,old_attribute7
       ,new_attribute7
       ,old_attribute8
       ,new_attribute8
       ,old_attribute9
       ,new_attribute9
       ,old_attribute10
       ,new_attribute10
       ,old_attribute11
       ,new_attribute11
       ,old_attribute12
       ,new_attribute12
       ,old_attribute13
       ,new_attribute13
       ,old_attribute14
       ,new_attribute14
       ,old_attribute15
       ,new_attribute15
       ,full_dump_flag
       ,object_version_number
FROM   csi_ii_relationships_h
WHERE  csi_ii_relationships_h.relationship_history_id =  p_rel_hist_id
FOR UPDATE OF object_version_number;

l_rel_hist_csr   rel_hist_csr%ROWTYPE;
l_rel_hist_id    NUMBER;

BEGIN


   x_return_status := fnd_api.g_ret_sts_success;
   --
   IF csi_datastructures_pub.g_install_param_rec.fetch_flag IS NULL THEN
      csi_gen_utility_pvt.populate_install_param_rec;
   END IF;
   --
   l_full_dump := csi_datastructures_pub.g_install_param_rec.history_full_dump_frequency;
   --
   IF l_full_dump IS NULL THEN
      FND_MESSAGE.SET_NAME('CSI','CSI_API_GET_FULL_DUMP_FAILED');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
   END IF;
   --
   IF p_flag = 'EXPIRE' THEN
      l_new_relship_rec.active_end_date := p_sysdate;
   END IF;
   -- Start of modifications for Bug#2547034 on 09/20/02 - rtalluri
       BEGIN
        SELECT  relationship_history_id
        INTO    l_rel_hist_id
        FROM    csi_ii_relationships_h h
        WHERE   h.transaction_id = p_transaction_id
        AND     h.relationship_id = p_old_relship_rec.relationship_id;

        OPEN   rel_hist_csr(l_rel_hist_id);
        FETCH  rel_hist_csr INTO l_rel_hist_csr ;
        CLOSE  rel_hist_csr;

        IF l_rel_hist_csr.full_dump_flag = 'Y'
        THEN
          csi_ii_relationships_h_pkg.update_row(
            p_relationship_history_id       =>  l_rel_hist_id                       ,
            p_relationship_id               =>  fnd_api.g_miss_num                  ,
            p_transaction_id                =>  fnd_api.g_miss_num                  ,
            p_old_subject_id                =>  fnd_api.g_miss_num                  ,
            p_new_subject_id                =>  l_new_relship_rec.subject_id        ,
            p_old_position_reference        =>  fnd_api.g_miss_char                 ,
            p_new_position_reference        =>  l_new_relship_rec.position_reference,
            p_old_active_start_date         =>  fnd_api.g_miss_date                 ,
            p_new_active_start_date         =>  l_new_relship_rec.active_start_date ,
            p_old_active_end_date           =>  fnd_api.g_miss_date                 ,
            p_new_active_end_date           =>  l_new_relship_rec.active_end_date   ,
            p_old_mandatory_flag            =>  fnd_api.g_miss_char                 ,
            p_new_mandatory_flag            =>  l_new_relship_rec.mandatory_flag    ,
            p_old_context                   =>  fnd_api.g_miss_char                 ,
            p_new_context                   =>  l_new_relship_rec.context           ,
            p_old_attribute1                =>  fnd_api.g_miss_char                 ,
            p_new_attribute1                =>  l_new_relship_rec.attribute1        ,
            p_old_attribute2                =>  fnd_api.g_miss_char                 ,
            p_new_attribute2                =>  l_new_relship_rec.attribute2        ,
            p_old_attribute3                =>  fnd_api.g_miss_char                 ,
            p_new_attribute3                =>  l_new_relship_rec.attribute3        ,
            p_old_attribute4                =>  fnd_api.g_miss_char                 ,
            p_new_attribute4                =>  l_new_relship_rec.attribute4        ,
            p_old_attribute5                =>  fnd_api.g_miss_char                 ,
            p_new_attribute5                =>  l_new_relship_rec.attribute5        ,
            p_old_attribute6                =>  fnd_api.g_miss_char                 ,
            p_new_attribute6                =>  l_new_relship_rec.attribute6        ,
            p_old_attribute7                =>  fnd_api.g_miss_char                 ,
            p_new_attribute7                =>  l_new_relship_rec.attribute7        ,
            p_old_attribute8                =>  fnd_api.g_miss_char                 ,
            p_new_attribute8                =>  l_new_relship_rec.attribute8        ,
            p_old_attribute9                =>  fnd_api.g_miss_char                 ,
            p_new_attribute9                =>  l_new_relship_rec.attribute9        ,
            p_old_attribute10               =>  fnd_api.g_miss_char                 ,
            p_new_attribute10               =>  l_new_relship_rec.attribute10       ,
            p_old_attribute11               =>  fnd_api.g_miss_char                 ,
            p_new_attribute11               =>  l_new_relship_rec.attribute11       ,
            p_old_attribute12               =>  fnd_api.g_miss_char                 ,
            p_new_attribute12               =>  l_new_relship_rec.attribute12       ,
            p_old_attribute13               =>  fnd_api.g_miss_char                 ,
            p_new_attribute13               =>  l_new_relship_rec.attribute13       ,
            p_old_attribute14               =>  fnd_api.g_miss_char                 ,
            p_new_attribute14               =>  l_new_relship_rec.attribute14       ,
            p_old_attribute15               =>  fnd_api.g_miss_char                 ,
            p_new_attribute15               =>  l_new_relship_rec.attribute15       ,
            p_full_dump_flag                =>  fnd_api.g_miss_char                 ,
            p_created_by                    =>  fnd_api.g_miss_num, -- fnd_global.user_id,
            p_creation_date                 =>  fnd_api.g_miss_date                 ,
            p_last_updated_by               =>  fnd_global.user_id                  ,
            p_last_update_date              =>  SYSDATE                             ,
            p_last_update_login             =>  fnd_global.conc_login_id            ,
            p_object_version_number         =>  fnd_api.g_miss_num );
        ELSE
          --
             IF    ( l_rel_hist_csr.old_subject_id IS NULL
                AND  l_rel_hist_csr.new_subject_id IS NULL ) THEN
                     IF  ( l_new_relship_rec.subject_id = l_old_relship_rec.subject_id )
                      OR ( l_new_relship_rec.subject_id = fnd_api.g_miss_num ) THEN
                           l_rel_hist_csr.old_subject_id := NULL;
                           l_rel_hist_csr.new_subject_id := NULL;
                     ELSE
                           l_rel_hist_csr.old_subject_id := fnd_api.g_miss_num;
                           l_rel_hist_csr.new_subject_id := l_new_relship_rec.subject_id;
                     END IF;
             ELSE
                     l_rel_hist_csr.old_subject_id := fnd_api.g_miss_num;
                     l_rel_hist_csr.new_subject_id := l_new_relship_rec.subject_id;
             END IF;
          --
             IF    ( l_rel_hist_csr.old_position_reference IS NULL
                AND  l_rel_hist_csr.new_position_reference IS NULL ) THEN
                     IF  ( l_new_relship_rec.position_reference = l_old_relship_rec.position_reference )
                      OR ( l_new_relship_rec.position_reference = fnd_api.g_miss_char ) THEN
                           l_rel_hist_csr.old_position_reference := NULL;
                           l_rel_hist_csr.new_position_reference := NULL;
                     ELSE
                           l_rel_hist_csr.old_position_reference := fnd_api.g_miss_char;
                           l_rel_hist_csr.new_position_reference := l_new_relship_rec.position_reference;
                     END IF;
             ELSE
                     l_rel_hist_csr.old_position_reference := fnd_api.g_miss_char;
                     l_rel_hist_csr.new_position_reference := l_new_relship_rec.position_reference;
             END IF;
          --
             IF    ( l_rel_hist_csr.old_active_start_date IS NULL
                AND  l_rel_hist_csr.new_active_start_date IS NULL ) THEN
                     IF  ( l_new_relship_rec.active_start_date = l_old_relship_rec.active_start_date )
                      OR ( l_new_relship_rec.active_start_date = fnd_api.g_miss_date ) THEN
                           l_rel_hist_csr.old_active_start_date := NULL;
                           l_rel_hist_csr.new_active_start_date := NULL;
                     ELSE
                           l_rel_hist_csr.old_active_start_date := fnd_api.g_miss_date;
                           l_rel_hist_csr.new_active_start_date := l_new_relship_rec.active_start_date;
                     END IF;
             ELSE
                     l_rel_hist_csr.old_active_start_date := fnd_api.g_miss_date;
                     l_rel_hist_csr.new_active_start_date := l_new_relship_rec.active_start_date;
             END IF;
          --
             IF    ( l_rel_hist_csr.old_active_end_date IS NULL
                AND  l_rel_hist_csr.new_active_end_date IS NULL ) THEN
                     IF  ( l_new_relship_rec.active_end_date = l_old_relship_rec.active_end_date )
                      OR ( l_new_relship_rec.active_end_date = fnd_api.g_miss_date ) THEN
                           l_rel_hist_csr.old_active_end_date := NULL;
                           l_rel_hist_csr.new_active_end_date := NULL;
                     ELSE
                           l_rel_hist_csr.old_active_end_date := fnd_api.g_miss_date;
                           l_rel_hist_csr.new_active_end_date := l_new_relship_rec.active_end_date;
                     END IF;
             ELSE
                     l_rel_hist_csr.old_active_end_date := fnd_api.g_miss_date;
                     l_rel_hist_csr.new_active_end_date := l_new_relship_rec.active_end_date;
             END IF;
          --
             IF    ( l_rel_hist_csr.old_mandatory_flag IS NULL
                AND  l_rel_hist_csr.new_mandatory_flag IS NULL ) THEN
                     IF  ( l_new_relship_rec.mandatory_flag = l_old_relship_rec.mandatory_flag )
                      OR ( l_new_relship_rec.mandatory_flag = fnd_api.g_miss_char ) THEN
                           l_rel_hist_csr.old_mandatory_flag := NULL;
                           l_rel_hist_csr.new_mandatory_flag := NULL;
                     ELSE
                           l_rel_hist_csr.old_mandatory_flag := fnd_api.g_miss_char;
                           l_rel_hist_csr.new_mandatory_flag := l_new_relship_rec.mandatory_flag;
                     END IF;
             ELSE
                     l_rel_hist_csr.old_mandatory_flag := fnd_api.g_miss_char;
                     l_rel_hist_csr.new_mandatory_flag := l_new_relship_rec.mandatory_flag;
             END IF;
          --
             IF    ( l_rel_hist_csr.old_context IS NULL
                AND  l_rel_hist_csr.new_context IS NULL ) THEN
                     IF  ( l_new_relship_rec.context = l_old_relship_rec.context )
                      OR ( l_new_relship_rec.context = fnd_api.g_miss_char ) THEN
                           l_rel_hist_csr.old_context := NULL;
                           l_rel_hist_csr.new_context := NULL;
                     ELSE
                           l_rel_hist_csr.old_context := fnd_api.g_miss_char;
                           l_rel_hist_csr.new_context := l_new_relship_rec.context;
                     END IF;
             ELSE
                     l_rel_hist_csr.old_context := fnd_api.g_miss_char;
                     l_rel_hist_csr.new_context := l_new_relship_rec.context;
             END IF;
          --
             IF    ( l_rel_hist_csr.old_attribute1 IS NULL
                AND  l_rel_hist_csr.new_attribute1 IS NULL ) THEN
                     IF  ( l_new_relship_rec.attribute1 = l_old_relship_rec.attribute1 )
                      OR ( l_new_relship_rec.attribute1 = fnd_api.g_miss_char ) THEN
                           l_rel_hist_csr.old_attribute1 := NULL;
                           l_rel_hist_csr.new_attribute1 := NULL;
                     ELSE
                           l_rel_hist_csr.old_attribute1 := fnd_api.g_miss_char;
                           l_rel_hist_csr.new_attribute1 := l_new_relship_rec.attribute1;
                     END IF;
             ELSE
                     l_rel_hist_csr.old_attribute1 := fnd_api.g_miss_char;
                     l_rel_hist_csr.new_attribute1 := l_new_relship_rec.attribute1;
             END IF;
          --
             IF    ( l_rel_hist_csr.old_attribute2 IS NULL
                AND  l_rel_hist_csr.new_attribute2 IS NULL ) THEN
                     IF  ( l_new_relship_rec.attribute2 = l_old_relship_rec.attribute2 )
                      OR ( l_new_relship_rec.attribute2 = fnd_api.g_miss_char ) THEN
                           l_rel_hist_csr.old_attribute2 := NULL;
                           l_rel_hist_csr.new_attribute2 := NULL;
                     ELSE
                           l_rel_hist_csr.old_attribute2 := fnd_api.g_miss_char;
                           l_rel_hist_csr.new_attribute2 := l_new_relship_rec.attribute2;
                     END IF;
             ELSE
                     l_rel_hist_csr.old_attribute2 := fnd_api.g_miss_char;
                     l_rel_hist_csr.new_attribute2 := l_new_relship_rec.attribute2;
             END IF;
          --
             IF    ( l_rel_hist_csr.old_attribute3 IS NULL
                AND  l_rel_hist_csr.new_attribute3 IS NULL ) THEN
                     IF  ( l_new_relship_rec.attribute3 = l_old_relship_rec.attribute3 )
                      OR ( l_new_relship_rec.attribute3 = fnd_api.g_miss_char ) THEN
                           l_rel_hist_csr.old_attribute3 := NULL;
                           l_rel_hist_csr.new_attribute3 := NULL;
                     ELSE
                           l_rel_hist_csr.old_attribute3 := fnd_api.g_miss_char;
                           l_rel_hist_csr.new_attribute3 := l_new_relship_rec.attribute3;
                     END IF;
             ELSE
                     l_rel_hist_csr.old_attribute3 := fnd_api.g_miss_char;
                     l_rel_hist_csr.new_attribute3 := l_new_relship_rec.attribute3;
             END IF;
          --
             IF    ( l_rel_hist_csr.old_attribute4 IS NULL
                AND  l_rel_hist_csr.new_attribute4 IS NULL ) THEN
                     IF  ( l_new_relship_rec.attribute4 = l_old_relship_rec.attribute4 )
                      OR ( l_new_relship_rec.attribute4 = fnd_api.g_miss_char ) THEN
                           l_rel_hist_csr.old_attribute4 := NULL;
                           l_rel_hist_csr.new_attribute4 := NULL;
                     ELSE
                           l_rel_hist_csr.old_attribute4 := fnd_api.g_miss_char;
                           l_rel_hist_csr.new_attribute4 := l_new_relship_rec.attribute4;
                     END IF;
             ELSE
                     l_rel_hist_csr.old_attribute4 := fnd_api.g_miss_char;
                     l_rel_hist_csr.new_attribute4 := l_new_relship_rec.attribute4;
             END IF;
          --
             IF    ( l_rel_hist_csr.old_attribute5 IS NULL
                AND  l_rel_hist_csr.new_attribute5 IS NULL ) THEN
                     IF  ( l_new_relship_rec.attribute5 = l_old_relship_rec.attribute5 )
                      OR ( l_new_relship_rec.attribute5 = fnd_api.g_miss_char ) THEN
                           l_rel_hist_csr.old_attribute5 := NULL;
                           l_rel_hist_csr.new_attribute5 := NULL;
                     ELSE
                           l_rel_hist_csr.old_attribute5 := fnd_api.g_miss_char;
                           l_rel_hist_csr.new_attribute5 := l_new_relship_rec.attribute5;
                     END IF;
             ELSE
                     l_rel_hist_csr.old_attribute5 := fnd_api.g_miss_char;
                     l_rel_hist_csr.new_attribute5 := l_new_relship_rec.attribute5;
             END IF;
          --
             IF    ( l_rel_hist_csr.old_attribute6 IS NULL
                AND  l_rel_hist_csr.new_attribute6 IS NULL ) THEN
                     IF  ( l_new_relship_rec.attribute6 = l_old_relship_rec.attribute6 )
                      OR ( l_new_relship_rec.attribute6 = fnd_api.g_miss_char ) THEN
                           l_rel_hist_csr.old_attribute6 := NULL;
                           l_rel_hist_csr.new_attribute6 := NULL;
                     ELSE
                           l_rel_hist_csr.old_attribute6 := fnd_api.g_miss_char;
                           l_rel_hist_csr.new_attribute6 := l_new_relship_rec.attribute6;
                     END IF;
             ELSE
                     l_rel_hist_csr.old_attribute6 := fnd_api.g_miss_char;
                     l_rel_hist_csr.new_attribute6 := l_new_relship_rec.attribute6;
             END IF;
          --
             IF    ( l_rel_hist_csr.old_attribute7 IS NULL
                AND  l_rel_hist_csr.new_attribute7 IS NULL ) THEN
                     IF  ( l_new_relship_rec.attribute7 = l_old_relship_rec.attribute7 )
                      OR ( l_new_relship_rec.attribute7 = fnd_api.g_miss_char ) THEN
                           l_rel_hist_csr.old_attribute7 := NULL;
                           l_rel_hist_csr.new_attribute7 := NULL;
                     ELSE
                           l_rel_hist_csr.old_attribute7 := fnd_api.g_miss_char;
                           l_rel_hist_csr.new_attribute7 := l_new_relship_rec.attribute7;
                     END IF;
             ELSE
                     l_rel_hist_csr.old_attribute7 := fnd_api.g_miss_char;
                     l_rel_hist_csr.new_attribute7 := l_new_relship_rec.attribute7;
             END IF;
          --
             IF    ( l_rel_hist_csr.old_attribute8 IS NULL
                AND  l_rel_hist_csr.new_attribute8 IS NULL ) THEN
                     IF  ( l_new_relship_rec.attribute8 = l_old_relship_rec.attribute8 )
                      OR ( l_new_relship_rec.attribute8 = fnd_api.g_miss_char ) THEN
                           l_rel_hist_csr.old_attribute8 := NULL;
                           l_rel_hist_csr.new_attribute8 := NULL;
                     ELSE
                           l_rel_hist_csr.old_attribute8 := fnd_api.g_miss_char;
                           l_rel_hist_csr.new_attribute8 := l_new_relship_rec.attribute8;
                     END IF;
             ELSE
                     l_rel_hist_csr.old_attribute8 := fnd_api.g_miss_char;
                     l_rel_hist_csr.new_attribute8 := l_new_relship_rec.attribute8;
             END IF;
          --
             IF    ( l_rel_hist_csr.old_attribute9 IS NULL
                AND  l_rel_hist_csr.new_attribute9 IS NULL ) THEN
                     IF  ( l_new_relship_rec.attribute9 = l_old_relship_rec.attribute9 )
                      OR ( l_new_relship_rec.attribute9 = fnd_api.g_miss_char ) THEN
                           l_rel_hist_csr.old_attribute9 := NULL;
                           l_rel_hist_csr.new_attribute9 := NULL;
                     ELSE
                           l_rel_hist_csr.old_attribute9 := fnd_api.g_miss_char;
                           l_rel_hist_csr.new_attribute9 := l_new_relship_rec.attribute9;
                     END IF;
             ELSE
                     l_rel_hist_csr.old_attribute9 := fnd_api.g_miss_char;
                     l_rel_hist_csr.new_attribute9 := l_new_relship_rec.attribute9;
             END IF;
          --
             IF    ( l_rel_hist_csr.old_attribute10 IS NULL
                AND  l_rel_hist_csr.new_attribute10 IS NULL ) THEN
                     IF  ( l_new_relship_rec.attribute10 = l_old_relship_rec.attribute10 )
                      OR ( l_new_relship_rec.attribute10 = fnd_api.g_miss_char ) THEN
                           l_rel_hist_csr.old_attribute10 := NULL;
                           l_rel_hist_csr.new_attribute10 := NULL;
                     ELSE
                           l_rel_hist_csr.old_attribute10 := fnd_api.g_miss_char;
                           l_rel_hist_csr.new_attribute10 := l_new_relship_rec.attribute10;
                     END IF;
             ELSE
                     l_rel_hist_csr.old_attribute10 := fnd_api.g_miss_char;
                     l_rel_hist_csr.new_attribute10 := l_new_relship_rec.attribute10;
             END IF;
          --
             IF    ( l_rel_hist_csr.old_attribute11 IS NULL
                AND  l_rel_hist_csr.new_attribute11 IS NULL ) THEN
                     IF  ( l_new_relship_rec.attribute11 = l_old_relship_rec.attribute11 )
                      OR ( l_new_relship_rec.attribute11 = fnd_api.g_miss_char ) THEN
                           l_rel_hist_csr.old_attribute11 := NULL;
                           l_rel_hist_csr.new_attribute11 := NULL;
                     ELSE
                           l_rel_hist_csr.old_attribute11 := fnd_api.g_miss_char;
                           l_rel_hist_csr.new_attribute11 := l_new_relship_rec.attribute11;
                     END IF;
             ELSE
                     l_rel_hist_csr.old_attribute11 := fnd_api.g_miss_char;
                     l_rel_hist_csr.new_attribute11 := l_new_relship_rec.attribute11;
             END IF;
          --
             IF    ( l_rel_hist_csr.old_attribute12 IS NULL
                AND  l_rel_hist_csr.new_attribute12 IS NULL ) THEN
                     IF  ( l_new_relship_rec.attribute12 = l_old_relship_rec.attribute12 )
                      OR ( l_new_relship_rec.attribute12 = fnd_api.g_miss_char ) THEN
                           l_rel_hist_csr.old_attribute12 := NULL;
                           l_rel_hist_csr.new_attribute12 := NULL;
                     ELSE
                           l_rel_hist_csr.old_attribute12 := fnd_api.g_miss_char;
                           l_rel_hist_csr.new_attribute12 := l_new_relship_rec.attribute12;
                     END IF;
             ELSE
                     l_rel_hist_csr.old_attribute12 := fnd_api.g_miss_char;
                     l_rel_hist_csr.new_attribute12 := l_new_relship_rec.attribute12;
             END IF;
          --
             IF    ( l_rel_hist_csr.old_attribute13 IS NULL
                AND  l_rel_hist_csr.new_attribute13 IS NULL ) THEN
                     IF  ( l_new_relship_rec.attribute13 = l_old_relship_rec.attribute13 )
                      OR ( l_new_relship_rec.attribute13 = fnd_api.g_miss_char ) THEN
                           l_rel_hist_csr.old_attribute13 := NULL;
                           l_rel_hist_csr.new_attribute13 := NULL;
                     ELSE
                           l_rel_hist_csr.old_attribute13 := fnd_api.g_miss_char;
                           l_rel_hist_csr.new_attribute13 := l_new_relship_rec.attribute13;
                     END IF;
             ELSE
                     l_rel_hist_csr.old_attribute13 := fnd_api.g_miss_char;
                     l_rel_hist_csr.new_attribute13 := l_new_relship_rec.attribute13;
             END IF;
          --
             IF    ( l_rel_hist_csr.old_attribute14 IS NULL
                AND  l_rel_hist_csr.new_attribute14 IS NULL ) THEN
                     IF  ( l_new_relship_rec.attribute14 = l_old_relship_rec.attribute14 )
                      OR ( l_new_relship_rec.attribute14 = fnd_api.g_miss_char ) THEN
                           l_rel_hist_csr.old_attribute14 := NULL;
                           l_rel_hist_csr.new_attribute14 := NULL;
                     ELSE
                           l_rel_hist_csr.old_attribute14 := fnd_api.g_miss_char;
                           l_rel_hist_csr.new_attribute14 := l_new_relship_rec.attribute14;
                     END IF;
             ELSE
                     l_rel_hist_csr.old_attribute14 := fnd_api.g_miss_char;
                     l_rel_hist_csr.new_attribute14 := l_new_relship_rec.attribute14;
             END IF;
          --
             IF    ( l_rel_hist_csr.old_attribute15 IS NULL
                AND  l_rel_hist_csr.new_attribute15 IS NULL ) THEN
                     IF  ( l_new_relship_rec.attribute15 = l_old_relship_rec.attribute15 )
                      OR ( l_new_relship_rec.attribute15 = fnd_api.g_miss_char ) THEN
                           l_rel_hist_csr.old_attribute15 := NULL;
                           l_rel_hist_csr.new_attribute15 := NULL;
                     ELSE
                           l_rel_hist_csr.old_attribute15 := fnd_api.g_miss_char;
                           l_rel_hist_csr.new_attribute15 := l_new_relship_rec.attribute15;
                     END IF;
             ELSE
                     l_rel_hist_csr.old_attribute15 := fnd_api.g_miss_char;
                     l_rel_hist_csr.new_attribute15 := l_new_relship_rec.attribute15;
             END IF;
          --

           csi_ii_relationships_h_pkg.update_row(
            p_relationship_history_id       =>  l_rel_hist_id                        ,
            p_relationship_id               =>  fnd_api.g_miss_num                   ,
            p_transaction_id                =>  fnd_api.g_miss_num                   ,
            p_old_subject_id                =>  l_rel_hist_csr.old_subject_id        ,
            p_new_subject_id                =>  l_rel_hist_csr.new_subject_id        ,
            p_old_position_reference        =>  l_rel_hist_csr.old_position_reference,
            p_new_position_reference        =>  l_rel_hist_csr.new_position_reference,
            p_old_active_start_date         =>  l_rel_hist_csr.old_active_start_date ,
            p_new_active_start_date         =>  l_rel_hist_csr.new_active_start_date ,
            p_old_active_end_date           =>  l_rel_hist_csr.old_active_end_date   ,
            p_new_active_end_date           =>  l_rel_hist_csr.new_active_end_date   ,
            p_old_mandatory_flag            =>  l_rel_hist_csr.old_mandatory_flag    ,
            p_new_mandatory_flag            =>  l_rel_hist_csr.new_mandatory_flag    ,
            p_old_context                   =>  l_rel_hist_csr.old_context           ,
            p_new_context                   =>  l_rel_hist_csr.new_context           ,
            p_old_attribute1                =>  l_rel_hist_csr.old_attribute1        ,
            p_new_attribute1                =>  l_rel_hist_csr.new_attribute1        ,
            p_old_attribute2                =>  l_rel_hist_csr.old_attribute2        ,
            p_new_attribute2                =>  l_rel_hist_csr.new_attribute2        ,
            p_old_attribute3                =>  l_rel_hist_csr.old_attribute3        ,
            p_new_attribute3                =>  l_rel_hist_csr.new_attribute3        ,
            p_old_attribute4                =>  l_rel_hist_csr.old_attribute4        ,
            p_new_attribute4                =>  l_rel_hist_csr.new_attribute4        ,
            p_old_attribute5                =>  l_rel_hist_csr.old_attribute5        ,
            p_new_attribute5                =>  l_rel_hist_csr.new_attribute5        ,
            p_old_attribute6                =>  l_rel_hist_csr.old_attribute6        ,
            p_new_attribute6                =>  l_rel_hist_csr.new_attribute6        ,
            p_old_attribute7                =>  l_rel_hist_csr.old_attribute7        ,
            p_new_attribute7                =>  l_rel_hist_csr.new_attribute7        ,
            p_old_attribute8                =>  l_rel_hist_csr.old_attribute8        ,
            p_new_attribute8                =>  l_rel_hist_csr.new_attribute8        ,
            p_old_attribute9                =>  l_rel_hist_csr.old_attribute9        ,
            p_new_attribute9                =>  l_rel_hist_csr.new_attribute9        ,
            p_old_attribute10               =>  l_rel_hist_csr.old_attribute10       ,
            p_new_attribute10               =>  l_rel_hist_csr.new_attribute10       ,
            p_old_attribute11               =>  l_rel_hist_csr.old_attribute11       ,
            p_new_attribute11               =>  l_rel_hist_csr.new_attribute11       ,
            p_old_attribute12               =>  l_rel_hist_csr.old_attribute12       ,
            p_new_attribute12               =>  l_rel_hist_csr.new_attribute12       ,
            p_old_attribute13               =>  l_rel_hist_csr.old_attribute13       ,
            p_new_attribute13               =>  l_rel_hist_csr.new_attribute13       ,
            p_old_attribute14               =>  l_rel_hist_csr.old_attribute14       ,
            p_new_attribute14               =>  l_rel_hist_csr.new_attribute14       ,
            p_old_attribute15               =>  l_rel_hist_csr.old_attribute15       ,
            p_new_attribute15               =>  l_rel_hist_csr.new_attribute15       ,
            p_full_dump_flag                =>  fnd_api.g_miss_char                  ,
            p_created_by                    =>  fnd_api.g_miss_num                   ,
            p_creation_date                 =>  fnd_api.g_miss_date                  ,
            p_last_updated_by               =>  fnd_global.user_id                   ,
            p_last_update_date              =>  SYSDATE                              ,
            p_last_update_login             =>  fnd_global.conc_login_id             ,
            p_object_version_number         =>  fnd_api.g_miss_num );
         END IF;

       EXCEPTION
         WHEN NO_DATA_FOUND THEN
         IF MOD(l_old_relship_rec.object_version_number+1,l_full_dump)=0 THEN

           csi_ii_relationships_h_pkg.insert_row(
            px_relationship_history_id      =>  l_relship_hist_rec.relationship_history_id,
            p_relationship_id               =>  l_old_relship_rec.relationship_id,
            p_transaction_id                =>  l_transaction_id,
            p_old_subject_id                =>  l_old_relship_rec.subject_id,
            p_new_subject_id                =>  l_new_relship_rec.subject_id,
            p_old_position_reference        =>  l_old_relship_rec.position_reference,
            p_new_position_reference        =>  l_new_relship_rec.position_reference,
            p_old_active_start_date         =>  l_old_relship_rec.active_start_date,
            p_new_active_start_date         =>  l_new_relship_rec.active_start_date,
            p_old_active_end_date           =>  l_old_relship_rec.active_end_date,
            p_new_active_end_date           =>  l_new_relship_rec.active_end_date,
            p_old_mandatory_flag            =>  l_old_relship_rec.mandatory_flag,
            p_new_mandatory_flag            =>  l_new_relship_rec.mandatory_flag,
            p_old_context                   =>  l_old_relship_rec.context,
            p_new_context                   =>  l_new_relship_rec.context,
            p_old_attribute1                =>  l_old_relship_rec.attribute1,
            p_new_attribute1                =>  l_new_relship_rec.attribute1,
            p_old_attribute2                =>  l_old_relship_rec.attribute2,
            p_new_attribute2                =>  l_new_relship_rec.attribute2,
            p_old_attribute3                =>  l_old_relship_rec.attribute3,
            p_new_attribute3                =>  l_new_relship_rec.attribute3,
            p_old_attribute4                =>  l_old_relship_rec.attribute4,
            p_new_attribute4                =>  l_new_relship_rec.attribute4,
            p_old_attribute5                =>  l_old_relship_rec.attribute5,
            p_new_attribute5                =>  l_new_relship_rec.attribute5,
            p_old_attribute6                =>  l_old_relship_rec.attribute6,
            p_new_attribute6                =>  l_new_relship_rec.attribute6,
            p_old_attribute7                =>  l_old_relship_rec.attribute7,
            p_new_attribute7                =>  l_new_relship_rec.attribute7,
            p_old_attribute8                =>  l_old_relship_rec.attribute8,
            p_new_attribute8                =>  l_new_relship_rec.attribute8,
            p_old_attribute9                =>  l_old_relship_rec.attribute9,
            p_new_attribute9                =>  l_new_relship_rec.attribute9,
            p_old_attribute10               =>  l_old_relship_rec.attribute10,
            p_new_attribute10               =>  l_new_relship_rec.attribute10,
            p_old_attribute11               =>  l_old_relship_rec.attribute11,
            p_new_attribute11               =>  l_new_relship_rec.attribute11,
            p_old_attribute12               =>  l_old_relship_rec.attribute12,
            p_new_attribute12               =>  l_new_relship_rec.attribute12,
            p_old_attribute13               =>  l_old_relship_rec.attribute13,
            p_new_attribute13               =>  l_new_relship_rec.attribute13,
            p_old_attribute14               =>  l_old_relship_rec.attribute14,
            p_new_attribute14               =>  l_new_relship_rec.attribute14,
            p_old_attribute15               =>  l_old_relship_rec.attribute15,
            p_new_attribute15               =>  l_new_relship_rec.attribute15,
            p_full_dump_flag                =>  'Y',
            p_created_by                    =>  fnd_global.user_id,
            p_creation_date                 =>  SYSDATE,
            p_last_updated_by               =>  fnd_global.user_id,
            p_last_update_date              =>  SYSDATE,
            p_last_update_login             =>  fnd_global.conc_login_id,
            p_object_version_number         =>  1);

         ELSE

          IF (l_new_relship_rec.subject_id = fnd_api.g_miss_num) OR
              NVL(l_old_relship_rec.subject_id,fnd_api.g_miss_num) = NVL(l_new_relship_rec.subject_id,fnd_api.g_miss_num) THEN
          --Modified code for bug 8516781, FP bug 8551918 old and new Subject_ID are always populated in CSI_II_RELATIONSHIPS_H such that
               --the parent's history always shows the subject ID which modified
               l_relship_hist_rec.old_subject_id := l_old_relship_rec.subject_id;
               l_relship_hist_rec.new_subject_id := l_old_relship_rec.subject_id;
          ELSIF
              NVL(l_old_relship_rec.subject_id,fnd_api.g_miss_num) <> NVL(l_new_relship_rec.subject_id,fnd_api.g_miss_num) THEN
               l_relship_hist_rec.old_subject_id := l_old_relship_rec.subject_id ;
               l_relship_hist_rec.new_subject_id := l_new_relship_rec.subject_id ;
          END IF;
          --
          IF (l_new_relship_rec.position_reference = fnd_api.g_miss_char) OR
              NVL(l_old_relship_rec.position_reference,fnd_api.g_miss_char) = NVL(l_new_relship_rec.position_reference,fnd_api.g_miss_char) THEN
               l_relship_hist_rec.old_position_reference := NULL;
               l_relship_hist_rec.new_position_reference := NULL;
          ELSIF
              NVL(l_old_relship_rec.position_reference,fnd_api.g_miss_char) <> NVL(l_new_relship_rec.position_reference,fnd_api.g_miss_char) THEN
               l_relship_hist_rec.old_position_reference := l_old_relship_rec.position_reference ;
               l_relship_hist_rec.new_position_reference := l_new_relship_rec.position_reference ;
          END IF;
          --
          IF (l_new_relship_rec.active_start_date = fnd_api.g_miss_date) OR
              NVL(l_old_relship_rec.active_start_date,fnd_api.g_miss_date) = NVL(l_new_relship_rec.active_start_date,fnd_api.g_miss_date) THEN
               l_relship_hist_rec.old_active_start_date := NULL;
               l_relship_hist_rec.new_active_start_date := NULL;
          ELSIF
              NVL(l_old_relship_rec.active_start_date,fnd_api.g_miss_date) <> NVL(l_new_relship_rec.active_start_date,fnd_api.g_miss_date) THEN
               l_relship_hist_rec.old_active_start_date := l_old_relship_rec.active_start_date ;
               l_relship_hist_rec.new_active_start_date := l_new_relship_rec.active_start_date ;
          END IF;
          --
          IF (l_new_relship_rec.active_end_date = fnd_api.g_miss_date) OR
              NVL(l_old_relship_rec.active_end_date,fnd_api.g_miss_date) = NVL(l_new_relship_rec.active_end_date,fnd_api.g_miss_date) THEN
               l_relship_hist_rec.old_active_end_date := NULL;
               l_relship_hist_rec.new_active_end_date := NULL;
          ELSIF
              NVL(l_old_relship_rec.active_end_date,fnd_api.g_miss_date) <> NVL(l_new_relship_rec.active_end_date,fnd_api.g_miss_date) THEN
               l_relship_hist_rec.old_active_end_date := l_old_relship_rec.active_end_date ;
               l_relship_hist_rec.new_active_end_date := l_new_relship_rec.active_end_date ;
          END IF;
          --
          IF (l_new_relship_rec.mandatory_flag = fnd_api.g_miss_char) OR
              NVL(l_old_relship_rec.mandatory_flag,fnd_api.g_miss_char) = NVL(l_new_relship_rec.mandatory_flag,fnd_api.g_miss_char) THEN
               l_relship_hist_rec.old_mandatory_flag := NULL;
               l_relship_hist_rec.new_mandatory_flag := NULL;
          ELSIF
              NVL(l_old_relship_rec.mandatory_flag,fnd_api.g_miss_char) <> NVL(l_new_relship_rec.mandatory_flag,fnd_api.g_miss_char) THEN
               l_relship_hist_rec.old_mandatory_flag := l_old_relship_rec.mandatory_flag ;
               l_relship_hist_rec.new_mandatory_flag := l_new_relship_rec.mandatory_flag ;
          END IF;
          --
          IF (l_new_relship_rec.context = fnd_api.g_miss_char) OR
              NVL(l_old_relship_rec.context,fnd_api.g_miss_char) = NVL(l_new_relship_rec.context,fnd_api.g_miss_char) THEN
               l_relship_hist_rec.old_context := NULL;
               l_relship_hist_rec.new_context := NULL;
          ELSIF
              NVL(l_old_relship_rec.context,fnd_api.g_miss_char) <> NVL(l_new_relship_rec.context,fnd_api.g_miss_char) THEN
               l_relship_hist_rec.old_context := l_old_relship_rec.context ;
               l_relship_hist_rec.new_context := l_new_relship_rec.context ;
          END IF;
          --
          IF (l_new_relship_rec.attribute1 = fnd_api.g_miss_char) OR
              NVL(l_old_relship_rec.attribute1,fnd_api.g_miss_char) = NVL(l_new_relship_rec.attribute1,fnd_api.g_miss_char) THEN
               l_relship_hist_rec.old_attribute1 := NULL;
               l_relship_hist_rec.new_attribute1 := NULL;
          ELSIF
              NVL(l_old_relship_rec.attribute1,fnd_api.g_miss_char) <> NVL(l_new_relship_rec.attribute1,fnd_api.g_miss_char) THEN
               l_relship_hist_rec.old_attribute1 := l_old_relship_rec.attribute1 ;
               l_relship_hist_rec.new_attribute1 := l_new_relship_rec.attribute1 ;
          END IF;
          --
          IF (l_new_relship_rec.attribute2 = fnd_api.g_miss_char) OR
              NVL(l_old_relship_rec.attribute2,fnd_api.g_miss_char) = NVL(l_new_relship_rec.attribute2,fnd_api.g_miss_char) THEN
               l_relship_hist_rec.old_attribute2 := NULL;
               l_relship_hist_rec.new_attribute2 := NULL;
          ELSIF
              NVL(l_old_relship_rec.attribute2,fnd_api.g_miss_char) <> NVL(l_new_relship_rec.attribute2,fnd_api.g_miss_char) THEN
               l_relship_hist_rec.old_attribute2 := l_old_relship_rec.attribute2 ;
               l_relship_hist_rec.new_attribute2 := l_new_relship_rec.attribute2 ;
          END IF;
          --
          IF (l_new_relship_rec.attribute3 = fnd_api.g_miss_char) OR
              NVL(l_old_relship_rec.attribute3,fnd_api.g_miss_char) = NVL(l_new_relship_rec.attribute3,fnd_api.g_miss_char) THEN
               l_relship_hist_rec.old_attribute3 := NULL;
               l_relship_hist_rec.new_attribute3 := NULL;
          ELSIF
              NVL(l_old_relship_rec.attribute3,fnd_api.g_miss_char) <> NVL(l_new_relship_rec.attribute3,fnd_api.g_miss_char) THEN
               l_relship_hist_rec.old_attribute3 := l_old_relship_rec.attribute3 ;
               l_relship_hist_rec.new_attribute3 := l_new_relship_rec.attribute3 ;
          END IF;
          --
          IF (l_new_relship_rec.attribute4 = fnd_api.g_miss_char) OR
              NVL(l_old_relship_rec.attribute4,fnd_api.g_miss_char) = NVL(l_new_relship_rec.attribute4,fnd_api.g_miss_char) THEN
               l_relship_hist_rec.old_attribute4 := NULL;
               l_relship_hist_rec.new_attribute4 := NULL;
          ELSIF
              NVL(l_old_relship_rec.attribute4,fnd_api.g_miss_char) <> NVL(l_new_relship_rec.attribute4,fnd_api.g_miss_char) THEN
               l_relship_hist_rec.old_attribute4 := l_old_relship_rec.attribute4 ;
               l_relship_hist_rec.new_attribute4 := l_new_relship_rec.attribute4 ;
          END IF;
          --
          IF (l_new_relship_rec.attribute5 = fnd_api.g_miss_char) OR
              NVL(l_old_relship_rec.attribute5,fnd_api.g_miss_char) = NVL(l_new_relship_rec.attribute5,fnd_api.g_miss_char) THEN
               l_relship_hist_rec.old_attribute5 := NULL;
               l_relship_hist_rec.new_attribute5 := NULL;
          ELSIF
              NVL(l_old_relship_rec.attribute5,fnd_api.g_miss_char) <> NVL(l_new_relship_rec.attribute5,fnd_api.g_miss_char) THEN
               l_relship_hist_rec.old_attribute5 := l_old_relship_rec.attribute5 ;
               l_relship_hist_rec.new_attribute5 := l_new_relship_rec.attribute5 ;
          END IF;
          --
          IF (l_new_relship_rec.attribute6 = fnd_api.g_miss_char) OR
              NVL(l_old_relship_rec.attribute6,fnd_api.g_miss_char) = NVL(l_new_relship_rec.attribute6,fnd_api.g_miss_char) THEN
               l_relship_hist_rec.old_attribute6 := NULL;
               l_relship_hist_rec.new_attribute6 := NULL;
          ELSIF
              NVL(l_old_relship_rec.attribute6,fnd_api.g_miss_char) <> NVL(l_new_relship_rec.attribute6,fnd_api.g_miss_char) THEN
               l_relship_hist_rec.old_attribute6 := l_old_relship_rec.attribute6 ;
               l_relship_hist_rec.new_attribute6 := l_new_relship_rec.attribute6 ;
          END IF;
          --
          IF (l_new_relship_rec.attribute7 = fnd_api.g_miss_char) OR
              NVL(l_old_relship_rec.attribute7,fnd_api.g_miss_char) = NVL(l_new_relship_rec.attribute7,fnd_api.g_miss_char) THEN
               l_relship_hist_rec.old_attribute7 := NULL;
               l_relship_hist_rec.new_attribute7 := NULL;
          ELSIF
              NVL(l_old_relship_rec.attribute7,fnd_api.g_miss_char) <> NVL(l_new_relship_rec.attribute7,fnd_api.g_miss_char) THEN
               l_relship_hist_rec.old_attribute7 := l_old_relship_rec.attribute7 ;
               l_relship_hist_rec.new_attribute7 := l_new_relship_rec.attribute7 ;
          END IF;
          --
          IF (l_new_relship_rec.attribute8 = fnd_api.g_miss_char) OR
              NVL(l_old_relship_rec.attribute8,fnd_api.g_miss_char) = NVL(l_new_relship_rec.attribute8,fnd_api.g_miss_char) THEN
               l_relship_hist_rec.old_attribute8 := NULL;
               l_relship_hist_rec.new_attribute8 := NULL;
          ELSIF
              NVL(l_old_relship_rec.attribute8,fnd_api.g_miss_char) <> NVL(l_new_relship_rec.attribute8,fnd_api.g_miss_char) THEN
               l_relship_hist_rec.old_attribute8 := l_old_relship_rec.attribute8 ;
               l_relship_hist_rec.new_attribute8 := l_new_relship_rec.attribute8 ;
          END IF;
          --
          IF (l_new_relship_rec.attribute9 = fnd_api.g_miss_char) OR
              NVL(l_old_relship_rec.attribute9,fnd_api.g_miss_char) = NVL(l_new_relship_rec.attribute9,fnd_api.g_miss_char) THEN
               l_relship_hist_rec.old_attribute9 := NULL;
               l_relship_hist_rec.new_attribute9 := NULL;
          ELSIF
              NVL(l_old_relship_rec.attribute9,fnd_api.g_miss_char) <> NVL(l_new_relship_rec.attribute9,fnd_api.g_miss_char) THEN
               l_relship_hist_rec.old_attribute9 := l_old_relship_rec.attribute9 ;
               l_relship_hist_rec.new_attribute9 := l_new_relship_rec.attribute9 ;
          END IF;
          --
          IF (l_new_relship_rec.attribute10 = fnd_api.g_miss_char) OR
              NVL(l_old_relship_rec.attribute10,fnd_api.g_miss_char) = NVL(l_new_relship_rec.attribute10,fnd_api.g_miss_char) THEN
               l_relship_hist_rec.old_attribute10 := NULL;
               l_relship_hist_rec.new_attribute10 := NULL;
          ELSIF
              NVL(l_old_relship_rec.attribute10,fnd_api.g_miss_char) <> NVL(l_new_relship_rec.attribute10,fnd_api.g_miss_char) THEN
               l_relship_hist_rec.old_attribute10 := l_old_relship_rec.attribute10 ;
               l_relship_hist_rec.new_attribute10 := l_new_relship_rec.attribute10 ;
          END IF;
          --
          IF (l_new_relship_rec.attribute11 = fnd_api.g_miss_char) OR
              NVL(l_old_relship_rec.attribute11,fnd_api.g_miss_char) = NVL(l_new_relship_rec.attribute11,fnd_api.g_miss_char) THEN
               l_relship_hist_rec.old_attribute11 := NULL;
               l_relship_hist_rec.new_attribute11 := NULL;
          ELSIF
              NVL(l_old_relship_rec.attribute11,fnd_api.g_miss_char) <> NVL(l_new_relship_rec.attribute11,fnd_api.g_miss_char) THEN
               l_relship_hist_rec.old_attribute11 := l_old_relship_rec.attribute11 ;
               l_relship_hist_rec.new_attribute11 := l_new_relship_rec.attribute11 ;
          END IF;
          --
          IF (l_new_relship_rec.attribute12 = fnd_api.g_miss_char) OR
              NVL(l_old_relship_rec.attribute12,fnd_api.g_miss_char) = NVL(l_new_relship_rec.attribute12,fnd_api.g_miss_char) THEN
               l_relship_hist_rec.old_attribute12 := NULL;
               l_relship_hist_rec.new_attribute12 := NULL;
          ELSIF
              NVL(l_old_relship_rec.attribute12,fnd_api.g_miss_char) <> NVL(l_new_relship_rec.attribute12,fnd_api.g_miss_char) THEN
               l_relship_hist_rec.old_attribute12 := l_old_relship_rec.attribute12 ;
               l_relship_hist_rec.new_attribute12 := l_new_relship_rec.attribute12 ;
          END IF;
          --
          IF (l_new_relship_rec.attribute13 = fnd_api.g_miss_char) OR
              NVL(l_old_relship_rec.attribute13,fnd_api.g_miss_char) = NVL(l_new_relship_rec.attribute13,fnd_api.g_miss_char) THEN
               l_relship_hist_rec.old_attribute13 := NULL;
               l_relship_hist_rec.new_attribute13 := NULL;
          ELSIF
              NVL(l_old_relship_rec.attribute13,fnd_api.g_miss_char) <> NVL(l_new_relship_rec.attribute13,fnd_api.g_miss_char) THEN
               l_relship_hist_rec.old_attribute13 := l_old_relship_rec.attribute13 ;
               l_relship_hist_rec.new_attribute13 := l_new_relship_rec.attribute13 ;
          END IF;
          --
          IF (l_new_relship_rec.attribute14 = fnd_api.g_miss_char) OR
              NVL(l_old_relship_rec.attribute14,fnd_api.g_miss_char) = NVL(l_new_relship_rec.attribute14,fnd_api.g_miss_char) THEN
               l_relship_hist_rec.old_attribute14 := NULL;
               l_relship_hist_rec.new_attribute14 := NULL;
          ELSIF
              NVL(l_old_relship_rec.attribute14,fnd_api.g_miss_char) <> NVL(l_new_relship_rec.attribute14,fnd_api.g_miss_char) THEN
               l_relship_hist_rec.old_attribute14 := l_old_relship_rec.attribute14 ;
               l_relship_hist_rec.new_attribute14 := l_new_relship_rec.attribute14 ;
          END IF;
          --
          IF (l_new_relship_rec.attribute15 = fnd_api.g_miss_char) OR
              NVL(l_old_relship_rec.attribute15,fnd_api.g_miss_char) = NVL(l_new_relship_rec.attribute15,fnd_api.g_miss_char) THEN
               l_relship_hist_rec.old_attribute15 := NULL;
               l_relship_hist_rec.new_attribute15 := NULL;
          ELSIF
              NVL(l_old_relship_rec.attribute15,fnd_api.g_miss_char) <> NVL(l_new_relship_rec.attribute15,fnd_api.g_miss_char) THEN
               l_relship_hist_rec.old_attribute15 := l_old_relship_rec.attribute15 ;
               l_relship_hist_rec.new_attribute15 := l_new_relship_rec.attribute15 ;
          END IF;
          --
          IF p_flag = 'EXPIRE'
          THEN
             l_relship_hist_rec.new_active_end_date := p_sysdate;
          END IF;

        csi_ii_relationships_h_pkg.insert_row(
            px_relationship_history_id      =>  l_relship_hist_rec.relationship_history_id,
            p_relationship_id               =>  l_old_relship_rec.relationship_id,
            p_transaction_id                =>  l_transaction_id,
            p_old_subject_id                =>  l_relship_hist_rec.old_subject_id,
            p_new_subject_id                =>  l_relship_hist_rec.new_subject_id,
            p_old_position_reference        =>  l_relship_hist_rec.old_position_reference,
            p_new_position_reference        =>  l_relship_hist_rec.new_position_reference,
            p_old_active_start_date         =>  l_relship_hist_rec.old_active_start_date,
            p_new_active_start_date         =>  l_relship_hist_rec.new_active_start_date,
            p_old_active_end_date           =>  l_relship_hist_rec.old_active_end_date,
            p_new_active_end_date           =>  l_relship_hist_rec.new_active_end_date,
            p_old_mandatory_flag            =>  l_relship_hist_rec.old_mandatory_flag,
            p_new_mandatory_flag            =>  l_relship_hist_rec.new_mandatory_flag,
            p_old_context                   =>  l_relship_hist_rec.old_context,
            p_new_context                   =>  l_relship_hist_rec.new_context,
            p_old_attribute1                =>  l_relship_hist_rec.old_attribute1,
            p_new_attribute1                =>  l_relship_hist_rec.new_attribute1,
            p_old_attribute2                =>  l_relship_hist_rec.old_attribute2,
            p_new_attribute2                =>  l_relship_hist_rec.new_attribute2,
            p_old_attribute3                =>  l_relship_hist_rec.old_attribute3,
            p_new_attribute3                =>  l_relship_hist_rec.new_attribute3,
            p_old_attribute4                =>  l_relship_hist_rec.old_attribute4,
            p_new_attribute4                =>  l_relship_hist_rec.new_attribute4,
            p_old_attribute5                =>  l_relship_hist_rec.old_attribute5,
            p_new_attribute5                =>  l_relship_hist_rec.new_attribute5,
            p_old_attribute6                =>  l_relship_hist_rec.old_attribute6,
            p_new_attribute6                =>  l_relship_hist_rec.new_attribute6,
            p_old_attribute7                =>  l_relship_hist_rec.old_attribute7,
            p_new_attribute7                =>  l_relship_hist_rec.new_attribute7,
            p_old_attribute8                =>  l_relship_hist_rec.old_attribute8,
            p_new_attribute8                =>  l_relship_hist_rec.new_attribute8,
            p_old_attribute9                =>  l_relship_hist_rec.old_attribute9,
            p_new_attribute9                =>  l_relship_hist_rec.new_attribute9,
            p_old_attribute10               =>  l_relship_hist_rec.old_attribute10,
            p_new_attribute10               =>  l_relship_hist_rec.new_attribute10,
            p_old_attribute11               =>  l_relship_hist_rec.old_attribute11,
            p_new_attribute11               =>  l_relship_hist_rec.new_attribute11,
            p_old_attribute12               =>  l_relship_hist_rec.old_attribute12,
            p_new_attribute12               =>  l_relship_hist_rec.new_attribute12,
            p_old_attribute13               =>  l_relship_hist_rec.old_attribute13,
            p_new_attribute13               =>  l_relship_hist_rec.new_attribute13,
            p_old_attribute14               =>  l_relship_hist_rec.old_attribute14,
            p_new_attribute14               =>  l_relship_hist_rec.new_attribute14,
            p_old_attribute15               =>  l_relship_hist_rec.old_attribute15,
            p_new_attribute15               =>  l_relship_hist_rec.new_attribute15,
            p_full_dump_flag                =>  NULL,
            p_created_by                    =>  fnd_global.user_id,
            p_creation_date                 =>  SYSDATE,
            p_last_updated_by               =>  fnd_global.user_id,
            p_last_update_date              =>  SYSDATE,
            p_last_update_login             =>  fnd_global.conc_login_id,
            p_object_version_number         =>  1);
         END IF;
       END;
      -- End of modifications for Bug#2547034 on 09/20/02 - rtalluri
EXCEPTION
   WHEN OTHERS THEN
     x_return_status := fnd_api.g_ret_sts_error;
END;
/* ----------------------------------------------------------------------------------------------------------+
| Case1. Create/Update Relationship                                                                          |
|        Only 'COMPONENT-OF' If subject_id not null and subject_id's creation_complete_flag                  |
|    is 'Y' and relationship is mandatory then set object_id's completeness_flag to 'Y'                      |
|                                                                                                            |
| Case2. Location attribute inheritance property.                                                            |
|    Create/Update Relationship                                                                              |                                                                                           |
|    Only for 'COMPONENT-OF' relationship_type_code update location of subject_id and its children in        |
|   'COMPONENT-OF' relationship with location of object_id.                                                  |
|                                                                                                            |
|                                                                                                            |
+------------------------------------------------------------------------------------------------------------*/
PROCEDURE update_instance
(   p_api_version                IN   NUMBER,
    p_commit                     IN   VARCHAR2,
    p_init_msg_list              IN   VARCHAR2,
    p_validation_level           IN   NUMBER,
    p_ii_relationship_rec        IN   csi_datastructures_pub.ii_relationship_rec,
    p_txn_rec                    IN OUT NOCOPY csi_datastructures_pub.transaction_rec,
    p_mode                       IN   VARCHAR2,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2)
IS

/* CURSOR completeness_csr (p_subject_id IN NUMBER) IS
    SELECT  object_id
    FROM    csi_ii_relationships
    START WITH subject_id = p_subject_id
    CONNECT BY subject_id = PRIOR object_id; */

l_ii_relationship_rec        csi_datastructures_pub.ii_relationship_rec;
l_ext_attrib_values_tbl      csi_datastructures_pub.extend_attrib_values_tbl;
l_party_tbl                  csi_datastructures_pub.party_tbl;
l_account_tbl                csi_datastructures_pub.party_account_tbl;
l_pricing_attrib_tbl         csi_datastructures_pub.pricing_attribs_tbl;
l_org_assignments_tbl        csi_datastructures_pub.organization_units_tbl;
l_asset_assignment_tbl       csi_datastructures_pub.instance_asset_tbl;
l_instance_id_lst            csi_datastructures_pub.id_tbl;
l_instance_rec               csi_datastructures_pub.instance_rec;
l_instance_rec1              csi_datastructures_pub.instance_rec;
l_temp_ins_rec               csi_datastructures_pub.instance_rec;
l_dummy                      NUMBER;
l_object_version             NUMBER;
l_object_version1            NUMBER;
l_subject_id                 NUMBER;
l_item_attribute_tbl         csi_item_instance_pvt.item_attribute_tbl;
l_location_tbl               csi_item_instance_pvt.location_tbl;
l_generic_id_tbl             csi_item_instance_pvt.generic_id_tbl;
l_lookup_tbl                 csi_item_instance_pvt.lookup_tbl;
l_ins_count_rec              csi_item_instance_pvt.ins_count_rec;
l_rel_tbl                    csi_datastructures_pub.ii_relationship_tbl;
px_oks_txn_inst_tbl          oks_ibint_pub.txn_instance_tbl;
px_child_inst_tbl            csi_item_instance_grp.child_inst_tbl;
-- Begin Add Code for Siebel Genesis Project
p_ext_attrib_values_tbl      csi_datastructures_pub.extend_attrib_values_tbl;
p_party_tbl                  csi_datastructures_pub.party_tbl;
p_account_tbl                csi_datastructures_pub.party_account_tbl;
p_pricing_attrib_tbl         csi_datastructures_pub.pricing_attribs_tbl;
p_org_assignments_tbl        csi_datastructures_pub.organization_units_tbl;
p_asset_assignment_tbl       csi_datastructures_pub.instance_asset_tbl;
-- End Add Code for Siebel Genesis Project

BEGIN

       x_return_status := fnd_api.g_ret_sts_success;
       l_ii_relationship_rec := p_ii_relationship_rec;
       --
       IF l_ii_relationship_rec.relationship_id IS NOT NULL AND
          l_ii_relationship_rec.relationship_id <> FND_API.G_MISS_NUM THEN
          IF l_ii_relationship_rec.subject_id IS NULL OR
             l_ii_relationship_rec.subject_id = FND_API.G_MISS_NUM THEN
             Begin
                select subject_id
                into l_ii_relationship_rec.subject_id
                from CSI_II_RELATIONSHIPS
                where relationship_id = l_ii_relationship_rec.relationship_id;
             End;
          END IF;
          --
          IF l_ii_relationship_rec.object_id IS NULL OR
             l_ii_relationship_rec.object_id = FND_API.G_MISS_NUM THEN
             Begin
                select object_id
                into l_ii_relationship_rec.object_id
                from CSI_II_RELATIONSHIPS
                where relationship_id = l_ii_relationship_rec.relationship_id;
             End;
          END IF;
       END IF;
       --
--To handle Case 2
      IF l_ii_relationship_rec.relationship_type_code='COMPONENT-OF' THEN
        BEGIN
           l_instance_rec.instance_id := l_ii_relationship_rec.subject_id;
                SELECT object_version_number,
                       config_inst_hdr_id,
                       config_inst_item_id,
                       config_inst_rev_num
                INTO   l_object_version1,
                       l_instance_rec.config_inst_hdr_id,  -- added
                       l_instance_rec.config_inst_item_id, -- added
                       l_instance_rec.config_inst_rev_num  -- added
                FROM   csi_item_instances
                WHERE  instance_id=l_ii_relationship_rec.subject_id;
                l_instance_rec.object_version_number:=l_object_version1;
             IF p_mode='CREATE' OR p_mode='UPDATE'
             THEN
                l_instance_rec.instance_usage_code :='IN_RELATIONSHIP';
             END IF;
                SELECT active_end_date,
		       instance_status_id, --added for bug7164722
                       location_type_code,
                       location_id,
                       inv_organization_id,
                       inv_subinventory_name,
                       inv_locator_id,
                       pa_project_id,
                       pa_project_task_id,
                       in_transit_order_line_id,
                       wip_job_id,
                       po_order_line_id,
                       operational_status_code,
                       install_location_id,
                       install_location_type_code
                INTO   l_instance_rec.active_end_date,
		       l_instance_rec.instance_status_id, --added for bug7164722
                       l_instance_rec.location_type_code,
                       l_instance_rec.location_id,
                       l_instance_rec.inv_organization_id,
                       l_instance_rec.inv_subinventory_name,
                       l_instance_rec.inv_locator_id,
                       l_instance_rec.pa_project_id,
                       l_instance_rec.pa_project_task_id,
                       l_instance_rec.in_transit_order_line_id,
                       l_instance_rec.wip_job_id,
                       l_instance_rec.po_order_line_id,
                       l_instance_rec.operational_status_code,
                       l_instance_rec.install_location_id,
                       l_instance_rec.install_location_type_code
                FROM   csi_item_instances
                WHERE  instance_id=l_ii_relationship_rec.object_id;

                -- Begin Add Code for Siebel Genesis Project
                csi_item_instance_pub.update_item_instance
                 (   p_api_version             =>  p_api_version
                    ,p_commit                  =>  p_commit
                    ,p_init_msg_list           =>  p_init_msg_list
                    ,p_validation_level        =>  p_validation_level
                    ,p_instance_rec            =>  l_instance_rec
                    ,p_ext_attrib_values_tbl   =>  p_ext_attrib_values_tbl
                    ,p_party_tbl               =>  p_party_tbl
                    ,p_account_tbl             =>  p_account_tbl
                    ,p_pricing_attrib_tbl      =>  p_pricing_attrib_tbl
                    ,p_org_assignments_tbl     =>  p_org_assignments_tbl
                    ,p_asset_assignment_tbl    =>  p_asset_assignment_tbl
                    ,p_txn_rec                 =>  p_txn_rec
                    ,x_instance_id_lst         =>  l_instance_id_lst
                    ,x_return_status           =>  x_return_status
                    ,x_msg_count               =>  x_msg_count
                    ,x_msg_data                =>  x_msg_data
                );
              /*csi_item_instance_pvt.update_item_instance
                 (   p_api_version             =>  p_api_version
                    ,p_commit                  =>  p_commit
                    ,p_init_msg_list           =>  p_init_msg_list
                    ,p_validation_level        =>  p_validation_level
                    ,p_instance_rec            =>  l_instance_rec
                    ,p_txn_rec                 =>  p_txn_rec
                    ,x_instance_id_lst         =>  l_instance_id_lst
                    ,x_return_status           =>  x_return_status
                    ,x_msg_count               =>  x_msg_count
                    ,x_msg_data                =>  x_msg_data
                    ,p_item_attribute_tbl      =>  l_item_attribute_tbl
                    ,p_location_tbl            =>  l_location_tbl
                    ,p_generic_id_tbl          =>  l_generic_id_tbl
                    ,p_lookup_tbl              =>  l_lookup_tbl
                    ,p_ins_count_rec           =>  l_ins_count_rec
                    ,p_oks_txn_inst_tbl        =>  px_oks_txn_inst_tbl
                    ,p_child_inst_tbl          =>  px_child_inst_tbl
                );*/
                -- End Add Code for Siebel Genesis Project

          IF NOT(x_return_status = fnd_api.g_ret_sts_success) THEN
                        fnd_message.set_name('CSI','CSI_FAILED_TO_VALIDATE_INS');
                        fnd_message.set_token('instance_id',l_instance_rec.instance_id);
                        fnd_msg_pub.add;
                    RAISE fnd_api.g_exc_error;
          END IF;

         EXCEPTION
         WHEN OTHERS THEN
            NULL;
         END;

       END IF;

--To handle Case 1
      BEGIN
         --FOR update_instance_csr IN completeness_csr(l_ii_relationship_rec.subject_id)
         csi_ii_relationships_pvt.Get_Immediate_Parents
            ( p_subject_id        => l_ii_relationship_rec.subject_id,
              p_rel_type_code     => 'COMPONENT-OF',
              p_rel_tbl           => l_rel_tbl
            );
         IF l_rel_tbl.count > 0 THEN
            FOR j in l_rel_tbl.FIRST .. l_rel_tbl.LAST LOOP
               l_subject_id:=NULL;
               BEGIN
                  SELECT subject_id
                  INTO   l_subject_id
                  FROM   csi_ii_relationships
                  WHERE  object_id = l_rel_tbl(j).object_id
                  AND    mandatory_flag = 'Y'
                  AND    relationship_type_code='COMPONENT-OF'
                  AND    ROWNUM=1;
               EXCEPTION
                  WHEN OTHERS THEN
                     l_subject_id:=NULL;
               END;
               --
               IF l_subject_id IS NOT NULL
               THEN
                  SELECT COUNT(*)
                  INTO   l_dummy
                  FROM   csi_item_instances
                  WHERE  instance_id IN (  SELECT subject_id
                                           FROM   csi_ii_relationships
                                           WHERE  object_id = l_rel_tbl(j).object_id
                                           AND    mandatory_flag = 'Y'
                                           AND    relationship_type_code='COMPONENT-OF'
                                        )
                  AND    creation_complete_flag = 'N';

                  IF nvl(l_dummy,fnd_api.g_miss_num) > 0 THEN
                     EXIT;
                  ELSE
                     SELECT object_version_number,
                            config_inst_hdr_id, --added
                            config_inst_item_id, --added
                            config_inst_rev_num
                     INTO   l_object_version,
                            l_instance_rec1.config_inst_hdr_id, --added
                            l_instance_rec1.config_inst_item_id, --added
                            l_instance_rec1.config_inst_rev_num --added
                     FROM   csi_item_instances
                     WHERE  instance_id = l_rel_tbl(j).object_id;

                     l_instance_rec1:=l_temp_ins_rec;
                     l_instance_rec1.object_version_number:=l_object_version;
                     l_instance_rec1.instance_id:=l_rel_tbl(j).object_id;
                     l_instance_rec1.completeness_flag:='Y';

                     csi_item_instance_pvt.update_item_instance
                        (   p_api_version             =>  p_api_version
                           ,p_commit                  =>  p_commit
                           ,p_init_msg_list           =>  p_init_msg_list
                           ,p_validation_level        =>  p_validation_level
                           ,p_instance_rec            =>  l_instance_rec1
                           ,p_txn_rec                 =>  p_txn_rec
                           ,x_instance_id_lst         =>  l_instance_id_lst
                           ,x_return_status           =>  x_return_status
                           ,x_msg_count               =>  x_msg_count
                           ,x_msg_data                =>  x_msg_data
                           ,p_item_attribute_tbl      =>  l_item_attribute_tbl
                           ,p_location_tbl            =>  l_location_tbl
                           ,p_generic_id_tbl          =>  l_generic_id_tbl
                           ,p_lookup_tbl              =>  l_lookup_tbl
                           ,p_ins_count_rec           =>  l_ins_count_rec
                           ,p_oks_txn_inst_tbl        =>  px_oks_txn_inst_tbl
                           ,p_child_inst_tbl          =>  px_child_inst_tbl
                       );

                     IF NOT(x_return_status = fnd_api.g_ret_sts_success) THEN
                        fnd_message.set_name('CSI','CSI_FAILED_TO_VALIDATE_INS');
                        fnd_message.set_token('instance_id',l_instance_rec1.instance_id);
                        fnd_msg_pub.add;
                        RAISE fnd_api.g_exc_error;
                     END IF;

                  END IF;
               END IF;
            END LOOP;
         END IF; -- l_rel_tbl count check
      EXCEPTION
         WHEN OTHERS THEN
           NULL;
      END;
END update_instance;

-- Added by sk on 9-Apr-02 for bug 2304221
/* ----------------------------------------------------------------------------------------------------------+
|        During creation of a relationship between 2 instances then parent owner party and owner account(in  |
|        case of external) has to inherited to the children.                                                 |
|        Code is applied only for 'COMPONENT-OF' relationship_type_code                                      |                                                                                                            |
+------------------------------------------------------------------------------------------------------------*/

PROCEDURE update_party_account
(   p_api_version                IN   NUMBER,
    p_commit                     IN   VARCHAR2,
    p_init_msg_list              IN   VARCHAR2,
    p_validation_level           IN   NUMBER,
    p_ii_relationship_rec        IN   csi_datastructures_pub.ii_relationship_rec,
    p_txn_rec                    IN OUT NOCOPY csi_datastructures_pub.transaction_rec,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2)
IS
l_ext_attrib_values_tbl      csi_datastructures_pub.extend_attrib_values_tbl;
l_party_tbl                  csi_datastructures_pub.party_tbl;
l_account_tbl                csi_datastructures_pub.party_account_tbl;
l_pricing_attrib_tbl         csi_datastructures_pub.pricing_attribs_tbl;
l_org_assignments_tbl        csi_datastructures_pub.organization_units_tbl;
l_asset_assignment_tbl       csi_datastructures_pub.instance_asset_tbl;
l_instance_id_lst            csi_datastructures_pub.id_tbl;
l_instance_rec               csi_datastructures_pub.instance_rec;
l_subject_id                 NUMBER;
l_record_found               VARCHAR2(1):= fnd_api.g_true;
BEGIN
 IF p_ii_relationship_rec.relationship_type_code='COMPONENT-OF' THEN

      BEGIN
            SELECT  cp.party_id
                   ,cp.party_source_table
                   ,cp.contact_flag
                   ,cp.relationship_type_code
                   ,ca.party_account_id
                   ,ca.relationship_type_code
            INTO    l_party_tbl(1).party_id
                   ,l_party_tbl(1).party_source_table
                   ,l_party_tbl(1).contact_flag
                   ,l_party_tbl(1).relationship_type_code
                   ,l_account_tbl(1).party_account_id
                   ,l_account_tbl(1).relationship_type_code
            FROM   csi_i_parties cp,
                   csi_ip_accounts ca
            WHERE  cp.instance_id = p_ii_relationship_rec.object_id
            AND    cp.instance_party_id = ca.instance_party_id
            AND    cp.relationship_type_code = 'OWNER'
            AND    cp.relationship_type_code = ca.relationship_type_code
            AND    (cp.active_end_date IS NULL OR cp.active_end_date > SYSDATE)
            AND    (ca.active_end_date IS NULL OR ca.active_end_date > SYSDATE);
      EXCEPTION
        WHEN OTHERS THEN
         l_record_found := fnd_api.g_false;
      END;

         BEGIN
            SELECT  instance_party_id
                   ,object_version_number
            INTO    l_party_tbl(1).instance_party_id
                   ,l_party_tbl(1).object_version_number
            FROM    csi_i_parties
            WHERE   instance_id = p_ii_relationship_rec.subject_id
            AND     relationship_type_code = 'OWNER';
            l_account_tbl(1).instance_party_id := l_party_tbl(1).instance_party_id;
        EXCEPTION
          WHEN OTHERS THEN
            NULL;
        END;

      IF l_record_found = fnd_api.g_true
      THEN
        BEGIN
            SELECT  instance_id
                   ,object_version_number
            INTO    l_instance_rec.instance_id
                   ,l_instance_rec.object_version_number
            FROM    csi_item_instances
            WHERE   instance_id = p_ii_relationship_rec.subject_id;

            l_party_tbl(1).instance_id := p_ii_relationship_rec.subject_id;
            l_account_tbl(1).parent_tbl_index := 1;
        EXCEPTION
          WHEN OTHERS THEN
            l_record_found := fnd_api.g_false;
        END;
      END IF;


        IF l_record_found = fnd_api.g_true
        THEN
                 csi_item_instance_pub.update_item_instance
                          ( p_api_version           =>  p_api_version
                           ,p_commit                =>  p_commit
                           ,p_init_msg_list         =>  p_init_msg_list
                           ,p_validation_level      =>  p_validation_level
                           ,p_instance_rec          =>  l_instance_rec
                           ,p_ext_attrib_values_tbl =>  l_ext_attrib_values_tbl
                           ,p_party_tbl             =>  l_party_tbl
                           ,p_account_tbl           =>  l_account_tbl
                           ,p_pricing_attrib_tbl    =>  l_pricing_attrib_tbl
                           ,p_org_assignments_tbl   =>  l_org_assignments_tbl
                           ,p_asset_assignment_tbl  =>  l_asset_assignment_tbl
                           ,p_txn_rec               =>  p_txn_rec
                           ,x_instance_id_lst       =>  l_instance_id_lst
                           ,x_return_status         =>  x_return_status
                           ,x_msg_count             =>  x_msg_count
                           ,x_msg_data              =>  x_msg_data
                           );

                IF NOT(x_return_status = fnd_api.g_ret_sts_success)
                THEN
                     fnd_message.set_name('CSI','CSI_FAILED_TO_VALIDATE_INS');
                     fnd_message.set_token('instance_id',l_instance_rec.instance_id);
                     fnd_msg_pub.add;
                    RAISE fnd_api.g_exc_error;
                END IF;
        END IF;
 END IF;
END update_party_account;

-- End addition by sk on 9-Apr-02 for bug 2304221


-- hint: primary key needs TO be returned.
PROCEDURE create_relationship(
    p_api_version                IN   NUMBER,
    p_commit                     IN   VARCHAR2,
    p_init_msg_list              IN   VARCHAR2,
    p_validation_level           IN   NUMBER,
    p_relationship_tbl        IN OUT NOCOPY csi_datastructures_pub.ii_relationship_tbl,
    p_txn_rec                    IN OUT NOCOPY csi_datastructures_pub.transaction_rec,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2
    )
 IS


l_api_name                   CONSTANT VARCHAR2(30) := 'create_relationship';
l_api_version                CONSTANT NUMBER       := 1.0;
l_return_status_full                  VARCHAR2(1);
l_access_flag                         VARCHAR2(1);
l_ii_relationship_rec                 csi_datastructures_pub.ii_relationship_rec;
l_line_count                          NUMBER;
l_relationship_id                     NUMBER;
l_debug_level                         NUMBER;
l_relship_history_id                  NUMBER;
l_msg_data                            VARCHAR2(2000);  -- Added by sguthiva for bug 2373109
l_msg_index                           NUMBER;          -- Added by sguthiva for bug 2373109
l_msg_count                           NUMBER;          -- Added by sguthiva for bug 2373109
l_exists                              VARCHAR2(1);

-- Added for cascade ownership change bug 2972082
l_ext_attrib_values_tbl               csi_datastructures_pub.extend_attrib_values_tbl;
l_party_tbl                           csi_datastructures_pub.party_tbl;
l_account_tbl                         csi_datastructures_pub.party_account_tbl;
l_temp_party_tbl                      csi_datastructures_pub.party_tbl;
l_temp_account_tbl                    csi_datastructures_pub.party_account_tbl;
l_pricing_attrib_tbl                  csi_datastructures_pub.pricing_attribs_tbl;
l_org_assignments_tbl                 csi_datastructures_pub.organization_units_tbl;
l_asset_assignment_tbl                csi_datastructures_pub.instance_asset_tbl;
l_instance_id_lst                     csi_datastructures_pub.id_tbl;
l_instance_rec                        csi_datastructures_pub.instance_rec;
l_cascade_instance_rec                csi_datastructures_pub.instance_rec;
-- End addition for cascade ownership changes bug 2972082

 BEGIN
      -- standard start of api savepoint
      SAVEPOINT create_relationship_pvt;

      -- standard call to check for call compatibility.
      IF NOT fnd_api.compatible_api_call ( l_api_version,
                                           p_api_version,
                                           l_api_name,
                                           g_pkg_name)
      THEN
          RAISE fnd_api.g_exc_unexpected_error;
      END IF;


      -- initialize message list if p_init_msg_list is set to true.
      IF fnd_api.to_boolean( p_init_msg_list )
      THEN
          fnd_msg_pub.initialize;
      END IF;

      -- initialize api return status to success
      x_return_status := fnd_api.g_ret_sts_success;

      l_debug_level:=fnd_profile.value('CSI_DEBUG_LEVEL');
    IF (l_debug_level > 0) THEN
          CSI_gen_utility_pvt.put_line( 'create_relationship');
    END IF;

    IF (l_debug_level > 1) THEN


             CSI_gen_utility_pvt.put_line(
                            p_api_version             ||'-'||
                            p_commit                  ||'-'||
                            p_init_msg_list           ||'-'||
                            p_validation_level        );

         csi_gen_utility_pvt.dump_rel_tbl(p_relationship_tbl);
         csi_gen_utility_pvt.dump_txn_rec(p_txn_rec);

    END IF;

      -- invoke validation procedures
      validate_ii_relationships(
          p_init_msg_list           => fnd_api.g_false,
          p_validation_level        => p_validation_level,
          p_validation_mode         => 'CREATE',
          p_ii_relationship_tbl     => p_relationship_tbl,
          x_return_status           => x_return_status,
          x_msg_count               => x_msg_count,
          x_msg_data                => x_msg_data);


      IF x_return_status<>fnd_api.g_ret_sts_success THEN
          RAISE fnd_api.g_exc_error;
      END IF;



        l_line_count := p_relationship_tbl.count;

  FOR l_count IN 1..l_line_count LOOP
    IF ( (p_relationship_tbl(l_count).mandatory_flag IS NULL) OR
         (p_relationship_tbl(l_count).mandatory_flag = fnd_api.g_miss_char) ) THEN
             p_relationship_tbl(l_count).mandatory_flag:='N';
    END IF;

        --Added for MACD lock functionality
        IF p_relationship_tbl(l_count).object_id IS NOT NULL AND
           p_relationship_tbl(l_count).object_id <> fnd_api.g_miss_num
        THEN
           IF csi_item_instance_pvt.check_item_instance_lock
                                      ( p_instance_id => p_relationship_tbl(l_count).object_id)
           THEN
            IF p_txn_rec.transaction_type_id NOT IN (51,53,54,401)
            THEN
             FND_MESSAGE.SET_NAME('CSI','CSI_LOCKED_INSTANCE');
             FND_MESSAGE.SET_TOKEN('INSTANCE_ID',p_relationship_tbl(l_count).object_id);
             FND_MSG_PUB.ADD;
             RAISE FND_API.G_EXC_ERROR;
            END IF;
           END IF;
        END IF;
        IF p_relationship_tbl(l_count).subject_id IS NOT NULL AND
           p_relationship_tbl(l_count).subject_id <> fnd_api.g_miss_num
        THEN
           IF csi_item_instance_pvt.check_item_instance_lock
                                      ( p_instance_id => p_relationship_tbl(l_count).subject_id)
           THEN
            IF p_txn_rec.transaction_type_id NOT IN (51,53,54,401)
            THEN
             FND_MESSAGE.SET_NAME('CSI','CSI_LOCKED_INSTANCE');
             FND_MESSAGE.SET_TOKEN('INSTANCE_ID',p_relationship_tbl(l_count).subject_id);
             FND_MSG_PUB.ADD;
             RAISE FND_API.G_EXC_ERROR;
            END IF;
           END IF;
        END IF;
        -- End addition for MACD lock functionality


    /* Added for cyclic relationships to skip validations for 'CONNECTED-TO' */
    IF p_relationship_tbl(l_count).relationship_type_code <> 'CONNECTED-TO'
    THEN
       IF subject_exists(p_subject_id        => p_relationship_tbl(l_count).subject_id,
                         p_relship_type_code => p_relationship_tbl(l_count).relationship_type_code,
                         p_relationship_id   => Null,
                         p_mode              => 'CREATE' )
       THEN
          x_return_status:=fnd_api.g_ret_sts_success;
       ELSE
          x_return_status:=fnd_api.g_ret_sts_error;
          RAISE fnd_api.g_exc_error;
       END IF;

       IF ((x_return_status=fnd_api.g_ret_sts_success) AND
           (p_relationship_tbl(l_count).object_id IS NOT NULL) ) THEN
           csi_ii_relationships_pvt.check_for_object
            (p_subject_id  =>p_relationship_tbl(l_count).subject_id,
              p_object_id              =>p_relationship_tbl(l_count).object_id,
              p_relationship_type_code =>p_relationship_tbl(l_count).relationship_type_code,
              x_return_status          =>x_return_status,
              x_msg_count              =>x_msg_count,
              x_msg_data               =>x_msg_data
           );
         IF x_return_status<>fnd_api.g_ret_sts_success THEN
            RAISE fnd_api.g_exc_error;
         END IF;
       END IF;
    END IF; /* end of additional for cyclic relationship */
    /* Another one for cyclic relationship */
    /* added this to aviod creating 'CONNECTED-TO' relationship in the reverse direction */
   IF p_relationship_tbl(l_count).relationship_type_code='CONNECTED-TO' THEN
      IF relationship_not_exists(p_relationship_tbl(l_count).subject_id,
                                 p_relationship_tbl(l_count).object_id,
                                 p_relationship_tbl(l_count).relationship_type_code,
                                 'CREATE',
                                 fnd_api.g_miss_num)
      THEN
         x_return_status:=fnd_api.g_ret_sts_success;
      ELSE
         x_return_status:=fnd_api.g_ret_sts_error;
         RAISE fnd_api.g_exc_error;
      END IF;
      -- Start of att enhancements by sguthiva
      IF csi_ii_relationships_pvt.Is_link_type (p_instance_id => p_relationship_tbl(l_count).object_id )
      THEN
	 IF csi_ii_relationships_pvt.relationship_for_link
                                  ( p_instance_id     => p_relationship_tbl(l_count).object_id
				   ,p_mode            => 'CREATE'
				   ,p_relationship_id => NULL )
	 THEN
	   fnd_message.set_name('CSI','CSI_LINK_EXISTS');
	   fnd_message.set_token('INSTANCE_ID',p_relationship_tbl(l_count).object_id);
	   fnd_msg_pub.add;
	   RAISE fnd_api.g_exc_error;
	 END IF;
      END IF;

      IF csi_ii_relationships_pvt.Is_link_type (p_instance_id => p_relationship_tbl(l_count).subject_id )
      THEN
	 IF csi_ii_relationships_pvt.relationship_for_link
                                  ( p_instance_id     => p_relationship_tbl(l_count).subject_id
				   ,p_mode            => 'CREATE'
				   ,p_relationship_id => NULL )
	 THEN
	   fnd_message.set_name('CSI','CSI_LINK_EXISTS');
	   fnd_message.set_token('INSTANCE_ID',p_relationship_tbl(l_count).subject_id);
	   fnd_msg_pub.add;
	   RAISE fnd_api.g_exc_error;
	 END IF;
      END IF;
      -- End of att enhancements by sguthiva
   END IF;

   /* end of cyclic relationship */

   IF ((p_relationship_tbl(l_count).active_start_date IS NULL) OR
       (p_relationship_tbl(l_count).active_start_date = FND_API.G_MISS_DATE))
   THEN
        p_relationship_tbl(l_count).active_start_date := SYSDATE;
   END IF;

      IF x_return_status=fnd_api.g_ret_sts_success THEN
         -- srramakr Moved the Update_instance call before the table handler Bug # 3296009
         update_instance
            (   p_api_version                =>     p_api_version,
                p_commit                     =>     fnd_api.g_false,
                p_init_msg_list              =>     p_init_msg_list,
                p_validation_level           =>     p_validation_level,
                p_ii_relationship_rec        =>     p_relationship_tbl(l_count),
                p_txn_rec                    =>     p_txn_rec,
                p_mode                       =>     'CREATE',
                x_return_status              =>     x_return_status,
                x_msg_count                  =>     x_msg_count,
                x_msg_data                   =>     x_msg_data);
         -- Added by sguthiva for bug 2373109
           IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
                   l_msg_index := 1;
                   l_msg_count := x_msg_count;
             WHILE l_msg_count > 0
             LOOP
                     x_msg_data := FND_MSG_PUB.GET
                               (  l_msg_index,
                                  FND_API.G_FALSE );
              csi_gen_utility_pvt.put_line( ' Error from CSI_II_RELATIONSHIPS_PVT.CREATE_RELATIONSHIP');
              csi_gen_utility_pvt.put_line( ' Call to update_instance has errored ....');
              csi_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
               l_msg_index := l_msg_index + 1;
               l_msg_count := l_msg_count - 1;
             END LOOP;
               RAISE FND_API.G_EXC_ERROR;
           END IF;
         -- End of addition by sguthiva for bug 2373109



        -- Added by sk on 9-Apr-02 for bug 2304221
           -- invoke table handler(csi_ii_relationships_pkg.insert_row)
             csi_ii_relationships_pkg.insert_row(
          px_relationship_id                => p_relationship_tbl(l_count).relationship_id,
          p_relationship_type_code          => p_relationship_tbl(l_count).relationship_type_code,
          p_object_id                       => p_relationship_tbl(l_count).object_id,
          p_subject_id                      => p_relationship_tbl(l_count).subject_id,
          p_position_reference              => p_relationship_tbl(l_count).position_reference,
          p_active_start_date               => p_relationship_tbl(l_count).active_start_date,
          p_active_end_date                 => p_relationship_tbl(l_count).active_end_date,
          p_display_order                   => p_relationship_tbl(l_count).display_order,
          p_mandatory_flag                  => p_relationship_tbl(l_count).mandatory_flag,
          p_context                         => p_relationship_tbl(l_count).context,
          p_attribute1                      => p_relationship_tbl(l_count).attribute1,
          p_attribute2                      => p_relationship_tbl(l_count).attribute2,
          p_attribute3                      => p_relationship_tbl(l_count).attribute3,
          p_attribute4                      => p_relationship_tbl(l_count).attribute4,
          p_attribute5                      => p_relationship_tbl(l_count).attribute5,
          p_attribute6                      => p_relationship_tbl(l_count).attribute6,
          p_attribute7                      => p_relationship_tbl(l_count).attribute7,
          p_attribute8                      => p_relationship_tbl(l_count).attribute8,
          p_attribute9                      => p_relationship_tbl(l_count).attribute9,
          p_attribute10                     => p_relationship_tbl(l_count).attribute10,
          p_attribute11                     => p_relationship_tbl(l_count).attribute11,
          p_attribute12                     => p_relationship_tbl(l_count).attribute12,
          p_attribute13                     => p_relationship_tbl(l_count).attribute13,
          p_attribute14                     => p_relationship_tbl(l_count).attribute14,
          p_attribute15                     => p_relationship_tbl(l_count).attribute15,
          p_created_by                      => fnd_global.user_id,
          p_creation_date                   => SYSDATE,
          p_last_updated_by                 => fnd_global.user_id,
          p_last_update_date                => SYSDATE,
          p_last_update_login               => fnd_global.conc_login_id,
          p_object_version_number           => 1);
      -- hint: primary key should be returned.
      -- x_relationship_id := px_relationship_id;
      END IF;

          IF x_return_status <> fnd_api.g_ret_sts_success THEN
              RAISE fnd_api.g_exc_error;
          END IF;

        csi_transactions_pvt.create_transaction
          (
             p_api_version            => p_api_version
            ,p_commit                 => p_commit
            ,p_init_msg_list          => p_init_msg_list
            ,p_validation_level       => p_validation_level
            ,p_success_if_exists_flag => 'Y'
            ,p_transaction_rec        => p_txn_rec
            ,x_return_status          => x_return_status
            ,x_msg_count              => x_msg_count
            ,x_msg_data               => x_msg_data
          );

         IF NOT(x_return_status = fnd_api.g_ret_sts_success) THEN
              fnd_message.set_name('CSI','CSI_FAILED_TO_VALIDATE_TXN');
              fnd_message.set_token('transaction_id',p_txn_rec.transaction_id );
              fnd_msg_pub.add;
              RAISE fnd_api.g_exc_error;
              ROLLBACK TO create_relationship_pvt;
         END IF;

         -- The following code has been commented by sguthiva
         -- after a discussion for bug 2373109 on 21-May-02
         -- During a creation of relationship there should not be
         -- any changes to the ownership.
   /*
         update_party_account
            (   p_api_version                =>     p_api_version,
                p_commit                     =>     fnd_api.g_false,
                p_init_msg_list              =>     p_init_msg_list,
                p_validation_level           =>     p_validation_level,
                p_ii_relationship_rec        =>     p_relationship_tbl(l_count),
                p_txn_rec                    =>     p_txn_rec,
                x_return_status              =>     x_return_status,
                x_msg_count                  =>     x_msg_count,
                x_msg_data                   =>     x_msg_data);
         */
        -- End addition by sk for bug 2304221

IF x_return_status = fnd_api.g_ret_sts_success THEN

 l_relship_history_id := NULL;

 csi_ii_relationships_h_pkg.insert_row(
            px_relationship_history_id      =>  l_relship_history_id,
            p_relationship_id               =>  p_relationship_tbl(l_count).relationship_id,
            p_transaction_id                =>  p_txn_rec.transaction_id,
            p_old_subject_id                =>  NULL,
            p_new_subject_id                =>  p_relationship_tbl(l_count).subject_id,
            p_old_position_reference        =>  NULL,
            p_new_position_reference        =>  p_relationship_tbl(l_count).position_reference,
            p_old_active_start_date         =>  NULL,
            p_new_active_start_date         =>  p_relationship_tbl(l_count).active_start_date,
            p_old_active_end_date           =>  NULL,
            p_new_active_end_date           =>  p_relationship_tbl(l_count).active_end_date,
            p_old_mandatory_flag            =>  NULL,
            p_new_mandatory_flag            =>  p_relationship_tbl(l_count).mandatory_flag,
            p_old_context                   =>  NULL,
            p_new_context                   =>  p_relationship_tbl(l_count).context,
            p_old_attribute1                =>  NULL,
            p_new_attribute1                =>  p_relationship_tbl(l_count).attribute1,
            p_old_attribute2                =>  NULL,
            p_new_attribute2                =>  p_relationship_tbl(l_count).attribute2,
            p_old_attribute3                =>  NULL,
            p_new_attribute3                =>  p_relationship_tbl(l_count).attribute3,
            p_old_attribute4                =>  NULL,
            p_new_attribute4                =>  p_relationship_tbl(l_count).attribute4,
            p_old_attribute5                =>  NULL,
            p_new_attribute5                =>  p_relationship_tbl(l_count).attribute5,
            p_old_attribute6                =>  NULL,
            p_new_attribute6                =>  p_relationship_tbl(l_count).attribute6,
            p_old_attribute7                =>  NULL,
            p_new_attribute7                =>  p_relationship_tbl(l_count).attribute7,
            p_old_attribute8                =>  NULL,
            p_new_attribute8                =>  p_relationship_tbl(l_count).attribute8,
            p_old_attribute9                =>  NULL,
            p_new_attribute9                =>  p_relationship_tbl(l_count).attribute9,
            p_old_attribute10               =>  NULL,
            p_new_attribute10               =>  p_relationship_tbl(l_count).attribute10,
            p_old_attribute11               =>  NULL,
            p_new_attribute11               =>  p_relationship_tbl(l_count).attribute11,
            p_old_attribute12               =>  NULL,
            p_new_attribute12               =>  p_relationship_tbl(l_count).attribute12,
            p_old_attribute13               =>  NULL,
            p_new_attribute13               =>  p_relationship_tbl(l_count).attribute13,
            p_old_attribute14               =>  NULL,
            p_new_attribute14               =>  p_relationship_tbl(l_count).attribute14,
            p_old_attribute15               =>  NULL,
            p_new_attribute15               =>  p_relationship_tbl(l_count).attribute15,
            p_full_dump_flag                =>  'Y',
            p_created_by                    =>  fnd_global.user_id,
            p_creation_date                 =>  SYSDATE,
            p_last_updated_by               =>  fnd_global.user_id,
            p_last_update_date              =>  SYSDATE,
            p_last_update_login             =>  fnd_global.conc_login_id,
            p_object_version_number         =>  1);


  END IF;

-- Start of cascade ownership changes bug 2972082
-- Get the parent instance owner party and owner account

 IF nvl(p_relationship_tbl(l_count).cascade_ownership_flag,'N')='Y'
 THEN
 csi_gen_utility_pvt.put_line('Cascade_ownership_flag       : '||p_relationship_tbl(l_count).cascade_ownership_flag);
          l_instance_rec:=l_cascade_instance_rec;
          l_ext_attrib_values_tbl.delete;
          l_party_tbl.delete;
          l_account_tbl.delete;
          l_pricing_attrib_tbl.delete;
          l_org_assignments_tbl.delete;
          l_instance_id_lst.delete;

        IF p_relationship_tbl(l_count).object_id IS NOT NULL AND
           p_relationship_tbl(l_count).object_id <> fnd_api.g_miss_num
        THEN
           l_instance_rec.instance_id:=p_relationship_tbl(l_count).object_id;
        END IF;

        BEGIN
          SELECT object_version_number,
                 'Y'
          INTO   l_instance_rec.object_version_number,
                 l_instance_rec.cascade_ownership_flag
          FROM   csi_item_instances
          WHERE  instance_id=l_instance_rec.instance_id
          AND   (active_end_date IS NULL OR active_end_date > sysdate);
        EXCEPTION
          WHEN OTHERS
          THEN
             csi_gen_utility_pvt.put_line( 'Error from create relationship API.');
             csi_gen_utility_pvt.put_line( 'The object_id, which you are trying to cascade its ownership, is not found or expired in csi_item_instances table. ');
             RAISE fnd_api.g_exc_error;
        END;

                 csi_item_instance_pub.update_item_instance
                 ( p_api_version           =>  p_api_version
                  ,p_commit                =>  p_commit
                  ,p_init_msg_list         =>  p_init_msg_list
                  ,p_validation_level      =>  p_validation_level
                  ,p_instance_rec          =>  l_instance_rec
                  ,p_ext_attrib_values_tbl =>  l_ext_attrib_values_tbl
                  ,p_party_tbl             =>  l_party_tbl
                  ,p_account_tbl           =>  l_account_tbl
                  ,p_pricing_attrib_tbl    =>  l_pricing_attrib_tbl
                  ,p_org_assignments_tbl   =>  l_org_assignments_tbl
                  ,p_asset_assignment_tbl  =>  l_asset_assignment_tbl
                  ,p_txn_rec               =>  p_txn_rec
                  ,x_instance_id_lst       =>  l_instance_id_lst
                  ,x_return_status         =>  x_return_status
                  ,x_msg_count             =>  x_msg_count
                  ,x_msg_data              =>  x_msg_data
                  );

                IF NOT(x_return_status = fnd_api.g_ret_sts_success)
                THEN
                     csi_gen_utility_pvt.put_line( 'Error from create relationship API.');
                     csi_gen_utility_pvt.put_line( 'Call to update_item_instance API for cascade ownership has errored');
                     fnd_message.set_name('CSI','CSI_FAILED_TO_VALIDATE_INS');
                     fnd_message.set_token('instance_id',l_instance_rec.instance_id);
                     fnd_msg_pub.add;
                    RAISE fnd_api.g_exc_error;
                END IF;
 END IF;

-- End of cascade ownership changes bug 2972082

 END LOOP;
            IF x_return_status <> fnd_api.g_ret_sts_success THEN
              RAISE fnd_api.g_exc_error;
            END IF;
      --
      -- END of API BODY
      --

      -- standard check for p_commit
      IF fnd_api.to_boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;

      -- standard call to get message count and if count is 1, get message info.
      fnd_msg_pub.count_AND_get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

       EXCEPTION
          WHEN fnd_api.g_exc_error THEN
                ROLLBACK TO create_relationship_pvt;
                x_return_status := fnd_api.g_ret_sts_error ;
                fnd_msg_pub.count_AND_get
                        (p_count => x_msg_count ,
                         p_data => x_msg_data
                        );

          WHEN fnd_api.g_exc_unexpected_error THEN
                ROLLBACK TO create_relationship_pvt;
                x_return_status := fnd_api.g_ret_sts_unexp_error ;
                fnd_msg_pub.count_AND_get
                        (p_count => x_msg_count ,
                         p_data => x_msg_data
                        );

          WHEN OTHERS THEN
                ROLLBACK TO create_relationship_pvt;
                x_return_status := fnd_api.g_ret_sts_unexp_error ;
                  IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
                         fnd_msg_pub.add_exc_msg(g_pkg_name ,l_api_name);
                  END IF;
                fnd_msg_pub.count_AND_get
                        (p_count => x_msg_count ,
                         p_data => x_msg_data
                        );

END create_relationship;


PROCEDURE update_relationship
(
     p_api_version                IN  NUMBER,
     p_commit                     IN  VARCHAR2,
     p_init_msg_list              IN  VARCHAR2,
     p_validation_level           IN  NUMBER,
     p_relationship_tbl           IN      csi_datastructures_pub.ii_relationship_tbl,
     p_replace_flag               IN  VARCHAR2,
     p_txn_rec                    IN  OUT NOCOPY csi_datastructures_pub.transaction_rec,
     x_return_status              OUT NOCOPY VARCHAR2,
     x_msg_count                  OUT NOCOPY NUMBER,
     x_msg_data                   OUT NOCOPY VARCHAR2
) IS

 CURSOR  relship_csr (relship_id  IN  NUMBER) IS
     SELECT relationship_id,
            relationship_type_code,
            object_id,
            subject_id,
            position_reference,
            active_start_date,
            active_end_date,
            display_order,
            mandatory_flag,
            context,
            attribute1,
            attribute2,
            attribute3,
            attribute4,
            attribute5,
            attribute6,
            attribute7,
            attribute8,
            attribute9,
            attribute10,
            attribute11,
            attribute12,
            attribute13,
            attribute14,
            attribute15,
            object_version_number
      FROM  csi_ii_relationships
      WHERE relationship_id=relship_id
      FOR UPDATE OF object_version_number ;


    l_api_name               CONSTANT VARCHAR2(30) := 'update_ii_relationships';
    l_api_version            CONSTANT NUMBER   := 1.0;
    -- local variables
    --
    l_index                           NUMBER;
    l_count                           NUMBER;
    l_debug_level                     NUMBER;
    l_line_count                      NUMBER;
    l_relship_csr                     relship_csr%ROWTYPE;
    l_old_relship_rec                 csi_datastructures_pub.ii_relationship_rec;
    l_new_relship_rec                 csi_datastructures_pub.ii_relationship_rec;
    l_instance_rec                    csi_datastructures_pub.instance_rec;
    l_temp_ins_rec                    csi_datastructures_pub.instance_rec;
    l_object_id                       NUMBER;
    l_obv_number                      NUMBER;
    l_ins_usage_code                  VARCHAR2(30);
    l_instance_id_lst                 csi_datastructures_pub.id_tbl;
    l_item_attribute_tbl              csi_item_instance_pvt.item_attribute_tbl;
    l_location_tbl                    csi_item_instance_pvt.location_tbl;
    l_generic_id_tbl                  csi_item_instance_pvt.generic_id_tbl;
    l_lookup_tbl                      csi_item_instance_pvt.lookup_tbl;
    l_ins_count_rec                   csi_item_instance_pvt.ins_count_rec;
    l_relationship_tbl                csi_datastructures_pub.ii_relationship_tbl;
    l_obj_id                          NUMBER;
    l_sub_id                          NUMBER;
    l_msg_data                        VARCHAR2(2000);
    l_msg_index                       NUMBER;
    l_msg_count                       NUMBER;
    l_found                           BOOLEAN;
    l_exists                          VARCHAR2(1);
-- Added for cascade ownership change bug 2972082
    l_relationship_query_rec          csi_datastructures_pub.relationship_query_rec;
    l_rel_tbl                         csi_datastructures_pub.ii_relationship_tbl;
    l_ii_relationship_level_tbl       csi_ii_relationships_pvt.ii_relationship_level_tbl;
    l_ext_attrib_values_tbl           csi_datastructures_pub.extend_attrib_values_tbl;
    l_party_tbl                       csi_datastructures_pub.party_tbl;
    l_account_tbl                     csi_datastructures_pub.party_account_tbl;
    l_temp_party_tbl                  csi_datastructures_pub.party_tbl;
    l_temp_account_tbl                csi_datastructures_pub.party_account_tbl;
    l_pricing_attrib_tbl              csi_datastructures_pub.pricing_attribs_tbl;
    l_org_assignments_tbl             csi_datastructures_pub.organization_units_tbl;
    l_asset_assignment_tbl            csi_datastructures_pub.instance_asset_tbl;
    l_inst_id_lst                     csi_datastructures_pub.id_tbl;
    l_inst_rec                        csi_datastructures_pub.instance_rec;
    l_cascade_instance_rec            csi_datastructures_pub.instance_rec;
    l_item_id                         NUMBER;
    l_srl_ctl                         NUMBER;
    l_vld_org                         NUMBER;
    l_loc_type_code                   VARCHAR2(30);
-- End addition for cascade ownership changes bug 2972082
    l_subject_lock                    NUMBER;
    px_oks_txn_inst_tbl               oks_ibint_pub.txn_instance_tbl;
    px_child_inst_tbl                 csi_item_instance_grp.child_inst_tbl;
BEGIN
      -- standard start of api savepoint
      SAVEPOINT update_relationship_pvt;
      -- standard call to check for call compatibility.
      IF NOT fnd_api.compatible_api_call ( l_api_version,
                                           p_api_version,
                                           l_api_name,
                                           g_pkg_name)
      THEN
          RAISE fnd_api.g_exc_unexpected_error;
      END IF;


      -- initialize message list IF p_init_msg_list IS set TO true.
      IF fnd_api.to_boolean( p_init_msg_list )
      THEN
          fnd_msg_pub.initialize;
      END IF;


      -- initialize api return status to success
      x_return_status := fnd_api.g_ret_sts_success;


       l_debug_level:=fnd_profile.value('CSI_DEBUG_LEVEL');
    IF (l_debug_level > 0) THEN
          CSI_gen_utility_pvt.put_line( 'update_relationship');
    END IF;

    IF (l_debug_level > 1) THEN


             CSI_gen_utility_pvt.put_line(
                            p_api_version             ||'-'||
                            p_commit                  ||'-'||
                            p_init_msg_list           ||'-'||
                            p_validation_level        );

         csi_gen_utility_pvt.dump_rel_tbl(p_relationship_tbl);
         csi_gen_utility_pvt.dump_txn_rec(p_txn_rec);

    END IF;


      validate_ii_relationships(
          p_init_msg_list           => fnd_api.g_false,
          p_validation_level        => p_validation_level,
          p_validation_mode         => 'UPDATE',
          p_ii_relationship_tbl     => p_relationship_tbl,
          x_return_status           => x_return_status,
          x_msg_count               => x_msg_count,
          x_msg_data                => x_msg_data);

      IF x_return_status<>fnd_api.g_ret_sts_success THEN
          RAISE fnd_api.g_exc_error;
      END IF;

    l_line_count := p_relationship_tbl.count;

     FOR l_count IN 1..l_line_count LOOP
         l_obv_number:=NULL;
     /* Cyclic Relationship */
     /* added this to validate input parameters */

      IF NOT  valid_in_parameters
           (p_relship_id      => p_relationship_tbl(l_count).relationship_id,
            p_object_id       => p_relationship_tbl(l_count).object_id,
            p_subject_id      => p_relationship_tbl(l_count).subject_id )
      THEN
        fnd_message.set_name('CSI','CSI_API_INVALID_PARAMETERS');
        fnd_msg_pub.add;
        RAISE fnd_api.g_exc_error;
      END IF;

        --Added for MACD lock functionality
        IF p_relationship_tbl(l_count).object_id IS NOT NULL AND
           p_relationship_tbl(l_count).object_id <> fnd_api.g_miss_num
        THEN
           IF csi_item_instance_pvt.check_item_instance_lock
                                      ( p_instance_id => p_relationship_tbl(l_count).object_id)
           THEN
            IF p_txn_rec.transaction_type_id NOT IN (51,53,54,401)
            THEN
             FND_MESSAGE.SET_NAME('CSI','CSI_LOCKED_INSTANCE');
             FND_MESSAGE.SET_TOKEN('INSTANCE_ID',p_relationship_tbl(l_count).object_id);
             FND_MSG_PUB.ADD;
             RAISE FND_API.G_EXC_ERROR;
            END IF;
           END IF;
        END IF;
        IF p_relationship_tbl(l_count).subject_id IS NOT NULL AND
           p_relationship_tbl(l_count).subject_id <> fnd_api.g_miss_num
        THEN
           IF csi_item_instance_pvt.check_item_instance_lock
                                      ( p_instance_id => p_relationship_tbl(l_count).subject_id)
           THEN
            IF p_txn_rec.transaction_type_id NOT IN (51,53,54,401)
            THEN
             FND_MESSAGE.SET_NAME('CSI','CSI_LOCKED_INSTANCE');
             FND_MESSAGE.SET_TOKEN('INSTANCE_ID',p_relationship_tbl(l_count).subject_id);
             FND_MSG_PUB.ADD;
             RAISE FND_API.G_EXC_ERROR;
            END IF;
           END IF;
        ELSE
           l_subject_lock:=NULL;
          BEGIN
           SELECT subject_id
             INTO l_subject_lock
             FROM csi_ii_relationships
            WHERE relationship_id=p_relationship_tbl(l_count).relationship_id;
           IF csi_item_instance_pvt.check_item_instance_lock
                                      ( p_instance_id => l_subject_lock)
           THEN
            IF p_txn_rec.transaction_type_id NOT IN (51,53,54,401)
            THEN
             FND_MESSAGE.SET_NAME('CSI','CSI_LOCKED_INSTANCE');
             FND_MESSAGE.SET_TOKEN('INSTANCE_ID',l_subject_lock);
             FND_MSG_PUB.ADD;
             RAISE FND_API.G_EXC_ERROR;
            END IF;
           END IF;
           EXCEPTION
             WHEN NO_DATA_FOUND THEN
              NULL;
          END;

        END IF;
        -- End addition for MACD lock functionality

      l_new_relship_rec:=p_relationship_tbl(l_count);
      OPEN relship_csr (p_relationship_tbl(l_count).relationship_id);
      FETCH relship_csr INTO l_relship_csr;
       IF ( (l_relship_csr.object_version_number<>p_relationship_tbl(l_count).object_version_number)
         AND (p_relationship_tbl(l_count).object_version_number <> fnd_api.g_miss_num) ) THEN
         fnd_message.set_name('CSI', 'CSI_RECORD_CHANGED');
          fnd_msg_pub.add;
         RAISE fnd_api.g_exc_error;
       END IF;
      CLOSE relship_csr;

      /* Cyclic relationship */
      /* added this call to check configurator_id */
  /*   IF  config_set
         (p_relationship_id=>p_relationship_tbl(l_count).relationship_id)
     THEN
        RAISE fnd_api.g_exc_error;
     END IF;
*/
     /* added this to skip this validation ,in case subject and object_id are null */
     IF  ((p_relationship_tbl(l_count).relationship_id IS NOT NULL
         AND  p_relationship_tbl(l_count).relationship_id <> fnd_api.g_miss_num)
         AND ( p_relationship_tbl(l_count).object_id IS NOT NULL
         AND  p_relationship_tbl(l_count).object_id <> fnd_api.g_miss_num))
     THEN
         /* End cyclic relationship */
        IF object_relship_exists(p_relationship_tbl(l_count).relationship_id,
                                 p_relationship_tbl(l_count).object_id,
                                 p_relationship_tbl(l_count).relationship_type_code)
        THEN
            x_return_status := fnd_api.g_ret_sts_success;
        ELSE
            x_return_status := fnd_api.g_ret_sts_error;
            RAISE fnd_api.g_exc_error;
        END IF;
     END IF;

     /* Cyclic relationship -- added the condition to skip the validation for 'CONNECTED-TO' relationship */
     IF p_relationship_tbl(l_count).relationship_type_code <> 'CONNECTED-TO' THEN

       IF subject_exists(p_subject_id        => p_relationship_tbl(l_count).subject_id,
                         p_relship_type_code => p_relationship_tbl(l_count).relationship_type_code,
                         p_relationship_id   => p_relationship_tbl(l_count).relationship_id,
                         p_mode              => 'UPDATE')
       THEN
           x_return_status:=fnd_api.g_ret_sts_success;
       ELSE
           x_return_status:=fnd_api.g_ret_sts_error;
           RAISE fnd_api.g_exc_error;
       END IF;
       --
       -- check whether the Inverse Active Relationship exists
       Begin
	  select 'x'
	  into l_exists
	  from csi_ii_relationships
	  where object_id = decode(p_relationship_tbl(l_count).subject_id,fnd_api.g_miss_num,l_relship_csr.subject_id,
                                   p_relationship_tbl(l_count).subject_id)
	  and   subject_id = decode(p_relationship_tbl(l_count).object_id,fnd_api.g_miss_num,l_relship_csr.object_id,
                                   p_relationship_tbl(l_count).object_id)
	  and   relationship_type_code = decode(p_relationship_tbl(l_count).relationship_type_code,fnd_api.g_miss_char,
                                           l_relship_csr.relationship_type_code,
                                           p_relationship_tbl(l_count).relationship_type_code)
	  and   ((active_end_date is null) or (active_end_date > sysdate))
	  and   relationship_id <> p_relationship_tbl(l_count).relationship_id;
	  --
	  fnd_message.set_name('CSI','CSI_CHILD_PARENT_REL_LOOP');
	  fnd_msg_pub.add;
	  x_return_status := fnd_api.g_ret_sts_error;
	  RAISE fnd_api.g_exc_error;
      Exception
	 when no_data_found then
	    null;
      End;
      --
   -- Start of att enhancements by sguthiva
     ELSIF p_relationship_tbl(l_count).relationship_type_code = 'CONNECTED-TO'
     THEN
	IF p_relationship_tbl(l_count).object_id IS NULL OR
            p_relationship_tbl(l_count).object_id=fnd_api.g_miss_num
	THEN
	    l_obj_id:=NULL;
	    BEGIN
	       SELECT object_id
	       INTO   l_obj_id
	       FROM   csi_ii_relationships
	       WHERE  relationship_id=p_relationship_tbl(l_count).relationship_id;
	    EXCEPTION
	       WHEN OTHERS THEN
		  NULL;
	    END;
	ELSE
	   l_obj_id := p_relationship_tbl(l_count).object_id;
	END IF;
        --
        IF p_relationship_tbl(l_count).subject_id IS NULL OR
           p_relationship_tbl(l_count).subject_id=fnd_api.g_miss_num
        THEN
            l_sub_id:=NULL;
            BEGIN
               SELECT subject_id
               INTO   l_sub_id
               FROM   csi_ii_relationships
               WHERE  relationship_id=p_relationship_tbl(l_count).relationship_id;
            EXCEPTION
               WHEN OTHERS THEN
                  NULL;
            END;
        ELSE
           l_sub_id := p_relationship_tbl(l_count).subject_id;
        END IF;
        --
	IF csi_ii_relationships_pvt.Is_link_type (p_instance_id => l_obj_id )
	THEN
	   IF csi_ii_relationships_pvt.relationship_for_link
                                  ( p_instance_id     => l_obj_id
				     ,p_mode            => 'UPDATE'
				     ,p_relationship_id => p_relationship_tbl(l_count).relationship_id )
	   THEN
	      fnd_message.set_name('CSI','CSI_LINK_EXISTS');
	      fnd_message.set_token('INSTANCE_ID',l_obj_id);
	      fnd_msg_pub.add;
	      RAISE fnd_api.g_exc_error;
	   END IF;
	END IF;
        --
	IF csi_ii_relationships_pvt.Is_link_type (p_instance_id => l_sub_id )
	THEN
           IF csi_ii_relationships_pvt.relationship_for_link
                           ( p_instance_id     => l_sub_id
                             ,p_mode            => 'UPDATE'
                             ,p_relationship_id => p_relationship_tbl(l_count).relationship_id )
	   THEN
	      fnd_message.set_name('CSI','CSI_LINK_EXISTS');
	      fnd_message.set_token('INSTANCE_ID',l_sub_id);
	      fnd_msg_pub.add;
	      RAISE fnd_api.g_exc_error;
	   END IF;
        END IF;
        -- End of att enhancements by sguthiva
      END IF;
     --
        IF (p_relationship_tbl(l_count).subject_id IS NOT NULL AND
            p_relationship_tbl(l_count).subject_id <> fnd_api.g_miss_num AND
            l_relship_csr.subject_id <> p_relationship_tbl(l_count).subject_id
            AND (  (p_relationship_tbl(l_count).relationship_type_code IS NOT NULL AND
                    p_relationship_tbl(l_count).relationship_type_code <> fnd_api.g_miss_char AND
                    p_relationship_tbl(l_count).relationship_type_code = 'COMPONENT-OF'
                    )
                OR (p_relationship_tbl(l_count).relationship_type_code = fnd_api.g_miss_char  AND
                    l_relship_csr.relationship_type_code = 'COMPONENT-OF'
                    )
                )
             )
            OR
            (l_relship_csr.relationship_type_code = 'COMPONENT-OF' AND
             p_relationship_tbl(l_count).ACTIVE_END_DATE <= SYSDATE AND
             p_relationship_tbl(l_count).ACTIVE_END_DATE <> fnd_api.g_miss_date AND
             p_relationship_tbl(l_count).ACTIVE_END_DATE IS NOT NULL
             )
        THEN
             l_object_id := NULL;
             l_found:=FALSE;
	     csi_ii_relationships_pvt.Get_Top_Most_Parent
		( p_subject_id       => l_relship_csr.subject_id,
		  p_rel_type_code    => 'COMPONENT-OF',
		  p_object_id        => l_object_id
		);
	      --
	      IF l_object_id <> l_relship_csr.subject_id THEN
		 BEGIN
		    SELECT instance_usage_code
		    INTO   l_ins_usage_code
		    FROM   csi_item_instances
		    WHERE  instance_id=l_object_id;
		 EXCEPTION
		    WHEN NO_DATA_FOUND THEN
		       NULL;
		 END;

		 l_obv_number:=NULL;
		 BEGIN
		    SELECT  object_version_number,
			    config_inst_hdr_id, --added
			    config_inst_item_id, --added
			    config_inst_rev_num, --added
			    location_type_code,
			    inventory_item_id,
			    last_vld_organization_id
		    INTO    l_obv_number,
			    l_instance_rec.config_inst_hdr_id, --added
			    l_instance_rec.config_inst_item_id, --added
			    l_instance_rec.config_inst_rev_num, --added
			    l_loc_type_code,
			    l_item_id,
			    l_vld_org
		    FROM    csi_item_instances
		    WHERE   instance_id = l_relship_csr.subject_id;
		    --
		    -- Bug 4232599. Serialized at SO issue items cannot have usage as IN_INVENTORY
		    -- as taken from parent. Since relationship can be broken only thru' RMA,
		    -- usage is set as RETURNED. Other INV/WIP txns will not let serialized at SO issue
		    -- items to be transacted with the serial number. Hence other locations are not considered.
		    Begin
		       select serial_number_control_code
		       into l_srl_ctl
		       from MTL_SYSTEM_ITEMS_B
		       where inventory_item_id = l_item_id
		       and   organization_id = l_vld_org;
		       --
		       IF l_srl_ctl = 6 THEN
			  IF l_loc_type_code = 'INVENTORY' THEN
			     l_ins_usage_code := 'RETURNED';
			  END IF;
		       END IF;
		    Exception
		       when no_data_found then
			  null;
		    End;
		 EXCEPTION
		     WHEN NO_DATA_FOUND THEN
		       NULL;
		 END;
                 l_found:=TRUE;
              END IF;
        END IF;
        -- End Addition by sk for bug 2151750
       /* added this to aviod creating 'CONNECTED-TO' relationship in the reverse direction */
       IF p_relationship_tbl(l_count).relationship_type_code='CONNECTED-TO' THEN
           IF relationship_not_exists(p_relationship_tbl(l_count).subject_id,
                                      p_relationship_tbl(l_count).object_id,
                                      p_relationship_tbl(l_count).relationship_type_code,
                                      'UPDATE',
                                      p_relationship_tbl(l_count).relationship_id)
           THEN
              x_return_status:=fnd_api.g_ret_sts_success;
           ELSE
              x_return_status:=fnd_api.g_ret_sts_error;
              RAISE fnd_api.g_exc_error;
           END IF;
        END IF;

    IF x_return_status = fnd_api.g_ret_sts_success  THEN
       -- Update for the New subject only if the subject or relationship type is changing
       -- OR during Un-expiry
       IF (( (p_relationship_tbl(l_count).subject_id IS NOT NULL AND
             p_relationship_tbl(l_count).subject_id <> fnd_api.g_miss_num AND
             l_relship_csr.subject_id <> p_relationship_tbl(l_count).subject_id) OR
            ( p_relationship_tbl(l_count).relationship_type_code IS NOT NULL AND
              p_relationship_tbl(l_count).relationship_type_code <> fnd_api.g_miss_char AND
              p_relationship_tbl(l_count).relationship_type_code = 'COMPONENT-OF' AND
              l_relship_csr.relationship_type_code <> p_relationship_tbl(l_count).relationship_type_code) )
            OR
            ( (p_relationship_tbl(l_count).active_end_date IS NULL AND
              nvl(l_relship_csr.active_end_date,(sysdate+1)) <= SYSDATE) AND
             (p_relationship_tbl(l_count).subject_id = FND_API.G_MISS_NUM OR
              p_relationship_tbl(l_count).subject_id = l_relship_csr.subject_id) )
          )
       THEN
          csi_gen_utility_pvt.put_line('Calling Update_Instance..');
          update_instance
	      ( p_api_version                =>     p_api_version,
	        p_commit                     =>     fnd_api.g_false,--p_commit,
	        p_init_msg_list              =>     p_init_msg_list,
		p_validation_level           =>     p_validation_level,
		p_ii_relationship_rec        =>     p_relationship_tbl(l_count),
		p_txn_rec                    =>     p_txn_rec,
		p_mode                       =>     'UPDATE',
		x_return_status              =>     x_return_status,
		x_msg_count                  =>     x_msg_count,
		x_msg_data                   =>     x_msg_data);
	  IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
	     l_msg_index := 1;
	     l_msg_count := x_msg_count;
	     WHILE l_msg_count > 0
	     LOOP
	        x_msg_data := FND_MSG_PUB.GET
	        	         (  l_msg_index,
				    FND_API.G_FALSE );
		csi_gen_utility_pvt.put_line( ' Error from CSI_II_RELATIONSHIPS_PVT.UPDATE_RELATIONSHIP');
		csi_gen_utility_pvt.put_line( ' Call to update_instance has errored ....');
		csi_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
		l_msg_index := l_msg_index + 1;
		l_msg_count := l_msg_count - 1;
	     END LOOP;
	     RAISE FND_API.G_EXC_ERROR;
	  END IF;
       END IF;
      --
      csi_ii_relationships_pkg.update_row(
          p_relationship_id                 => p_relationship_tbl(l_count).relationship_id,
          p_relationship_type_code          => p_relationship_tbl(l_count).relationship_type_code,
          p_object_id                       => p_relationship_tbl(l_count).object_id,
          p_subject_id                      => p_relationship_tbl(l_count).subject_id,
          p_position_reference              => p_relationship_tbl(l_count).position_reference,
          p_active_start_date               => fnd_api.g_miss_date, -- p_relationship_tbl(l_count).active_start_date,
          p_active_end_date                 => p_relationship_tbl(l_count).active_end_date,
          p_display_order                   => p_relationship_tbl(l_count).display_order,
          p_mandatory_flag                  => p_relationship_tbl(l_count).mandatory_flag,
          p_context                         => p_relationship_tbl(l_count).context,
          p_attribute1                      => p_relationship_tbl(l_count).attribute1,
          p_attribute2                      => p_relationship_tbl(l_count).attribute2,
          p_attribute3                      => p_relationship_tbl(l_count).attribute3,
          p_attribute4                      => p_relationship_tbl(l_count).attribute4,
          p_attribute5                      => p_relationship_tbl(l_count).attribute5,
          p_attribute6                      => p_relationship_tbl(l_count).attribute6,
          p_attribute7                      => p_relationship_tbl(l_count).attribute7,
          p_attribute8                      => p_relationship_tbl(l_count).attribute8,
          p_attribute9                      => p_relationship_tbl(l_count).attribute9,
          p_attribute10                     => p_relationship_tbl(l_count).attribute10,
          p_attribute11                     => p_relationship_tbl(l_count).attribute11,
          p_attribute12                     => p_relationship_tbl(l_count).attribute12,
          p_attribute13                     => p_relationship_tbl(l_count).attribute13,
          p_attribute14                     => p_relationship_tbl(l_count).attribute14,
          p_attribute15                     => p_relationship_tbl(l_count).attribute15,
          p_created_by                      => fnd_api.g_miss_num,
          p_creation_date                   => fnd_api.g_miss_date,
          p_last_updated_by                 => fnd_global.user_id,
          p_last_update_date                => SYSDATE,
          p_last_update_login               => fnd_global.conc_login_id,
          p_object_version_number           => p_relationship_tbl(l_count).object_version_number);
          IF x_return_status <> fnd_api.g_ret_sts_success THEN
              RAISE fnd_api.g_exc_error;
          END IF;

/*
      ELSE
         csi_ii_relationships_pvt.expire_relationship
           (p_api_version           =>     p_api_version,
            p_commit                =>     fnd_api.g_false,
            p_init_msg_list         =>     p_init_msg_list,
            p_validation_level      =>     p_validation_level,
            p_relationship_rec      =>     p_relationship_tbl(l_count),
            p_txn_rec               =>     p_txn_rec,
            x_instance_id_lst       =>     l_instance_id_lst,
            x_return_status         =>     x_return_status,
            x_msg_count             =>     x_msg_count,
            x_msg_data              =>     x_msg_data);


       IF x_return_status <> fnd_api.g_ret_sts_success THEN
          RAISE fnd_api.g_exc_error;
       END IF;

       l_relationship_tbl(1).relationship_type_code := p_relationship_tbl(l_count).relationship_type_code; --'CONNECTED-TO' ;
       l_relationship_tbl(1).object_id := p_relationship_tbl(l_count).object_id;
       l_relationship_tbl(1).subject_id  := p_relationship_tbl(l_count).subject_id ;
       l_relationship_tbl(1).subject_has_child   := 'Y' ;
       l_relationship_tbl(1).active_start_date   := SYSDATE ;
       l_relationship_tbl(1).object_version_number:=1;

       csi_ii_relationships_pvt.create_relationship(
             p_api_version          => p_api_version,
             p_commit               => fnd_api.g_false,
             p_init_msg_list        => p_init_msg_list,
             p_validation_level     => p_validation_level,
             p_relationship_tbl     => l_relationship_tbl,
             p_txn_rec              => p_txn_rec,
             x_return_status        => x_return_status,
             x_msg_count            => x_msg_count,
             x_msg_data             => x_msg_data);

       IF x_return_status <> fnd_api.g_ret_sts_success THEN
          RAISE fnd_api.g_exc_error;
       END IF;
       --   END IF;
       */
    -- END IF;
   END IF;

   /*        IF x_return_status <> fnd_api.g_ret_sts_success THEN
              RAISE fnd_api.g_exc_error;
          END IF;*/
           csi_transactions_pvt.create_transaction
          (
             p_api_version            => p_api_version
            ,p_commit                 => p_commit
            ,p_init_msg_list          => p_init_msg_list
            ,p_validation_level       => p_validation_level
            ,p_success_if_exists_flag => 'Y'
            ,p_transaction_rec        => p_txn_rec
            ,x_return_status          => x_return_status
            ,x_msg_count              => x_msg_count
            ,x_msg_data               => x_msg_data
          );

         IF NOT(x_return_status = fnd_api.g_ret_sts_success) THEN
              fnd_message.set_name('CSI','CSI_FAILED_TO_VALIDATE_TXN');
              fnd_message.set_token('transaction_id',p_txn_rec.transaction_id );
                  fnd_msg_pub.add;
              RAISE fnd_api.g_exc_error;
              ROLLBACK TO create_relationship_pvt;
         END IF;
         --
	 l_instance_rec:=l_temp_ins_rec;
	 l_instance_rec.instance_id:= l_relship_csr.subject_id;
	 l_instance_rec.instance_usage_code :=l_ins_usage_code;
	 l_instance_rec.object_version_number :=l_obv_number;
         -- TSO with equipment changes.
         -- Nullify the keys when the relationship is broken
         l_instance_rec.config_inst_hdr_id := NULL;
         l_instance_rec.config_inst_rev_num := NULL;
         l_instance_rec.config_inst_item_id := NULL;
         l_instance_rec.config_valid_status := NULL;
         --
	IF l_instance_rec.instance_id IS NOT NULL AND
	   l_instance_rec.object_version_number IS NOT NULL AND
	   l_found
	THEN
	   IF  l_relship_csr.subject_id = l_instance_rec.instance_id AND
	       nvl(p_replace_flag,fnd_api.g_false)<> fnd_api.g_true
	   THEN
	      csi_gen_utility_pvt.put_line('Calling update_item_instance..');
          csi_gen_utility_pvt.put_line('Parameter p_called_from_rel set to true..');
	      csi_item_instance_pvt.update_item_instance
         (p_api_version             =>  p_api_version
         ,p_commit                  =>  p_commit
         ,p_init_msg_list           =>  p_init_msg_list
         ,p_validation_level        =>  p_validation_level
         ,p_instance_rec            =>  l_instance_rec
         ,p_txn_rec                 =>  p_txn_rec
         ,x_instance_id_lst         =>  l_instance_id_lst
         ,x_return_status           =>  x_return_status
         ,x_msg_count               =>  x_msg_count
         ,x_msg_data                =>  x_msg_data
         ,p_item_attribute_tbl      =>  l_item_attribute_tbl
         ,p_location_tbl            =>  l_location_tbl
         ,p_generic_id_tbl          =>  l_generic_id_tbl
         ,p_lookup_tbl              =>  l_lookup_tbl
         ,p_ins_count_rec           =>  l_ins_count_rec
         ,p_called_from_rel         =>  fnd_api.g_true
         ,p_oks_txn_inst_tbl        =>  px_oks_txn_inst_tbl
         ,p_child_inst_tbl          =>  px_child_inst_tbl
	     );
	   END IF;

	   IF NOT(x_return_status = fnd_api.g_ret_sts_success) THEN
		fnd_message.set_name('CSI','CSI_FAILED_TO_VALIDATE_INS');
		fnd_message.set_token('instance_id',l_instance_rec.instance_id);
		fnd_msg_pub.add;
		RAISE fnd_api.g_exc_error;
	   END IF;
	END IF;
        --
          l_old_relship_rec.relationship_id         :=  l_relship_csr.relationship_id;
          l_old_relship_rec.relationship_type_code  :=  l_relship_csr.relationship_id;
          l_old_relship_rec.object_id               :=  l_relship_csr.object_id;
          l_old_relship_rec.subject_id              :=  l_relship_csr.subject_id;
          l_old_relship_rec.position_reference      :=  l_relship_csr.position_reference;
          l_old_relship_rec.active_start_date       :=  l_relship_csr.active_start_date;
          l_old_relship_rec.active_end_date         :=  l_relship_csr.active_end_date;
          l_old_relship_rec.display_order           :=  l_relship_csr.display_order;
          l_old_relship_rec.mandatory_flag          :=  l_relship_csr.mandatory_flag;
          l_old_relship_rec.context                 :=  l_relship_csr.context;
          l_old_relship_rec.attribute1              :=  l_relship_csr.attribute1;
          l_old_relship_rec.attribute2              :=  l_relship_csr.attribute2;
          l_old_relship_rec.attribute3              :=  l_relship_csr.attribute3;
          l_old_relship_rec.attribute4              :=  l_relship_csr.attribute4;
          l_old_relship_rec.attribute5              :=  l_relship_csr.attribute5;
          l_old_relship_rec.attribute6              :=  l_relship_csr.attribute6;
          l_old_relship_rec.attribute7              :=  l_relship_csr.attribute7;
          l_old_relship_rec.attribute8              :=  l_relship_csr.attribute8;
          l_old_relship_rec.attribute9              :=  l_relship_csr.attribute9;
          l_old_relship_rec.attribute10             :=  l_relship_csr.attribute10;
          l_old_relship_rec.attribute11             :=  l_relship_csr.attribute11;
          l_old_relship_rec.attribute12             :=  l_relship_csr.attribute12;
          l_old_relship_rec.attribute13             :=  l_relship_csr.attribute13;
          l_old_relship_rec.attribute14             :=  l_relship_csr.attribute14;
          l_old_relship_rec.attribute15             :=  l_relship_csr.attribute15;
          l_old_relship_rec.object_version_number   :=  l_relship_csr.object_version_number;


                validate_history(p_old_relship_rec  =>  l_old_relship_rec,
                                 p_new_relship_rec  =>  l_new_relship_rec,
                                 p_transaction_id   =>  p_txn_rec.transaction_id,
                                 p_flag             =>  NULL,
                                 p_sysdate          =>  NULL,
                                 x_return_status    =>  x_return_status,
                                 x_msg_count        =>  x_msg_count,
                                 x_msg_data         =>  x_msg_data
                                 );

-- Start of cascade ownership changes bug 2972082
-- Get the parent instance owner party and owner account

 IF nvl(p_relationship_tbl(l_count).cascade_ownership_flag,'N')='Y'
 THEN
 csi_gen_utility_pvt.put_line('Cascade_ownership_flag       : '||p_relationship_tbl(l_count).cascade_ownership_flag);
          l_inst_rec:=l_cascade_instance_rec;
          l_ext_attrib_values_tbl.delete;
          l_party_tbl.delete;
          l_account_tbl.delete;
          l_pricing_attrib_tbl.delete;
          l_org_assignments_tbl.delete;
          l_inst_id_lst.delete;

        IF p_relationship_tbl(l_count).object_id IS NOT NULL AND
           p_relationship_tbl(l_count).object_id <> fnd_api.g_miss_num
        THEN
           l_inst_rec.instance_id:=p_relationship_tbl(l_count).object_id;
        ELSE
          BEGIN
            SELECT object_id
            INTO   l_inst_rec.instance_id
            FROM   csi_ii_relationships
            WHERE  relationship_id=p_relationship_tbl(l_count).relationship_id;
          EXCEPTION
            WHEN OTHERS
            THEN
             csi_gen_utility_pvt.put_line( 'Error from update relationship API.');
             csi_gen_utility_pvt.put_line( 'Object_id not found in csi_ii_relationships to cascade ownership');
             RAISE fnd_api.g_exc_error;
          END;
        END IF;

        BEGIN
          SELECT object_version_number,
                 'Y'
          INTO   l_inst_rec.object_version_number,
                 l_inst_rec.cascade_ownership_flag
          FROM   csi_item_instances
          WHERE  instance_id=l_inst_rec.instance_id
          AND   (active_end_date IS NULL OR active_end_date > sysdate);
        EXCEPTION
          WHEN OTHERS
          THEN
             csi_gen_utility_pvt.put_line( 'Error from update relationship API.');
             csi_gen_utility_pvt.put_line( 'The object_id, which you are trying to cascade its ownership, is not found or expired in csi_item_instances table. ');
             RAISE fnd_api.g_exc_error;
        END;

                 csi_item_instance_pub.update_item_instance
                 ( p_api_version           =>  p_api_version
                  ,p_commit                =>  p_commit
                  ,p_init_msg_list         =>  p_init_msg_list
                  ,p_validation_level      =>  p_validation_level
                  ,p_instance_rec          =>  l_inst_rec
                  ,p_ext_attrib_values_tbl =>  l_ext_attrib_values_tbl
                  ,p_party_tbl             =>  l_party_tbl
                  ,p_account_tbl           =>  l_account_tbl
                  ,p_pricing_attrib_tbl    =>  l_pricing_attrib_tbl
                  ,p_org_assignments_tbl   =>  l_org_assignments_tbl
                  ,p_asset_assignment_tbl  =>  l_asset_assignment_tbl
                  ,p_txn_rec               =>  p_txn_rec
                  ,x_instance_id_lst       =>  l_inst_id_lst
                  ,x_return_status         =>  x_return_status
                  ,x_msg_count             =>  x_msg_count
                  ,x_msg_data              =>  x_msg_data
                  );

                IF NOT(x_return_status = fnd_api.g_ret_sts_success)
                THEN
                     csi_gen_utility_pvt.put_line( 'Error from update relationship API.');
                     csi_gen_utility_pvt.put_line( 'Call to update_item_instance API for cascade ownership has errored');
                     fnd_message.set_name('CSI','CSI_FAILED_TO_VALIDATE_INS');
                     fnd_message.set_token('instance_id',l_instance_rec.instance_id);
                     fnd_msg_pub.add;
                    RAISE fnd_api.g_exc_error;
                END IF;
 END IF;

-- End of cascade ownership changes bug 2972082


  END LOOP;
    --
    -- END of API body.
    --

      IF x_return_status <> fnd_api.g_ret_sts_success THEN
              RAISE fnd_api.g_exc_error;
      END IF;

      -- standard check for p_commit
      IF fnd_api.to_boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;




      -- standard call to get message count and if count is 1, get message info.
      fnd_msg_pub.count_AND_get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

      EXCEPTION
          WHEN fnd_api.g_exc_error THEN
                ROLLBACK TO update_relationship_pvt;
                x_return_status := fnd_api.g_ret_sts_error ;
                fnd_msg_pub.count_AND_get
                        (p_count => x_msg_count ,
                         p_data => x_msg_data
                        );

          WHEN fnd_api.g_exc_unexpected_error THEN
                ROLLBACK TO update_relationship_pvt;
                x_return_status := fnd_api.g_ret_sts_unexp_error ;
                fnd_msg_pub.count_AND_get
                       (p_count => x_msg_count ,
                        p_data => x_msg_data
                        );

          WHEN OTHERS THEN
                ROLLBACK TO update_relationship_pvt;
                x_return_status := fnd_api.g_ret_sts_unexp_error ;
                  IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
                         fnd_msg_pub.add_exc_msg(g_pkg_name ,l_api_name);
                  END IF;
                fnd_msg_pub.count_AND_get
                        (p_count => x_msg_count ,
                         p_data => x_msg_data
                        );

END update_relationship;


PROCEDURE expire_relationship
(
     p_api_version                 IN       NUMBER,
     p_commit                      IN       VARCHAR2,
     p_init_msg_list               IN       VARCHAR2,
     p_validation_level            IN       NUMBER,
     p_relationship_rec            IN  csi_datastructures_pub.ii_relationship_rec,
     p_txn_rec                     IN  OUT NOCOPY  csi_datastructures_pub.transaction_rec,
     x_instance_id_lst             OUT NOCOPY      csi_datastructures_pub.id_tbl,
     x_return_status               OUT NOCOPY      VARCHAR2,
     x_msg_count                   OUT NOCOPY      NUMBER,
     x_msg_data                    OUT NOCOPY      VARCHAR2
) IS

CURSOR  relship_csr (relship_id  IN  NUMBER) IS
     SELECT relationship_id,
            relationship_type_code,
            object_id,
            subject_id,
            position_reference,
            active_start_date,
            active_end_date,
            display_order,
            mandatory_flag,
            context,
            attribute1,
            attribute2,
            attribute3,
            attribute4,
            attribute5,
            attribute6,
            attribute7,
            attribute8,
            attribute9,
            attribute10,
            attribute11,
            attribute12,
            attribute13,
            attribute14,
            attribute15,
            object_version_number
      FROM  csi_ii_relationships
      WHERE relationship_id=relship_id
      FOR UPDATE OF object_version_number ;

    l_relship_csr                      relship_csr%ROWTYPE;
    l_api_name                CONSTANT VARCHAR2(30) := 'expire_relationship';
    l_api_version             CONSTANT NUMBER   := 1.0;
    l_debug_level                      NUMBER;
    l_old_relship_rec                  csi_datastructures_pub.ii_relationship_rec;
    l_new_relship_rec                  csi_datastructures_pub.ii_relationship_rec;
    l_ii_relationship_tbl              csi_datastructures_pub.ii_relationship_tbl;
    l_sysdate                 CONSTANT DATE :=SYSDATE;
    l_instance_rec                     csi_datastructures_pub.instance_rec;
    l_temp_ins_rec                     csi_datastructures_pub.instance_rec;
    l_object_id                        NUMBER;
    l_obv_number                       NUMBER;
    l_ins_usage_code                   VARCHAR2(30);
    l_instance_id_lst                  csi_datastructures_pub.id_tbl;
    l_item_attribute_tbl               csi_item_instance_pvt.item_attribute_tbl;
    l_location_tbl                     csi_item_instance_pvt.location_tbl;
    l_generic_id_tbl                   csi_item_instance_pvt.generic_id_tbl;
    l_lookup_tbl                       csi_item_instance_pvt.lookup_tbl;
    l_ins_count_rec                    csi_item_instance_pvt.ins_count_rec;
    l_found                            BOOLEAN;
    l_item_id                          NUMBER;
    l_vld_org                          NUMBER;
    l_srl_ctl                          NUMBER;
    l_loc_type_code                    VARCHAR2(30);
    px_oks_txn_inst_tbl                oks_ibint_pub.txn_instance_tbl;
    px_child_inst_tbl                  csi_item_instance_grp.child_inst_tbl;
BEGIN
      -- standard start of api savepoint
      SAVEPOINT expire_relationship_pvt;

      -- standard call to check for call compatibility.
      IF NOT fnd_api.compatible_api_call ( l_api_version,
                                           p_api_version,
                                           l_api_name,
                                           g_pkg_name)
      THEN
          RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      -- initialize message list if p_init_msg_list is set to true.
      IF fnd_api.to_boolean( p_init_msg_list )
      THEN
          fnd_msg_pub.initialize;
      END IF;

      -- initialize api return status to success
      x_return_status := fnd_api.g_ret_sts_success;

        l_debug_level:=fnd_profile.value('CSI_DEBUG_LEVEL');
    IF (l_debug_level > 0) THEN
          CSI_gen_utility_pvt.put_line( 'expire_relationship');
    END IF;

    IF (l_debug_level > 1) THEN

             CSI_gen_utility_pvt.put_line(
                            p_api_version             ||'-'||
                            p_commit                  ||'-'||
                            p_init_msg_list           ||'-'||
                            p_validation_level
                                );

         -- dump the relationship query records
         csi_gen_utility_pvt.dump_txn_rec(p_txn_rec);
         csi_gen_utility_pvt.dump_rel_rec(p_relationship_rec);

    END IF;

      --
      -- API BODY
      --
      OPEN relship_csr (p_relationship_rec.relationship_id);
      FETCH relship_csr INTO l_relship_csr;
       IF ( (l_relship_csr.object_version_number<>p_relationship_rec.object_version_number)
         AND (p_relationship_rec.object_version_number <> fnd_api.g_miss_num) ) THEN
         fnd_message.set_name('CSI', 'CSI_RECORD_CHANGED');
          fnd_msg_pub.add;
         RAISE fnd_api.g_exc_error;
       END IF;
      CLOSE relship_csr;

      l_ii_relationship_tbl(1) := p_relationship_rec;
       validate_ii_relationships(
          p_init_msg_list           => fnd_api.g_false,
          p_validation_level        => p_validation_level,
          p_validation_mode         => 'EXPIRE',
          p_ii_relationship_tbl     => l_ii_relationship_tbl,
          x_return_status           => x_return_status,
          x_msg_count               => x_msg_count,
          x_msg_data                => x_msg_data);

      IF x_return_status<>fnd_api.g_ret_sts_success THEN
          RAISE fnd_api.g_exc_error;
      END IF;
      IF l_relship_csr.relationship_type_code = 'COMPONENT-OF'
      THEN
      BEGIN
             l_object_id := NULL;
             l_found:=FALSE;
	     csi_ii_relationships_pvt.Get_Top_Most_Parent
		( p_subject_id       => l_relship_csr.subject_id,
		  p_rel_type_code    => 'COMPONENT-OF',
		  p_object_id        => l_object_id
		);
	      --
	      IF l_object_id <> l_relship_csr.subject_id THEN
		 BEGIN
		    SELECT instance_usage_code
		    INTO   l_ins_usage_code
		    FROM   csi_item_instances
		    WHERE  instance_id=l_object_id;
		 EXCEPTION
		    WHEN NO_DATA_FOUND THEN
		       NULL;
		 END;
                 l_obv_number:=NULL;
		 BEGIN
		    SELECT  object_version_number,
			    config_inst_hdr_id, --added
			    config_inst_item_id, --added
			    config_inst_rev_num,
			    inventory_item_id,
			    last_vld_organization_id,
			    location_type_code
		    INTO    l_obv_number,
			    l_instance_rec.config_inst_hdr_id, --added
			    l_instance_rec.config_inst_item_id, --added
			    l_instance_rec.config_inst_rev_num,
			    l_item_id,
			    l_vld_org,
			    l_loc_type_code
		    FROM    csi_item_instances
		    WHERE   instance_id = l_relship_csr.subject_id;
		    --
		    -- Bug 4232599. Serialized at SO issue items cannot have usage as IN_INVENTORY
		    -- as taken from parent. Since relationship can be broken only thru' RMA,
		    -- usage is set as RETURNED. Other INV/WIP txns will not let serialized at SO issue
		    -- items to be transacted with the serial number. Hence other locations are not considered.
		    Begin
		       select serial_number_control_code
		       into l_srl_ctl
		       from MTL_SYSTEM_ITEMS_B
		       where inventory_item_id = l_item_id
		       and   organization_id = l_vld_org;
		       --
		       IF l_srl_ctl = 6 THEN
			  IF l_loc_type_code = 'INVENTORY' THEN
			     l_ins_usage_code := 'RETURNED';
			  END IF;
		       END IF;
		    Exception
		       when no_data_found then
			  null;
		    End;
		 EXCEPTION
		     WHEN NO_DATA_FOUND THEN
		       NULL;
		 END;
                 l_found:=TRUE;
              END IF;
        END;
        END IF;


        --Added for MACD lock functionality
        IF l_relship_csr.object_id IS NOT NULL AND
           l_relship_csr.object_id <> fnd_api.g_miss_num
        THEN
           IF csi_item_instance_pvt.check_item_instance_lock
                                      ( p_instance_id => l_relship_csr.object_id)
           THEN
	   --Added the below if condition for bug 5217556--
             IF p_txn_rec.transaction_type_id NOT IN (53,54)
              THEN
              FND_MESSAGE.SET_NAME('CSI','CSI_LOCKED_INSTANCE');
              FND_MESSAGE.SET_TOKEN('INSTANCE_ID',l_relship_csr.object_id);
              FND_MSG_PUB.ADD;
              RAISE FND_API.G_EXC_ERROR;
             END IF;
           END IF;
        END IF;

        IF l_relship_csr.subject_id IS NOT NULL AND
           l_relship_csr.subject_id <> fnd_api.g_miss_num
        THEN
           IF csi_item_instance_pvt.check_item_instance_lock
                                      ( p_instance_id => l_relship_csr.subject_id)
           THEN
             FND_MESSAGE.SET_NAME('CSI','CSI_LOCKED_INSTANCE');
             FND_MESSAGE.SET_TOKEN('INSTANCE_ID',l_relship_csr.subject_id);
             FND_MSG_PUB.ADD;
             RAISE FND_API.G_EXC_ERROR;
           END IF;
        END IF;
        -- End addition for MACD lock functionality



      csi_ii_relationships_pkg.update_row(
          p_relationship_id             => p_relationship_rec.relationship_id,
          p_relationship_type_code      => fnd_api.g_miss_char,
          p_object_id                   => fnd_api.g_miss_num,
          p_subject_id                  => fnd_api.g_miss_num,
          p_position_reference          => fnd_api.g_miss_char,
          p_active_start_date           => fnd_api.g_miss_date,
          p_active_end_date             => l_sysdate,
          p_display_order               => fnd_api.g_miss_num,
          p_mandatory_flag              => fnd_api.g_miss_char,
          p_context                     => fnd_api.g_miss_char,
          p_attribute1                  => fnd_api.g_miss_char,
          p_attribute2                  => fnd_api.g_miss_char,
          p_attribute3                  => fnd_api.g_miss_char,
          p_attribute4                  => fnd_api.g_miss_char,
          p_attribute5                  => fnd_api.g_miss_char,
          p_attribute6                  => fnd_api.g_miss_char,
          p_attribute7                  => fnd_api.g_miss_char,
          p_attribute8                  => fnd_api.g_miss_char,
          p_attribute9                  => fnd_api.g_miss_char,
          p_attribute10                 => fnd_api.g_miss_char,
          p_attribute11                 => fnd_api.g_miss_char,
          p_attribute12                 => fnd_api.g_miss_char,
          p_attribute13                 => fnd_api.g_miss_char,
          p_attribute14                 => fnd_api.g_miss_char,
          p_attribute15                 => fnd_api.g_miss_char,
          p_created_by                  => fnd_api.g_miss_num,
          p_creation_date               => fnd_api.g_miss_date,
          p_last_updated_by             => fnd_global.user_id,
          p_last_update_date            => l_sysdate,
          p_last_update_login           => fnd_global.conc_login_id,
          p_object_version_number       => fnd_api.g_miss_num);


           csi_transactions_pvt.create_transaction
          (
             p_api_version            => p_api_version
            ,p_commit                 => p_commit
            ,p_init_msg_list          => p_init_msg_list
            ,p_validation_level       => p_validation_level
            ,p_success_if_exists_flag => 'Y'
            ,p_transaction_rec        => p_txn_rec
            ,x_return_status          => x_return_status
            ,x_msg_count              => x_msg_count
            ,x_msg_data               => x_msg_data
          );

         IF NOT(x_return_status = fnd_api.g_ret_sts_success) THEN
              fnd_message.set_name('CSI','CSI_FAILED_TO_VALIDATE_TXN');
              fnd_message.set_token('transaction_id',p_txn_rec.transaction_id );
                  fnd_msg_pub.add;
              RAISE fnd_api.g_exc_error;
              ROLLBACK TO create_relationship_pvt;
         END IF;

                 l_instance_rec:=l_temp_ins_rec;
                 l_instance_rec.instance_id:= l_relship_csr.subject_id;
                 l_instance_rec.instance_usage_code :=l_ins_usage_code;
                 l_instance_rec.object_version_number :=l_obv_number;
                 -- TSO with equipment changes.
                 -- Nullify the keys when the relationship is broken
                 l_instance_rec.config_inst_hdr_id := null;
                 l_instance_rec.config_inst_rev_num := null;
                 l_instance_rec.config_inst_item_id := null;
                 l_instance_rec.config_valid_status := null;
                IF l_instance_rec.instance_id IS NOT NULL AND
                   l_instance_rec.object_version_number IS NOT NULL AND
                   l_found
                THEN
                 csi_gen_utility_pvt.put_line('Calling Update II from Exp Rel...');
                 csi_item_instance_pvt.update_item_instance
                 (   p_api_version             =>  p_api_version
                    ,p_commit                  =>  p_commit
                    ,p_init_msg_list           =>  p_init_msg_list
                    ,p_validation_level        =>  p_validation_level
                    ,p_instance_rec            =>  l_instance_rec
                    ,p_txn_rec                 =>  p_txn_rec
                    ,x_instance_id_lst         =>  l_instance_id_lst
                    ,x_return_status           =>  x_return_status
                    ,x_msg_count               =>  x_msg_count
                    ,x_msg_data                =>  x_msg_data
                    ,p_item_attribute_tbl      =>  l_item_attribute_tbl
                    ,p_location_tbl            =>  l_location_tbl
                    ,p_generic_id_tbl          =>  l_generic_id_tbl
                    ,p_lookup_tbl              =>  l_lookup_tbl
                    ,p_ins_count_rec           =>  l_ins_count_rec
                    ,p_called_from_rel         =>  fnd_api.g_true
                    ,p_oks_txn_inst_tbl        =>  px_oks_txn_inst_tbl
                    ,p_child_inst_tbl          =>  px_child_inst_tbl
                );


                   IF NOT(x_return_status = fnd_api.g_ret_sts_success) THEN
                        fnd_message.set_name('CSI','CSI_FAILED_TO_VALIDATE_INS');
                        fnd_message.set_token('instance_id',l_instance_rec.instance_id);
                        fnd_msg_pub.add;
                        RAISE fnd_api.g_exc_error;
                   END IF;
                END IF;

        -- End Addition by sk for bug 2151750
          l_old_relship_rec.relationship_id         :=  l_relship_csr.relationship_id;
          l_old_relship_rec.relationship_type_code  :=  l_relship_csr.relationship_id;
          l_old_relship_rec.object_id               :=  l_relship_csr.object_id;
          l_old_relship_rec.subject_id              :=  l_relship_csr.subject_id;
          l_old_relship_rec.position_reference      :=  l_relship_csr.position_reference;
          l_old_relship_rec.active_start_date       :=  l_relship_csr.active_start_date;
          l_old_relship_rec.active_end_date         :=  l_relship_csr.active_end_date;
          l_old_relship_rec.display_order           :=  l_relship_csr.display_order;
          l_old_relship_rec.mandatory_flag          :=  l_relship_csr.mandatory_flag;
          l_old_relship_rec.context                 :=  l_relship_csr.context;
          l_old_relship_rec.attribute1              :=  l_relship_csr.attribute1;
          l_old_relship_rec.attribute2              :=  l_relship_csr.attribute2;
          l_old_relship_rec.attribute3              :=  l_relship_csr.attribute3;
          l_old_relship_rec.attribute4              :=  l_relship_csr.attribute4;
          l_old_relship_rec.attribute5              :=  l_relship_csr.attribute5;
          l_old_relship_rec.attribute6              :=  l_relship_csr.attribute6;
          l_old_relship_rec.attribute7              :=  l_relship_csr.attribute7;
          l_old_relship_rec.attribute8              :=  l_relship_csr.attribute8;
          l_old_relship_rec.attribute9              :=  l_relship_csr.attribute9;
          l_old_relship_rec.attribute10             :=  l_relship_csr.attribute10;
          l_old_relship_rec.attribute11             :=  l_relship_csr.attribute11;
          l_old_relship_rec.attribute12             :=  l_relship_csr.attribute12;
          l_old_relship_rec.attribute13             :=  l_relship_csr.attribute13;
          l_old_relship_rec.attribute14             :=  l_relship_csr.attribute14;
          l_old_relship_rec.attribute15             :=  l_relship_csr.attribute15;
          l_old_relship_rec.object_version_number   :=  l_relship_csr.object_version_number;


                validate_history(p_old_relship_rec  =>  l_old_relship_rec,
                                 p_new_relship_rec  =>  l_new_relship_rec,
                                 p_transaction_id   =>  p_txn_rec.transaction_id,
                                 p_flag             =>  'EXPIRE',
                                 p_sysdate          =>  l_sysdate,
                                 x_return_status    =>  x_return_status,
                                 x_msg_count        =>  x_msg_count,
                                 x_msg_data         =>  x_msg_data
                                 );



      IF x_return_status <> fnd_api.g_ret_sts_success THEN
              RAISE fnd_api.g_exc_error;
      END IF;

      -- standard check for p_commit
      IF fnd_api.to_boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;

      -- standard call to get message count and if count is 1, get message info.
      fnd_msg_pub.count_AND_get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

      EXCEPTION
          WHEN fnd_api.g_exc_error THEN
                ROLLBACK TO expire_relationship_pvt;
                x_return_status := fnd_api.g_ret_sts_error ;
                fnd_msg_pub.count_AND_get
                        (p_count => x_msg_count ,
                         p_data => x_msg_data
                        );

          WHEN fnd_api.g_exc_unexpected_error THEN
                ROLLBACK TO expire_relationship_pvt;
                x_return_status := fnd_api.g_ret_sts_unexp_error ;
                fnd_msg_pub.count_AND_get
                        (p_count => x_msg_count ,
                         p_data => x_msg_data
                        );

          WHEN OTHERS THEN
                ROLLBACK TO expire_relationship_pvt;
                x_return_status := fnd_api.g_ret_sts_unexp_error ;
                  IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
                         fnd_msg_pub.add_exc_msg(g_pkg_name ,l_api_name);
                  END IF;
                fnd_msg_pub.count_AND_get
                        (p_count => x_msg_count ,
                         p_data => x_msg_data
                        );
END expire_relationship;


PROCEDURE validate_relationship_id (
    p_init_msg_list              IN   VARCHAR2,
    p_validation_mode            IN   VARCHAR2,
    p_relationship_id            IN   NUMBER,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2
    )
IS
l_dummy         VARCHAR2(1);
BEGIN

      -- initialize message list IF p_init_msg_list IS set TO true.
      IF fnd_api.to_boolean( p_init_msg_list )
      THEN
          fnd_msg_pub.initialize;
      END IF;


      -- initialize api return status to success
      x_return_status := fnd_api.g_ret_sts_success;
     IF(p_validation_mode ='CREATE') THEN
      -- validate not null column
      IF ( (p_relationship_id IS NOT NULL) AND (p_relationship_id <> fnd_api.g_miss_num) )
      /* if p_relationship_id is not null check if it already exists if found return success else error*/
      THEN
          BEGIN
          SELECT 'x'
          INTO   l_dummy
          FROM   csi_ii_relationships
          WHERE  relationship_id=p_relationship_id
          AND    ROWNUM=1;
           fnd_message.set_name('CSI','CSI_INVALID_RELSHIPID');
           fnd_message.set_token('relationship_id',p_relationship_id);
           fnd_msg_pub.add;
           x_return_status := fnd_api.g_ret_sts_error;
          EXCEPTION
             WHEN NO_DATA_FOUND THEN
                 x_return_status := fnd_api.g_ret_sts_success;

          END;

      ELSE
         /* if p_relationship_id is null then return success */
               x_return_status := fnd_api.g_ret_sts_success;
      END IF;
     ELSIF ( (p_validation_mode = 'UPDATE') OR (p_validation_mode = 'EXPIRE') ) THEN
         IF ( (p_relationship_id IS  NOT NULL) AND (p_relationship_id <> fnd_api.g_miss_num) ) THEN
             BEGIN
             /* Added the condition 'AND    ACTIVE_END_DATE IS NULL' to avoid updating expired relationship */
                     SELECT 'x'
                     INTO   l_dummy
                     FROM   csi_ii_relationships
                     WHERE  relationship_id=p_relationship_id;
                    -- AND   ( ACTIVE_END_DATE IS NULL
                    -- OR     ACTIVE_END_DATE >SYSDATE)
                    -- AND    ROWNUM=1;
                    -- IF SQL%FOUND THEN
                      x_return_status := fnd_api.g_ret_sts_success;
                    -- END IF;
              EXCEPTION
                 WHEN NO_DATA_FOUND THEN
                        fnd_message.set_name('CSI', 'CSI_INVALID_RELSHIPID');
                        fnd_msg_pub.add;
                        x_return_status := fnd_api.g_ret_sts_error;
              END;
          ELSE
                        fnd_message.set_name('CSI', 'CSI_NO_RELSHIP_ID_PASSED');
                        fnd_msg_pub.add;
                        x_return_status := fnd_api.g_ret_sts_error;
          END IF;
     END IF;



            -- standard call to get message count and if count is 1, get message info.
      fnd_msg_pub.count_AND_get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END validate_relationship_id;


PROCEDURE validate_rel_type_code (
    p_init_msg_list              IN   VARCHAR2,
    p_validation_mode            IN   VARCHAR2,
    p_relationship_type_code     IN   VARCHAR2,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2
    )
IS
l_dummy         VARCHAR2(1);
BEGIN
      -- initialize message list if p_init_msg_list is set to true.
      IF fnd_api.to_boolean( p_init_msg_list )
      THEN
          fnd_msg_pub.initialize;
      END IF;

      -- initialize api return status to success
      x_return_status := fnd_api.g_ret_sts_success;
         IF(p_validation_mode ='CREATE')
         THEN
          IF ((p_relationship_type_code IS NOT NULL) AND (p_relationship_type_code <> fnd_api.g_miss_char)) THEN
             BEGIN
               SELECT 'x'
               INTO   l_dummy
               FROM   csi_ii_relation_types
               WHERE  relationship_type_code=p_relationship_type_code;

               IF SQL%FOUND THEN
                x_return_status := fnd_api.g_ret_sts_success;
               END IF;

             EXCEPTION
              WHEN NO_DATA_FOUND THEN
                fnd_message.set_name('CSI', 'CSI_INVALID_RELSHIP_CODE');
                fnd_message.set_token('relationship_type_code',p_relationship_type_code);
                fnd_msg_pub.add;
                x_return_status := fnd_api.g_ret_sts_error;
              END;
          ELSE
             fnd_message.set_name('CSI', 'CSI_NO_RELSHIP_CODE');
             --fnd_message.set_token('relationship_type_code',p_relationship_type_code);
             fnd_msg_pub.add;
             x_return_status := fnd_api.g_ret_sts_error;

          END IF;
      ELSIF(p_validation_mode ='UPDATE')
      THEN
          IF ((p_relationship_type_code IS NOT NULL) AND (p_relationship_type_code <> fnd_api.g_miss_char)) THEN
              BEGIN
               SELECT 'x'
               INTO   l_dummy
               FROM   csi_ii_relation_types
               WHERE  relationship_type_code=p_relationship_type_code;
               IF SQL%FOUND THEN
                  x_return_status := fnd_api.g_ret_sts_success;
               END IF;
              EXCEPTION
               WHEN NO_DATA_FOUND THEN
                fnd_message.set_name('CSI', 'CSI_INVALID_RELSHIP_CODE');
                fnd_message.set_token('relationship_type_code',p_relationship_type_code);
                fnd_msg_pub.add;
                x_return_status := fnd_api.g_ret_sts_error;
              END;
           ELSIF p_relationship_type_code IS NULL -- Added for bug 2151750
           THEN
             fnd_message.set_name('CSI', 'CSI_NO_RELSHIP_CODE');
             fnd_msg_pub.add;
             x_return_status := fnd_api.g_ret_sts_error;
           END IF;
      END IF;
      -- standard call to get message count and if count is 1, get message info.
      fnd_msg_pub.count_AND_get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END validate_rel_type_code;


PROCEDURE validate_object_id (
    p_init_msg_list              IN   VARCHAR2,
    p_validation_mode            IN   VARCHAR2,
    p_object_id                  IN   NUMBER,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2
    )
IS
l_dummy                     VARCHAR2(1);
l_instance_id               NUMBER;
l_quantity                  NUMBER;
l_location_type_code        VARCHAR2(30);
l_inventory_item_id         NUMBER;
l_serial_code               NUMBER;
l_item_type                 VARCHAR2(30);
l_bom_item_type             NUMBER;
l_vld_org_id                NUMBER;
l_pick_comp_flag            VARCHAR2(1);
l_base_item_id              NUMBER;
l_repl_order_flag           VARCHAR2(1);
l_active                    VARCHAR2(1);
BEGIN

      -- initialize message list if p_init_msg_list is set to true.
      IF fnd_api.to_boolean( p_init_msg_list )
      THEN
          fnd_msg_pub.initialize;
      END IF;


      -- initialize api return status to success
      x_return_status := fnd_api.g_ret_sts_success;

      -- validate not null column
      IF(p_validation_mode ='CREATE')
      THEN
          IF ((p_object_id IS NOT NULL) AND (p_object_id <> fnd_api.g_miss_num)) THEN
          -- The following code has been added by sguthiva for bug 2416144.
             BEGIN
                SELECT 'x'
                INTO   l_active
                FROM   csi_item_instances cii
                WHERE  cii.instance_id=p_object_id
                AND   (SYSDATE BETWEEN NVL(cii.active_start_date, SYSDATE) AND NVL(cii.active_end_date, SYSDATE));
             EXCEPTION
               WHEN NO_DATA_FOUND THEN
                fnd_message.set_name('CSI', 'CSI_EXPIRED_OBJECT');
                fnd_message.set_token('object_id',p_object_id);
                fnd_msg_pub.add;
                x_return_status := fnd_api.g_ret_sts_error;
                RAISE fnd_api.g_exc_error;
             END;
          -- End of addition for bug 2416144.

             BEGIN
             -- Modified by sk for bug 2266166
             SELECT instance_id
                   ,quantity
                   ,location_type_code
                   ,inventory_item_id
                   ,last_vld_organization_id
             INTO   l_instance_id
                   ,l_quantity
                   ,l_location_type_code
                   ,l_inventory_item_id
                   ,l_vld_org_id
             FROM   csi_item_instances
             WHERE  instance_id=p_object_id;
                 IF l_quantity IS NOT NULL THEN
                     IF l_quantity<>1 THEN
                        fnd_message.set_name('CSI', 'CSI_QTY_NOTEQUAL_TO_ONE');
                        fnd_message.set_token('object_id',p_object_id);
                        fnd_msg_pub.add;
                        x_return_status := fnd_api.g_ret_sts_error;
                     END IF;
                 END IF;
                 /* commented by sk for bug 2151750
                 IF l_location_type_code IS NOT NULL THEN
                    IF UPPER(l_location_type_code) = 'INVENTORY' THEN
                        fnd_message.set_name('CSI', 'CSI_INVALID_LOCATION_TYPE');
                        fnd_message.set_token('object_id',p_object_id);
                        fnd_msg_pub.add;
                        x_return_status := fnd_api.g_ret_sts_error;
                    END IF;
                  END IF;
                  */
                    BEGIN
                        SELECT serial_number_control_code
                              ,item_type
                              ,bom_item_type
                              ,pick_components_flag
                              ,base_item_id             -- Added by rk on 9-Apr
                              ,replenish_to_order_flag  -- for bug 2304221
                        INTO   l_serial_code
                              ,l_item_type
                              ,l_bom_item_type
                              ,l_pick_comp_flag
                              ,l_base_item_id
                              ,l_repl_order_flag
                        FROM   mtl_system_items
                        WHERE  inventory_item_id = l_inventory_item_id
                        AND    organization_id   = l_vld_org_id ;
                -- Item is under serial control but serial_number is NULL
                -- '1' stands for - No serial number control
                -- '2' stands for - Predefined serial numbers
                -- '5' stands for - Dynamic entry at inventory receipt
                -- '6' stands for - Dynamic entry at sales order issue
                -- Passed object_id should be a serialized item if not it should also be an ATO/PTO item type.
                -- below code is commented by rtalluri on 05/20/02 for the bug 2255773
                /*
                        IF NVL(l_serial_code,0) IN  (2,5,6) THEN --SERIALIZED ITEM
                           NULL;
                        ELSIF NVL(l_serial_code,0)=1 AND
                              ( l_bom_item_type IN (1,2)
                              OR
                                l_pick_comp_flag = 'Y'
                              OR
                              ( l_base_item_id IS NOT NULL AND l_repl_order_flag = 'Y'))  -- fix for bug 2304221
                 */
                        IF l_quantity = 1
                        THEN
--AND NVL(l_item_type,'X') IN ('ATO','PTO') THEN --NON-SERIALIZED ITEM
-- Modified by sk for bug 2266166
                           NULL;
                        ELSE
                         fnd_message.set_name('CSI', 'CSI_NON_ATO_PTO_ITEM');
                         fnd_message.set_token('object_id',p_object_id);
                         fnd_msg_pub.add;
                         x_return_status := fnd_api.g_ret_sts_error;
                        END IF;

                    EXCEPTION
                       WHEN OTHERS THEN
                       NULL;
                    END;
             EXCEPTION
               WHEN NO_DATA_FOUND THEN
                fnd_message.set_name('CSI', 'CSI_INVALID_OBJECT_ID');
                fnd_message.set_token('object_id',p_object_id);
                fnd_msg_pub.add;
                x_return_status := fnd_api.g_ret_sts_error;
             END;
          ELSE
             fnd_message.set_name('CSI', 'CSI_NO_OBJ_ID_PASSED');
             fnd_msg_pub.add;
             x_return_status := fnd_api.g_ret_sts_error;
           END IF;

      ELSIF(p_validation_mode ='UPDATE')
      THEN
          IF ((p_object_id IS NOT NULL) AND (p_object_id <> fnd_api.g_miss_num)) THEN
             BEGIN
             -- Modified by sk for bug 2266166
             SELECT instance_id
                   ,quantity
                   ,location_type_code
                   ,inventory_item_id
                   ,last_vld_organization_id
             INTO   l_instance_id
                   ,l_quantity
                   ,l_location_type_code
                   ,l_inventory_item_id
                   ,l_vld_org_id
             FROM   csi_item_instances
             WHERE  instance_id=p_object_id;

                 IF l_quantity IS NOT NULL THEN
                     IF l_quantity<>1 THEN
                        fnd_message.set_name('CSI', 'CSI_QTY_NOTEQUAL_TO_ONE');
                        fnd_message.set_token('object_id',p_object_id);
                        fnd_msg_pub.add;
                        x_return_status := fnd_api.g_ret_sts_error;
                     END IF;
                 END IF;
                 /* commented by sk for bug 2151750
                 IF l_location_type_code IS NOT NULL THEN
                    IF UPPER(l_location_type_code) = 'INVENTORY' THEN
                        fnd_message.set_name('CSI', 'CSI_INVALID_LOCATION_TYPE');
                        fnd_message.set_token('object_id',p_object_id);
                        fnd_msg_pub.add;
                        x_return_status := fnd_api.g_ret_sts_error;
                    END IF;
                  END IF;
                  */
                    BEGIN
                        SELECT serial_number_control_code
                              ,item_type
                              ,bom_item_type
                              ,pick_components_flag
                              ,base_item_id
                              ,replenish_to_order_flag
                        INTO   l_serial_code
                              ,l_item_type
                              ,l_bom_item_type
                              ,l_pick_comp_flag
                              ,l_base_item_id        -- fix for bug 2304221
                              ,l_repl_order_flag
                        FROM   mtl_system_items
                        WHERE  inventory_item_id = l_inventory_item_id
                        AND    organization_id   = l_vld_org_id ;
                -- Item is under serial control but serial_number is NULL
                -- '1' stands for - No serial number control
                -- '2' stands for - Predefined serial numbers
                -- '5' stands for - Dynamic entry at inventory receipt
                -- '6' stands for - Dynamic entry at sales order issue
                -- Passed object_id should be a serialized item if not it should also be an ATO/PTO item type.
                -- below code is commented by rtalluri on 05/20/02 for the bug 2255773
                /*
                        IF NVL(l_serial_code,0) IN  (2,5,6) THEN --SERIALIZED ITEM
                           NULL;
                        ELSIF NVL(l_serial_code,0)=1 AND
                              ( l_bom_item_type IN (1,2)
                              OR
                                l_pick_comp_flag = 'Y'
                              OR
                              ( l_base_item_id IS NOT NULL AND l_repl_order_flag = 'Y'))  -- fix for bug 2304221
                 */
                        IF l_quantity = 1
                        THEN
--NVL(l_item_type,'X') IN ('ATO','PTO') THEN --NON-SERIALIZED ITEM
-- Modified by sk for bug 2266166
                           NULL;
                        ELSE
                         fnd_message.set_name('CSI', 'CSI_NON_ATO_PTO_ITEM');
                         fnd_message.set_token('object_id',p_object_id);
                         fnd_msg_pub.add;
                         x_return_status := fnd_api.g_ret_sts_error;
                        END IF;

                    EXCEPTION
                       WHEN OTHERS THEN
                       NULL;
                    END;

             EXCEPTION
               WHEN NO_DATA_FOUND THEN
                fnd_message.set_name('CSI', 'CSI_INVALID_OBJECT_ID');
                fnd_message.set_token('object_id',p_object_id);
                fnd_msg_pub.add;
                x_return_status := fnd_api.g_ret_sts_error;
             END;
          END IF;
      END IF;

            -- standard call to get message count and if count is 1, get message info.
      fnd_msg_pub.count_and_get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END validate_object_id;


PROCEDURE validate_subject_id (
    p_init_msg_list              IN   VARCHAR2,
    p_validation_mode            IN   VARCHAR2,
    p_subject_id                 IN   NUMBER,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2
    )
IS
l_dummy                     VARCHAR2(1);
l_instance_id               NUMBER;
l_quantity                  NUMBER;
l_location_type_code        VARCHAR2(30);
l_active                    VARCHAR2(1);
BEGIN

      -- initialize message list if p_init_msg_list is set to true.
      IF fnd_api.to_boolean( p_init_msg_list )
      THEN
          fnd_msg_pub.initialize;
      END IF;


      -- initialize API RETURN status TO success
      x_return_status := fnd_api.g_ret_sts_success;

          IF ((p_subject_id IS NOT NULL) AND (p_subject_id <> fnd_api.g_miss_num)) THEN
          -- The following code has been added by sguthiva for bug 2416144.
            IF (p_validation_mode ='CREATE')
            THEN
             BEGIN
                SELECT 'x'
                INTO   l_active
                FROM   csi_item_instances cii
                WHERE  cii.instance_id=p_subject_id
                AND   (SYSDATE BETWEEN NVL(cii.active_start_date, SYSDATE) AND NVL(cii.active_end_date, SYSDATE));
             EXCEPTION
               WHEN NO_DATA_FOUND THEN
                fnd_message.set_name('CSI', 'CSI_EXPIRED_SUBJECT');
                fnd_message.set_token('subject_id',p_subject_id);
                fnd_msg_pub.add;
                x_return_status := fnd_api.g_ret_sts_error;
                RAISE fnd_api.g_exc_error;
             END;
            END IF;
          -- End of addition for bug 2416144.
             BEGIN
             SELECT instance_id,location_type_code
             INTO   l_instance_id,l_location_type_code
             FROM   csi_item_instances
             WHERE  instance_id=p_subject_id;
             /* commented by sk for bug 2151750
                   IF l_location_type_code IS NOT NULL THEN
                    IF UPPER(l_location_type_code) = 'INVENTORY' THEN
                        fnd_message.set_name('CSI', 'CSI_INVALID_LOCATION_TYPE');
                        fnd_message.set_token('subject_id',p_subject_id);
                        fnd_msg_pub.add;
                        x_return_status := fnd_api.g_ret_sts_error;
                    END IF;
                   END IF;
              */
             EXCEPTION
               WHEN NO_DATA_FOUND THEN
                fnd_message.set_name('CSI', 'CSI_INVALID_SUBJECT_ID');
                fnd_message.set_token('subject_id',p_subject_id);
                fnd_msg_pub.add;
                x_return_status := fnd_api.g_ret_sts_error;
               END;
           END IF;
      -- standard call to get message count and if count is 1, get message info.
      fnd_msg_pub.count_AND_get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END validate_subject_id;

PROCEDURE validate_active_end_date (
    p_init_msg_list              IN   VARCHAR2,
    p_validation_mode            IN   VARCHAR2,
    p_active_end_date                IN   DATE,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2
    )
IS
BEGIN
      -- initialize message list if p_init_msg_list is set to true.
      IF fnd_api.to_boolean( p_init_msg_list )
      THEN
          fnd_msg_pub.initialize;
      END IF;


      -- initialize api return status to success
      x_return_status := fnd_api.g_ret_sts_success;
      IF(p_validation_mode ='CREATE') THEN
              IF ((p_active_end_date IS NOT NULL) AND (p_active_end_date <> fnd_api.g_miss_date)) THEN
                 fnd_message.set_name('CSI', 'CSI_ACTIVE_END_DATE');
                 fnd_message.set_token('ACTIVE_END_DATE',p_active_end_date);
                 fnd_msg_pub.add;
                 x_return_status := fnd_api.g_ret_sts_error;
              END IF;
       END IF;
          -- standard call to get message count and if count is 1, get message info.
      fnd_msg_pub.count_AND_get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END validate_active_end_date;


PROCEDURE validate_object_version_num (
    p_init_msg_list              IN   VARCHAR2,
    p_validation_mode            IN   VARCHAR2,
    p_object_version_number      IN   NUMBER,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2
    )
IS
l_dummy         VARCHAR2(1);
BEGIN

      -- initialize message list if p_init_msg_list is set to true.
      IF fnd_api.to_boolean( p_init_msg_list )
      THEN
          fnd_msg_pub.initialize;
      END IF;


      -- initialize api return status to success
      x_return_status := fnd_api.g_ret_sts_success;

      -- validate not null column


       IF( (p_validation_mode = 'UPDATE') OR (p_validation_mode = 'EXPIRE') ) THEN
          IF ( (p_object_version_number IS NULL) OR (p_object_version_number = fnd_api.g_miss_num) ) THEN
             fnd_message.set_name('CSI', 'CSI_MISSING_OBJ_VER_NUM');
             fnd_msg_pub.add;
             x_return_status := fnd_api.g_ret_sts_error;
          ELSE
             x_return_status := fnd_api.g_ret_sts_success;
          END IF;
       END IF;

      -- standard call to get message count and if count is 1, get message info.
      fnd_msg_pub.count_and_get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END validate_object_version_num;

PROCEDURE validate_ii_relationships(
    p_init_msg_list              IN   VARCHAR2,
    p_validation_level           IN   NUMBER,
    p_validation_mode            IN   VARCHAR2,
    p_ii_relationship_tbl        IN   csi_datastructures_pub.ii_relationship_tbl,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2
    )
IS
l_api_name   CONSTANT VARCHAR2(30) := 'validate_ii_relationships';
l_ct                  NUMBER;
 BEGIN



      -- initialize api return status to success
      x_return_status := fnd_api.g_ret_sts_success;

      l_ct := p_ii_relationship_tbl.count;
 FOR l_count IN 1..l_ct LOOP

-- The following IF statement has been commented out for Bug: 3271806
--      IF (p_validation_level >= fnd_api.g_valid_level_full) THEN

          validate_relationship_id(
              p_init_msg_list          => fnd_api.g_false,
              p_validation_mode        => p_validation_mode,
              p_relationship_id        => p_ii_relationship_tbl(l_count).relationship_id,
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> fnd_api.g_ret_sts_success THEN
              RAISE fnd_api.g_exc_error;
          END IF;

          validate_rel_type_code(
              p_init_msg_list          => fnd_api.g_false,
              p_validation_mode        => p_validation_mode,
              p_relationship_type_code => p_ii_relationship_tbl(l_count).relationship_type_code,
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> fnd_api.g_ret_sts_success THEN
              RAISE fnd_api.g_exc_error;
          END IF;

          validate_object_id(
              p_init_msg_list          => fnd_api.g_false,
              p_validation_mode        => p_validation_mode,
              p_object_id              => p_ii_relationship_tbl(l_count).object_id,
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> fnd_api.g_ret_sts_success THEN
              RAISE fnd_api.g_exc_error;
          END IF;

          validate_subject_id(
              p_init_msg_list          => fnd_api.g_false,
              p_validation_mode        => p_validation_mode,
              p_subject_id             => p_ii_relationship_tbl(l_count).subject_id,
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> fnd_api.g_ret_sts_success THEN
              RAISE fnd_api.g_exc_error;
          END IF;

          validate_active_end_date(
              p_init_msg_list          => fnd_api.g_false,
              p_validation_mode        => p_validation_mode,
              p_active_end_date        => p_ii_relationship_tbl(l_count).active_end_date,
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> fnd_api.g_ret_sts_success THEN
              RAISE fnd_api.g_exc_error;
          END IF;

        validate_object_version_num (
              p_init_msg_list           => fnd_api.g_false,
              p_validation_mode         => p_validation_mode,
              p_object_version_number   => p_ii_relationship_tbl(l_count).object_version_number,
              x_return_status           => x_return_status,
              x_msg_count               => x_msg_count,
              x_msg_data                => x_msg_data);

          IF x_return_status <> fnd_api.g_ret_sts_success THEN
              RAISE fnd_api.g_exc_error;
          END IF;

--      END IF;
 END LOOP;

END validate_ii_relationships;


/*----------------------------------------------------------*/
/* Procedure name:  Resolve_id_columns                      */
/* Description : This procudure gets the descriptions for   */
/*               id columns                                 */
/*----------------------------------------------------------*/

PROCEDURE  Resolve_id_columns
            (p_rel_history_tbl  IN OUT NOCOPY  csi_datastructures_pub.relationship_history_tbl)
IS

BEGIN
   IF p_rel_history_tbl.count > 0 THEN
      FOR tab_row in p_rel_history_tbl.FIRST..p_rel_history_tbl.LAST
      LOOP
	IF p_rel_history_tbl.EXISTS(tab_row) THEN
	    IF ( (p_rel_history_tbl(tab_row).relationship_type_code IS NOT NULL) AND
		 (p_rel_history_tbl(tab_row).relationship_type_code <> FND_API.G_MISS_CHAR) ) THEN
	       BEGIN
		 SELECT name
		 INTO   p_rel_history_tbl(tab_row).relationship_type
		 FROM   csi_ii_relation_types
		 WHERE  relationship_type_code = p_rel_history_tbl(tab_row).relationship_type_code;
	       EXCEPTION
		 WHEN OTHERS THEN
		   NULL;
	       END;
	    END IF;

	    IF ( (p_rel_history_tbl(tab_row).OLD_SUBJECT_ID IS NOT NULL) AND
		 (p_rel_history_tbl(tab_row).OLD_SUBJECT_ID <> FND_API.G_MISS_NUM) ) THEN
	       BEGIN
		 SELECT instance_number
		 INTO   p_rel_history_tbl(tab_row).old_subject_number
		 FROM   csi_item_instances
		 WHERE  instance_id = p_rel_history_tbl(tab_row).old_subject_id;
	       EXCEPTION
		 WHEN OTHERS THEN
		   NULL;
	       END;
	    END IF;

	    IF ( (p_rel_history_tbl(tab_row).NEW_SUBJECT_ID IS NOT NULL) AND
		 (p_rel_history_tbl(tab_row).NEW_SUBJECT_ID <> FND_API.G_MISS_NUM) ) THEN
	       BEGIN
		 SELECT instance_number
		 INTO   p_rel_history_tbl(tab_row).new_subject_number
		 FROM   csi_item_instances
		 WHERE  instance_id = p_rel_history_tbl(tab_row).new_subject_id;
	       EXCEPTION
		 WHEN OTHERS THEN
		   NULL;
	       END;
	    END IF;
	  END IF;
      END LOOP;
   END IF;
END Resolve_id_columns;


/*------------------------------------------------------------*/
/* Procedure name:  get_inst_relationship_hist                */
/* Description :    Procedure used to get inst relationships  */
/*                  from history for a given transaction_id   */
/*------------------------------------------------------------*/

PROCEDURE get_inst_relationship_hist
 (    p_api_version             IN  NUMBER
     ,p_commit                  IN  VARCHAR2 := fnd_api.g_false
     ,p_init_msg_list           IN  VARCHAR2 := fnd_api.g_false
     ,p_validation_level        IN  NUMBER   := fnd_api.g_valid_level_full
     ,p_transaction_id          IN  NUMBER
     ,x_rel_history_tbl         OUT NOCOPY csi_datastructures_pub.relationship_history_tbl
     ,x_return_status           OUT NOCOPY VARCHAR2
     ,x_msg_count               OUT NOCOPY NUMBER
     ,x_msg_data                OUT NOCOPY VARCHAR2
    )IS

     l_api_name                 CONSTANT VARCHAR2(30)   := 'get_inst_relationship_hist' ;
     l_api_version              CONSTANT NUMBER         := 1.0                          ;
     l_csi_debug_level          NUMBER                                                  ;
     l_flag                     VARCHAR2(1)             :='N'                           ;
     i                          NUMBER                  :=1                             ;
     l_relationship_query_rec   csi_datastructures_pub.relationship_query_rec           ;
     l_time_stamp               DATE                                                    ;
     l_ii_relationship_tbl      csi_datastructures_pub.ii_relationship_tbl              ;

     CURSOR get_relationship_hist(i_transaction_id NUMBER)
     IS
     SELECT
                 cih.relationship_history_id ,
                 cih.relationship_id ,
                 cih.transaction_id ,
                 cih.old_subject_id ,
                 cih.new_subject_id ,
                 cih.old_position_reference ,
                 cih.new_position_reference ,
                 cih.old_active_start_date ,
                 cih.new_active_start_date ,
                 cih.old_active_end_date ,
                 cih.new_active_end_date ,
                 cih.old_mandatory_flag ,
                 cih.new_mandatory_flag ,
                 cih.old_context ,
                 cih.new_context ,
                 cih.old_attribute1 ,
                 cih.new_attribute1 ,
                 cih.old_attribute2 ,
                 cih.new_attribute2 ,
                 cih.old_attribute3 ,
                 cih.new_attribute3 ,
                 cih.old_attribute4 ,
                 cih.new_attribute4 ,
                 cih.old_attribute5 ,
                 cih.new_attribute5 ,
                 cih.old_attribute6 ,
                 cih.new_attribute6 ,
                 cih.old_attribute7 ,
                 cih.new_attribute7 ,
                 cih.old_attribute8 ,
                 cih.new_attribute8 ,
                 cih.old_attribute9 ,
                 cih.new_attribute9 ,
                 cih.old_attribute10 ,
                 cih.new_attribute10 ,
                 cih.old_attribute11 ,
                 cih.new_attribute11 ,
                 cih.old_attribute12 ,
                 cih.new_attribute12 ,
                 cih.old_attribute13 ,
                 cih.new_attribute13 ,
                 cih.old_attribute14 ,
                 cih.new_attribute14 ,
                 cih.old_attribute15 ,
                 cih.new_attribute15 ,
                 cih.full_dump_flag ,
                 cih.object_version_number ,
                 cir.relationship_type_code ,
                 cir.object_id ,
                 cih.creation_date
     FROM     csi_ii_relationships_h cih ,
              csi_ii_relationships cir
     WHERE    cih.transaction_id     = i_transaction_id
     AND      cih.relationship_id    = cir.relationship_id;

BEGIN
        -- Standard Start of API savepoint
        --SAVEPOINT   get_inst_relationship_hist;

        -- Standard call to check for call compatibility.
        IF NOT FND_API.Compatible_API_Call (    l_api_version           ,
                                                p_api_version           ,
                                                l_api_name              ,
                                                g_pkg_name              )
        THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        -- Initialize message list if p_init_msg_list is set to TRUE.
        IF FND_API.to_Boolean( p_init_msg_list ) THEN
                FND_MSG_PUB.initialize;
        END IF;

        --  Initialize API return status to success
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        -- Check the profile option CSI_DEBUG_LEVEL for debug message reporting
        l_csi_debug_level:=fnd_profile.value('CSI_DEBUG_LEVEL');

        -- If CSI_DEBUG_LEVEL = 1 then dump the procedure name
        IF (l_csi_debug_level > 0) THEN
            csi_gen_utility_pvt.put_line( 'get_inst_relationship_hist');
        END IF;

        -- If the debug level = 2 then dump all the parameters values.
        IF (l_csi_debug_level > 1) THEN
            csi_gen_utility_pvt.put_line(  'get_inst_relationship_hist'       ||
                                                 p_api_version           ||'-'||
                                                 p_commit                ||'-'||
                                                 p_init_msg_list         ||'-'||
                                                 p_validation_level      ||'-'||
                                                 p_transaction_id               );
        END IF;

        /***** srramakr commented for bug # 3304439
        -- Check for the profile option and enable trace
        l_flag:=csi_gen_utility_pvt.enable_trace(l_trace_flag => l_flag);
        -- End enable trace
        ****/

        -- Start API body

        FOR C1 IN get_relationship_hist(p_transaction_id)
        LOOP

             x_rel_history_tbl(i).relationship_history_id    := c1.relationship_history_id;
             x_rel_history_tbl(i).relationship_id            := c1.relationship_id;
             x_rel_history_tbl(i).transaction_id             := c1.transaction_id;
             x_rel_history_tbl(i).old_subject_id             := c1.old_subject_id;
             x_rel_history_tbl(i).new_subject_id             := c1.new_subject_id;
             x_rel_history_tbl(i).old_position_reference     := c1.old_position_reference;
             x_rel_history_tbl(i).new_position_reference     := c1.new_position_reference;
             x_rel_history_tbl(i).old_active_start_date      := c1.old_active_start_date;
             x_rel_history_tbl(i).new_active_start_date      := c1.new_active_start_date;
             x_rel_history_tbl(i).old_active_end_date        := c1.old_active_end_date;
             x_rel_history_tbl(i).new_active_end_date        := c1.new_active_end_date;
             x_rel_history_tbl(i).old_mandatory_flag         := c1.old_mandatory_flag;
             x_rel_history_tbl(i).new_mandatory_flag         := c1.new_mandatory_flag;
             x_rel_history_tbl(i).old_context                := c1.old_context;
             x_rel_history_tbl(i).new_context                := c1.new_context;
             x_rel_history_tbl(i).old_attribute1             := c1.old_attribute1;
             x_rel_history_tbl(i).new_attribute1             := c1.new_attribute1;
             x_rel_history_tbl(i).old_attribute2             := c1.old_attribute2;
             x_rel_history_tbl(i).new_attribute2             := c1.new_attribute2;
             x_rel_history_tbl(i).old_attribute3             := c1.old_attribute3;
             x_rel_history_tbl(i).new_attribute3             := c1.new_attribute3;
             x_rel_history_tbl(i).old_attribute4             := c1.old_attribute4;
             x_rel_history_tbl(i).new_attribute4             := c1.new_attribute4;
             x_rel_history_tbl(i).old_attribute5             := c1.old_attribute5;
             x_rel_history_tbl(i).new_attribute5             := c1.new_attribute5;
             x_rel_history_tbl(i).old_attribute6             := c1.old_attribute6;
             x_rel_history_tbl(i).new_attribute6             := c1.new_attribute6;
             x_rel_history_tbl(i).old_attribute7             := c1.old_attribute7;
             x_rel_history_tbl(i).new_attribute7             := c1.new_attribute7;
             x_rel_history_tbl(i).old_attribute8             := c1.old_attribute8;
             x_rel_history_tbl(i).new_attribute8             := c1.new_attribute8;
             x_rel_history_tbl(i).old_attribute9             := c1.old_attribute9;
             x_rel_history_tbl(i).new_attribute9             := c1.new_attribute9;
             x_rel_history_tbl(i).old_attribute10            := c1.old_attribute10;
             x_rel_history_tbl(i).new_attribute10            := c1.new_attribute10;
             x_rel_history_tbl(i).old_attribute11            := c1.old_attribute11;
             x_rel_history_tbl(i).new_attribute11            := c1.new_attribute11;
             x_rel_history_tbl(i).old_attribute12            := c1.old_attribute12;
             x_rel_history_tbl(i).new_attribute12            := c1.new_attribute12;
             x_rel_history_tbl(i).old_attribute13            := c1.old_attribute13;
             x_rel_history_tbl(i).new_attribute13            := c1.new_attribute13;
             x_rel_history_tbl(i).old_attribute14            := c1.old_attribute14;
             x_rel_history_tbl(i).new_attribute14            := c1.new_attribute14;
             x_rel_history_tbl(i).old_attribute15            := c1.old_attribute15;
             x_rel_history_tbl(i).new_attribute15            := c1.new_attribute15;
             x_rel_history_tbl(i).full_dump_flag             := c1.full_dump_flag;
             x_rel_history_tbl(i).object_version_number      := c1.object_version_number;
             x_rel_history_tbl(i).relationship_type_code     := c1.relationship_type_code;
             x_rel_history_tbl(i).object_id                  := c1.object_id;
             x_rel_history_tbl(i).creation_date              := c1.creation_date;


             IF (
                  (x_rel_history_tbl(i).new_subject_id IS NULL)
               OR (x_rel_history_tbl(i).new_subject_id = FND_API.G_MISS_NUM)
                )
             THEN

                l_relationship_query_rec.relationship_id := x_rel_history_tbl(i).relationship_id;
                l_time_stamp                             := x_rel_history_tbl(i).creation_date;

                 get_relationships
                   (
                      p_api_version               => 1.0,
                      p_commit                    => fnd_api.g_false,
                      p_init_msg_list             => fnd_api.g_false,
                      p_validation_level          => fnd_api.g_valid_level_full,
                      p_relationship_query_rec    => l_relationship_query_rec,
                      p_depth                     => NULL,
                      p_time_stamp                => l_time_stamp,
                      p_active_relationship_only  => fnd_api.g_false,
                      x_relationship_tbl          => l_ii_relationship_tbl,
                      x_return_status             => x_return_status,
                      x_msg_count                 => x_msg_count,
                      x_msg_data                  => x_msg_data
                   );

                IF NOT(x_return_status = fnd_api.g_ret_sts_success) THEN
                   RAISE fnd_api.g_exc_error;
                END IF;
                --
                IF l_ii_relationship_tbl.count > 0 THEN
                   x_rel_history_tbl(i).new_subject_id        := l_ii_relationship_tbl(1).subject_id;
                   x_rel_history_tbl(i).old_subject_id        := l_ii_relationship_tbl(1).subject_id;
                   x_rel_history_tbl(i).object_id             := l_ii_relationship_tbl(1).object_id;
                   x_rel_history_tbl(i).old_active_start_date := l_ii_relationship_tbl(1).active_start_date;
                   x_rel_history_tbl(i).new_active_start_date := l_ii_relationship_tbl(1).active_start_date;
                   --
                END IF;
             END IF;
             i := i + 1;
       END LOOP;
        -- srramakr moved outside the loop
        -- Resolve the id columns
        csi_ii_relationships_pvt.Resolve_id_columns(x_rel_history_tbl);

       -- End of API body

       -- Standard check of p_commit.
       /*
       IF FND_API.To_Boolean( p_commit ) THEN
             COMMIT WORK;
       END IF;
       */

       /***** srramakr commented for bug # 3304439
       -- Check for the profile option and disable the trace
       IF (l_flag = 'Y') THEN
            dbms_session.set_sql_trace(false);
       END IF;
       -- End disable trace
       ****/

       -- Standard call to get message count and if count is  get message info.
       FND_MSG_PUB.Count_And_Get
                (p_count        =>      x_msg_count ,
                 p_data         =>      x_msg_data   );

EXCEPTION

        WHEN FND_API.G_EXC_ERROR THEN
             --   ROLLBACK TO get_inst_relationship_hist;
                x_return_status := FND_API.G_RET_STS_ERROR ;
                FND_MSG_PUB.Count_And_Get
                (   p_count   =>      x_msg_count,
                    p_data    =>      x_msg_data );
        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            --    ROLLBACK TO get_inst_relationship_hist;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                FND_MSG_PUB.Count_And_Get
                (   p_count   =>      x_msg_count,
                    p_data    =>      x_msg_data  );
        WHEN OTHERS THEN
             --   ROLLBACK TO get_inst_relationship_hist;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                IF      FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
                FND_MSG_PUB.Add_Exc_Msg
                (       g_pkg_name          ,
                        l_api_name           );
                END IF;
                FND_MSG_PUB.Count_And_Get
                ( p_count     =>      x_msg_count,
                  p_data      =>      x_msg_data  );

END get_inst_relationship_hist;
--
/*-------------------------------------------------------------------*/
/* Procedure name:  Get_Cyclic_node                                  */
/* Description :    Given a vertex (instance_id), it traverses thru' */
/*                  the structure and find whether a cycle exists    */
/*                  or not. If p_stop_at_cyclic is set to false,     */
/*                  it gives the complete structure in p_rel_tbl.    */
/*                  This will be Depth-First-Search order.           */
/*                  p_cyclic_node is a vertex that participates in   */
/*                  the cycle.                                       */
/* Author      :    Srinivasan Ramakrishnan                          */
/*-------------------------------------------------------------------*/
  PROCEDURE Get_Cyclic_Node
       ( p_instance_id      IN         NUMBER,
	 p_cyclic_node      OUT NOCOPY NUMBER,
	 p_rel_tbl          OUT NOCOPY csi_datastructures_pub.ii_relationship_tbl,
         p_stop_at_cyclic   IN         VARCHAR2,
	 x_return_status    OUT NOCOPY VARCHAR2,
	 x_msg_count        OUT NOCOPY NUMBER,
	 x_msg_data         OUT NOCOPY VARCHAR2 ) IS
     l_max_count    NUMBER;
     l_ctr          NUMBER;
     l_temp_id      NUMBER;
     l_found        NUMBER;
     l_node_found   NUMBER;
     l_check_id     NUMBER;
     l_exists       NUMBER;
     l_cycle_exists VARCHAR2(1);
     l_instance_id  NUMBER;
     l_msg_index    NUMBER;
     l_msg_count    NUMBER;
     l_debug_level  NUMBER;
     l_adj_node     NUMBER;
     l_rel_tbl_final csi_datastructures_pub.ii_relationship_tbl;
     l_api_name     CONSTANT VARCHAR2(50) := 'get_cyclic_node';
     --
     l_rel_color_tbl     csi_ii_relationships_pvt.REL_COLOR_TBL;
     l_rel_color_ctr     NUMBER := 0;
     --
     COMP_ERROR     EXCEPTION;
  BEGIN
     x_return_status := fnd_api.g_ret_sts_success;
     p_cyclic_node := NULL;
     l_instance_id := p_instance_id;
     --
     l_debug_level:=fnd_profile.value('CSI_DEBUG_LEVEL');
     IF (l_debug_level > 0) THEN
	CSI_gen_utility_pvt.put_line( 'Get_Cyclic_Node');
     END IF;
     --
     csi_ii_relationships_pvt.get_cyclic_relationships(
	      p_api_version                => 1.0,
	      p_commit                     => fnd_api.g_false,
	      p_init_msg_list              => fnd_api.g_true,
	      p_validation_level           => fnd_api.g_valid_level_full,
	      p_instance_id                => l_instance_id,
	      p_depth                      => NULL ,
	      p_time_stamp                 => fnd_api.g_miss_date,
	      p_active_relationship_only   => fnd_api.g_true,
	      x_relationship_tbl           => p_rel_tbl,
	      x_return_status              => x_return_status,
	      x_msg_count                  => x_msg_count,
	      x_msg_data                   => x_msg_data
	   );
     --
     IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
	l_msg_index := 1;
	l_msg_count := x_msg_count;
	WHILE l_msg_count > 0 LOOP
	   x_msg_data := FND_MSG_PUB.GET
			    (  l_msg_index,
			       FND_API.G_FALSE );
	   csi_gen_utility_pvt.put_line( ' Error from Get_cyclic_relationships.. ');
	   csi_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
	   l_msg_index := l_msg_index + 1;
	   l_msg_count := l_msg_count - 1;
	END LOOP;
	RAISE FND_API.G_EXC_ERROR;
     END IF;
     --
     csi_gen_utility_pvt.put_line('p_rel_tbl count after get_cyclic_relationships is '
					  ||to_char(p_rel_tbl.count));
     l_rel_tbl_final.DELETE;
     l_rel_tbl_final := p_rel_tbl;
     p_rel_tbl.DELETE;
     l_ctr := 0;
     l_rel_color_ctr := 0;
     --
     -- The output of l_rel_tbl_final will be Breadth first search Order.
     -- This needs to be converted to depth-first-search(DFS) order since DFS is capable of
     -- hitting the cyclic node.
     --
     -- There is no concept of Parent-Child in a graph structure. All we do in a DFS is, given a
     -- vertex, we try to get its adjacent node and walk thru' the graph.
     -- Since in CSI_II_RELATIONSHIPS table, they are identified as Object_id and Subject_id
     -- we pick up the adjacent node in whichever form it appears (object or subject).
     --
     -- The following LOOP does this.
     --
     IF l_rel_tbl_final.count > 0 THEN
	l_max_count := l_rel_tbl_final.count;
	l_temp_id := l_instance_id;
	LOOP
	   IF p_rel_tbl.count = l_max_count OR
	   l_rel_tbl_final.count = 0 THEN
	      exit;
	   END IF;
	   --
           csi_gen_utility_pvt.put_line('Processing '||to_char(l_temp_id));
           --
	   FOR rel IN l_rel_tbl_final.FIRST .. l_rel_tbl_final.LAST LOOP
	      l_found := 0;
              l_adj_node := -9999;
              --
	      IF l_rel_tbl_final.EXISTS(rel) THEN
                 -- Try to get the Adjacent Node
		 IF l_rel_tbl_final(rel).object_id = l_temp_id THEN
                    l_adj_node := l_rel_tbl_final(rel).subject_id;
		    l_found := 1;
                 ELSIF l_rel_tbl_final(rel).subject_id = l_temp_id THEN
                    l_adj_node := l_rel_tbl_final(rel).object_id;
                    l_found := 1;
                 END IF;
                 --
                 IF l_found = 1 THEN
		    l_ctr := l_ctr + 1;
		    p_rel_tbl(l_ctr) := l_rel_tbl_final(rel); -- Push the processed row
                    -- Add the current node if not exists in the visited list
                    l_exists := 0;
                    IF l_rel_color_tbl.count > 0 THEN
                       FOR rel_color in l_rel_color_tbl.FIRST .. l_rel_color_tbl.LAST LOOP
                          IF l_rel_color_tbl(rel_color).node_id = l_temp_id THEN
                             l_exists := 1;
                             exit;
                          END IF;
                       END LOOP;
                    END IF;
                    --
                    IF l_exists = 0 THEN
	               l_rel_color_ctr := l_rel_color_ctr + 1;
	               l_rel_color_tbl(l_rel_color_ctr).node_id := l_temp_id;
	               l_rel_color_tbl(l_rel_color_ctr).color_code := 'R';
                    END IF;
                    --
		    l_temp_id := l_adj_node; -- set this to the adjacent node and continue
		    l_rel_tbl_final.DELETE(rel); -- Pop the processed row
                    --
                    -- Check for cycle
		    IF l_rel_color_tbl.count > 0 THEN
		       FOR color_rec in l_rel_color_tbl.FIRST .. l_rel_color_tbl.LAST LOOP
			  IF l_rel_color_tbl(color_rec).node_id = l_temp_id AND -- adjacent node
			     l_rel_color_tbl(color_rec).color_code = 'R' THEN
			     p_cyclic_node := l_temp_id;
                             IF nvl(p_stop_at_cyclic,fnd_api.g_true) = fnd_api.g_true THEN
                                csi_gen_utility_pvt.put_line('Cycle exists at '||to_char(p_cyclic_node));
			        Raise COMP_ERROR;
                             END IF;
			  END IF;
		       END LOOP;
		    END IF; -- end of check for cycle
		    exit;
		 END IF; -- l_found = 1
	      END IF;
	   END LOOP;
	   --
	   IF l_found = 0 THEN -- If No more components then go back
	      -- If all the nodes under the current node are traversed then mark the node as 'B'.
	      -- The reason for marking this to 'B' is to eliminate this node while getting
              -- the previous visited node
	      l_node_found := 0;
	      IF l_rel_color_tbl.count > 0 THEN
		 FOR mark in l_rel_color_tbl.FIRST .. l_rel_color_tbl.LAST LOOP
		    IF l_rel_color_tbl(mark).node_id = l_temp_id THEN
		       l_rel_color_tbl(mark).color_code := 'B';
		       l_node_found := 1;
                       csi_gen_utility_pvt.put_line('Marked '||l_temp_id);
                       exit;
		    END IF;
		 END LOOP;
	      END IF;
	      --
	      IF l_node_found = 0 THEN
		 l_rel_color_ctr := l_rel_color_ctr + 1;
		 l_rel_color_tbl(l_rel_color_ctr).node_id := l_temp_id;
		 l_rel_color_tbl(l_rel_color_ctr).color_code := 'B'; -- since l_found = 0
                 csi_gen_utility_pvt.put_line('Marked '||l_temp_id);
	      END IF;
	      --
              -- Get the unmarked node from l_rel_color_tbl in Reverse direction
              -- The idea is to go back in the same path once a node is marked as 'B'.
              FOR adj IN REVERSE l_rel_color_tbl.FIRST .. l_rel_color_tbl.LAST LOOP
                 IF l_rel_color_tbl(adj).color_code = 'R' THEN
                    l_temp_id := l_rel_color_tbl(adj).node_id;
                    exit;
                 END IF;
              END LOOP;
              --
              csi_gen_utility_pvt.put_line('Adjacent Node is '||l_temp_id);
	      IF l_temp_id = -9999 THEN
		 csi_gen_utility_pvt.put_line('Unable to get the Adjacent Node.. Exiting...');
		 Raise FND_API.G_EXC_UNEXPECTED_ERROR;
	      END IF;
	   END IF; -- l_found = 0 check
	END LOOP;
     END IF;
     csi_gen_utility_pvt.put_line('End of Get_Cyclic_Node...');
  EXCEPTION
     WHEN COMP_ERROR THEN
	null;
     WHEN FND_API.G_EXC_ERROR THEN
	x_return_status := fnd_api.g_ret_sts_error ;
	fnd_msg_pub.count_AND_get
	   (p_count => x_msg_count ,
	    p_data => x_msg_data
	   );

     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	x_return_status := fnd_api.g_ret_sts_unexp_error ;
	fnd_msg_pub.count_AND_get
	   (p_count => x_msg_count ,
	    p_data => x_msg_data
	   );

     WHEN OTHERS THEN
	x_return_status := fnd_api.g_ret_sts_unexp_error ;
	IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
	   fnd_msg_pub.add_exc_msg(g_pkg_name,l_api_name);
	END IF;
	fnd_msg_pub.count_AND_get
	   (p_count => x_msg_count ,
	    p_data => x_msg_data
	   );
  END Get_Cyclic_Node;

-- Begin Add Code for Siebel Genesis Project
FUNCTION Get_Root_Parent
(
    p_subject_id      IN  NUMBER,
    p_rel_type_code   IN  VARCHAR2,
    p_object_id       IN  NUMBER
) RETURN NUMBER
IS
    l_object_id       NUMBER;
    l_root_object_id  NUMBER;
BEGIN
    IF p_rel_type_code IS NULL OR
       p_subject_id IS NULL THEN
       l_object_id := p_object_id;
       RETURN l_object_id;
    END IF;

    l_object_id := p_subject_id;

    Begin
        select object_id
        into   l_object_id
        from   CSI_II_RELATIONSHIPS
        where subject_id = p_subject_id
        and   relationship_type_code = p_rel_type_code
        and   ((active_end_date is null) or (active_end_date > sysdate));
     Exception
        when no_data_found then
           l_object_id := p_subject_id;
           RETURN l_object_id;
     End;
     -- Call Recursively for prior parent
     Get_Top_Most_Parent
          (p_subject_id      => l_object_id,
           p_rel_type_code   => p_rel_type_code,
           p_object_id       => l_root_object_id
          );
     return l_root_object_id;
END Get_Root_Parent;
-- End Add Code for Siebel Genesis Project

END csi_ii_relationships_pvt;

/
