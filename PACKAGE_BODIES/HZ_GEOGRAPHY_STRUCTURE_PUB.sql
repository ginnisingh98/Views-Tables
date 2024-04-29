--------------------------------------------------------
--  DDL for Package Body HZ_GEOGRAPHY_STRUCTURE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_GEOGRAPHY_STRUCTURE_PUB" AS
/*$Header: ARHGSTSB.pls 120.21 2006/03/23 15:03:02 idali noship $ */

-- Type declarations

------------------------------------
-- declaration of private procedures
------------------------------------

PROCEDURE do_create_geography_type(
    p_geography_type_rec            IN     GEOGRAPHY_TYPE_REC_TYPE,
    x_return_status                 IN OUT NOCOPY VARCHAR2
);

PROCEDURE do_create_geo_rel_type(
    p_geo_rel_type_rec           IN     GEO_REL_TYPE_REC_TYPE,
    x_relationship_type_id       OUT  NOCOPY  NUMBER,
    x_return_status              IN OUT NOCOPY VARCHAR2
);

PROCEDURE do_update_geo_rel_type(
    p_relationship_type_id     	    IN NUMBER,
    p_status                        IN VARCHAR2,
    p_object_version_number         IN OUT NOCOPY NUMBER,
    x_return_status                 IN OUT NOCOPY VARCHAR2
    );

PROCEDURE do_create_geo_structure(
        p_geo_structure_rec            IN GEO_STRUCTURE_REC_TYPE,
        x_return_status                IN OUT NOCOPY VARCHAR2
        );

PROCEDURE validate_geo_element_col(
   p_geography_type     IN VARCHAR2,
   p_geography_id       IN NUMBER,
   p_geo_element_column IN VARCHAR2,
   x_return_status      IN OUT NOCOPY VARCHAR2
   );

/*
 PROCEDURE update_geo_rel_type(
    p_init_msg_list             	  IN         VARCHAR2 := FND_API.G_FALSE,
    p_relationship_type_id            IN         NUMBER,
    p_status                          IN         VARCHAR2,
    p_object_version_number    		  IN    OUT NOCOPY  NUMBER,
    x_return_status             	  OUT   NOCOPY    VARCHAR2,
    x_msg_count                 	  OUT   NOCOPY     NUMBER,
    x_msg_data                  	  OUT   NOCOPY     VARCHAR2
 );
 */

-------------------------------
-- body of private procedures
-------------------------------

-- check if the geography_type has multiple parents and geography_type has same value for
-- geography_column_element for all these rows.
PROCEDURE validate_geo_element_col(
   p_geography_type     IN VARCHAR2,
   p_geography_id       IN NUMBER,
   p_geo_element_column    IN VARCHAR2,
   x_return_status      IN OUT NOCOPY VARCHAR2
   )IS

   CURSOR c_geo_parent IS
      SELECT parent_geography_type,geography_element_column
        FROM HZ_GEO_STRUCTURE_LEVELS
       WHERE geography_type = p_geography_type
         AND geography_id =  p_geography_id;

    l_geo_parent     c_geo_parent%ROWTYPE;

    BEGIN

     OPEN c_geo_parent;
   LOOP
     FETCH c_geo_parent INTO l_geo_parent;
       EXIT WHEN c_geo_parent%NOTFOUND;
              IF l_geo_parent.geography_element_column <> p_geo_element_column
        THEN
            FND_MESSAGE.SET_NAME('AR', 'HZ_GEO_MULTIPLE_GEO_COL');
            FND_MESSAGE.SET_TOKEN('GEO_ID', p_geography_id);
            FND_MESSAGE.SET_TOKEN('GEO_TYPE', p_geography_type);
            FND_MSG_PUB.ADD;
            x_return_status := fnd_api.g_ret_sts_error;
        END IF;
   END LOOP;
    CLOSE c_geo_parent;

END validate_geo_element_col;

PROCEDURE do_create_geography_type(
       p_geography_type_rec            IN     GEOGRAPHY_TYPE_REC_TYPE,
       x_return_status                 IN OUT NOCOPY VARCHAR2
 ) IS

   --l_geography_type_rec             GEOGRAPHY_TYPE_REC_TYPE := p_geography_type_rec;
   l_geography_type                   hz_geography_types_b.GEOGRAPHY_TYPE%TYPE := UPPER(p_geography_type_rec.geography_type);
   l_count                            NUMBER;
   l_rowid                            VARCHAR2(64);
   l_object_id                        NUMBER;
   --l_dummy                          VARCHAR2(1);
   l_instance_set_id                  NUMBER;
   l_predicate                        VARCHAR2(4000);
   l_geography_type_name              VARCHAR2(80);

   BEGIN

       l_geography_type_name := p_geography_type_rec.geography_type_name;

    -- replaced by find_index_name
    /*  -- If primary_key is passed, check for uniqueness
     IF l_geography_type <> FND_API.G_MISS_CHAR
       AND
       l_geography_type IS NOT NULL
    THEN
        BEGIN

        -- check for geography type uniqueness
            SELECT 1
            INTO   l_count
            FROM   hz_geography_types_b
            WHERE  GEOGRAPHY_TYPE = l_geography_type;

            FND_MESSAGE.SET_NAME('AR', 'HZ_API_DUPLICATE_COLUMN');
            FND_MESSAGE.SET_TOKEN('COLUMN', 'geography_type');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;

        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                NULL;
        END;

    END IF;*/

      IF p_geography_type_rec.geography_type_name IS NULL THEN
       l_geography_type_name := initcap(p_geography_type_rec.geography_type);
      END IF;

    -- call the table handler to create geography_type
    hz_geography_types_PKG.Insert_Row (
    x_rowid                              =>   l_rowid,
    x_geography_type                     =>   UPPER(l_geography_type),
    x_geography_type_name                =>   l_geography_type_name,
    x_object_version_number              =>   1,
    x_geography_use                      =>   'MASTER_REF',
    x_postal_code_range_flag             =>   'N',
    x_limited_by_geography_id            =>   NULL,
    x_created_by_module                  =>   p_geography_type_rec.created_by_module,
    x_application_id                     =>   p_geography_type_rec.application_id,
    x_program_login_id                   =>   NULL
);


 -- initialize the variables for creating fnd_object_instance_sets


    SELECT object_id into l_object_id
      FROM FND_OBJECTS
     WHERE obj_name='HZ_GEOGRAPHIES';

