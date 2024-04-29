--------------------------------------------------------
--  DDL for Package Body CN_TABLE_MAPS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_TABLE_MAPS_PVT" AS
/* $Header: cnvtmapb.pls 120.8 2006/01/11 23:53:52 apink noship $ */

G_PKG_NAME        CONSTANT VARCHAR2(30) := 'CN_TABLE_MAPS_PVT';
G_LAST_UPDATE_DATE          	DATE    := SYSDATE;
G_LAST_UPDATED_BY           	NUMBER  := fnd_global.user_id;
G_CREATION_DATE             	DATE    := SYSDATE;
G_CREATED_BY                	NUMBER  := fnd_global.user_id;
G_LAST_UPDATE_LOGIN        	NUMBER  := fnd_global.login_id;

-----------------------------------------------------------------------------+
-- Procedure   : Create_Map
-----------------------------------------------------------------------------+
PROCEDURE Create_Map (
   p_api_version       IN NUMBER,
   p_init_msg_list     IN VARCHAR2 := FND_API.G_FALSE,
   p_commit            IN VARCHAR2 := FND_API.G_FALSE,
   p_validation_level  IN  NUMBER  := FND_API.G_VALID_LEVEL_FULL,
   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,
   p_source_name       IN  VARCHAR2 ,
   p_table_map_rec     IN OUT NOCOPY table_map_rec_type,
   x_event_id_out      OUT NOCOPY NUMBER    -- Modified For R12
 ) IS
     l_api_name                  CONSTANT VARCHAR2(30) := 'Create_Map';
     l_api_version               CONSTANT NUMBER  := 1.0;
     l_rowid                     ROWID;
     l_event_id                  cn_events.event_id%TYPE;
     l_application_repository_id cn_events.application_repository_id%TYPE;
     l_parent_module_id          cn_modules.parent_module_id%TYPE;
     l_user_id                   NUMBER := nvl(fnd_profile.value('USER_ID'),-1);
     l_column_map_id             cn_column_maps.column_map_id%TYPE;
     l_object_id                 cn_objects.object_id%TYPE;
     l_table_map_object_id       cn_table_map_objects.object_id%TYPE;
     l_org_append                VARCHAR2(100);
     l_count  NUMBER;

     -- Variable For ORG_ID Value - MOAC Change
     l_org_id   NUMBER;

     -- Variable for Notes
     l_note_msg	   VARCHAR2(4000);
     l_object_name	   VARCHAR2(4000);
     x_note_id	   NUMBER;

     CURSOR get_object_name(x_object_id NUMBER, x_org_id NUMBER) IS
     SELECT name
     FROM   CN_OBJECTS
     WHERE  object_id = x_object_id
     AND    org_id = x_org_id;