--  Replace the ' in predicate with ''
      l_predicate := 'GEOGRAPHY_TYPE='||''''||replace(l_geography_type,'''','''''')||'''';

  BEGIN
   SELECT count(*)
      INTO l_count
      FROM FND_OBJECT_INSTANCE_SETS
     WHERE INSTANCE_SET_NAME = l_geography_type;

        IF l_count = 0  THEN

         SELECT FND_OBJECT_INSTANCE_SETS_S.nextval INTO l_instance_set_id FROM dual;
         l_rowid := NULL;

        -- call the table handler to create fnd_object_instance_sets
    FND_OBJECT_INSTANCE_SETS_PKG.INSERT_ROW (
    X_ROWID                     => l_rowid,
    X_INSTANCE_SET_ID 		=> l_instance_set_id,
    X_INSTANCE_SET_NAME         => l_geography_type,
    X_OBJECT_ID                 => l_object_id,
    X_PREDICATE                 => l_predicate,
    X_DISPLAY_NAME              => l_geography_type,
    X_DESCRIPTION               => l_geography_type,
    X_CREATION_DATE             => HZ_UTILITY_V2PUB.creation_date,
    X_CREATED_BY                => HZ_UTILITY_V2PUB.created_by,
    X_LAST_UPDATE_DATE          => HZ_UTILITY_V2PUB.last_update_date,
    X_LAST_UPDATED_BY           => HZ_UTILITY_V2PUB.last_updated_by,
    X_LAST_UPDATE_LOGIN         => HZ_UTILITY_V2PUB.last_update_login
   ) ;


   END IF;

  END;

 END do_create_geography_type;

 -- create Geo Relationship Type

 PROCEDURE do_create_geo_rel_type(
    p_geo_rel_type_rec      IN geo_rel_type_REC_TYPE,
    x_relationship_type_id  OUT NOCOPY NUMBER,
    x_return_status         IN OUT NOCOPY VARCHAR2
    ) IS

    l_relationship_type_rec     HZ_RELATIONSHIP_TYPE_V2PUB.RELATIONSHIP_TYPE_REC_TYPE;
    l_geography_type            hz_geography_types_b.GEOGRAPHY_TYPE%TYPE :=p_geo_rel_type_rec.geography_type;
    l_parent_geography_type     hz_geography_types_b.GEOGRAPHY_TYPE%TYPE :=p_geo_rel_type_rec.parent_geography_type;
    l_geography_use             hz_geography_types_b.GEOGRAPHY_USE%TYPE;
    l_count  number;
    x_msg_count NUMBER;
    x_msg_data VARCHAR2(2000);

    BEGIN

        -- validate geography relationship type
       HZ_GEO_STRUCTURE_VALIDATE_PVT.validate_geo_rel_type(
         p_create_update_flag => 'C',
         p_geo_rel_type_rec    => p_geo_rel_type_rec,
         x_return_status                => x_return_status
         );


       --if validation failed at any point, then raise an exception to stop processing
       IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
           RAISE FND_API.G_EXC_ERROR;
       END IF;
         --dbms_output.put_line('After validate in geo_rel_type');

      BEGIN
      -- derive geography use of parent geography type which will be the relationship type
      SELECT GEOGRAPHY_USE
        INTO l_geography_use
        FROM hz_geography_types_b
       WHERE GEOGRAPHY_TYPE = l_parent_geography_type;

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
            FND_MESSAGE.SET_NAME('AR', 'HZ_GEO_INVALID_VALUE');
            FND_MESSAGE.SET_TOKEN('VALUE', l_parent_geography_type);
            FND_MESSAGE.SET_TOKEN('COLUMN', 'parent_geography_type');
            FND_MSG_PUB.ADD;
           RAISE FND_API.G_EXC_ERROR;
      END;
      -- check if geography_type is already 'PARENT_OF' parent_geography_type (bug fix 2838632)
    SELECT count(*) INTO l_count FROM hz_relationship_types
     WHERE relationship_type=l_geography_use
       AND subject_type=l_geography_type
       AND object_type=l_parent_geography_type
       AND status = 'A'
       AND forward_rel_code='PARENT_OF'
       AND backward_rel_code = 'CHILD_OF';
       IF l_count > 0 THEN
        FND_MESSAGE.SET_NAME('AR', 'HZ_GEO_INVALID_REL_TYPE');
            FND_MESSAGE.SET_TOKEN('CHILD', l_geography_type);
            FND_MESSAGE.SET_TOKEN('PARENT', l_parent_geography_type);
            FND_MSG_PUB.ADD;
           RAISE FND_API.G_EXC_ERROR;
        END IF;

    --l_relationship_type_rec.relationship_type_id            :=NULL;
    l_relationship_type_rec.relationship_type               :=l_geography_use;
    l_relationship_type_rec.forward_rel_code                :='PARENT_OF';
    l_relationship_type_rec.backward_rel_code               :='CHILD_OF';
    l_relationship_type_rec.direction_code                  :='P';

   IF l_geography_use = 'MASTER_REF' THEN
      l_relationship_type_rec.hierarchical_flag               :='Y';
   ELSE
      l_relationship_type_rec.hierarchical_flag               :='N';
   END IF;

    l_relationship_type_rec.create_party_flag               :='N';
    l_relationship_type_rec.allow_relate_to_self_flag       :='N';
    l_relationship_type_rec.allow_circular_relationships    :='N';
    l_relationship_type_rec.subject_type                    :=l_parent_geography_type;
    l_relationship_type_rec.object_type                     :=l_geography_type;
    l_relationship_type_rec.status                          :=p_geo_rel_type_rec.status;
    l_relationship_type_rec.created_by_module               :=p_geo_rel_type_rec.created_by_module;
    l_relationship_type_rec.application_id                  :=p_geo_rel_type_rec.application_id;
    l_relationship_type_rec.multiple_parent_allowed         :='Y';
    l_relationship_type_rec.incl_unrelated_entities         :=NULL;
    l_relationship_type_rec.forward_role                    :=NULL;
    l_relationship_type_rec.backward_role                   :=NULL;


    HZ_RELATIONSHIP_TYPE_V2PUB.create_relationship_type (
        p_init_msg_list             => 'F',
        p_relationship_type_rec     =>  l_relationship_type_rec,
        x_relationship_type_id      =>  x_relationship_type_id,
        x_return_status             =>  x_return_status,
        x_msg_count                 =>  x_msg_count,
        x_msg_data                  =>  x_msg_data
        );


   --if validation failed at any point, then raise an exception to stop processing
       IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
           RAISE FND_API.G_EXC_ERROR;
       END IF;

 END do_create_geo_rel_type;

 -- update geography Relationship Type
 PROCEDURE do_update_geo_rel_type(
    p_relationship_type_id     IN NUMBER,
    p_status                   IN VARCHAR2,
    p_object_version_number         IN OUT NOCOPY NUMBER,
    x_return_status                 IN OUT NOCOPY VARCHAR2
    ) IS

    l_relationship_type_rec     HZ_RELATIONSHIP_TYPE_V2PUB.RELATIONSHIP_TYPE_REC_TYPE;
    --l_relationship_type_id      hz_geography_types_b.GEOGRAPHY_TYPE%TYPE :=p_relationship_type_id;
    --x_return_status VARCHAR2(2000);
    x_msg_count          NUMBER;
    x_msg_data           VARCHAR2(2000);
    l_count              NUMBER;

    BEGIN

       -- validate relationship_type_id
       BEGIN
       select 1 into l_count from
       hz_relationship_types
       where relationship_type_id=p_relationship_type_id;
       EXCEPTION WHEN NO_DATA_FOUND THEN
           FND_MESSAGE.SET_NAME('AR', 'HZ_GEO_NO_RECORD');
            FND_MESSAGE.SET_TOKEN('TOKEN1', 'Relationship Type');
            FND_MESSAGE.SET_TOKEN('TOKEN2', 'relationship_type_id '||p_relationship_type_id);
            FND_MSG_PUB.ADD;
           RAISE FND_API.G_EXC_ERROR;
       END;

       hz_utility_v2pub.validate_mandatory(
          p_create_update_flag     => 'U',
          p_column                 => 'object_version_number',
          p_column_value           => p_object_version_number,
          x_return_status          => x_return_status
          );

          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
               RAISE FND_API.G_EXC_ERROR;
        END IF;

          --construct relationship type rec for update

          l_relationship_type_rec.relationship_type_id  := p_relationship_type_id;
          l_relationship_type_rec.status                := p_status;
          l_relationship_type_rec.subject_type          := NULL;
          l_relationship_type_rec.object_type           := NULL;
          l_relationship_type_rec.created_by_module     := NULL;
          l_relationship_type_rec.application_id        := NULL;

          -- update geography relationship type
          HZ_RELATIONSHIP_TYPE_V2PUB.update_relationship_type(
           	p_init_msg_list            =>'F',
    		p_relationship_type_rec    =>l_relationship_type_rec,
    		p_object_version_number    =>p_object_version_number,
    		x_return_status            =>x_return_status,
    		x_msg_count                =>x_msg_count,
    		x_msg_data                 =>x_msg_data
    		);

        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
           RAISE FND_API.G_EXC_ERROR;
        END IF;

END do_update_geo_rel_type;


-- create Geography Structure
PROCEDURE do_create_geo_structure(
        p_geo_structure_rec            IN GEO_STRUCTURE_REC_TYPE,
        x_return_status                IN OUT NOCOPY VARCHAR2
        )IS

       l_relationship_type_id         NUMBER;
       l_object_version_number        NUMBER := 1;
       l_rowid			              VARCHAR2(64);
       l_country_code                 VARCHAR2(30);
       l_geo_rel_type_rec             GEO_REL_TYPE_REC_TYPE;
       x_relationship_type_id         NUMBER;
       x_msg_count                    NUMBER;
       x_msg_data                     VARCHAR2(2000);
       l_count                        NUMBER;
       l_status                       VARCHAR2(1);
       l_geo_element_col        VARCHAR2(30);

  BEGIN

     -- validate geography structure record
     HZ_GEO_STRUCTURE_VALIDATE_PVT.validate_geo_structure(
       p_create_update_flag       => 'C',
       p_geo_structure_rec        => p_geo_structure_rec,
       x_return_status            => x_return_status
       );

     IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
           RAISE FND_API.G_EXC_ERROR;
     END IF;

     --dbms_output.put_line('After validation '|| x_return_status);

     -- get country code
--     SELECT geography_code
--  Bug 4591502 : ISSUE # 15
--  Use country_code and not geography_code
     SELECT country_code
       INTO l_country_code
       FROM HZ_GEOGRAPHIES
      WHERE geography_id = p_geo_structure_rec.geography_id;

      ----dbms_output.put_line('Country_code is '||l_country_code);

      IF l_country_code IS NULL THEN
           FND_MESSAGE.SET_NAME( 'AR', 'HZ_GEO_NO_RECORD' );
           FND_MESSAGE.SET_TOKEN( 'TOKEN1', 'country_code' );
           FND_MESSAGE.SET_TOKEN( 'TOKEN2', 'geography_id '||p_geo_structure_rec.geography_id );
           FND_MSG_PUB.ADD;
           RAISE FND_API.G_EXC_ERROR;
     END IF;

     -- see whether this geography_element_column to be created is already being used with in this country
        -- for another geography_type. if yes, do not create

  /*    commented the validation per bug :2911108
        SELECT count(*) INTO l_count FROM hz_geo_structure_levels
         WHERE geography_element_column = p_geo_structure_rec.geography_element_column
           AND geography_type <> p_geo_structure_rec.geography_type
           AND geography_id = p_geo_structure_rec.geography_id
           AND rownum < 2;

          IF l_count > 0 THEN
           FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_DUPLICATE_COLUMN' );
           FND_MESSAGE.SET_TOKEN( 'COLUMN', 'geography_element_column');
           FND_MSG_PUB.ADD;
           RAISE FND_API.G_EXC_ERROR;
         END IF;*/

        BEGIN

         SELECT geography_element_column into l_geo_element_col FROM hz_geo_structure_levels
         WHERE geography_id=p_geo_structure_rec.geography_id
           AND geography_type=p_geo_structure_rec.geography_type
           AND rownum < 2;

        EXCEPTION WHEN no_data_found THEN
          BEGIN
          SELECT 'GEOGRAPHY_ELEMENT'||NVL(max(substr(geography_element_column,18))+1,2) geo_element_col
            into l_geo_element_col
            FROM hz_geo_structure_levels
           WHERE geography_id = p_geo_structure_rec.geography_id;

           EXCEPTION WHEN no_data_found THEN
            l_geo_element_col:='GEOGRAPHY_ELEMENT2';
           END;
        END;

      BEGIN

       -- Get the relationship_type_id if there exists one for this geography_type and parent_geography_type
       SELECT relationship_type_id,object_version_number,status
         INTO l_relationship_type_id,l_object_version_number,l_status
         FROM HZ_RELATIONSHIP_TYPES
        WHERE subject_type = p_geo_structure_rec.parent_geography_type
          AND object_type= p_geo_structure_rec.geography_type
          AND forward_rel_code = 'PARENT_OF'
          AND backward_rel_code = 'CHILD_OF'
          AND relationship_type='MASTER_REF';

          -- Activate the relationship_type if it was Inactive
     IF l_status = 'I' THEN
          update_geo_rel_type(
           p_init_msg_list              => 'F',
           p_relationship_type_id       => l_relationship_type_id,
           p_status                     => 'A',
           p_object_version_number      => l_object_version_number,
           x_return_status             	=> x_return_status,
           x_msg_count                 	=> x_msg_count,
           x_msg_data                  	=> x_msg_data
           );

           IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
               RAISE FND_API.G_EXC_ERROR;
           END IF;

      END IF;

        -- validate geo_element_column before inserting the row

      /*  commented as per bug : 2911108
          validate_geo_element_col(
             p_geography_type => p_geo_structure_rec.geography_type,
             p_geography_id   => p_geo_structure_rec.geography_id,
             p_geo_element_column => p_geo_structure_rec.geography_element_column,
             x_return_status  => x_return_status
             );

        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
               RAISE FND_API.G_EXC_ERROR;
        END IF;*/


           -- call table handler to insert a row in HZ_GEO_STRUCTURE_LEVELS
           HZ_GEO_STRUCTURE_LEVELS_PKG.Insert_Row (
            	x_rowid                                 => l_rowid,
            	x_geography_id                          => p_geo_structure_rec.geography_id,
            	x_geography_type                        => p_geo_structure_rec.geography_type,
    		x_parent_geography_type                 => p_geo_structure_rec.parent_geography_type,
    		x_object_version_number                 => 1,
    		x_relationship_type_id                  => l_relationship_type_id,
    		x_country_code                          => l_country_code,
    		x_geography_element_column              => l_geo_element_col,
    		x_created_by_module                     => p_geo_structure_rec.created_by_module,
    		x_application_id                        => p_geo_structure_rec.application_id,
    		x_program_login_id                      => NULL,
                x_addr_val_level                        => p_geo_structure_rec.addr_val_level
    		);

    EXCEPTION
        WHEN NO_DATA_FOUND THEN

        BEGIN

           -- create a relationship type with this geography type and parent geography type

          -- construct geo_rel_type_rec record
           l_geo_rel_type_rec.geography_type := p_geo_structure_rec.geography_type;
           l_geo_rel_type_rec.parent_geography_type := p_geo_structure_rec.parent_geography_type;
           l_geo_rel_type_rec.status   := 'A';
           l_geo_rel_type_rec.created_by_module  := p_geo_structure_rec.created_by_module;
           l_geo_rel_type_rec.application_id     := p_geo_structure_rec.application_id;

          --dbms_output.put_line('Before create_geo_rel_type');
           -- call create_geo_rel_type
          create_geo_rel_type(
          p_init_msg_list             	  =>  'F',
          p_geo_rel_type_rec              => l_geo_rel_type_rec,
          x_relationship_type_id          => x_relationship_type_id,
          x_return_status             	  => x_return_status,
          x_msg_count                 	  => x_msg_count,
          x_msg_data                  	  => x_msg_data
          );


        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
               RAISE FND_API.G_EXC_ERROR;
        END IF;

        -- validate geo_element_column before inserting the row
       /* commented per bug: 2911108
          validate_geo_element_col(
             p_geography_type => p_geo_structure_rec.geography_type,
             p_geography_id   => p_geo_structure_rec.geography_id,
             p_geo_element_column => p_geo_structure_rec.geography_element_column,
             x_return_status  => x_return_status
             );

             IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
               RAISE FND_API.G_EXC_ERROR;
        END IF;*/

        -- insert a row in hz_geo_structure_levels with new relationship_type_id
     HZ_GEO_STRUCTURE_LEVELS_PKG.Insert_Row (
            	x_rowid                                 => l_rowid,
            	x_geography_id                          => p_geo_structure_rec.geography_id,
            	x_geography_type                        => p_geo_structure_rec.geography_type,
    		x_parent_geography_type                 => p_geo_structure_rec.parent_geography_type,
    		x_object_version_number                 => 1,
    		x_relationship_type_id                  => x_relationship_type_id,
    		x_country_code                          => l_country_code,
    		x_geography_element_column              => l_geo_element_col,
    		x_created_by_module                     => p_geo_structure_rec.created_by_module,
    		x_application_id                        => p_geo_structure_rec.application_id,
    		x_program_login_id                      => NULL,
                x_addr_val_level                        => p_geo_structure_rec.addr_val_level
    		);

        END;
   END;

END do_create_geo_structure;

/*  Obsoleting as it is no more needed ( bug 2911108)
-- update geography structure
PROCEDURE do_update_geo_structure(
    p_geography_id                        IN         NUMBER,
    p_geography_type                      IN         VARCHAR2,
    p_parent_geography_type               IN         VARCHAR2,
    p_geography_element_column            IN         VARCHAR2,
    p_object_version_number    		  IN  OUT NOCOPY  NUMBER,
    x_return_status             	  IN  OUT NOCOPY  VARCHAR2
           ) IS

        l_relation_count          NUMBER;
        l_rowid                   ROWID;
        l_object_type             VARCHAR2(30);
        l_country_code            VARCHAR2(2);
        l_stmnt                   VARCHAR2(1000);
        l_geo_element_col         VARCHAR2(30);
        l_count                   NUMBER;
        l_geo_structure_rec       GEO_STRUCTURE_REC_TYPE;
        l_object_version_number   NUMBER;
        CURSOR c_geo_structure_map IS
        SELECT distinct map.map_id
          FROM hz_geo_struct_map map, hz_geo_struct_map_dtl dtl
         WHERE map.country_code = l_country_code
           AND map.map_id = dtl.map_id;
         l_geo_structure_map    c_geo_structure_map%ROWTYPE;

       BEGIN

         l_geo_structure_rec.geography_id := p_geography_id;
         l_geo_structure_rec.geography_type := p_geography_type;
         l_geo_structure_rec.parent_geography_type := p_parent_geography_type;
         l_geo_structure_rec.geography_element_column := p_geography_element_column;

        --dbms_output.put_line('before validate');

         -- validate record for update
         HZ_GEO_STRUCTURE_VALIDATE_PVT.validate_geo_structure(
                   p_create_update_flag    => 'U',
 		   p_geo_structure_rec     => l_geo_structure_rec,
 		   x_return_status         => x_return_status
 		   );

 	IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
               RAISE FND_API.G_EXC_ERROR;
        END IF;

     hz_utility_v2pub.validate_mandatory(
          p_create_update_flag     => 'U',
          p_column                 => 'object_version_number',
          p_column_value           => p_object_version_number,
          x_return_status          => x_return_status
          );

          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
               RAISE FND_API.G_EXC_ERROR;
        END IF;

        --dbms_output.put_line('after validate');

        -- see whether this geography_element_column to be updated is already being used with in this country for
        -- another geography_type . if yes, do not update

        SELECT count(*) INTO l_count FROM hz_geo_structure_levels
         WHERE geography_element_column = p_geography_element_column
           AND geography_type <> p_geography_type
           AND geography_id = p_geography_id
           AND rownum < 2;

          IF l_count > 0 THEN
           FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_DUPLICATE_COLUMN' );
           FND_MESSAGE.SET_TOKEN( 'COLUMN', 'geography_element_column for this geography_id' );
           FND_MSG_PUB.ADD;
           RAISE FND_API.G_EXC_ERROR;
         END IF;

        BEGIN
         SELECT country_code,geography_element_column,rowid,object_version_number
           INTO l_country_code,l_geo_element_col,l_rowid,l_object_version_number
           FROM hz_geo_structure_levels
          WHERE geography_id = p_geography_id
            AND geography_type = p_geography_type
            AND parent_geography_type = p_parent_geography_type;

          IF p_object_version_number <> l_object_version_number THEN
             FND_MESSAGE.SET_NAME('AR', 'HZ_API_RECORD_CHANGED');
             FND_MESSAGE.SET_TOKEN('TABLE', 'hz_geo_structure_levels');
             FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
            ELSE
              p_object_version_number := l_object_version_number+1;
            END IF;
          EXCEPTION WHEN NO_DATA_FOUND THEN
             FND_MESSAGE.SET_NAME( 'AR', 'HZ_GEO_NO_RECORD' );
           FND_MESSAGE.SET_TOKEN( 'TOKEN1', 'country_code , geography_element_column' );
           FND_MESSAGE.SET_TOKEN( 'TOKEN2', 'geography_id '||p_geography_id||', geography_type '||p_geography_type||', parent_geography_type '||p_parent_geography_type );
           FND_MSG_PUB.ADD;
           RAISE FND_API.G_EXC_ERROR;
         END;

         BEGIN
              --dbms_output.put_line('l_geography_element '||l_geo_element_col);
              --dbms_output.put_line('l_country_code '||''''||l_country_code||'''');
              --dbms_output.put_line('before execute');
          --see if there exists any geography in hz_geographies where this geography_element_column being update
          -- is denormalized. If yes, do not update.

       BEGIN

         /* EXECUTE IMMEDIATE 'SELECT 1 FROM hz_geographies WHERE '||l_geo_element_col||' IS NOT NULL AND country_code='||''''||l_country_code||''''||
                  ' AND rownum <2'; */

     /*    SELECT 1 into l_count from
         hz_relationships hrl
         WHERE
               hrl.relationship_type='MASTER_REF'
           AND hrl.subject_type= p_parent_geography_type
           AND hrl.object_type=p_geography_type
           AND hrl.relationship_code='PARENT_OF'
           AND hrl.status = 'A'
           AND hrl.subject_id in ( SELECT geography_id from hz_geographies where
                                    country_code = l_country_code )
           AND rownum <2;
           --dbms_output.put_line('after execute');
           FND_MESSAGE.SET_NAME( 'AR', 'HZ_GEO_ELEMENT_NONUPDATEABLE' );
           --FND_MESSAGE.SET_TOKEN( 'COLUMN', 'geography_element_column' );
           FND_MSG_PUB.ADD;
           --x_return_status := FND_API.G_RET_STS_ERROR;
           RAISE FND_API.G_EXC_ERROR;

           --dbms_output.put_line('l_count is '|| to_char(l_count));
       EXCEPTION WHEN NO_DATA_FOUND THEN
            --dbms_output.put_line('before update');
           --call table handler to update row
           HZ_GEO_STRUCTURE_LEVELS_PKG.Update_Row (
    x_rowid                                 => l_rowid,
    x_geography_id                          => p_geography_id,
    x_geography_type                        => p_geography_type,
    x_parent_geography_type                 => p_parent_geography_type,
    x_object_version_number                 => p_object_version_number,
    x_relationship_type_id                  => NULL,
    x_country_code                          => NULL,
    x_geography_element_column              => p_geography_element_column,
    x_created_by_module                     => NULL,
    x_application_id                        => NULL,
    x_program_login_id                      => NULL
    );
    end;

    -- update hz_geo_structure_map table
    OPEN c_geo_structure_map;
    LOOP
    FETCH c_geo_structure_map INTO l_geo_structure_map;
    EXIT WHEN c_geo_structure_map%NOTFOUND;
     UPDATE hz_geo_struct_map_dtl
        SET geo_element_col=p_geography_element_column
      WHERE geography_type= p_geography_type
        AND map_id = l_geo_structure_map.map_id;
     END LOOP;
     CLOSE c_geo_structure_map;
  END;

END do_update_geo_structure;
*/


 --delete geography structure
 PROCEDURE do_delete_geo_structure(
        p_geography_id              IN NUMBER,
        p_geography_type            IN VARCHAR2,
        p_parent_geography_type     IN VARCHAR2,
        x_return_status             IN OUT NOCOPY VARCHAR2
        )IS

        l_column         VARCHAR2(30);
        l_error          BOOLEAN := FALSE;
        l_relationship_type_id NUMBER;
        l_country_code   VARCHAR2(2);
        l_geo_rel_type_rec   GEO_REL_TYPE_REC_TYPE;
        x_msg_count      NUMBER;
        x_msg_data       VARCHAR2(2000);
        l_count          NUMBER;
        l_object_version_number NUMBER;
        l_child_geography_type VARCHAR2(30);
        l_new_relationship_type_id NUMBER;
        l_status   VARCHAR2(1);
        l_map_id         NUMBER;
	l_geography_id   NUMBER;
	l_usage_id       NUMBER;
	l_location_id    NUMBER;
	l_loc_tbl_name   VARCHAR2(50);
	l_zone_type      VARCHAR2(50);
	l_zone_id        NUMBER;
	l_start_date     VARCHAR2(30);
	l_master_ref_geography_id  NUMBER;
	l_geography_from   VARCHAR2(30);
	l_location_table_name  VARCHAR2(30);
	l_country        VARCHAR2(2);
        l_address_style  VARCHAR2(30);
        l_geo_struct_map_dtl_tbl HZ_GEO_STRUCT_MAP_PUB.geo_struct_map_dtl_tbl_type;


	CURSOR c_get_geo_map is
	Select map_id
	from hz_geo_struct_map
	where country_code = l_country_code;

	CURSOR c_get_addr_usg is
	SELECT usage_id
	FROM hz_address_usages
	WHERE map_id = l_map_id;

	CURSOR c_get_geographies is
	SELECT geography_id
	FROM hz_geographies
	WHERE geography_type = p_geography_type
	AND country_code = l_country_code;

	CURSOR c_get_geo_name_ref is
	SELECT location_id,Location_table_name
	FROM hz_geo_name_references
	WHERE geography_id = l_geography_id;

	CURSOR c_get_ranges is
	SELECT geography_id,master_ref_geography_id,geography_from,
		                start_date
	FROM hz_geography_ranges hgr
	WHERE (SELECT country_code
		          FROM  hz_geographies hg
		          WHERE hg.geography_id = hgr.master_ref_geography_id ) = l_country_code;

	CURSOR c_get_zone_types  IS
	SELECT geography_type
	FROM   hz_geography_types_b
	WHERE  limited_by_geography_id = l_geography_id
	AND    geography_use = 'TAX';

   BEGIN


        -- check for mandatory columns

        IF p_geography_id IS NULL THEN
           l_error := TRUE;
            l_column := 'geography_id';
           ELSIF p_geography_type IS NULL THEN
             l_error := TRUE;
             l_column := 'geography_type';
           ELSIF p_parent_geography_type IS NULL THEN
             l_error := TRUE;
             l_column := 'parent_geography_type';
         END IF;

         IF l_error = TRUE THEN
          FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_MISSING_COLUMN' );
          FND_MESSAGE.SET_TOKEN( 'COLUMN', l_column );
          FND_MSG_PUB.ADD;
          RAISE FND_API.G_EXC_ERROR;
         END IF;


         -- get the relationship_type_id for this row
       BEGIN

         SELECT relationship_type_id,country_code INTO l_relationship_type_id,l_country_code
           FROM hz_geo_structure_levels
          WHERE geography_id = p_geography_id
            AND geography_type = p_geography_type
            AND parent_geography_type = p_parent_geography_type;

            EXCEPTION WHEN NO_DATA_FOUND THEN
              FND_MESSAGE.SET_NAME( 'AR', 'HZ_GEO_NO_RECORD' );
          FND_MESSAGE.SET_TOKEN( 'TOKEN1', 'relationship_type_id,country_code' );
          FND_MESSAGE.SET_TOKEN( 'TOKEN2', 'geography_id '||p_geography_id||', geography_type '||p_geography_type||', parent_geography_type '||p_parent_geography_type );
          FND_MSG_PUB.ADD;
          RAISE FND_API.G_EXC_ERROR;
       END;
      -- code added for bug 4730508
       BEGIN

       SELECT geography_type into l_child_geography_type
        FROM  hz_geo_structure_levels
       WHERE  geography_id = p_geography_id
         AND  parent_geography_type = p_geography_type;

        BEGIN
       -- Get the relationship_type_id if there exists one for this geography_type and parent_geography_type
       SELECT relationship_type_id,object_version_number,status
         INTO l_new_relationship_type_id,l_object_version_number,l_status
         FROM HZ_RELATIONSHIP_TYPES
        WHERE subject_type = p_parent_geography_type
          AND object_type= l_child_geography_type
          AND forward_rel_code = 'PARENT_OF'
          AND backward_rel_code = 'CHILD_OF'
          AND relationship_type='MASTER_REF';

          -- Activate the relationship_type if it was Inactive
       IF l_status = 'I' THEN
          update_geo_rel_type(
           p_init_msg_list              => 'F',
           p_relationship_type_id       => l_new_relationship_type_id,
           p_status                     => 'A',
           p_object_version_number      => l_object_version_number,
           x_return_status             	=> x_return_status,
           x_msg_count                 	=> x_msg_count,
           x_msg_data                  	=> x_msg_data
           );

           IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
               RAISE FND_API.G_EXC_ERROR;
           END IF;

        END IF;

    --  Bug 4543926  : update parent_geography_type for a child level
    --  before deleting a level to its parent_geography_type
        UPDATE hz_geo_structure_levels
        set parent_geography_type = p_parent_geography_type,
            relationship_type_id = l_new_relationship_type_id
        where geography_id = p_geography_id
        and parent_geography_type = p_geography_type;


    EXCEPTION
        WHEN NO_DATA_FOUND THEN

        BEGIN

           -- create a relationship type with this geography type and parent geography type

          -- construct geo_rel_type_rec record
           l_geo_rel_type_rec.geography_type := l_child_geography_type;
           l_geo_rel_type_rec.parent_geography_type := p_parent_geography_type;
           l_geo_rel_type_rec.status   := 'A';
           l_geo_rel_type_rec.created_by_module  := 'HZ_GEO_HIERARCHY';
           l_geo_rel_type_rec.application_id     :=  222;

          --dbms_output.put_line('Before create_geo_rel_type');
         -- call create_geo_rel_type
          create_geo_rel_type(
          p_init_msg_list             	  =>  'F',
          p_geo_rel_type_rec              => l_geo_rel_type_rec,
          x_relationship_type_id          => l_new_relationship_type_id,
          x_return_status             	  => x_return_status,
          x_msg_count                 	  => x_msg_count,
          x_msg_data                  	  => x_msg_data
          );


        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
               RAISE FND_API.G_EXC_ERROR;
        END IF;

  --  Bug 4543926 : update parent_geography_type for a child level
  --  before deleting a level to its parent_geography_type
        UPDATE hz_geo_structure_levels
        set parent_geography_type = p_parent_geography_type,
        relationship_type_id = l_new_relationship_type_id
        where geography_id = p_geography_id
        and parent_geography_type = p_geography_type;

      END;
     END;
    EXCEPTION
       WHEN NO_DATA_FOUND THEN
          null;
    END;


         -- call table handler to delete the row
         HZ_GEO_STRUCTURE_LEVELS_PKG.Delete_Row (
   		 x_geography_id               => p_geography_id,
    		 x_geography_type             => p_geography_type,
    		 x_parent_geography_type      => p_parent_geography_type
    		 );

          -- disable the relationship_type if it is not used by any other structure
           SELECT count(*) INTO l_count
             FROM hz_geo_structure_levels
            WHERE country_code <> l_country_code
              AND relationship_type_id=l_relationship_type_id
              AND rownum <3;

        IF l_count = 0 THEN
             -- call API to disable the relationship_type
           /*  l_geo_rel_type_rec.relationship_type_id := l_relationship_type_id;
             l_geo_rel_type_rec.status := 'I';
             l_geo_rel_type_rec.parent_geography_type := NULL;
             l_geo_rel_type_rec.geography_type := NULL;
             l_geo_rel_type_rec.created_by_module := NULL;
             l_geo_rel_type_rec.application_id := NULL;*/

            SELECT object_version_number into l_object_version_number
              FROM hz_relationship_types
             WHERE relationship_type_id = l_relationship_type_id;

             update_geo_rel_type(
             p_init_msg_list             	=> 'F',
   	         p_relationship_type_id             => l_relationship_type_id,
   	         p_status                           => 'I',
             p_object_version_number            => l_object_version_number,
             x_return_status             	=> x_return_status,
             x_msg_count                 	=> x_msg_count,
             x_msg_data                  	=> x_msg_data
             );

           IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
               RAISE FND_API.G_EXC_ERROR;
           END IF;

           -- disable the backward relationship_type too
           SELECT object_version_number,relationship_type_id into l_object_version_number,l_relationship_type_id
           FROM hz_relationship_types
           WHERE subject_type=p_geography_type
             AND object_type=p_parent_geography_type
             AND relationship_type='MASTER_REF'
             AND forward_rel_code = 'CHILD_OF'
             AND backward_rel_code = 'PARENT_OF';

             update_geo_rel_type(
             p_init_msg_list             	=> 'F',
   	         p_relationship_type_id             => l_relationship_type_id,
   	         p_status                           => 'I',
             p_object_version_number            => l_object_version_number,
             x_return_status             	=> x_return_status,
             x_msg_count                 	=> x_msg_count,
             x_msg_data                  	=> x_msg_data
             );

           IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
               RAISE FND_API.G_EXC_ERROR;
           END IF;

      END IF;

    -- Delete when geography type is checked as included geo type in a tax zone type
     delete hz_relationship_types
     where relationship_type = 'TAX'
     and  ((object_type = p_geography_type
           and subject_type in (select hgt.geography_type from
                                hz_geography_types_b hgt,hz_geographies hg
                                where hgt.limited_by_geography_id = hg.geography_id
                                and  hgt.geography_use = 'TAX'
                                and  hg.country_code = l_country_code ))
     or   (subject_type = p_geography_type
           and  object_type in (select hgt.geography_type from
                                hz_geography_types_b hgt,hz_geographies hg
                                where hgt.limited_by_geography_id = hg.geography_id
                                and  hgt.geography_use = 'TAX'
                                and  hg.country_code = l_country_code )));

   -- Delete geographies
      open c_get_geographies;
      loop
        fetch c_get_geographies into l_geography_id;
        exit when c_get_geographies%NOTFOUND;

        delete hz_geographies
        where geography_id = l_geography_id;

     -- Delete geography identifiers
	delete hz_geography_identifiers
	where geography_id = l_geography_id;

     -- delete geo name reference and geo name ref log
	open c_get_geo_name_ref;
	loop
	    fetch c_get_geo_name_ref into l_location_id,l_loc_tbl_name;
	    exit when c_get_geo_name_ref%NOTFOUND;

	    delete hz_geo_name_references
	    where location_id = l_location_id
	    and   location_table_name = l_loc_tbl_name;

	    delete hz_geo_name_reference_log
	    where location_id = l_location_id
	    and location_table_name = l_loc_tbl_name;
	end loop;
	CLOSE c_get_geo_name_ref;
	  -- if postal_code is deleted from structure delete all ranges record
	  -- for this country
	if p_geography_type = 'POSTAL_CODE' then
	   open c_get_ranges;
	   loop
	     fetch c_get_ranges into l_zone_id,l_master_ref_geography_id,l_geography_from,l_start_date;
	     exit when c_get_ranges%NOTFOUND;

	     delete hz_geography_ranges hgr
	     where geography_id = l_zone_id
	     and   geography_from = l_geography_from
	     and   start_date = l_start_date;

	     -- delete master_ref_geogrpahy for postal code range
	     delete hz_relationships
	     where subject_id = l_zone_id
	     and   object_id = l_master_ref_geography_id
	     and   subject_table_name = 'HZ_GEOGRAPHIES'
	     and   object_table_name = 'HZ_GEOGRAPHIES'
	     and   directional_flag = 'F'
	     and   relationship_type = 'TAX'  ;

	     delete hz_relationships
	     where subject_id = l_master_ref_geography_id
	       and   object_id = l_zone_id
	     and   subject_table_name = 'HZ_GEOGRAPHIES'
	       and   object_table_name = 'HZ_GEOGRAPHIES'
	       and   directional_flag = 'B'
	     and   relationship_type = 'TAX';

	   end loop;
	   CLOSE c_get_ranges;

	   update hz_geography_types_b hgt
           set postal_code_range_flag = 'N'
	   where geography_use = 'TAX'
	   and limited_by_geography_id is not null
	   and (select country_code
		from hz_geographies
		where geography_id = hgt.limited_by_geography_id)
		= l_country_code;
	 end if;
	 -- delete geogrpahy ranges if any master_ref_geo is deleted
	 delete hz_geography_ranges
	 where master_ref_geography_id = l_geography_id;

	 -- delete relationships record both for tax and master_ref relationship_type
	 delete hz_relationships
	 where (object_id = l_geography_id
	 or    subject_id = l_geography_id )
	 and   subject_table_name = 'HZ_GEOGRAPHIES'
	 and   object_table_name = 'HZ_GEOGRAPHIES'
	 and   (relationship_type = 'TAX'
	 or     relationship_type = 'MASTER_REF');

	 -- delete hierarchy nodes record for master_ref geos
	 delete hz_hierarchy_nodes
	 where (parent_id = l_geography_id
	 or     child_id = l_geography_id)
	 and parent_table_name = 'HZ_GEOGRAPHIES'
	 and child_table_name = 'HZ_GEOGRAPHIES'
	 and hierarchy_type = 'MASTER_REF';

	  -- delete tax zone type whose limited by geo id is deleted
	  OPEN c_get_zone_types;
	  LOOP
	    FETCH c_get_zone_types INTO l_zone_type;
	    EXIT WHEN c_get_zone_types%NOTFOUND ;

	    DELETE hz_geography_types_b
	    WHERE geography_type = l_zone_type
	    AND geography_use = 'TAX';

            -- delete identifiers and relationships for tax zones to be deleted

	    DELETE hz_geography_identifiers
	    WHERE geography_id IN (SELECT geography_id
	                          FROM hz_geographies
	                          WHERE geography_type = l_zone_type
	                          AND geography_use = 'TAX');


            DELETE hz_relationships
            WHERE subject_id in (SELECT geography_id
	                          FROM hz_geographies
	                          WHERE geography_type = l_zone_type
	                          AND geography_use = 'TAX')
            AND subject_type = l_zone_type
            AND subject_table_name = 'HZ_GEOGRAPHIES'
            AND relationship_type = 'TAX';


            DELETE hz_relationships
            WHERE object_id in (SELECT geography_id
	                        FROM hz_geographies
	                        WHERE geography_type = l_zone_type
	                        AND geography_use = 'TAX')
            AND  object_type = l_zone_type
            AND  object_table_name = 'HZ_GEOGRAPHIES'
            AND  relationship_type = 'TAX';

	    -- delete tax zone assosiated with this tax zone type

	    DELETE hz_geographies
	    WHERE geography_type = l_zone_type
	    AND geography_use = 'TAX' ;
	  END LOOP;
	  CLOSE c_get_zone_types;
	END LOOP;
	CLOSE c_get_geographies;