BEGIN
     -- Standard Start of API savepoint
     SAVEPOINT	Create_Map;
     -- Standard call to check for call compatibility.
     IF NOT FND_API.Compatible_API_Call (l_api_version,
                                         p_api_version,
                                         l_api_name,
                                         G_PKG_NAME)
     THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

     -- Standard Check For Create Operations to validate the
     -- ORG_ID by calling the common validation utility.


     l_org_id := MO_GLOBAL.get_valid_org(p_table_map_rec.org_id);

     cn_collection_gen.set_org_id(l_org_id);
     l_org_append  := cn_collection_gen.get_org_append;


     IF l_org_id is NULL THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
         RAISE FND_API.G_EXC_ERROR;
     END IF;

     -- Initialize message list if p_init_msg_list is set to TRUE.
     IF FND_API.to_Boolean(p_init_msg_list) THEN
         FND_MSG_PUB.initialize;
     END IF;
     --  Initialize API return status to success
     x_return_status := FND_API.G_RET_STS_SUCCESS;
	------------------+
     -- API body
	------------------+
     --+
     --+ Remove spaces in Mapping_Type
     --+
     p_table_map_rec.mapping_type := TRANSLATE(p_table_map_rec.mapping_type,' ','_');

     p_table_map_rec.creation_date := SYSDATE;
     p_table_map_rec.last_update_date := SYSDATE;

      -- Check if the mapping type exists.
      SELECT count(1)
        INTO l_count
        FROM cn_table_maps
       WHERE mapping_type = p_table_map_rec.mapping_type
       AND org_id = l_org_id;

     IF l_count >= 1 THEN
	 -- Ensure that a mapping type must be unique.
    	 IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
    	   THEN
    	    fnd_message.set_name('CN', 'CL_UNIQUE_MAPPING_TYPE');
    	    fnd_msg_pub.add;
    	 END IF;
    	 RAISE FND_API.G_EXC_ERROR;
      END IF;

     --+
     --+ Get Repository_Id, Parent_Module_Id and Event_Id
     --+
     SELECT repository_id, module_id
       INTO   l_application_repository_id, l_parent_module_id
       FROM   cn_modules
       WHERE  module_type = 'COL'
       AND    org_id = l_org_id;

     SELECT cn_events_s.NEXTVAL
       INTO l_event_id
       FROM dual;

      --+
      --+ Sending Event Id Back, As Required By TableMapsEO. If Update
      --+ Happens Right After Create
      --+ Modified For R12
      --+
         x_event_id_out := l_event_id;
     --+
     --+ Create Event
     --+ Added ORG_ID MOAC Change
     --+

     cn_events_all_pkg.insert_row (
       x_rowid                      => l_rowid,
       x_event_id                   => l_event_id,
       x_application_repository_id  => l_application_repository_id,
       x_description                => NULL,
       x_name                       => p_source_name,
       x_creation_date              => p_table_map_rec.creation_date,
       x_created_by                 => p_table_map_rec.created_by,
       x_last_update_date           => p_table_map_rec.last_update_date,
       x_last_updated_by            => p_table_map_rec.last_updated_by,
       x_last_update_login          => p_table_map_rec.last_update_login,
       x_org_id                     => p_table_map_rec.org_id);



    --+
	--+ Get Module_Id
	--+
	SELECT cn_modules_s.NEXTVAL
	INTO p_table_map_rec.module_id
	FROM dual;
    --+
	--+ Create Module using Source Name and Event Id
    --+ Added ORG_ID MOAC Change
	--+
     cn_modules_pkg.insert_row (
       x_rowid                 => l_rowid,
       x_module_id             => p_table_map_rec.module_id,
       x_module_type           => p_table_map_rec.mapping_type,
       x_repository_id         => l_application_repository_id,
       x_description           => NULL,
       x_parent_module_id      => l_parent_module_id,
       x_source_repository_id  => NULL,
       x_module_status         => 'UNSYNC',
       x_event_id              => l_event_id,
       x_last_modification     => SYSDATE,
       x_last_synchronization  => NULL,
       x_output_filename       => NULL,
       x_collect_flag          => 'YES',
       x_name                  => p_source_name,
       x_creation_date         => p_table_map_rec.creation_date,
       x_created_by            => p_table_map_rec.created_by,
       x_last_update_date      => p_table_map_rec.last_update_date,
       x_last_updated_by       => p_table_map_rec.last_updated_by,
       x_last_update_login     => p_table_map_rec.last_update_login,
       x_org_id                => p_table_map_rec.org_id);

	--+
	--+ cn_table_maps.source_table_id is a legacy column, but is NOT NULL so we
    --+ must fill it. However, we must make sure that it is the table to which
    --+ the source_tbl_pkcol_id belongs...
	--+
    --+ SELECT table_id
    --+ INTO   p_table_map_rec.source_table_id
    --+ FROM   cn_obj_columns_v
    --+ WHERE  column_id = p_table_map_rec.source_tbl_pkcol_id;

     SELECT table_id
     INTO   p_table_map_rec.source_table_id
     FROM   CN_OBJECTS
     WHERE  object_type = 'COL'
     AND    object_id = p_table_map_rec.source_tbl_pkcol_id
     AND    org_id = p_table_map_rec.org_id;

    --+
    --+ Select Destination Table Id For CN_COMM_LINES_API
    --+ As It Is Required Column In CN_TABLE_MAPS_ALL
	--+

    SELECT  object_id
    INTO    p_table_map_rec.destination_table_id
    FROM    cn_objects
    WHERE   name = 'CN_COMM_LINES_API'
    AND    org_id = p_table_map_rec.org_id;

	--+ Create Table Map that points to Module
	--+
	IF p_table_map_rec.delete_flag IS NULL THEN
	   p_table_map_rec.delete_flag := 'N';
     END IF;
     cn_table_maps_pkg.insert_row(
       x_rowid                    => l_rowid,
       x_table_map_id             => p_table_map_rec.table_map_id,  -- autocreated if left null
       x_mapping_type             => p_table_map_rec.mapping_type,
       x_module_id                => p_table_map_rec.module_id,
       x_source_table_id          => p_table_map_rec.source_table_id,
       x_source_tbl_pkcol_id      => p_table_map_rec.source_tbl_pkcol_id,
       x_destination_table_id     => p_table_map_rec.destination_table_id,
       x_source_hdr_tbl_pkcol_id  => p_table_map_rec.source_hdr_tbl_pkcol_id,
       x_source_tbl_hdr_fkcol_id  => p_table_map_rec.source_tbl_hdr_fkcol_id,
       x_notify_where             => p_table_map_rec.notify_where,
       x_collect_where            => p_table_map_rec.collect_where,
       x_delete_flag              => p_table_map_rec.delete_flag,
       x_creation_date            => p_table_map_rec.creation_date,
       x_created_by               => p_table_map_rec.created_by,
       x_org_id                   => p_table_map_rec.org_id);

    --+
	--+ Create mandatory column-mapping mapping rows
	--+

     FOR rec IN
         (SELECT *
          FROM cn_column_maps
          WHERE table_map_id = -999
          AND org_id = l_org_id) -- MOAC Need To Verify
     LOOP
	   l_column_map_id := NULL;  -- set inside the procedure
        cn_column_maps_pkg.insert_row (
                 x_rowid                  => l_rowid,
                 x_column_map_id          => l_column_map_id,
                 x_destination_column_id  => rec.destination_column_id,
                 x_table_map_id           => p_table_map_rec.table_map_id,
                 x_expression             => rec.expression,
                 x_editable               => rec.editable,
                 x_modified               => rec.modified,
                 x_update_clause          => rec.update_clause,
                 x_calc_ext_table_id      => rec.calc_ext_table_id,
                 --x_creation_date          => p_table_map_rec.creation_date,
                 x_creation_date          => SYSDATE,
                 x_created_by             => p_table_map_rec.created_by,
                 x_org_id                 => p_table_map_rec.org_id);
     END LOOP;
	--+
	--+ Create Collection Package Spec and Body objects
	--+

     Create_Table_Map_Object (
        p_api_version       => 1.0,
        x_return_status     => x_return_status,
        x_msg_count         => x_msg_count,
        x_msg_data          => x_msg_data,
        p_table_map_id      => p_table_map_rec.table_map_id,
        p_object_name       => 'cn_collect_'||LOWER(p_table_map_rec.mapping_type)||l_org_append,
        p_tm_object_type    => 'PKS',
        p_creation_date     => p_table_map_rec.creation_date,
        p_created_by        => p_table_map_rec.created_by,
        x_table_map_object_id => l_table_map_object_id,
        x_object_id           => l_object_id,
        x_org_id              => p_table_map_rec.org_id);

     Create_Table_Map_Object (
        p_api_version       => 1.0,
        x_return_status     => x_return_status,
        x_msg_count         => x_msg_count,
        x_msg_data          => x_msg_data,
        p_table_map_id      => p_table_map_rec.table_map_id,
        p_object_name       => 'cn_collect_'||LOWER(p_table_map_rec.mapping_type)||l_org_append,
        p_tm_object_type    => 'PKB',
        p_creation_date     => p_table_map_rec.creation_date,
        p_created_by        => p_table_map_rec.created_by,
        x_table_map_object_id => l_table_map_object_id,
        x_object_id           => l_object_id,
        x_org_id              => p_table_map_rec.org_id);

	------------------+
     -- End of API body.
	------------------+
     -- Standard check of p_commit.
     --IF FND_API.To_Boolean( p_commit ) THEN
     --    COMMIT WORK;
     --END IF;
     -- Standard call to get message count and if count is 1, get message info.
     FND_MSG_PUB.Count_And_Get
                        (p_count   =>  x_msg_count ,
                         p_data    =>  x_msg_data  ,
                         p_encoded => FND_API.G_FALSE);

    -- Creating notes for the new Transaction Source. Code written here because the
    -- sequence is generated in the Pl/SQL call
    FND_MESSAGE.SET_NAME('CN', 'CN_TRANS_SRC_ATTR_INSERT_NOTE');
    FND_MESSAGE.SET_TOKEN('ATTRIBUTE', 'Transaction Source');
    FND_MESSAGE.SET_TOKEN('VALUE',p_source_name);
    l_note_msg := FND_MESSAGE.GET;

    jtf_notes_pub.create_note
     ( p_api_version           => 1.0,
       x_return_status         => x_return_status,
       x_msg_count             => x_msg_count,
       x_msg_data              => x_msg_data,
       p_source_object_id      => p_table_map_rec.table_map_id,
       p_source_object_code    => 'CN_TABLE_MAPS',
       p_notes                 => l_note_msg,
       p_notes_detail          => l_note_msg,
       p_note_type             => 'CN_SYSGEN',
       x_jtf_note_id           => x_note_id
       );

    -- Adding notes for Transaction Source Type
    FND_MESSAGE.SET_NAME('CN', 'CN_TRANS_SRC_ATTR_INSERT_NOTE');
    FND_MESSAGE.SET_TOKEN('ATTRIBUTE', 'Transaction Source Type');
    FND_MESSAGE.SET_TOKEN('VALUE',p_table_map_rec.mapping_type);
    l_note_msg := FND_MESSAGE.GET;

    jtf_notes_pub.create_note
     ( p_api_version           => 1.0,
       x_return_status         => x_return_status,
       x_msg_count             => x_msg_count,
       x_msg_data              => x_msg_data,
       p_source_object_id      => p_table_map_rec.table_map_id,
       p_source_object_code    => 'CN_TABLE_MAPS',
       p_notes                 => l_note_msg,
       p_notes_detail          => l_note_msg,
       p_note_type             => 'CN_SYSGEN',
       x_jtf_note_id           => x_note_id
       );

    -- Creating notes for Source Table entry
    OPEN get_object_name(p_table_map_rec.source_table_id, p_table_map_rec.org_id);
    FETCH get_object_name INTO l_object_name;
    CLOSE get_object_name;

    FND_MESSAGE.SET_NAME('CN', 'CN_TRANS_SRC_ATTR_INSERT_NOTE');
    FND_MESSAGE.SET_TOKEN('ATTRIBUTE', 'Line Table');
    FND_MESSAGE.SET_TOKEN('VALUE',l_object_name);
    l_note_msg := FND_MESSAGE.GET;

    jtf_notes_pub.create_note
     ( p_api_version           => 1.0,
       x_return_status         => x_return_status,
       x_msg_count             => x_msg_count,
       x_msg_data              => x_msg_data,
       p_source_object_id      => p_table_map_rec.table_map_id,
       p_source_object_code    => 'CN_TABLE_MAPS',
       p_notes                 => l_note_msg,
       p_notes_detail          => l_note_msg,
       p_note_type             => 'CN_SYSGEN',
       x_jtf_note_id           => x_note_id
       );

    -- Creating notes for Source Table Key Column entry
    OPEN get_object_name(p_table_map_rec.source_tbl_pkcol_id, p_table_map_rec.org_id);
    FETCH get_object_name INTO l_object_name;
    CLOSE get_object_name;

    FND_MESSAGE.SET_NAME('CN', 'CN_TRANS_SRC_ATTR_INSERT_NOTE');
    FND_MESSAGE.SET_TOKEN('ATTRIBUTE', 'Line Table Key Column');
    FND_MESSAGE.SET_TOKEN('VALUE',l_object_name);
    l_note_msg := FND_MESSAGE.GET;

    jtf_notes_pub.create_note
     ( p_api_version           => 1.0,
       x_return_status         => x_return_status,
       x_msg_count             => x_msg_count,
       x_msg_data              => x_msg_data,
       p_source_object_id      => p_table_map_rec.table_map_id,
       p_source_object_code    => 'CN_TABLE_MAPS',
       p_notes                 => l_note_msg,
       p_notes_detail          => l_note_msg,
       p_note_type             => 'CN_SYSGEN',
       x_jtf_note_id           => x_note_id
       );

     EXCEPTION
         WHEN FND_API.G_EXC_ERROR THEN
             ROLLBACK TO Create_Map;
             x_return_status := FND_API.G_RET_STS_ERROR ;
             FND_MSG_PUB.Count_And_Get
                             (p_count   => x_msg_count,
                              p_data    => x_msg_data,
                              p_encoded => FND_API.G_FALSE);
         WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
             ROLLBACK TO Create_Map;
             x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
             FND_MSG_PUB.Count_And_Get
                             (p_count   => x_msg_count,
                              p_data    => x_msg_data,
                              p_encoded => FND_API.G_FALSE);
         WHEN OTHERS THEN
             ROLLBACK TO Create_Map;
             x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
             IF FND_MSG_PUB.Check_Msg_Level
                                (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
                 FND_MSG_PUB.Add_Exc_Msg
                                (G_PKG_NAME,
                                 l_api_name );
             END IF;
             FND_MSG_PUB.Count_And_Get
                             (p_count   => x_msg_count,
                              p_data    => x_msg_data,
                              p_encoded => FND_API.G_FALSE);
END Create_Map;


-----------------------------------------------------------------------------+
-- Procedure   : Delete_Map
-- HITHANKI Modified For R12
-----------------------------------------------------------------------------+
PROCEDURE Delete_Map
(  p_api_version       IN NUMBER,
   p_init_msg_list     IN VARCHAR2 := FND_API.G_FALSE,
   p_commit            IN VARCHAR2 := FND_API.G_FALSE,
   p_validation_level  IN  NUMBER  := FND_API.G_VALID_LEVEL_FULL,
   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,
   p_table_map_id      IN  NUMBER,
   p_org_id            IN NUMBER    -- Added For R12 MOAC
 ) IS
     l_api_name                  CONSTANT VARCHAR2(30) := 'Delete_Map';
     l_api_version               CONSTANT NUMBER  := 1.0;
     l_rowid                     ROWID;
     l_event_id                  cn_events.event_id%TYPE;
     l_pkg_spec_id               cn_objects.object_id%TYPE;
     l_pkg_body_id               cn_objects.object_id%TYPE;

     CURSOR c_table_map IS
       SELECT * FROM cn_table_maps_v
       WHERE table_map_id = p_table_map_id
       AND org_id = p_org_id;  -- Added For MOAC
       -- Need To Change This View Definition
       -- And Then Add This Clause
       --AND org_id = p_org_id;  -- Added For MOAC

     l_table_map_rec c_table_map%ROWTYPE;
     l_org_append                VARCHAR2(100) ;

     CURSOR l_pks_csr(p_mapping_type VARCHAR2,p_org_append VARCHAR2) IS
	SELECT object_id
	  FROM cn_objects
	  WHERE object_type = 'PKS'
	  AND name = 'cn_collect_'||LOWER(p_mapping_type)||p_org_append
      AND org_id = p_org_id; -- Added For MOAC

     CURSOR l_pkb_csr(p_mapping_type VARCHAR2,p_org_append VARCHAR2) IS
	SELECT object_id
	  FROM cn_objects
	  WHERE object_type = 'PKB'
	  AND name = 'cn_collect_'||LOWER(p_mapping_type)||p_org_append
      AND org_id = p_org_id; -- Added For MOAC

BEGIN
     -- Standard Start of API savepoint
     SAVEPOINT	Delete_Map;
     -- Standard call to check for call compatibility.
     IF NOT FND_API.Compatible_API_Call (l_api_version,
                                         p_api_version,
                                         l_api_name,
                                         G_PKG_NAME)
     THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;
     -- Initialize message list if p_init_msg_list is set to TRUE.
     IF FND_API.to_Boolean( p_init_msg_list ) THEN
         FND_MSG_PUB.initialize;
     END IF;
     --  Initialize API return status to success
     x_return_status := FND_API.G_RET_STS_SUCCESS;


    --Changed by Ashley as part of MOACing exercise
     cn_collection_gen.set_org_id(p_org_id);
     l_org_append  := cn_collection_gen.get_org_append;

	-------------------+
     -- API body
	-------------------+
	--+
	--+ Cannot delete seeded table map
	--+
	IF p_table_map_id < 0 THEN
         RAISE FND_API.G_EXC_ERROR;
	END IF;
     --+
     --+ Get information about the map to be deleted
     --+
     OPEN c_table_map;
     FETCH c_table_map INTO l_table_map_rec;
     CLOSE c_table_map;
     --+
	--+ Delete Event
	--+
     cn_events_all_pkg.delete_row (x_event_id => l_table_map_rec.event_id,
     x_org_id => p_org_id); -- Added For R12 MOAC
     --+
	--+ Delete Module
	--+
     cn_modules_pkg.delete_row (x_module_id => l_table_map_rec.module_id,
     x_org_id => p_org_id); -- Added For R12 MOAC
	--+
	--+ Delete Table Map
	--+
     cn_table_maps_pkg.delete_row(x_table_map_id => p_table_map_id,
     x_org_id => p_org_id); -- Added For R12 MOAC
    --+
	--+ Delete column-mapping mapping rows
	--+
     DELETE FROM cn_column_maps
     WHERE table_map_id = p_table_map_id
     AND org_id = p_org_id; -- Added For R12 MOAC
     --+
     --+ Delete Collection Package Spec and Body objects
     --+

     -- SELECT object_id
     -- INTO l_pkg_spec_id
     -- FROM cn_objects
     -- WHERE object_type = 'PKS'
     --      AND name = 'cn_collect_'||LOWER(l_table_map_rec.mapping_type)||l_org_append;
     -- SELECT object_id
     -- INTO l_pkg_body_id
     -- FROM cn_objects
     -- WHERE object_type = 'PKB'
     --      AND name = 'cn_collect_'||LOWER(l_table_map_rec.mapping_type)||l_org_append;

     OPEN  l_pks_csr(l_table_map_rec.mapping_type, l_org_append);
     FETCH l_pks_csr INTO l_pkg_spec_id;
     CLOSE l_pks_csr;

     OPEN  l_pkb_csr(l_table_map_rec.mapping_type, l_org_append);
     FETCH l_pkb_csr INTO l_pkg_body_id;
     CLOSE l_pkb_csr;

     DELETE FROM cn_source WHERE object_id IN (l_pkg_spec_id, l_pkg_body_id);
     DELETE FROM cn_objects WHERE object_id IN (l_pkg_spec_id, l_pkg_body_id);
	--+
	-- Delete Table Map Objects
	--+
	FOR rec IN
       (SELECT table_map_object_id,
               UPPER(tm_object_type) tm_object_type,
               object_id
        FROM   cn_table_map_objects
        WHERE  table_map_id = p_table_map_id
        AND    org_id = p_org_id) -- Added For R12 MOAC
     LOOP
       IF rec.tm_object_type IN ('PARAM','FILTER','PKS','PKB') THEN
	    --+
	    -- Object belongs exclusively to Collections and can be deleted
	    --+
         delete_table_map_Object (
            p_api_version       => 1.0,
            x_return_status     => x_return_status,
            x_msg_count         => x_msg_count,
            x_msg_data          => x_msg_data,
            p_table_map_object_id => rec.table_map_object_id,
            x_org_id => p_org_id); -- Added For R12 MOAC
       ELSE
	    --+
	    -- Collections only created the reference to the object, so just
	    -- delete that.
	    --+
         cn_table_map_objects_pkg.delete_row(rec.table_map_object_id,p_org_id);
       END IF;
     END LOOP;
	-------------------+
     -- End of API body.
	-------------------+
     -- Standard check of p_commit.
     --IF FND_API.To_Boolean( p_commit ) THEN
     --   COMMIT WORK;
     --END IF;
     -- Standard call to get message count and if count is 1, get message info.
     FND_MSG_PUB.Count_And_Get
                        (p_count   =>  x_msg_count ,
                         p_data    =>  x_msg_data  ,
                         p_encoded => FND_API.G_FALSE);
     EXCEPTION
         WHEN FND_API.G_EXC_ERROR THEN
             ROLLBACK TO Delete_Map;
             x_return_status := FND_API.G_RET_STS_ERROR ;
             FND_MSG_PUB.Count_And_Get
                             (p_count   => x_msg_count,
                              p_data    => x_msg_data,
                              p_encoded => FND_API.G_FALSE);
         WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
             ROLLBACK TO Delete_Map;
             x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
             FND_MSG_PUB.Count_And_Get
                             (p_count   => x_msg_count,
                              p_data    => x_msg_data,
                              p_encoded => FND_API.G_FALSE);
         WHEN OTHERS THEN
             ROLLBACK TO Delete_Map;
             x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
             IF FND_MSG_PUB.Check_Msg_Level
                                (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
                 FND_MSG_PUB.Add_Exc_Msg
                                (G_PKG_NAME,
                                 l_api_name );
             END IF;
             FND_MSG_PUB.Count_And_Get
                             (p_count   => x_msg_count,
                              p_data    => x_msg_data,
                              p_encoded => FND_API.G_FALSE);
END Delete_Map;


-----------------------------------------------------------------------------+
-- Procedure   : Update_Table_Map_Objects
-----------------------------------------------------------------------------+

PROCEDURE Update_Table_Map_Objects
     (
      p_api_version   	            IN      NUMBER,
      p_init_msg_list               IN      VARCHAR2 	:= FND_API.G_FALSE,
      p_commit                      IN      VARCHAR2  := FND_API.G_FALSE,
      p_validation_level            IN  NUMBER 	:= FND_API.G_VALID_LEVEL_FULL,
      x_return_status               OUT NOCOPY     VARCHAR2,
      x_msg_count                   OUT NOCOPY     NUMBER,
      x_msg_data                    OUT NOCOPY     VARCHAR2,
      p_table_map_id                IN  NUMBER,
      p_delete_flag                 IN  VARCHAR2,
      p_object_name                 IN  VARCHAR2,
      p_object_id                   IN  NUMBER,
      p_object_value                IN  VARCHAR2,
      p_object_version_number       IN  OUT NOCOPY NUMBER,
      x_org_id                      IN  NUMBER)  -- Added For R12 MOAC
IS

	 l_api_name                CONSTANT VARCHAR2(30) := 'Update_Table_Map_Objects';
	 l_api_version             CONSTANT NUMBER       := 1.0;
	 l_ovn_obj_number          cn_objects.object_version_number%TYPE;
	 l_ovn_tbl_number          cn_table_maps.object_version_number%TYPE;

     l_org_id NUMBER; -- Added For R12 MOAC

	 CURSOR l_ovn_obj IS
	    SELECT object_version_number
	      FROM cn_objects
	      WHERE object_id = p_object_id
          AND org_id = x_org_id; -- Added For R12 MOAC

	 CURSOR l_ovn_tbl IS
	    SELECT object_version_number
	      FROM cn_table_maps
	      WHERE table_map_id = p_table_map_id
          AND org_id = x_org_id; -- Added For R12 MOAC

BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT update_trx_source_sv;
   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call ( l_api_version ,
                                        p_api_version ,
                                        l_api_name,
                                        G_PKG_NAME ) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;

   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   -- API Body Begin

   -- check if the object version number is the same
   OPEN l_ovn_obj;
   FETCH l_ovn_obj INTO l_ovn_obj_number;
   CLOSE l_ovn_obj;

   OPEN l_ovn_tbl;
   FETCH l_ovn_tbl INTO l_ovn_tbl_number;
   CLOSE l_ovn_tbl;

	IF (l_ovn_obj_number <> p_object_version_number)
    THEN

		IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
		THEN
			fnd_message.set_name('CN', 'CL_INVALID_OVN');
			fnd_msg_pub.add;
		END IF;

		RAISE FND_API.G_EXC_ERROR;

	END IF;

	l_org_id := x_org_id;

    IF p_delete_flag = 'Y'
    THEN
        UPDATE cn_table_maps
        SET delete_flag = p_delete_flag,
        object_version_number = l_ovn_tbl_number + 1
        WHERE table_map_id = p_table_map_id
        AND org_id = l_org_id;
    END IF;

        UPDATE CN_OBJECTS
        SET NAME = p_object_name,
        OBJECT_VALUE = p_object_value
        WHERE OBJECT_ID = p_object_id
        AND org_id = l_org_id;

   FND_MSG_PUB.Count_And_Get
     (p_count                 =>      x_msg_count             ,
     p_data                   =>      x_msg_data              ,
     p_encoded                =>      FND_API.G_FALSE         );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO update_trx_source_sv;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get(
           p_count   =>  x_msg_count ,
           p_data    =>  x_msg_data  ,
           p_encoded => FND_API.G_FALSE);
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO update_trx_source_sv;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get(
           p_count   =>  x_msg_count ,
           p_data    =>  x_msg_data   ,
           p_encoded => FND_API.G_FALSE);
   WHEN OTHERS THEN
      ROLLBACK TO update_trx_source_sv;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level(
         FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME ,l_api_name );
      END IF;
      FND_MSG_PUB.Count_And_Get(
           p_count   =>  x_msg_count ,
           p_data    =>  x_msg_data  ,
           p_encoded => FND_API.G_FALSE);

END Update_Table_Map_Objects;

-----------------------------------------------------------------------------+
-- Procedure   : Update_Map
-----------------------------------------------------------------------------+
PROCEDURE Update_Map
     (
      p_api_version   	      IN      NUMBER,
      p_init_msg_list         IN      VARCHAR2 	:= FND_API.G_FALSE,
      p_commit                IN      VARCHAR2  := FND_API.G_FALSE,
      p_validation_level      IN      NUMBER 	:= FND_API.G_VALID_LEVEL_FULL,
      x_return_status         OUT NOCOPY     VARCHAR2,
      x_msg_count             OUT NOCOPY     NUMBER,
      x_msg_data              OUT NOCOPY     VARCHAR2,
      p_table_map_id              IN  NUMBER,
      p_mapping_type              IN  VARCHAR2,
      p_module_id                 IN  NUMBER,
      p_source_table_id           IN  NUMBER,
      p_source_tbl_pkcol_id       IN  NUMBER,
      p_destination_table_id      IN  NUMBER,
      p_source_hdr_tbl_pkcol_id   IN  NUMBER,
      p_source_tbl_hdr_fkcol_id   IN  NUMBER,
      p_notify_where              IN  VARCHAR2,
      p_collect_where             IN  VARCHAR2,
      p_delete_flag               IN  VARCHAR2,
      p_event_id                  IN  NUMBER,
      p_event_name                IN  VARCHAR2,
      p_object_version_number     IN  OUT NOCOPY NUMBER,
      x_org_id                    IN  NUMBER)  -- Added For R12 MOAC
      IS

	 l_api_name               CONSTANT VARCHAR2(30) := 'update_trx_source';
	 l_api_version            CONSTANT NUMBER       := 1.0;
	 l_object_version_number  cn_table_maps.object_version_number%TYPE;
	 l_evn_object_version_number  cn_events_all_b.object_version_number%TYPE := 1;
	 --l_mod_object_version_number  cn_modules_all_b.object_version_number%TYPE;
     l_org_id NUMBER; -- Added For R12 MOAC

	 CURSOR l_ovn_csr IS
	    SELECT object_version_number
	      FROM cn_table_maps
	      WHERE table_map_id = p_table_map_id
          AND org_id = x_org_id; -- Added For R12 MOAC


BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT update_trx_source_sv;
   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call ( l_api_version ,
                                        p_api_version ,
                                        l_api_name,
                                        G_PKG_NAME ) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;
   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   -- API Body Begin

   -- check if the object version number is the same
   OPEN l_ovn_csr;
   FETCH l_ovn_csr INTO l_object_version_number;
   CLOSE l_ovn_csr;



	if (l_object_version_number <> p_object_version_number) THEN

		IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
		THEN
			fnd_message.set_name('CN', 'CL_INVALID_OVN');
			fnd_msg_pub.add;
		END IF;
		RAISE FND_API.G_EXC_ERROR;

	end if;

	l_org_id := x_org_id;



	   cn_table_maps_pkg.update_row(x_table_map_id=> p_table_map_id,
				x_mapping_type => p_mapping_type,
				x_module_id => p_module_id,
				x_source_table_id => p_source_table_id,
				x_source_tbl_pkcol_id => p_source_tbl_pkcol_id,
				x_destination_table_id => p_destination_table_id,
				x_source_hdr_tbl_pkcol_id => p_source_hdr_tbl_pkcol_id,
				x_source_tbl_hdr_fkcol_id => p_source_tbl_hdr_fkcol_id,
				x_notify_where => p_notify_where,
				x_collect_where => p_collect_where,
				x_delete_flag => p_delete_flag,
				x_last_update_date => G_LAST_UPDATE_DATE,
				x_last_updated_by => G_LAST_UPDATED_BY,
				x_last_update_login => g_last_update_login,
				x_object_version_number => p_object_version_number,
                x_org_id => l_org_id); -- Added For R12 MOAC

		    IF p_event_id IS NOT NULL THEN
		       cn_events_all_pkg.update_row
			 (x_event_id => p_event_id,
			  x_application_repository_id => 100,
			  x_description => NULL,
			  x_name => p_event_name,
			  x_last_update_date  => G_LAST_UPDATE_DATE,
			  x_last_updated_by   => G_LAST_UPDATED_BY,
			  x_last_update_login => G_LAST_UPDATE_LOGIN,
		      x_org_id => l_org_id,
              p_object_version_number => l_evn_object_version_number); -- Added For R12 MOAC
		    END IF;


    p_object_version_number := l_object_version_number + 1;

   -- End of API body.
   -- Standard check of p_commit.
   --IF FND_API.To_Boolean( p_commit ) THEN
   --   COMMIT WORK;
   --END IF;
   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get
     (p_count                 =>      x_msg_count             ,
     p_data                   =>      x_msg_data              ,
     p_encoded                =>      FND_API.G_FALSE         );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO update_trx_source_sv;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get(
           p_count   =>  x_msg_count ,
           p_data    =>  x_msg_data  ,
           p_encoded => FND_API.G_FALSE);
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO update_trx_source_sv;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get(
           p_count   =>  x_msg_count ,
           p_data    =>  x_msg_data   ,
           p_encoded => FND_API.G_FALSE);
   WHEN OTHERS THEN
      ROLLBACK TO update_trx_source_sv;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level(
         FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME ,l_api_name );
      END IF;
      FND_MSG_PUB.Count_And_Get(
           p_count   =>  x_msg_count ,
           p_data    =>  x_msg_data  ,
           p_encoded => FND_API.G_FALSE);
END Update_Map;



------------------------------------------------------------------------------+
-- Procedure   : Create_Table_Map_Object
------------------------------------------------------------------------------+
--              WARNING: only use this procedure to create a table map object that
--                       does not yet exist in CN_OBJECTS. If you are creating a
--                       table map object which references an existing object (for
--                       example an Extra Collection Table) then just use the
--                       cn_table_map_objects_pkg.insert_row procedure.
PROCEDURE Create_Table_Map_Object (
   p_api_version       IN NUMBER,
   p_init_msg_list     IN VARCHAR2 := FND_API.G_FALSE,
   p_commit            IN VARCHAR2 := FND_API.G_FALSE,
   p_validation_level  IN  NUMBER  := FND_API.G_VALID_LEVEL_FULL,
   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,
   p_table_map_id      IN  NUMBER,
   p_object_name       IN  VARCHAR2,
   p_object_value      IN  VARCHAR2 := NULL,
   p_tm_object_type    IN  VARCHAR2,
   p_creation_date     IN  DATE,
   p_created_by        IN  NUMBER,
   x_table_map_object_id  OUT NOCOPY  NUMBER,
   x_object_id            OUT NOCOPY  NUMBER,
   x_org_id            IN NUMBER) IS

     l_api_name                  CONSTANT VARCHAR2(30) := 'Create_Table_Map_Object';
     l_api_version               CONSTANT NUMBER  := 1.0;
     l_rowid                     ROWID;
     l_application_repository_id cn_events.application_repository_id%TYPE;
     l_org_id  NUMBER;
BEGIN
     -- Standard Start of API savepoint
     SAVEPOINT	Create_Table_Map_Object;
     -- Standard call to check for call compatibility.
     IF NOT FND_API.Compatible_API_Call (l_api_version,
                                         p_api_version,
                                         l_api_name,
                                         G_PKG_NAME)
     THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;
     -- Initialize message list if p_init_msg_list is set to TRUE.
     IF FND_API.to_Boolean( p_init_msg_list ) THEN
         FND_MSG_PUB.initialize;
     END IF;
     --  Initialize API return status to success
     x_return_status := FND_API.G_RET_STS_SUCCESS;

     l_org_id := x_org_id;

	-------------------+
     -- API body
	-------------------+
   SELECT repository_id
   INTO   l_application_repository_id
   FROM   cn_modules_all_b
	WHERE  module_type = 'COL' -- name = 'Collection';
    AND    org_id = x_org_id;  -- MOAC Change Need To Verify
     --+

	SELECT cn_objects_s.NEXTVAL
	INTO x_object_id
	FROM dual;
     --+
     -- Create the object in CN_OBJECTS
     --+

     cn_objects_pkg.insert_row(
                 x_rowid                      => l_rowid,
                 x_object_id                  => x_object_id,
                 x_dependency_map_complete    => 'N',
                 x_name                       => p_object_name,
                 x_object_value               => p_object_value,
                 x_description                => 'Custom Data Source Collection Object',
                 x_object_type                => UPPER(p_tm_object_type),
                 x_repository_id              => l_application_repository_id,
                 x_next_synchronization_date  => NULL,
                 x_synchronization_frequency  => NULL,
                 x_object_status              => 'A',
                 X_org_id                     => l_org_id);
     --+
     -- Create the reference to the object in CN_TABLE_MAP_OBJECTS
     --+

     cn_table_map_objects_pkg.insert_row(
                 x_rowid                    => l_rowid,
                 x_table_map_object_id      => x_table_map_object_id, --set inside procedure
                 x_tm_object_type           => UPPER(p_tm_object_type),
                 x_table_map_id             => p_table_map_id,
                 x_object_id                => x_object_id,
                 x_creation_date            => p_creation_date,
                 x_created_by               => p_created_by,
                 X_org_id                   => l_org_id);
	-------------------+
     -- End of API body.
	-------------------+
     -- Standard check of p_commit.
     --IF FND_API.To_Boolean( p_commit ) THEN
     --    COMMIT WORK;
     --END IF;
     -- Standard call to get message count and if count is 1, get message info.
     FND_MSG_PUB.Count_And_Get
                        (p_count   =>  x_msg_count ,
                         p_data    =>  x_msg_data  ,
                         p_encoded => FND_API.G_FALSE);
     EXCEPTION
         WHEN FND_API.G_EXC_ERROR THEN
             ROLLBACK TO Create_Table_Map_Object;
             x_return_status := FND_API.G_RET_STS_ERROR ;
             FND_MSG_PUB.Count_And_Get
                             (p_count   => x_msg_count,
                              p_data    => x_msg_data,
                              p_encoded => FND_API.G_FALSE);
         WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
             ROLLBACK TO Create_Table_Map_Object;
             x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
             FND_MSG_PUB.Count_And_Get
                             (p_count   => x_msg_count,
                              p_data    => x_msg_data,
                              p_encoded => FND_API.G_FALSE);
         WHEN OTHERS THEN
             ROLLBACK TO Create_Table_Map_Object;
             x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
             IF FND_MSG_PUB.Check_Msg_Level
                                (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
                 FND_MSG_PUB.Add_Exc_Msg
                                (G_PKG_NAME,
                                 l_api_name );
             END IF;
             FND_MSG_PUB.Count_And_Get
                             (p_count   => x_msg_count,
                              p_data    => x_msg_data,
                              p_encoded => FND_API.G_FALSE);
END Create_Table_Map_Object;



------------------------------------------------------------------------------+
-- Procedure   : Delete_Table_Map_Object
------------------------------------------------------------------------------+
--              WARNING: Use this procedure for deleting objects like Notification
--                       Query Parameters. If you only want to delete the CN_TABLE_MAP_OBJECTS
--                       references to an object (for example an Extra Collection Table)
--                       then just use the cn_table_map_objects_pkg.delete_row procedure.
PROCEDURE Delete_Table_Map_Object (
   p_api_version       IN NUMBER,
   p_init_msg_list     IN VARCHAR2 := FND_API.G_FALSE,
   p_commit            IN VARCHAR2 := FND_API.G_FALSE,
   p_validation_level  IN  NUMBER  := FND_API.G_VALID_LEVEL_FULL,
   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,
   p_table_map_object_id      IN  NUMBER,
   x_org_id IN NUMBER) IS -- Added For R12 MOAC

     l_api_name                  CONSTANT VARCHAR2(30) := 'Create_Map';
     l_api_version               CONSTANT NUMBER  := 1.0;
     l_object_id NUMBER;

	CURSOR del_tbmp IS
	SELECT object_id
	FROM   cn_table_map_objects
	WHERE  table_map_object_id = p_table_map_object_id
	AND    org_id = x_org_id;

BEGIN
     -- Standard Start of API savepoint
     SAVEPOINT	Delete_Table_Map_Object;
     -- Standard call to check for call compatibility.
     IF NOT FND_API.Compatible_API_Call (l_api_version,
                                         p_api_version,
                                         l_api_name,
                                         G_PKG_NAME)
     THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;
     -- Initialize message list if p_init_msg_list is set to TRUE.
     IF FND_API.to_Boolean( p_init_msg_list ) THEN
         FND_MSG_PUB.initialize;
     END IF;
     --  Initialize API return status to success
     x_return_status := FND_API.G_RET_STS_SUCCESS;
	-------------------+
     -- API body
	-------------------+
     --+
     -- Delete the object in CN_OBJECTS
     --+
		FOR del IN del_tbmp
		LOOP
			DELETE FROM cn_objects WHERE object_id = del.object_id;
		END LOOP;
     --+
     -- Delete the reference to the object in CN_TABLE_MAP_OBJECTS
     --+
     cn_table_map_objects_pkg.delete_row(
                 x_table_map_object_id      => p_table_map_object_id,
                 x_org_id => x_org_id); -- Added For R12 MOAC
	-------------------+
     -- End of API body.
	-------------------+
     -- Standard check of p_commit.
     --IF FND_API.To_Boolean( p_commit ) THEN
     --    COMMIT WORK;
     --END IF;
     -- Standard call to get message count and if count is 1, get message info.
     FND_MSG_PUB.Count_And_Get
                        (p_count   =>  x_msg_count ,
                         p_data    =>  x_msg_data  ,
                         p_encoded => FND_API.G_FALSE);
     EXCEPTION
         WHEN FND_API.G_EXC_ERROR THEN
             ROLLBACK TO Delete_Table_Map_Object;
             x_return_status := FND_API.G_RET_STS_ERROR ;
             FND_MSG_PUB.Count_And_Get
                             (p_count   => x_msg_count,
                              p_data    => x_msg_data,
                              p_encoded => FND_API.G_FALSE);
         WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
             ROLLBACK TO Delete_Table_Map_Object;
             x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
             FND_MSG_PUB.Count_And_Get
                             (p_count   => x_msg_count,
                              p_data    => x_msg_data,
                              p_encoded => FND_API.G_FALSE);
         WHEN OTHERS THEN
             ROLLBACK TO Delete_Table_Map_Object;
             x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
             IF FND_MSG_PUB.Check_Msg_Level
                                (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
                 FND_MSG_PUB.Add_Exc_Msg
                                (G_PKG_NAME,
                                 l_api_name );
             END IF;
             FND_MSG_PUB.Count_And_Get
                             (p_count   => x_msg_count,
                              p_data    => x_msg_data,
                              p_encoded => FND_API.G_FALSE);
END Delete_Table_Map_Object;

------------------------------------------------------------------------------+
-- Procedure   : Get_SQL_Clauses
------------------------------------------------------------------------------+
PROCEDURE Get_SQL_Clauses
(  p_api_version       IN NUMBER,
   p_init_msg_list     IN VARCHAR2 := FND_API.G_FALSE,
   p_commit            IN VARCHAR2 := FND_API.G_FALSE,
   p_validation_level  IN  NUMBER  := FND_API.G_VALID_LEVEL_FULL,
   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,
   p_table_map_id      IN  NUMBER ,
   x_notify_from       OUT NOCOPY VARCHAR2,
   x_notify_where      OUT NOCOPY VARCHAR2,
   x_collect_from      OUT NOCOPY VARCHAR2,
   x_collect_where     OUT NOCOPY VARCHAR2,
   p_org_id            IN  NUMBER
 ) IS
     l_api_name                  CONSTANT VARCHAR2(30) := 'GET_SQL_CLAUSES';
     l_api_version               CONSTANT NUMBER  := 1.0;
	-- Cursor to get all necessary info about header and line tables
     CURSOR c1 IS
         SELECT
		   tmv.table_map_id,
             LOWER(tmv.source_table_name) line_tab_name,
             LOWER(NVL(tmv.source_table_alias,tmv.source_table_name)) line_tab_alias,
             LOWER(tmv.linepk_name)  line_pk_col,
             LOWER(tmv.linefk_name)  line_fk_col,
             LOWER(tmv.header_table_name)  hdr_tab_name,
             LOWER(NVL(tmv.header_table_alias,tmv.header_table_name)) hdr_tab_alias,
             LOWER(tmv.hdrpk_name)  hdr_pk_col
         FROM
             cn_table_maps_v tmv
         WHERE
             tmv.table_map_id = p_table_map_id
			 AND tmv.org_id = p_org_id;
     l_c1_rec            c1%ROWTYPE;

BEGIN
     -- Standard Start of API savepoint
     SAVEPOINT	Get_SQL_Clauses;
     -- Standard call to check for call compatibility.
     IF NOT FND_API.Compatible_API_Call (l_api_version,
                                         p_api_version,
                                         l_api_name,
                                         G_PKG_NAME)
     THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;
     -- Initialize message list if p_init_msg_list is set to TRUE.
     IF FND_API.to_Boolean( p_init_msg_list ) THEN
         FND_MSG_PUB.initialize;
     END IF;
     --  Initialize API return status to success
     x_return_status := FND_API.G_RET_STS_SUCCESS;
	-------------------+
     -- API body
	-------------------+
	--+
	-- Get the information from CN_TABLE_MAPS about the Line table and how
	-- to join it to the Header table (if there is one)
	--+
     OPEN c1;
     FETCH c1 into l_c1_rec;
     CLOSE c1;
	--+
	-- FIRST we derive the NOTIFY FROM and WHERE clauses
	--+
	--+
	-- By default, the Notify_From clause only contains the Line table
	-- and the Notify_Where clause is empty.
	--+
     x_notify_from := l_c1_rec.line_tab_name||' '||l_c1_rec.line_tab_alias;
     x_notify_where := '1 = 1';
     --+
	-- If a header table is specified
	--+
     IF l_c1_rec.hdr_pk_col IS NOT NULL THEN
	    --+
	    -- Add the Header Table to the Notify_From table list and add
	    -- the join to it into the Notify_Where clause
	    --+
	    x_notify_from := x_notify_from||','||fnd_global.local_chr(10)||l_c1_rec.hdr_tab_name||
					 ' '||l_c1_rec.hdr_tab_alias;
         x_notify_where := l_c1_rec.hdr_tab_alias||'.'||l_c1_rec.hdr_pk_col||' = '||
					  l_c1_rec.line_tab_alias||'.'||l_c1_rec.line_fk_col;
     END IF;
	--+
	-- NOW we derive the COLLECT FROM and WHERE clauses
	--+
	-- The Collect_From table list starts out the same as the list from Notify_Where
	--+
     x_collect_from := x_notify_from||',';
     FOR rec IN
	    --+
	    -- Add to the Collect_From list any extra collection tables that have been specified
	    --+
	    (SELECT LOWER(obj.name||' '||NVL(obj.alias,obj.name)) name
	     FROM   cn_table_map_objects tmobj,
			  cn_objects obj
          WHERE  tmobj.table_map_id = l_c1_rec.table_map_id
			  AND tmobj.tm_object_type = 'COLLTAB'
			  AND obj.object_id = tmobj.object_id
			  AND obj.org_id = p_org_id AND obj.org_id = tmobj.org_id)
     LOOP
	    x_collect_from := x_collect_from||fnd_global.local_chr(10)||rec.name||',';
     END LOOP;
	--+
	-- Terminate the Collect_From list with the CN_NOT_TRX table
	--+
     x_collect_from := x_collect_from||fnd_global.local_chr(10)||'cn_not_trx cnt';
	--+
	-- The Collect_Where clause at a minimun joins the primary_key of the Line
	-- table to cnt.Source_Trx_Line_Id
	--+
     x_collect_where := l_c1_rec.line_tab_alias||'.'||l_c1_rec.line_pk_col||
				   ' = cnt.source_trx_line_id';
	--+
	-- If there is a header table then the Collect_Where is extended to join
	-- the primary_key of the Header table to cnt.Source_Trx_Id
	--+
     IF l_c1_rec.hdr_pk_col IS NOT NULL THEN
         x_collect_where := x_collect_where||fnd_global.local_chr(10)||'AND '||
					   l_c1_rec.hdr_tab_alias||'.'||l_c1_rec.hdr_pk_col||' = cnt.source_trx_id';
     END IF;
	-------------------+
     -- End of API body.
	-------------------+
     -- Standard check of p_commit.
     IF FND_API.To_Boolean( p_commit ) THEN
         COMMIT WORK;
     END IF;
     -- Standard call to get message count and if count is 1, get message info.
     FND_MSG_PUB.Count_And_Get
                        (p_count   =>  x_msg_count ,
                         p_data    =>  x_msg_data  ,
                         p_encoded => FND_API.G_FALSE);
     EXCEPTION
         WHEN FND_API.G_EXC_ERROR THEN
             ROLLBACK TO Get_SQL_Clauses;
             x_return_status := FND_API.G_RET_STS_ERROR ;
             FND_MSG_PUB.Count_And_Get
                             (p_count   => x_msg_count,
                              p_data    => x_msg_data,
                              p_encoded => FND_API.G_FALSE);
         WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
             ROLLBACK TO Get_SQL_Clauses;
             x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
             FND_MSG_PUB.Count_And_Get
                             (p_count   => x_msg_count,
                              p_data    => x_msg_data,
                              p_encoded => FND_API.G_FALSE);
         WHEN OTHERS THEN
             ROLLBACK TO Get_SQL_Clauses;
             x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
             IF FND_MSG_PUB.Check_Msg_Level
                                (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
                 FND_MSG_PUB.Add_Exc_Msg
                                (G_PKG_NAME,
                                 l_api_name );
             END IF;
             FND_MSG_PUB.Count_And_Get
                             (p_count   => x_msg_count,
                              p_data    => x_msg_data,
                              p_encoded => FND_API.G_FALSE);
END Get_SQL_Clauses;

END cn_table_maps_pvt;


/