-- Delete mapping and address usages for geography type
   open c_get_geo_map;
   loop
     fetch c_get_geo_map into l_map_id;
     exit when c_get_geo_map%NOTFOUND ;

     select map_id,loc_tbl_name,country_code,
	    address_style
     into  l_map_id,l_location_table_name,l_country,
	   l_address_style
     from hz_geo_struct_map
     where map_id = l_map_id;
     if l_map_id is not null then
       select loc_seq_num,loc_component,geography_type
       bulk collect into l_geo_struct_map_dtl_tbl
       from hz_geo_struct_map_dtl
       where map_id = l_map_id
       and geography_type = p_geography_type;

       if l_geo_struct_map_dtl_tbl.COUNT > 0 then

	HZ_GEO_STRUCT_MAP_PUB.delete_geo_struct_mapping(l_map_id,
						     l_location_table_name,
						     l_country,
						     l_address_style,
						     l_geo_struct_map_dtl_tbl,
						     FND_API.G_FALSE,
						     x_return_status,
						     x_msg_count,
						     x_msg_data);
	 IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	    RAISE FND_API.G_EXC_ERROR;
	 END IF;
       end if;
      end if;
/*
     delete hz_geo_struct_map_dtl
     where map_id = l_map_id
     and geography_type = p_geography_type;

	   open c_get_addr_usg;
	   LOOP
	      fetch c_get_addr_usg into l_usage_id;
	      exit when c_get_addr_usg%NOTFOUND;

	      delete hz_address_usage_dtls
	      where usage_id = l_usage_id
	      and geography_type = p_geography_type;

	   end loop;
	   CLOSE c_get_addr_usg;
*/
    end loop;
    CLOSE c_get_geo_map;


END do_delete_geo_structure;


-- create zone type
PROCEDURE do_create_zone_type(
        p_zone_type_rec             IN   ZONE_TYPE_REC_TYPE,
        x_return_status             IN OUT NOCOPY VARCHAR2
       ) IS

       l_object_id          NUMBER;
       l_predicate          VARCHAR2(1000);
       l_rowid              VARCHAR2(64);
       l_count              NUMBER;
       l_geo_rel_type_rec   GEO_REL_TYPE_REC_TYPE;
       x_relationship_type_id NUMBER;
       l_instance_set_id      NUMBER;
       x_msg_count            NUMBER;
       x_msg_data             VARCHAR2(2000);
       l_geography_type_name  VARCHAR2(80);

       --  Added ro ER 4232852
       l_rel_status VARCHAR2(1);
       l_object_version_number NUMBER;

       l_limited_by_geo_type   VARCHAR2(30);
       l_country_code          VARCHAR2(30);
       l_valid_geo_type        VARCHAR2(30);

  BEGIN

     l_geography_type_name := p_zone_type_rec.geography_type_name;

      HZ_GEO_STRUCTURE_VALIDATE_PVT.validate_zone_type (
        p_zone_type_rec     => p_zone_type_rec,
        p_create_update_flag => 'C',
        x_return_status  => x_return_status
        );

        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
               RAISE FND_API.G_EXC_ERROR;
           END IF;
        IF p_zone_type_rec.geography_type_name IS NULL THEN
          l_geography_type_name := initcap(p_zone_type_rec.geography_type);
        END IF;

       --dbms_output.put_line('l_geography_type_name is '||l_geography_type_name);
        -- call the table handler to create geography_type
    hz_geography_types_PKG.Insert_Row (
    x_rowid                              =>   l_rowid,
    x_geography_type                     =>   p_zone_type_rec.geography_type,
    x_geography_type_name                =>   l_geography_type_name,
    x_object_version_number              =>   1,
    x_geography_use                      =>   p_zone_type_rec.geography_use,
    x_postal_code_range_flag             =>   p_zone_type_rec.postal_code_range_flag,
    x_limited_by_geography_id            =>   p_zone_type_rec.limited_by_geography_id,
    x_created_by_module                  =>   p_zone_type_rec.created_by_module,
    x_application_id                     =>   p_zone_type_rec.application_id,
    x_program_login_id                   =>   NULL
);

 --dbms_output.put_line('After geography_type insert');

 -- initialize the variables for creating fnd_object_instance_sets


    SELECT object_id into l_object_id
      FROM FND_OBJECTS
     WHERE obj_name='HZ_GEOGRAPHIES';

--  Replace the ' in predicate with ''
      l_predicate := 'GEOGRAPHY_TYPE='||''''||replace(p_zone_type_rec.geography_type,'''','''''')||'''';

  BEGIN
   SELECT count(*)
      INTO l_count
      FROM FND_OBJECT_INSTANCE_SETS
     WHERE INSTANCE_SET_NAME = p_zone_type_rec.geography_type;

        IF l_count = 0  THEN

         SELECT FND_OBJECT_INSTANCE_SETS_S.nextval INTO l_instance_set_id FROM dual;
         l_rowid := NULL;

        -- call the table handler to create fnd_object_instance_sets
    FND_OBJECT_INSTANCE_SETS_PKG.INSERT_ROW (
    X_ROWID                     => l_rowid,
    X_INSTANCE_SET_ID 		=> l_instance_set_id,
    X_INSTANCE_SET_NAME         => p_zone_type_rec.geography_type,
    X_OBJECT_ID                 => l_object_id,
    X_PREDICATE                 => l_predicate,
    X_DISPLAY_NAME              => p_zone_type_rec.geography_type,
    X_DESCRIPTION               => p_zone_type_rec.geography_type,
    X_CREATION_DATE             => HZ_UTILITY_V2PUB.creation_date,
    X_CREATED_BY                => HZ_UTILITY_V2PUB.created_by,
    X_LAST_UPDATE_DATE          => HZ_UTILITY_V2PUB.last_update_date,
    X_LAST_UPDATED_BY           => HZ_UTILITY_V2PUB.last_updated_by,
    X_LAST_UPDATE_LOGIN         => HZ_UTILITY_V2PUB.last_update_login
   ) ;

   END IF;
  END;


   -- create relationship_types between geography_type and included_geography_type
   IF p_zone_type_rec.included_geography_type.count > 0 THEN

           l_geo_rel_type_rec.parent_geography_type := p_zone_type_rec.geography_type;
           l_geo_rel_type_rec.status   := 'A';
           l_geo_rel_type_rec.created_by_module  := p_zone_type_rec.created_by_module;
           l_geo_rel_type_rec.application_id     := p_zone_type_rec.application_id;

    FOR i in 1 .. p_zone_type_rec.included_geography_type.count LOOP

      -- check if included_geography_type is COUNTRY and if yes, check for limited_by_geography_id to be null
        IF p_zone_type_rec.included_geography_type(i) = 'COUNTRY' THEN
         IF p_zone_type_rec.limited_by_geography_id IS NOT NULL THEN
           FND_MESSAGE.SET_NAME( 'AR', 'HZ_GEO_LIMITED_GEOGRAPHY');
           FND_MSG_PUB.ADD;
           RAISE FND_API.G_EXC_ERROR;
          END IF;
        END IF;


      -- Below check added for bug # 3116311, 3170024
      -- We should chk to make sure the included_geo_types are the types for children under limited_geo_id.
      IF (p_zone_type_rec.limited_by_geography_id IS NOT NULL AND p_zone_type_rec.limited_by_geography_id <> fnd_api.g_miss_num) THEN
        BEGIN
           SELECT geography_type, country_code
           INTO   l_limited_by_geo_type, l_country_code
           FROM hz_geographies
           WHERE geography_id = p_zone_type_rec.limited_by_geography_id;

           SELECT geography_type
           INTO   l_valid_geo_type
           FROM   hz_geo_structure_levels
           WHERE  country_code = l_country_code
           AND    geography_type = p_zone_type_rec.included_geography_type(i)
           START WITH parent_geography_type = l_limited_by_geo_type
           AND country_code = l_country_code
           CONNECT BY PRIOR geography_type = parent_geography_type
           AND country_code = l_country_code;

        EXCEPTION WHEN NO_DATA_FOUND THEN
           FND_MESSAGE.SET_NAME( 'AR', 'HZ_GEO_INVALID_INC_GEO_TYPE');
           FND_MESSAGE.SET_TOKEN('P_LIMITED_BY_GEOGRAPHY', l_limited_by_geo_type);
           FND_MSG_PUB.ADD;
           RAISE FND_API.G_EXC_ERROR;
        END;
      END IF;

      -- check if there exists a relationship_type for this geography_type and included_geography_type
        Begin
            SELECT status, relationship_type_id, object_version_number
            INTO l_rel_status, x_relationship_type_id, l_object_version_number
            FROM HZ_RELATIONSHIP_TYPES
            WHERE subject_type = p_zone_type_rec.geography_type
            AND object_type= p_zone_type_rec.included_geography_type(i)
            AND forward_rel_code = 'PARENT_OF'
            AND backward_rel_code = 'CHILD_OF'
            AND relationship_type = p_zone_type_rec.geography_use;

            IF l_rel_status = 'I' THEN
               HZ_GEOGRAPHY_STRUCTURE_PUB.update_geo_rel_type(
               p_init_msg_list              => 'F',
               p_relationship_type_id       => x_relationship_type_id,
               p_status                     => 'A',
               p_object_version_number      => l_object_version_number,
               x_return_status             	=> x_return_status,
               x_msg_count                 	=> x_msg_count,
               x_msg_data                  	=> x_msg_data
               );
               IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                  RAISE FND_API.G_EXC_ERROR;
               END IF;
            END IF;
        EXCEPTION
           WHEN NO_DATA_FOUND THEN
-- create a relationship type with this geography type and included geography type
           l_geo_rel_type_rec.geography_type := p_zone_type_rec.included_geography_type(i);
           x_relationship_type_id := NULL;

          HZ_GEOGRAPHY_STRUCTURE_PUB.create_geo_rel_type(
          p_init_msg_list               =>  'F',
          p_geo_rel_type_rec              => l_geo_rel_type_rec,
          x_relationship_type_id          => x_relationship_type_id,
          x_return_status               => x_return_status,
          x_msg_count                   => x_msg_count,
          x_msg_data                     => x_msg_data
          );

          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
             RAISE FND_API.G_EXC_ERROR;
          END IF;
        END;
      END LOOP;
      END IF;
END do_create_zone_type;


-- update zone Type

PROCEDURE do_update_zone_type(
        p_zone_type_rec                IN         ZONE_TYPE_REC_TYPE,
        p_object_version_number        IN OUT NOCOPY NUMBER,
        x_return_status                IN OUT NOCOPY VARCHAR2,
        x_msg_count                 	  OUT  NOCOPY     NUMBER,
        x_msg_data                  	  OUT  NOCOPY      VARCHAR2
        ) IS

        l_postal_code_range_flag VARCHAR2(1);
        l_limited_by_geo_id      NUMBER;
        l_count                      NUMBER;
        l_rowid                      ROWID;
        l_object_version_number      NUMBER;
        l_geography_type             VARCHAR2(30);

        p_geography_type VARCHAR2(30) := p_zone_type_rec.geography_type;
        p_limited_by_geography_id NUMBER := p_zone_type_rec.limited_by_geography_id;
        p_postal_code_range_flag VARCHAR2(1) := p_zone_type_rec.postal_code_range_flag;
        l_rel_status VARCHAR2(1);
        x_relationship_type_id NUMBER;
        l_geo_rel_type_rec   GEO_REL_TYPE_REC_TYPE;
        l_object_type             VARCHAR2(30);
        removed boolean := TRUE;

        cursor included_geo_type is
        select relationship_type_id, object_version_number, object_type
        from HZ_RELATIONSHIP_TYPES
        where subject_type = p_zone_type_rec.geography_type
        and forward_rel_code = 'PARENT_OF'
        and backward_rel_code = 'CHILD_OF'
        and relationship_type = 'TAX'
        and status = 'A';


 BEGIN

      hz_utility_v2pub.validate_mandatory(
          p_create_update_flag     => 'U',
          p_column                 => 'object_version_number',
          p_column_value           => p_object_version_number,
          x_return_status          => x_return_status
          );

          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
               RAISE FND_API.G_EXC_ERROR;
        END IF;

   -- validate for zone type update

      BEGIN

             SELECT OBJECT_VERSION_NUMBER,
               ROWID,
               GEOGRAPHY_TYPE,
               POSTAL_CODE_RANGE_FLAG,
               LIMITED_BY_GEOGRAPHY_ID
        INTO   l_object_version_number,
               l_rowid,
               l_geography_type,
               l_postal_code_range_flag,
               l_limited_by_geo_id
        FROM   HZ_GEOGRAPHY_TYPES_B
        WHERE  GEOGRAPHY_TYPE = p_GEOGRAPHY_TYPE
        FOR UPDATE OF GEOGRAPHY_TYPE NOWAIT;


        --validate object_version_number
      IF l_object_version_number <> p_object_version_number THEN
            FND_MESSAGE.SET_NAME('AR', 'HZ_API_RECORD_CHANGED');
            FND_MESSAGE.SET_TOKEN('TABLE', 'hz_geography_types_b');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
        ELSE
         p_object_version_number := l_object_version_number + 1;
       END IF;

        EXCEPTION WHEN NO_DATA_FOUND THEN
        FND_MESSAGE.SET_NAME('AR', 'HZ_GEO_NO_RECORD');
        FND_MESSAGE.SET_TOKEN('TOKEN1','zone_type');
        FND_MESSAGE.SET_TOKEN('TOKEN2', 'zone_type '||p_geography_type);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;

     END;

      HZ_GEO_STRUCTURE_VALIDATE_PVT.validate_zone_type(
        p_zone_type_rec     => p_zone_type_rec,
        p_create_update_flag => 'U',
        x_return_status  => x_return_status
        );


        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
               RAISE FND_API.G_EXC_ERROR;
           END IF;

           --dbms_output.put_line('After validate');

     IF (p_postal_code_range_flag = 'Y' and l_postal_code_range_flag = 'N') THEN

      -- check if there exists any rows in hz_geography_ranges table for this zone_type
      -- if yes, then do not allow update

      SELECT count(*) INTO l_count
        FROM hz_geography_ranges
       WHERE geography_id in (SELECT geography_id from hz_geographies
                               WHERE geography_type=p_geography_type
                                 AND end_date > sysdate)
         AND rownum <2;

        --dbms_output.put_line('l_count is '||to_char(l_count));
         IF l_count >0 THEN
             FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_NONUPDATEABLE_COLUMN' );
             FND_MESSAGE.SET_TOKEN( 'COLUMN', 'postal_code_range_flag from Y to N as there exists rows in hz_geography_ranges');
             FND_MSG_PUB.ADD;
            -- x_return_status := FND_API.G_RET_STS_ERROR;
             RAISE FND_API.G_EXC_ERROR;
          END IF;
       END IF;

       IF p_limited_by_geography_id <> l_limited_by_geo_id THEN
          --this can be updated only if there are no zones created for this geography_type
        SELECT count(*) INTO l_count
          FROM hz_geographies
         WHERE geography_type = p_geography_type
          AND  end_date > SYSDATE
           AND rownum <3;

           --dbms_output.put_line('l_count for limited_id '||to_char(l_count));

           IF l_count > 0 THEN
             FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_NONUPDATEABLE_COLUMN' );
             FND_MESSAGE.SET_TOKEN( 'COLUMN', 'limited_by_geography_id as there exists zones for this geography_type');
             FND_MSG_PUB.ADD;
            -- x_return_status := FND_API.G_RET_STS_ERROR;
             RAISE FND_API.G_EXC_ERROR;
           END IF;
        END IF;
         --dbms_output.put_line('l_rowid is '|| l_rowid);
         --dbms_output.put_line('geography_type_name is '||p_geography_type_name);
        -- call table handler to update zone type
         hz_geography_types_PKG.update_row(
                       x_rowid                           => l_rowid,
                       x_geography_type                   => p_geography_type,
                       x_geography_type_name              => NULL,
                       x_object_version_number            => p_object_version_number,
                       x_geography_use                    => NULL,
                       x_postal_code_range_flag           => p_postal_code_range_flag,
                       x_limited_by_geography_id          => p_limited_by_geography_id,
                       x_created_by_module                => NULL,
                       x_application_id                   => NULL,
                       x_program_login_id                 => NULL
                       );
          --dbms_output.put_line('After insert');

   -- create relationship_types between geography_type and included_geography_type
   IF p_zone_type_rec.included_geography_type.count > 0 THEN

           l_geo_rel_type_rec.parent_geography_type := p_zone_type_rec.geography_type;
           l_geo_rel_type_rec.status   := 'A';
           l_geo_rel_type_rec.created_by_module  := p_zone_type_rec.created_by_module;
           l_geo_rel_type_rec.application_id     := p_zone_type_rec.application_id;

    FOR i in 1 .. p_zone_type_rec.included_geography_type.count LOOP

      -- check if included_geography_type is COUNTRY and if yes, check for limited_by_geography_id to be null
        IF p_zone_type_rec.included_geography_type(i) = 'COUNTRY' THEN
         IF p_zone_type_rec.limited_by_geography_id IS NOT NULL THEN
           FND_MESSAGE.SET_NAME( 'AR', 'HZ_GEO_LIMITED_GEOGRAPHY');
           FND_MSG_PUB.ADD;
           RAISE FND_API.G_EXC_ERROR;
          END IF;
        END IF;
        Begin
            SELECT status, relationship_type_id, object_version_number
            INTO l_rel_status, x_relationship_type_id, l_object_version_number
            FROM HZ_RELATIONSHIP_TYPES
            WHERE subject_type = p_zone_type_rec.geography_type
            AND object_type= p_zone_type_rec.included_geography_type(i)
            AND forward_rel_code = 'PARENT_OF'
            AND backward_rel_code = 'CHILD_OF'
            AND relationship_type = p_zone_type_rec.geography_use;

            IF l_rel_status = 'I' THEN
               HZ_GEOGRAPHY_STRUCTURE_PUB.update_geo_rel_type(
               p_init_msg_list              => 'F',
               p_relationship_type_id       => x_relationship_type_id,
               p_status                     => 'A',
               p_object_version_number      => l_object_version_number,
               x_return_status             	=> x_return_status,
               x_msg_count                 	=> x_msg_count,
               x_msg_data                  	=> x_msg_data
               );
               IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                  RAISE FND_API.G_EXC_ERROR;
               END IF;
            END IF;
        EXCEPTION
           WHEN NO_DATA_FOUND THEN
-- create a relationship type with this geography type and included geography type
           l_geo_rel_type_rec.geography_type := p_zone_type_rec.included_geography_type(i);
           x_relationship_type_id := NULL;
            l_geo_rel_type_rec.status:= 'A';

          HZ_GEOGRAPHY_STRUCTURE_PUB.create_geo_rel_type(
          p_init_msg_list               =>  'F',
          p_geo_rel_type_rec              => l_geo_rel_type_rec,
          x_relationship_type_id          => x_relationship_type_id,
          x_return_status               => x_return_status,
          x_msg_count                   => x_msg_count,
          x_msg_data                     => x_msg_data
          );

          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
             RAISE FND_API.G_EXC_ERROR;
          END IF;
        END;

      END LOOP;
      END IF;

  open included_geo_type;
  loop
     fetch included_geo_type into
     x_relationship_type_id, l_object_version_number, l_object_type;
        exit when included_geo_type%NOTFOUND;
     removed := TRUE;
     FOR j in 1 .. p_zone_type_rec.included_geography_type.count LOOP
       if(l_object_type = p_zone_type_rec.included_geography_type(j)) then
         removed := FALSE;
         exit;
       end if;
     END LOOP;
     if(removed) then
     HZ_GEOGRAPHY_STRUCTURE_PUB.update_geo_rel_type(
               p_init_msg_list              => 'F',
               p_relationship_type_id       => x_relationship_type_id,
               p_status                     => 'I',
               p_object_version_number      => l_object_version_number,
               x_return_status             	=> x_return_status,
               x_msg_count                 	=> x_msg_count,
               x_msg_data                  	=> x_msg_data
               );
               IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                  RAISE FND_API.G_EXC_ERROR;
               END IF;
     end if;
   end loop;
   close included_geo_type;

END do_update_zone_type;


----------------------------
-- body of public procedures
----------------------------

/**
 * PROCEDURE create_geography_type
 *
 * DESCRIPTION
 *     Creates Geography type.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_geography_type_rec           Geography type record.
 *   IN/OUT:
 *   OUT:
 *     x_return_status                Return status after the call. The status can
 *                                    be FND_API.G_RET_STS_SUCCESS (success),
 *                                    FND_API.G_RET_STS_ERROR (error),
 *                                    FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
 *     x_msg_count                    Number of messages in message stack.
 *     x_msg_data                     Message text if x_msg_count is 1.
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   11-04-2002    Rekha Nalluri        o Created.
 *
 */

PROCEDURE create_geography_type (
    p_init_msg_list             IN         VARCHAR2 := FND_API.G_FALSE,
    p_geography_type_rec        IN         GEOGRAPHY_TYPE_REC_TYPE,
    x_return_status             OUT   NOCOPY     VARCHAR2,
    x_msg_count                 OUT   NOCOPY     NUMBER,
    x_msg_data                  OUT   NOCOPY     VARCHAR2
) IS

 --l_geography_type_rec             GEOGRAPHY_TYPE_REC_TYPE := p_geography_type_rec;
 p_index_name         VARCHAR2(30);

 BEGIN
 -- Standard start of API savepoint
    SAVEPOINT create_geography_type;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- Initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Call to business logic.
    do_create_geography_type(
        p_geography_type_rec            => p_geography_type_rec,
        x_return_status                 => x_return_status
       );

   --if validation failed at any point, then raise an exception to stop processing
   IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       RAISE FND_API.G_EXC_ERROR;
   END IF;

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data  => x_msg_data);

   EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO create_geography_type;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO create_geography_type;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

    WHEN DUP_VAL_ON_INDEX THEN
        ROLLBACK TO create_geography_type;
        x_return_status := FND_API.G_RET_STS_ERROR;
        HZ_UTILITY_V2PUB.find_index_name(p_index_name);
        IF p_index_name = 'HZ_GEOGRAPHY_TYPES_B_U1' THEN
          FND_MESSAGE.SET_NAME('AR', 'HZ_API_DUPLICATE_COLUMN');
            FND_MESSAGE.SET_TOKEN('COLUMN', 'geography_type');
            FND_MSG_PUB.ADD;
          END IF;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count        => x_msg_count,
                                p_data        => x_msg_data);

    WHEN OTHERS THEN
        ROLLBACK TO create_geography_type;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
        FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
        FND_MSG_PUB.ADD;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count        => x_msg_count,
                                p_data        => x_msg_data);

END create_geography_type;


/**
 * PROCEDURE create_geography_rel_type
 *
 * DESCRIPTION
 *     Creates Geography Relationship type.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_geography_rel_type_rec       Geography Relationship type record.
 *   IN/OUT:
 *   OUT:
 *     x_return_status                Return status after the call. The status can
 *                                    be FND_API.G_RET_STS_SUCCESS (success),
 *                                    FND_API.G_RET_STS_ERROR (error),
 *                                    FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
 *     x_msg_count                    Number of messages in message stack.
 *     x_msg_data                     Message text if x_msg_count is 1.
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   11-11-2002    Rekha Nalluri        o Created.
 *
 */

 PROCEDURE create_geo_rel_type(
    p_init_msg_list             	  IN         VARCHAR2 := FND_API.G_FALSE,
    p_geo_rel_type_rec                    IN         GEO_REL_TYPE_REC_TYPE,
    x_relationship_type_id                OUT  NOCOPY      NUMBER,
    x_return_status             	  OUT  NOCOPY      VARCHAR2,
    x_msg_count                 	  OUT  NOCOPY      NUMBER,
    x_msg_data                  	  OUT  NOCOPY      VARCHAR2
) IS

  l_geo_rel_type_rec      geo_rel_type_REC_TYPE := p_geo_rel_type_rec;

 BEGIN

    -- Standard start of API savepoint
    SAVEPOINT create_geo_rel_type;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- Initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Call to business logic.
      do_create_geo_rel_type(
        p_geo_rel_type_rec    => l_geo_rel_type_rec,
        x_relationship_type_id  => x_relationship_type_id,
        x_return_status                => x_return_status
        );

        --if validation failed at any point, then raise an exception to stop processing
   IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       RAISE FND_API.G_EXC_ERROR;
   END IF;

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data  => x_msg_data);

    EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO create_geo_rel_type;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO create_geo_rel_type;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

    WHEN OTHERS THEN
        ROLLBACK TO create_geo_rel_type;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MSG_PUB.ADD;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count        => x_msg_count,
                                p_data        => x_msg_data);

END CREATE_GEO_REL_TYPE;

/**
 * PROCEDURE update_geography_rel_type
 *
 * DESCRIPTION
 *     Updates only Status of geography relationship type.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_geography_rel_type_rec       Geography Relationship type record.
 *   IN/OUT:
 *     p_object_version_number        object version number of the row being updated
 *   OUT:
 *     x_return_status                Return status after the call. The status can
 *                                    be FND_API.G_RET_STS_SUCCESS (success),
 *                                    FND_API.G_RET_STS_ERROR (error),
 *                                    FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
 *     x_msg_count                    Number of messages in message stack.
 *     x_msg_data                     Message text if x_msg_count is 1.
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   11-13-2002    Rekha Nalluri        o Created.
 *
 */

PROCEDURE update_geo_rel_type(
    p_init_msg_list             	  IN         VARCHAR2 := FND_API.G_FALSE,
    p_relationship_type_id                IN         NUMBER,
    p_status                              IN         VARCHAR2,
    p_object_version_number               IN  OUT NOCOPY      NUMBER,
    x_return_status             	  OUT  NOCOPY      VARCHAR2,
    x_msg_count                 	  OUT  NOCOPY      NUMBER,
    x_msg_data                  	  OUT  NOCOPY      VARCHAR2
 )IS

   --l_geo_rel_type_rec      geo_rel_type_REC_TYPE := p_geo_rel_type_rec;

 BEGIN

    -- Standard start of API savepoint
    SAVEPOINT update_geo_rel_type;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- Initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Call to business logic.
      do_update_geo_rel_type(
        p_relationship_type_id    => p_relationship_type_id,
        p_status                  => p_status,
        p_object_version_number        => p_object_version_number,
        x_return_status                => x_return_status
        );

        --if validation failed at any point, then raise an exception to stop processing
   IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       RAISE FND_API.G_EXC_ERROR;
   END IF;

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data  => x_msg_data);

    EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO update_geo_rel_type;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO update_geo_rel_type;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

    WHEN OTHERS THEN
        ROLLBACK TO update_geo_rel_type;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MSG_PUB.ADD;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count        => x_msg_count,
                                p_data        => x_msg_data);

END UPDATE_GEO_REL_TYPE;

/**
 * PROCEDURE create_geo_structure
 *
 * DESCRIPTION
 *     Creates Geography Structure.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_geo_structure_rec            Geography structure type record.

 *   IN/OUT:
 *   OUT:
 *     x_return_status                Return status after the call. The status can
 *                                    be FND_API.G_RET_STS_SUCCESS (success),
 *                                    FND_API.G_RET_STS_ERROR (error),
 *                                    FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
 *     x_msg_count                    Number of messages in message stack.
 *     x_msg_data                     Message text if x_msg_count is 1.
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   11-18-2002    Rekha Nalluri        o Created.
 *
 */


PROCEDURE create_geo_structure(
    p_init_msg_list             	  IN         VARCHAR2 := FND_API.G_FALSE,
    p_geo_structure_rec                   IN         GEO_STRUCTURE_REC_TYPE,
    x_return_status             	  OUT   NOCOPY     VARCHAR2,
    x_msg_count                 	  OUT   NOCOPY     NUMBER,
    x_msg_data                  	  OUT   NOCOPY     VARCHAR2
) IS

    p_index_name             VARCHAR2(30);

 BEGIN

    -- Standard start of API savepoint
    SAVEPOINT create_geo_structure;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- Initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Call to business logic.
      do_create_geo_structure(
        p_geo_structure_rec            => p_geo_structure_rec,
        x_return_status                => x_return_status
        );

        --if validation failed at any point, then raise an exception to stop processing
   IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       RAISE FND_API.G_EXC_ERROR;
   END IF;

       -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data  => x_msg_data);

    EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO create_geo_structure;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO create_geo_structure;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

   WHEN DUP_VAL_ON_INDEX THEN
        ROLLBACK TO create_geo_structure;
        HZ_UTILITY_V2PUB.find_index_name(p_index_name);
        IF p_index_name = 'HZ_GEO_STRUCTURE_LEVELS_U1' THEN
          FND_MESSAGE.SET_NAME('AR', 'HZ_API_DUPLICATE_COLUMN');
            FND_MESSAGE.SET_TOKEN('COLUMN', 'geography_id,geography_type and parent_geography_type');
            FND_MSG_PUB.ADD;
          END IF;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count        => x_msg_count,
                                p_data        => x_msg_data);

    WHEN OTHERS THEN
        ROLLBACK TO create_geo_structure;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MSG_PUB.ADD;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count        => x_msg_count,
                                p_data        => x_msg_data);

END create_geo_structure;


/**
 * PROCEDURE update_geo_structure
 *
 * DESCRIPTION
 *  Updates geography_element_column in a Geography Structure - geography_element_column can be updated for
 *     a geography_id and relationship_type_id only when there exists no geographies that have used this
 *     structure.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_geo_structure_rec            Geography structure type record.

 *   IN/OUT:
 *      p_object_version_number       object version number of the row being updated
 *   OUT:
 *     x_return_status                Return status after the call. The status can
 *                                    be FND_API.G_RET_STS_SUCCESS (success),
 *                                    FND_API.G_RET_STS_ERROR (error),
 *                                    FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
 *     x_msg_count                    Number of messages in message stack.
 *     x_msg_data                     Message text if x_msg_count is 1.
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   12-18-2002    Rekha Nalluri        o Created.
 *
 */

/*  Obsoleting as it is no more needed ( bug 2911108)
PROCEDURE update_geo_structure(
    p_init_msg_list             	  IN         VARCHAR2 := FND_API.G_FALSE,
    p_geography_id                        IN         NUMBER,
    p_geography_type                      IN         VARCHAR2,
    p_parent_geography_type               IN         VARCHAR2,
    p_geography_element_column            IN         VARCHAR2,
    p_object_version_number    		  IN   OUT NOCOPY  NUMBER,
    x_return_status             	  OUT  NOCOPY      VARCHAR2,
    x_msg_count                 	  OUT  NOCOPY      NUMBER,
    x_msg_data                  	  OUT  NOCOPY     VARCHAR2
 ) IS

 BEGIN

    -- Standard start of API savepoint
    SAVEPOINT update_geo_structure;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- Initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Call to business logic.
      do_update_geo_structure(
    p_geography_id                        =>p_geography_id,
    p_geography_type                =>p_geography_type,
    p_parent_geography_type         => p_parent_geography_type,
    p_geography_element_column            =>p_geography_element_column,
    p_object_version_number               => p_object_version_number,
    x_return_status                       => x_return_status
        );

        --if validation failed at any point, then raise an exception to stop processing
   IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       RAISE FND_API.G_EXC_ERROR;
   END IF;

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data  => x_msg_data);

    EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO update_geo_structure;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO update_geo_structure;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

    WHEN OTHERS THEN
        ROLLBACK TO update_geo_structure;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MSG_PUB.ADD;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count        => x_msg_count,
                                p_data        => x_msg_data);

END update_geo_structure;
*/

/**
 * PROCEDURE delete_geo_structure
 *
 * DESCRIPTION
 *     Deletes the row in the structure. Disables the relationship_type if it is not used by any other structure.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_geo_structure_rec            Geography structure type record.

 *   IN/OUT:
 *
 *   OUT:
 *     x_return_status                Return status after the call. The status can
 *                                    be FND_API.G_RET_STS_SUCCESS (success),
 *                                    FND_API.G_RET_STS_ERROR (error),
 *                                    FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
 *     x_msg_count                    Number of messages in message stack.
 *     x_msg_data                     Message text if x_msg_count is 1.
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   12-19-2002    Rekha Nalluri        o Created.
 *
 */

 PROCEDURE delete_geo_structure(
    p_init_msg_list             	  IN         VARCHAR2 := FND_API.G_FALSE,
    p_geography_id                        IN         NUMBER,
    p_geography_type                      IN         VARCHAR2,
    p_parent_geography_type               IN         VARCHAR2,
    x_return_status             	  OUT    NOCOPY    VARCHAR2,
    x_msg_count                 	  OUT    NOCOPY    NUMBER,
    x_msg_data                  	  OUT    NOCOPY    VARCHAR2
    )IS


 BEGIN

    -- Standard start of API savepoint
    SAVEPOINT delete_geo_structure;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- Initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Call to business logic.
      do_delete_geo_structure(
        p_geography_id               => p_geography_id,
        p_geography_type             => p_geography_type,
        p_parent_geography_type      => p_parent_geography_type,
        x_return_status                => x_return_status
        );

        --if validation failed at any point, then raise an exception to stop processing
   IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       RAISE FND_API.G_EXC_ERROR;
   END IF;

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data  => x_msg_data);

    EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO delete_geo_structure;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO delete_geo_structure;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

    WHEN OTHERS THEN
        ROLLBACK TO delete_geo_structure;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MSG_PUB.ADD;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count        => x_msg_count,
                                p_data        => x_msg_data);

END delete_geo_structure;

 /**
 * PROCEDURE create_zone_type
 *
 * DESCRIPTION
 *     Creates Zone Type.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_zone_type_rec               Zone_type type record.
 *   IN/OUT:
 *   OUT:
 *
 *     x_return_status                Return status after the call. The status can
 *                                    be FND_API.G_RET_STS_SUCCESS (success),
 *                                    FND_API.G_RET_STS_ERROR (error),
 *                                    FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
 *     x_msg_count                    Number of messages in message stack.
 *     x_msg_data                     Message text if x_msg_count is 1.
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *     01-09-2003    Rekha Nalluri        o Created.
 *
 */

PROCEDURE create_zone_type(
    p_init_msg_list             IN         VARCHAR2 := FND_API.G_FALSE,
    p_zone_type_rec             IN         ZONE_TYPE_REC_TYPE,
    x_return_status             OUT   NOCOPY     VARCHAR2,
    x_msg_count                 OUT   NOCOPY     NUMBER,
    x_msg_data                  OUT   NOCOPY     VARCHAR2
) IS

   p_index_name             VARCHAR2(30);

 BEGIN
 -- Standard start of API savepoint
    SAVEPOINT create_zone_type;
    --dbms_output.put_line('In the beginning of create_master_geography');

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- Initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

     --dbms_output.put_line('before call to do_create_zone_type');
    -- Call to business logic.
    do_create_zone_type(
        p_zone_type_rec                => p_zone_type_rec,
        x_return_status                => x_return_status
       );

   --if validation failed at any point, then raise an exception to stop processing
   IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       RAISE FND_API.G_EXC_ERROR;
   END IF;

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data  => x_msg_data);

   EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO create_zone_type;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO create_zone_type;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

     WHEN DUP_VAL_ON_INDEX THEN
        ROLLBACK TO create_zone_type;
        x_return_status := FND_API.G_RET_STS_ERROR;
        HZ_UTILITY_V2PUB.find_index_name(p_index_name);
        IF p_index_name = 'HZ_GEOGRAPHY_TYPES_B_U1' THEN
          FND_MESSAGE.SET_NAME('AR', 'HZ_API_DUPLICATE_COLUMN');
            FND_MESSAGE.SET_TOKEN('COLUMN', 'geography_type');
            FND_MSG_PUB.ADD;
          END IF;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count        => x_msg_count,
                                p_data        => x_msg_data);

    WHEN OTHERS THEN
        ROLLBACK TO create_zone_type;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
        FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
        FND_MSG_PUB.ADD;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count,
                                p_data    => x_msg_data);

END create_zone_type;

/**
 * PROCEDURE update_zone_type
 *
 * DESCRIPTION
 *     Updates zone type.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_geographytype                Geography type.
 *     p_limited_by_geography_id
 *     p_postal_code_range_flag
 *   IN/OUT:
 *     p_object_version_number        object version number of the row being updated
 *   OUT:
 *     x_return_status                Return status after the call. The status can
 *                                    be FND_API.G_RET_STS_SUCCESS (success),
 *                                    FND_API.G_RET_STS_ERROR (error),
 *                                    FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
 *     x_msg_count                    Number of messages in message stack.
 *     x_msg_data                     Message text if x_msg_count is 1.
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   01-13-2003    Rekha Nalluri        o Created.
 *
 */

PROCEDURE update_zone_type(
    p_init_msg_list             	  IN         VARCHAR2 := FND_API.G_FALSE,
    p_zone_type_rec                       IN         ZONE_TYPE_REC_TYPE,
    p_object_version_number    		  IN OUT NOCOPY  NUMBER,
    x_return_status             	  OUT  NOCOPY      VARCHAR2,
    x_msg_count                 	  OUT  NOCOPY     NUMBER,
    x_msg_data                  	  OUT  NOCOPY      VARCHAR2
 ) IS

BEGIN

    -- Standard start of API savepoint
    SAVEPOINT update_zone_type;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- Initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;
      -- Call to business logic.
      do_update_zone_type(
        p_zone_type_rec => p_zone_type_rec,
        p_object_version_number        => p_object_version_number,
        x_return_status                => x_return_status,
        x_msg_count => x_msg_count,
        x_msg_data => x_msg_data
        );

        --if validation failed at any point, then raise an exception to stop processing
   IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       RAISE FND_API.G_EXC_ERROR;
   END IF;

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data  => x_msg_data);

    EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO update_zone_type;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO update_zone_type;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

    WHEN OTHERS THEN
        ROLLBACK TO update_zone_type;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MSG_PUB.ADD;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count        => x_msg_count,
                                p_data        => x_msg_data);

END update_zone_type;

END HZ_GEOGRAPHY_STRUCTURE_PUB;

/
