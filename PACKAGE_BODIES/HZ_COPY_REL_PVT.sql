--------------------------------------------------------
--  DDL for Package Body HZ_COPY_REL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_COPY_REL_PVT" AS
/* $Header: ARHCPRLB.pls 120.19 2006/03/22 13:52:59 jgjoseph noship $ */

-- Bug 3615970: various fixes in convert_rel_type

TYPE t_indexed_number_tbl IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
TYPE t_indexed_varchar400_tbl IS TABLE OF VARCHAR2(400) INDEX BY BINARY_INTEGER;
TYPE t_varchar400_tbl IS TABLE OF VARCHAR2(400);
TYPE t_varchar4000_tbl IS TABLE OF VARCHAR2(4000);
TYPE t_number_tbl IS TABLE OF NUMBER;
TYPE t_date_tbl IS TABLE OF DATE;
TYPE t_varchar30_tbl IS TABLE OF VARCHAR2(30);
-- Bug 4288839
G_RET_CODE                         BOOLEAN := TRUE;

-- one relationship type can have relationships in different tables + object types.
-- we have to consider table_name + object_type in case of the same id has been
-- used in different combination of table_name + object_type

g_passed_nodes_tbl                t_indexed_varchar400_tbl;
g_failed_nodes_tbl                t_indexed_varchar400_tbl;
g_indexed_parent_nodes_tbl        t_indexed_varchar400_tbl;
g_parent_nodes_tbl                t_varchar400_tbl := t_varchar400_tbl();
g_relationship_id_tbl             t_number_tbl := t_number_tbl();
g_message_fmt1                    t_varchar4000_tbl := t_varchar4000_tbl();
g_message_fmt2                    t_varchar4000_tbl := t_varchar4000_tbl();

--------------------------------------------
-- AUTHOR : COLATHUR VIJAYAN ("VJN")
--------------------------------------------

--------------------------------------------
-- a procedure to log messages
--------------------------------------------
PROCEDURE log(
   message      IN      VARCHAR2,
   newline      IN      BOOLEAN DEFAULT TRUE) IS
BEGIN
  IF message = 'NEWLINE' THEN
   FND_FILE.NEW_LINE(FND_FILE.LOG, 1);
  ELSIF (newline) THEN
    FND_FILE.put_line(fnd_file.log,message);
  ELSE
    FND_FILE.put_line(fnd_file.log,message);
  END IF;
END log;

-----------------------------------------------------------------------
-- Function to fetch messages of the stack and log the error
-----------------------------------------------------------------------
PROCEDURE logerror(SQLERRM VARCHAR2 DEFAULT NULL)
IS
  l_msg_data VARCHAR2(2000);
BEGIN
  FND_MSG_PUB.Reset;
  log('---------------------------');
  FOR I IN 1..FND_MSG_PUB.Count_Msg LOOP
    l_msg_data := l_msg_data || FND_MSG_PUB.Get(p_encoded => FND_API.G_FALSE );
  END LOOP;
  IF (SQLERRM IS NOT NULL) THEN
    l_msg_data := l_msg_data || SQLERRM;
  END IF;
  log(l_msg_data);
END logerror;



--------------------------------------------
-- get_meaning
--------------------------------------------

FUNCTION get_meaning
(p_lookup_code  VARCHAR2 )
RETURN VARCHAR2
IS
CURSOR c0
IS
    SELECT meaning
    FROM ar_lookups
    WHERE lookup_code = p_lookup_code
    and lookup_type = 'HZ_RELATIONSHIP_ROLE'
    and rownum = 1  ;
meaning VARCHAR2(200);
BEGIN
   for cursor_rec in c0
   loop
    EXIT WHEN c0%NOTFOUND;
    meaning := cursor_rec.meaning ;
   end loop;
 RETURN meaning;
END get_meaning ;

--------------------------------------------
-- get_description
--------------------------------------------

FUNCTION get_description
(p_lookup_code  VARCHAR2 )
RETURN VARCHAR2
IS
CURSOR c0
IS
    SELECT description
    FROM ar_lookups
    WHERE lookup_code = p_lookup_code
    and lookup_type = 'HZ_RELATIONSHIP_ROLE'
    and rownum = 1  ;
description VARCHAR2(200);
BEGIN
   for cursor_rec in c0
   loop
    EXIT WHEN c0%NOTFOUND;
    description := cursor_rec.description ;
   end loop;
 RETURN description;
END get_description ;


--------------------------------------------
-- create_lookup
-- Bug 3620141. Added parameter x_return_status.
--              Handled the scenario where user was passing the same meaning as that of an existing record.
--------------------------------------------

PROCEDURE create_lookup
(p_lookup_code  VARCHAR2, p_lookup_meaning VARCHAR2, p_lookup_description VARCHAR2 , x_return_status IN OUT NOCOPY VARCHAR2)
IS
x_rowid varchar2(64);
l_count NUMBER := 0;
begin

    /* Bug 3620141*/
    SELECT COUNT(*)
    INTO   l_count
    FROM   FND_LOOKUP_VALUES
    WHERE  lookup_type = 'HZ_RELATIONSHIP_ROLE'
       AND (meaning = p_lookup_meaning
            OR description = p_lookup_description);
    IF l_count <> 0
    THEN
                       FND_MESSAGE.SET_NAME('AR', 'HZ_REL_TYPE_ROLE_MEANING_ERR');
                       FND_MSG_PUB.ADD;
                       x_return_status := fnd_api.g_ret_sts_error;
   ELSE
   BEGIN
    FND_LOOKUP_VALUES_PKG.INSERT_ROW(
                          X_ROWID               => x_rowid,
                          X_LOOKUP_TYPE         => 'HZ_RELATIONSHIP_ROLE',
                          X_SECURITY_GROUP_ID   => 0,
                          X_VIEW_APPLICATION_ID => 222,
                          X_LOOKUP_CODE         => p_lookup_code,
                          X_TAG                 => null,
                          X_ATTRIBUTE_CATEGORY  => null,
                          X_ATTRIBUTE1          => null,
                          X_ATTRIBUTE2          => null,
                          X_ATTRIBUTE3          => null,
                          X_ATTRIBUTE4          => null,
                          X_ENABLED_FLAG        => 'Y',
                          X_START_DATE_ACTIVE   => null,
                          X_END_DATE_ACTIVE     => null,
                          X_TERRITORY_CODE      => null,
                          X_ATTRIBUTE5          => null,
                          X_ATTRIBUTE6          => null,
                          X_ATTRIBUTE7          => null,
                          X_ATTRIBUTE8          => null,
                          X_ATTRIBUTE9          => null,
                          X_ATTRIBUTE10         => null,
                          X_ATTRIBUTE11         => null,
                          X_ATTRIBUTE12         => null,
                          X_ATTRIBUTE13         => null,
                          X_ATTRIBUTE14         => null,
                          X_ATTRIBUTE15         => null,
                          X_MEANING             => p_lookup_meaning,
                          X_DESCRIPTION         => p_lookup_description,
                          X_CREATION_DATE       => HZ_UTILITY_V2PUB.CREATION_DATE,
                          X_CREATED_BY          => HZ_UTILITY_V2PUB.CREATED_BY,
                          X_LAST_UPDATE_DATE    => HZ_UTILITY_V2PUB.LAST_UPDATE_DATE,
                          X_LAST_UPDATED_BY     => HZ_UTILITY_V2PUB.LAST_UPDATED_BY,
                          X_LAST_UPDATE_LOGIN   => HZ_UTILITY_V2PUB.LAST_UPDATE_LOGIN
                          );
         EXCEPTION
         WHEN OTHERS THEN
                   FND_MESSAGE.SET_NAME('AR', 'HZ_COPY_REL_API_ERROR');
                   FND_MESSAGE.SET_TOKEN('PROC' ,'CREATE_LOOKUP');
                   FND_MESSAGE.SET_TOKEN('ERROR' , SQLERRM);
                   FND_MSG_PUB.ADD;
                   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END;
     END IF;

end;

/**
 * PRIVATE FUNCTION get_party_name
 *
 * DESCRIPTION
 *     added for bug fix 3615970
 *     return party name by given the party id.
 *
 * MODIFICATION HISTORY
 *
 *   05-30-2004    Jianying Huang   o Created.
 *
 */

FUNCTION get_party_name (
    p_party_id                    IN     NUMBER
) RETURN VARCHAR2 IS

    CURSOR c_party IS
      SELECT party_name
      FROM   hz_parties
      WHERE  party_id = p_party_id;

    l_party_name                  VARCHAR2(400);

BEGIN

    OPEN c_party;
    FETCH c_party INTO l_party_name;
    IF c_party%NOTFOUND THEN
      l_party_name := 'Party Not Found';
    END IF;
    CLOSE c_party;

    RETURN l_party_name;

END get_party_name;

/**
 * PRIVATE PROCEDURE do_circularity_check
 *
 * DESCRIPTION
 *     added for bug fix 3615970
 *     do circularity check recursively.
 *
 * MODIFICATION HISTORY
 *
 *   05-30-2004    Jianying Huang   o Created.
 *
 */

PROCEDURE do_circularity_check (
    p_child_id                    IN     NUMBER,
    p_child_table_name            IN     VARCHAR2,
    p_child_type                  IN     VARCHAR2,
    p_rel_type                    IN     VARCHAR2,
    p_start_date                  IN     DATE,
    p_end_date                    IN     DATE,
    x_return_status               OUT    NOCOPY VARCHAR2
) IS

    -- this cursor retrieves parents for a given child in a
    -- particular hierarchy.

    CURSOR c_parents IS
    SELECT r.relationship_id,
           r.subject_id,
           r.subject_table_name,
           r.subject_type,
           r.start_date,
           r.end_date
    FROM   hz_relationships r,
           hz_relationship_types t
    WHERE  r.object_id = p_child_id
    AND    r.object_table_name = p_child_table_name
    AND    r.object_type = p_child_type
    AND    r.relationship_type = p_rel_type
    AND    r.relationship_type = t.relationship_type
    AND    r.relationship_code = t.forward_rel_code
    AND    r.subject_type = t.subject_type
    AND    r.object_type = t.object_type
    AND    t.direction_code = 'P'
    AND    (r.start_date BETWEEN NVL(p_start_date, SYSDATE)
            AND NVL(p_end_date, TO_DATE('31-12-4712 00:00:01', 'DD-MM-YYYY HH24:MI:SS'))
           OR
           r.end_date BETWEEN NVL(p_start_date, SYSDATE)
           AND NVL(p_end_date, TO_DATE('31-12-4712 00:00:01', 'DD-MM-YYYY HH24:MI:SS'))
           OR
           NVL(p_start_date, SYSDATE) BETWEEN r.start_date AND r.end_date
           OR
           NVL(p_end_date, TO_DATE('31-12-4712 00:00:01', 'DD-MM-YYYY HH24:MI:SS')) BETWEEN r.start_date AND r.end_date
           );

    i_relationship_id             t_number_tbl;
    i_parent_id                   t_number_tbl;
    i_parent_table_name           t_varchar30_tbl;
    i_parent_type                 t_varchar30_tbl;
    i_start_date                  t_date_tbl;
    i_end_date                    t_date_tbl;

    l_str                         VARCHAR2(400);
    l_str1                        VARCHAR2(400);
    l_id                          NUMBER;
    l_party_name                  VARCHAR2(400);
    l_table_name                  VARCHAR2(30);

BEGIN

    x_return_status := 'S';

    l_str := p_child_id||'#'||p_child_table_name||'#'||p_child_type;

    log('l_str = '||l_str);

    -- record the parent path
    --
    g_parent_nodes_tbl.extend(1);
    g_parent_nodes_tbl(g_parent_nodes_tbl.LAST) := l_str;

    IF (NOT g_indexed_parent_nodes_tbl.EXISTS(p_child_id)) OR
       (g_indexed_parent_nodes_tbl.EXISTS(p_child_id) AND
        INSTRB(g_indexed_parent_nodes_tbl(p_child_id), l_str) = 0)
    THEN
      IF g_indexed_parent_nodes_tbl.EXISTS(p_child_id) THEN
        l_str1 := g_indexed_parent_nodes_tbl(p_child_id)||',';
      ELSE
        l_str1 := '';
      END IF;
      g_indexed_parent_nodes_tbl(p_child_id) := l_str1||'-1#'||l_str;
    END IF;

    -- retrieve all of the parents
    --
    OPEN c_parents;
    FETCH c_parents BULK COLLECT INTO
      i_relationship_id,
      i_parent_id,
      i_parent_table_name,
      i_parent_type,
      i_start_date,
      i_end_date;
    CLOSE c_parents;

    IF i_relationship_id.COUNT = 0 THEN
      log('top parent ... ');
      RETURN;
    END IF;

    -- loop for every parent
    --
    FOR i IN 1..i_relationship_id.COUNT LOOP

      g_relationship_id_tbl.extend(1);
      g_relationship_id_tbl(g_relationship_id_tbl.LAST) := i_relationship_id(i);

      l_str1 := i_parent_id(i)||'#'||i_parent_table_name(i)||'#'||i_parent_type(i);

      log('i_relationship_id('||i||') = '||i_relationship_id(i));
      log(l_str1);

      IF (g_passed_nodes_tbl.EXISTS(p_child_id) AND
             INSTRB(g_passed_nodes_tbl(p_child_id), l_str) > 0) OR
            (g_passed_nodes_tbl.EXISTS(i_parent_id(i)) AND
             INSTRB(g_passed_nodes_tbl(i_parent_id(i)), l_str1) > 0)
      THEN
        log('case 1: in passed node table ...');

        x_return_status := 'S';

      ELSIF (g_failed_nodes_tbl.EXISTS(p_child_id) AND
             INSTRB(g_failed_nodes_tbl(p_child_id), l_str) > 0) OR
            (g_failed_nodes_tbl.EXISTS(i_parent_id(i)) AND
             INSTRB(g_failed_nodes_tbl(i_parent_id(i)), l_str1) > 0)
      THEN
        log('case 2: in failed node table ...');

        x_return_status := 'E';

      ELSIF l_str = l_str1 THEN
        log('case 3: self-related ...');

        x_return_status := 'E';

        -- prepare for message format 1
        --
        IF p_child_table_name = 'HZ_PARTIES' THEN
          l_party_name := get_party_name(p_child_id);
        ELSE
          l_party_name := p_child_table_name||':'||p_child_id;
        END IF;

        g_message_fmt1.extend(1);
        g_message_fmt1(g_message_fmt1.LAST) := l_party_name||' <- '||l_party_name;

        -- prepare for message format 2
        --
        g_message_fmt2.extend(1);
        g_message_fmt2(g_message_fmt2.LAST) :=
          i_parent_table_name(i)||':'||i_parent_id(i)||' <- '||
          i_relationship_id(i)||' <- '||
          p_child_table_name||':'||p_child_id;

      ELSIF (g_indexed_parent_nodes_tbl.EXISTS(i_parent_id(i)) AND
             INSTRB(g_indexed_parent_nodes_tbl(i_parent_id(i)), '-1#'||l_str1) > 0)
      THEN
        log('case 4: in parent table ...');

        x_return_status := 'E';

        -- prepare for message format 1
        --
        IF i_parent_table_name(i) = 'HZ_PARTIES' THEN
          l_party_name := get_party_name(i_parent_id(i));
        ELSE
          l_party_name := i_parent_table_name(i)||':'||i_parent_id(i);
        END IF;

        g_message_fmt1.extend(1);
        g_message_fmt1(g_message_fmt1.LAST) := l_party_name||' <- ';

        -- prepare for message format 2
        --
        g_message_fmt2.extend(1);
        g_message_fmt2(g_message_fmt2.LAST) :=
          i_parent_table_name(i)||':'||i_parent_id(i)||' <- '||
          i_relationship_id(i)||' <- ';

        FOR j IN REVERSE 1..g_parent_nodes_tbl.COUNT LOOP
          l_id := SUBSTRB(g_parent_nodes_tbl(j), 1, INSTRB(g_parent_nodes_tbl(j), '#')-1);
          l_table_name := SUBSTRB(g_parent_nodes_tbl(j),
                                  LENGTHB(l_id)+2,
                                  INSTRB(g_parent_nodes_tbl(j), '#', LENGTH(l_id)+2)-LENGTHB(l_id)-2);

          IF INSTRB(g_indexed_parent_nodes_tbl(l_id), '-1#'||g_parent_nodes_tbl(j)) > 0 THEN
            IF l_table_name = 'HZ_PARTIES' THEN
              l_party_name := get_party_name(l_id);
            ELSE
              l_party_name := l_table_name||':'||l_id;
            END IF;

            g_message_fmt1(g_message_fmt1.LAST) :=
              g_message_fmt1(g_message_fmt1.LAST)||l_party_name||fnd_global.NEWLINE;

            g_message_fmt2(g_message_fmt2.LAST) :=
              g_message_fmt2(g_message_fmt2.LAST)||l_table_name||':'||l_id||fnd_global.NEWLINE;
          END IF;

          IF l_str1 = g_parent_nodes_tbl(j) THEN
            EXIT;
          ELSIF INSTRB(g_indexed_parent_nodes_tbl(l_id), '-1#'||g_parent_nodes_tbl(j)) > 0 THEN
            g_message_fmt1(g_message_fmt1.LAST) :=
              g_message_fmt1(g_message_fmt1.LAST)||l_party_name||' <- ';

            g_message_fmt2(g_message_fmt2.LAST) :=
              g_message_fmt2(g_message_fmt2.LAST)||l_table_name||':'||l_id||' <- '||g_relationship_id_tbl(j-1)||' <- ';
          END IF;
        END LOOP;
      ELSE
        log('case 5: do_child_circularity ...');

        do_circularity_check (
          i_parent_id(i),
          i_parent_table_name(i),
          i_parent_type(i),
          p_rel_type,
          i_start_date(i),
          i_end_date(i),
          x_return_status
        );
      END IF;

      log('x_return_status = '||x_return_status);

      IF x_return_status <> 'S' THEN
        RETURN;
      ELSE
        IF g_indexed_parent_nodes_tbl.EXISTS(i_parent_id(i)) THEN
          g_indexed_parent_nodes_tbl(i_parent_id(i)) :=
            REPLACE(g_indexed_parent_nodes_tbl(i_parent_id(i)),'-1#'||l_str1, '1#'||l_str1);
        END IF;
      END IF;
    END LOOP;

END do_circularity_check;

------------------------------
-- copy_relationships
-----------------------------

PROCEDURE copy_relationships
-- copy all the relationships from source rel type to des rel type, by calling the create relationship API.
(p_source_rel_type VARCHAR2, p_dest_rel_type VARCHAR2, p_rel_valid_date DATE,
 x_return_status out NOCOPY VARCHAR2, x_msg_count out number, x_msg_data out VARCHAR2)
IS
 /***** FOR CREATING RELATIONSHIPS  **********/
    p_relationship_rec HZ_RELATIONSHIP_V2PUB.RELATIONSHIP_REC_TYPE;
    x_relationship_id NUMBER;
    x_party_id NUMBER;
    x_party_number VARCHAR2(2000);
 cursor c0
 IS
 -- BASICALLY, GET ALL RELATIONSHIPS THAT ARE VALID ON P_VALID_DATE
 -- IE., WHOSE END DATE IS EITHER NULL OR LATER THAN P_VALID_DATE
 -- AND MORE IMPORTANTLY, THE START DATE CANNOT BE LATER THAN P_VALID_DATE

 -- Bug 3651949: take care of copy in the same day as relationships created
 --
 select relationship_id
  FROM   hz_relationships r,
 	   hz_relationship_types t
  where r.relationship_type = p_source_rel_type
    AND    r.relationship_type = t.relationship_type
    AND    t.relationship_type = p_source_rel_type
    AND    r.relationship_code = t.forward_rel_code
    AND    r.subject_type = t.subject_type
    AND    r.object_type = t.object_type
    AND (r.end_date is null or trunc(r.end_date) >= p_rel_valid_date)
    AND trunc(r.start_date) <= p_rel_valid_date
    AND directional_flag='F'
 ;

 l_message_text VARCHAR2(1000);
BEGIN

          -- Bug 3651949: let system generate party number. this is to
          -- avoid api error.
          FND_PROFILE.PUT('HZ_GENERATE_PARTY_NUMBER', 'Y');

          -- initialize return status
          x_return_status := FND_API.G_RET_STS_SUCCESS;


          FOR id_cur in c0
          LOOP
                   -- GET RELATIONSHIP RECORD
                   hz_relationship_v2pub.get_relationship_rec(
                                                    FND_API.G_FALSE,
                                                    id_cur.relationship_id,
                                                    'F',
                                                    p_relationship_rec,
                                                    x_return_status,
                                                    x_msg_count,
                                                    x_msg_data
                     );

                    -- BEFORE CREATING THE IDENTICAL RELATIONSHIP MAKE SURE THAT THE APPROPRIATE
                    -- ATTRIBUTES ARE SET PROPERLY
                    p_relationship_rec.relationship_type := p_dest_rel_type;
                    p_relationship_rec.relationship_id := NULL;
                    p_relationship_rec.party_rec.party_id := NULL;
                    p_relationship_rec.party_rec.party_number := NULL;
                    p_relationship_rec.created_by_module := 'HZ_COPY_SCRIPT_CREATED';

                    -- CALL RELATIONSHIP API
                    hz_relationship_v2pub.create_relationship('T',p_relationship_rec,x_relationship_id,x_party_id,x_party_number,x_return_status,x_msg_count,x_msg_data,'');


                    -- RAISE HELL WHEN return status is not success

		    -- Bug 4288839.
		    -- Donot raise error when create relationship fails.
		    -- Instead log the errors in the log file and continue processing.
                    IF x_return_status <> FND_API.G_RET_STS_SUCCESS

                    THEN
			 log('NEWLINE');
			 log('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');

                         logerror;

                         log('NEWLINE');

                         log('Error while trying to copy the following source relationship:');
			 log('Source relationship type relationship_id -- '|| id_cur.relationship_id);
	                 log('subject id -- ' || p_relationship_rec.subject_id );
                         log('object id -- ' || p_relationship_rec.object_id );

                         log('NEWLINE');

                         FND_MESSAGE.SET_NAME('AR', 'HZ_COPY_REL_API_ERROR');
                         FND_MESSAGE.SET_TOKEN('PROC' ,'HZ_RELATIONSHIP_V2PUB.CREATE_RELATIONSHIP');
                         FND_MESSAGE.SET_TOKEN('ERROR' , SQLERRM);
                         --FND_MSG_PUB.ADD;
			 l_message_text := FND_MESSAGE.GET;
			 log(l_message_text);

			 log('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
                         log('NEWLINE');

			 G_RET_CODE := FALSE;
                      --   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

                    END IF;


          END LOOP;

          EXCEPTION
                  WHEN OTHERS
                  THEN
                    FND_MESSAGE.SET_NAME('AR', 'HZ_COPY_REL_API_ERROR');
                    FND_MESSAGE.SET_TOKEN('PROC' ,'COPY_RELATIONSHIPS');
                    FND_MESSAGE.SET_TOKEN('ERROR' , SQLERRM);
                    FND_MSG_PUB.ADD;
                    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END copy_relationships ;


--------------------------------------------------------------------------------------
-- copy_selected_phrase pairs ::: This will take 2 existing relationship types A,B
--                   and copy specific phrase pairs from A to B.
--                   HOWEVER, THIS PROCEDURE WILL NOT COPY RELATIONSHIPS UNDER A TO B.
--------------------------------------------------------------------------------------

PROCEDURE copy_selected_phrase_pair(p_source_rel_type VARCHAR2 , p_dest_rel_type VARCHAR2,
                          p_dest_rel_type_role_prefix VARCHAR2, p_dest_rel_type_role_suffix VARCHAR2,
                          p_forward_rel_code VARCHAR2, p_backward_rel_code VARCHAR2,
                          p_subject_type VARCHAR2, p_object_type VARCHAR2,
                          x_return_status OUT NOCOPY VARCHAR2, x_msg_count OUT NUMBER, x_msg_data OUT VARCHAR2)
IS
     p_relationship_type_rec HZ_RELATIONSHIP_TYPE_V2PUB.RELATIONSHIP_TYPE_REC_TYPE;
     x_relationship_type_id NUMBER;
     temp1 varchar2(200);
     temp2 varchar2(200);
     forward_role varchar2(200);
     backward_role varchar2(200);
     temp number;

     CREATE_LOOKUP_EXCEPTION EXCEPTION;
    -- THE CURSOR HERE SHOULD FETCH ONLY THE ROWS WHOSE DIRECTION CODE IS EITHER 'P' OR 'N'
    -- AFTER THE SELF JOIN AND CALL THE RELATIONSHIP TYPE API ONLY FOR THOSE ROWS.

    CURSOR c_get_rel_type_record
    IS
    select hrt1.relationship_type as relationship_type,
           hrt1.direction_code as direction_code,
           hrt1.role as forward_role,
           hrt2.role as backward_role,
           hrt1.forward_rel_code as forward_rel_code,
           hrt1.backward_rel_code as backward_rel_code,
           hrt1.hierarchical_flag as hierarchical_flag,
           hrt1.create_party_flag as create_party_flag,
           hrt1.allow_relate_to_self_flag as allow_relate_to_self_flag,
           hrt1.allow_circular_relationships as allow_circular_relationships,
           hrt1.subject_type as subject_type,
           hrt1.object_type as object_type,
           hrt1.status as status,
           hrt1.created_by_module as created_by_module,
           hrt1.application_id as application_id,
           hrt1.multiple_parent_allowed as multiple_parent_allowed,
           hrt1.incl_unrelated_entities as incl_unrelated_entities
    from hz_relationship_types hrt1, hz_relationship_types hrt2
    where hrt1.relationship_type = hrt2.relationship_type
    and hrt1.subject_type = hrt2.object_type
    and hrt1.object_type = hrt2.subject_type
    and hrt1.forward_rel_code = hrt2.backward_rel_code
    and hrt1.backward_rel_code = hrt2.forward_rel_code
    and (hrt1.direction_code = 'P' or hrt1.direction_code = 'N')
    -- Constraints based on what is passed in to this function
    and hrt1.relationship_type = p_source_rel_type
    and hrt1.forward_rel_code = p_forward_rel_code
    and hrt1.backward_rel_code = p_backward_rel_code
    and hrt1.subject_type = p_subject_type
    and hrt1.object_type = p_object_type ;


BEGIN
                -- INITIALIZE RETURN STATUS
                x_return_status := FND_API.G_RET_STS_SUCCESS;


                -- initialize the temporary variable
                temp := -1;


                -- LOOP THROUGH THE CURSOR
                FOR rel_type_record IN c_get_rel_type_record
                LOOP

                        -- CREATE TWO LOOKUPS OR ONE LOOKUP, DEPENDING ON THE DIRECTION CODE.
                        -- THE ROLES WILL BE SYSTEM GENERATED IN ANY CASE.
                        -- WHEN DIRECTION IS NOT 'P', ONLY ONE ROLE NEEDS TO BE GENERATED.
                        IF rel_type_record.direction_code = 'P'
                        THEN
                            temp1 := p_dest_rel_type_role_prefix || get_meaning(rel_type_record.forward_role)
                                     || p_dest_rel_type_role_suffix ;
                            temp2 := p_dest_rel_type_role_prefix || get_description(rel_type_record.forward_role)
                                     || p_dest_rel_type_role_suffix  ;

                            -- if first time in the loop, temp is current time
                            -- else it is incremented by 1
                            IF temp = -1
                            THEN
                                temp := dbms_utility.get_time;
                            ELSE
                                temp := temp + 1;
                            END IF;

                            forward_role := 'USER_ROLE'|| to_char(temp) ;

                            -- dbms_output.put_line('forward role is' || forward_role);
                            -- dbms_output.put_line('meaning is' || temp1);
                            -- dbms_output.put_line('description is' || temp2);
                            log('-------------------------------------------');
                            log('forward role code is ' || forward_role);
                            log('meaning is ' || temp1);
                            log('description is ' || temp2);
                            create_lookup(forward_role, temp1, temp2,x_return_status);
                            /* Bug 3620141 */
                            if (x_return_status <> FND_API.G_RET_STS_SUCCESS )
                            THEN
                                RAISE CREATE_LOOKUP_EXCEPTION;
                            END IF;
                            temp1 := p_dest_rel_type_role_prefix || get_meaning(rel_type_record.backward_role)
                                     || p_dest_rel_type_role_suffix ;
                            temp2 := p_dest_rel_type_role_prefix || get_description(rel_type_record.backward_role)
                                     || p_dest_rel_type_role_suffix  ;

                            -- always increment by 1
                            temp := temp + 1;
                            backward_role := 'USER_ROLE'|| to_char(temp) ;

                            -- dbms_output.put_line('backward role is' || backward_role);
                            -- dbms_output.put_line('meaning is' || temp1);
                            -- dbms_output.put_line('description is' || temp2);
                            log('-------------------------------------------');
                            log('backward role code is ' || backward_role);
                            log('meaning is ' || temp1);
                            log('description is ' || temp2);
                            create_lookup(backward_role, temp1, temp2,x_return_status);
                            /* Bug 3620141 */
                            if (x_return_status <> FND_API.G_RET_STS_SUCCESS )
                            THEN
                                RAISE CREATE_LOOKUP_EXCEPTION;
                            END IF;

                        ELSE
                            temp1 := p_dest_rel_type_role_prefix || get_meaning(rel_type_record.forward_role)
                                     || p_dest_rel_type_role_suffix ;
                            temp2 := p_dest_rel_type_role_prefix || get_description(rel_type_record.forward_role)
                                     || p_dest_rel_type_role_suffix  ;

                            -- if first time in the loop, temp is current time
                            -- else it is incremented by 1
                            IF temp = -1
                            THEN
                                temp := dbms_utility.get_time;
                            ELSE
                                temp := temp + 1;
                            END IF;

                            log('-------------------------------------------');
                            log('forward role code = backward role code = ' || forward_role);
                            log('meaning is ' || temp1);
                            log('description is ' || temp2);
                            create_lookup(forward_role, temp1, temp2,x_return_status);
                            /* Bug 3620141 */
                            if (x_return_status <> FND_API.G_RET_STS_SUCCESS)
                            THEN
                                RAISE CREATE_LOOKUP_EXCEPTION;
                            END IF;
                            backward_role := forward_role;

                        END IF;


                        -- CREATE THE NEW RELATIONSHIP TYPE WITH THE CORRESPONDING ROLE - PHRASE PAIR
                        p_relationship_type_rec.relationship_type_id := NULL;
                        p_relationship_type_rec.relationship_type := p_dest_rel_type ;
                        p_relationship_type_rec.forward_rel_code := rel_type_record.forward_rel_code ;
                        p_relationship_type_rec.backward_rel_code := rel_type_record.backward_rel_code;
                        p_relationship_type_rec.direction_code := rel_type_record.direction_code;
                        p_relationship_type_rec.hierarchical_flag :=  rel_type_record.hierarchical_flag ;
                        p_relationship_type_rec.create_party_flag := rel_type_record.create_party_flag;
                        p_relationship_type_rec.allow_relate_to_self_flag := rel_type_record.allow_relate_to_self_flag ;
                        p_relationship_type_rec.allow_circular_relationships := rel_type_record.allow_circular_relationships ;
                        p_relationship_type_rec.subject_type := rel_type_record.subject_type ;
                        p_relationship_type_rec.object_type :=  rel_type_record.object_type;
                        p_relationship_type_rec.status := rel_type_record.status ;
                        p_relationship_type_rec.created_by_module := 'HZ_COPY_SCRIPT_CREATED' ;
                        p_relationship_type_rec.application_id := NULL;
                        p_relationship_type_rec.multiple_parent_allowed := rel_type_record.multiple_parent_allowed ;
                        p_relationship_type_rec.incl_unrelated_entities := rel_type_record.incl_unrelated_entities ;
                        p_relationship_type_rec.forward_role := forward_role ;
                        p_relationship_type_rec.backward_role := backward_role;

                        hz_relationship_type_v2pub.create_relationship_type('T',p_relationship_type_rec,
                                                                             x_relationship_type_id,x_return_status,
                                                                             x_msg_count,x_msg_data);

                         -- RAISE HELL WHEN return status is not success
                        IF x_return_status <> FND_API.G_RET_STS_SUCCESS
                        THEN
                                 FND_MESSAGE.SET_NAME('AR', 'HZ_COPY_REL_API_ERROR');
                                 FND_MESSAGE.SET_TOKEN('PROC' ,'HZ_RELATIONSHIP_TYPE_V2PUB.CREATE_RELATIONSHIP_TYPE');
                                 FND_MESSAGE.SET_TOKEN('ERROR' , SQLERRM);
                                 FND_MSG_PUB.ADD;
                                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                        END IF;

                END LOOP;





                EXCEPTION
                         WHEN CREATE_LOOKUP_EXCEPTION THEN
                              FND_MSG_PUB.COUNT_AND_GET(
                                  p_encoded => FND_API.G_FALSE,
                                  p_count   => x_msg_count,
                                  p_data    => x_msg_data
                                     );
                         WHEN OTHERS THEN
                               FND_MESSAGE.SET_NAME('AR', 'HZ_COPY_REL_API_ERROR');
                               FND_MESSAGE.SET_TOKEN('PROC' ,'COPY_SELECTED_PHRASE_PAIR');
                               FND_MESSAGE.SET_TOKEN('ERROR' , SQLERRM);
                               FND_MSG_PUB.ADD;
                              FND_MSG_PUB.COUNT_AND_GET(
                                  p_encoded => FND_API.G_FALSE,
                                  p_count   => x_msg_count,
                                  p_data    => x_msg_data
                                     );
                               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END ;

-------------------------------------------------------------------------------------
-- create_hierarchy ::: The recursive procedure, that will take the passed in party_id
--                       find its immediate child and create the appropriate relationship
--                       in dest_rel_type.
----------------------------------------------------------------------------------------

PROCEDURE create_hierarchy(p_party_id NUMBER, p_source_rel_type VARCHAR2, p_dest_rel_type VARCHAR2,
                          p_dest_rel_type_role_prefix VARCHAR2, p_dest_rel_type_role_suffix VARCHAR2,
                          p_rel_valid_date DATE, x_return_status OUT NOCOPY VARCHAR2, x_msg_count OUT NUMBER,
                          x_msg_data OUT NOCOPY VARCHAR2)
IS
/***** FOR CREATING RELATIONSHIPS  **********/
    p_relationship_rec HZ_RELATIONSHIP_V2PUB.RELATIONSHIP_REC_TYPE;
    p_child NUMBER;
    x_relationship_id NUMBER;
    x_party_id NUMBER;
    x_party_number VARCHAR2(2000);

-- this cursor will get the relationship id for the relationship
-- in which the passed in party id is the parent
cursor c0
IS
select relationship_id
from hz_relationships
where subject_id = p_party_id
and relationship_type = p_source_rel_type
and direction_code = 'P'
and (end_date is null or end_date > p_rel_valid_date )
and start_date < p_rel_valid_date ;
BEGIN
    -- INITIALIZE RETURN STATUS
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    FOR id_rec in c0
    LOOP
                 -- GET RELATIONSHIP RECORD
                   hz_relationship_v2pub.get_relationship_rec(
                                                    FND_API.G_FALSE,
                                                    id_rec.relationship_id,
                                                    'F',
                                                    p_relationship_rec,
                                                    x_return_status,
                                                    x_msg_count,
                                                    x_msg_data
                     );

                    -- BEFORE CREATING THE IDENTICAL RELATIONSHIP MAKE SURE THAT THE APPROPRIATE
                    -- ATTRIBUTES ARE SET PROPERLY
                    p_relationship_rec.relationship_type := p_dest_rel_type;
                    p_relationship_rec.relationship_id := NULL;
                    p_relationship_rec.party_rec.party_id := NULL;
                    p_relationship_rec.party_rec.party_number := NULL;
                    p_relationship_rec.created_by_module := 'HZ_COPY_SCRIPT_CREATED';

                    log('-----------------------------------------------------------');
                    log('In create hierarchy: Parent = ' || p_relationship_rec.subject_id ||
                                              ' Child = ' || p_relationship_rec.object_id);
                    log('Relationship Id = ' || p_relationship_rec.relationship_id );
                    log('Relationship = ' || p_relationship_rec.relationship_code );
                    log('About to create relationship');
                    -- CALL RELATIONSHIP API
                    hz_relationship_v2pub.create_relationship('T',p_relationship_rec,x_relationship_id,
                                                  x_party_id,x_party_number,x_return_status,x_msg_count,x_msg_data,'');


                    IF x_return_status = FND_API.G_RET_STS_SUCCESS
                    THEN
                        -- this is the tricky bit, the child could be either the subject or the object.
                        -- in any case, the child should be the id in the record, which is not the parent.
                        IF p_relationship_rec.object_id = p_party_id
                        THEN
                            p_child := p_relationship_rec.subject_id ;
                        ELSE
                            p_child := p_relationship_rec.object_id ;

                        END IF;


                        -- RECURSION ::: PASS IT ON TO THE CHILD
                        create_hierarchy(p_child, p_source_rel_type, p_dest_rel_type,
                            p_dest_rel_type_role_prefix, p_dest_rel_type_role_suffix, p_rel_valid_date,
                            x_return_status, x_msg_count, x_msg_data);

                    -- RAISE HELL WHEN return status is not success
		    -- Bug 4288839. Donot raise hell. Log all errors and continue processing forward.

		    ELSE
		        DECLARE
			    l_message_text VARCHAR2(400);
			BEGIN
             		    log('NEWLINE');
			    log('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');

                            logerror;

                            log('NEWLINE');

                            log('Error while trying to copy the following source relationship:');
			    log('Source relationship type relationship_id -- '|| id_rec.relationship_id);
	                    log('subject id -- ' || p_relationship_rec.subject_id );
                            log('object id -- ' || p_relationship_rec.object_id );

                            log('NEWLINE');

                             FND_MESSAGE.SET_NAME('AR', 'HZ_COPY_REL_API_ERROR');
                             FND_MESSAGE.SET_TOKEN('PROC' ,'HZ_RELATIONSHIP_V2PUB.CREATE_RELATIONSHIP');
                             FND_MESSAGE.SET_TOKEN('ERROR' , SQLERRM);
                             -- FND_MSG_PUB.ADD;
                             --RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
			     l_message_text := FND_MESSAGE.GET;
			     log(l_message_text);

			    log('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
            		    log('NEWLINE');

			    G_RET_CODE := FALSE;

                        END;

                    END IF;



    END LOOP;


    EXCEPTION
             WHEN OTHERS THEN
                       FND_MESSAGE.SET_NAME('AR', 'HZ_COPY_REL_API_ERROR');
                       FND_MESSAGE.SET_TOKEN('PROC' ,'CREATE_HIERARCHY');
                       FND_MESSAGE.SET_TOKEN('ERROR' , SQLERRM);
                       FND_MSG_PUB.ADD;
                       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END create_hierarchy;


--------------------------------------------------------------------------------------
-- copy_rel_type_only ::: This will take a relationship type A and create a relationship
--                   type B, which is a copy of A in the following sense:
--                   B will be identical to A in terms of all the properties( phrase pairs,hierarchical type,
--                   circular flag etc., as seen in HZ_RELATIONSHIP_TYPES), that are
--                   associated with any relationship type.
--
--                   HOWEVER, THIS PROCEDURE WILL NOT COPY RELATIONSHIPS UNDER A TO B.
--------------------------------------------------------------------------------------

PROCEDURE copy_rel_type_only (
 -- in parameters
   p_source_rel_type            IN      VARCHAR2
  ,p_dest_rel_type              IN      VARCHAR2
  ,p_dest_rel_type_role_prefix  IN      VARCHAR2
  ,p_dest_rel_type_role_suffix  IN      VARCHAR2
  -- out NOCOPY parameters
  ,x_return_status             OUT NOCOPY    VARCHAR2
  ,x_msg_count                 OUT NOCOPY    NUMBER
  ,x_msg_data                  OUT NOCOPY    VARCHAR2
  )
IS
     p_relationship_type_rec HZ_RELATIONSHIP_TYPE_V2PUB.RELATIONSHIP_TYPE_REC_TYPE;
     x_relationship_type_id NUMBER;
     temp1 varchar2(200);
     temp2 varchar2(200);
     forward_role varchar2(200);
     backward_role varchar2(200);
     ret_value number;
     temp number;
    -- THE CURSOR HERE SHOULD FETCH ONLY THE ROWS WHOSE DIRECTION CODE IS EITHER 'P' OR 'N'
    -- AFTER THE SELF JOIN AND CALL THE RELATIONSHIP TYPE API ONLY FOR THOSE ROWS.
    -- NEED TO ADD MORE ATTRIBUTES FROM hrt1 TO THE SELECT IN QUERY.
     CREATE_LOOKUP_EXCEPTION EXCEPTION;

    CURSOR c_get_rel_type_record
    IS
    select hrt1.relationship_type as relationship_type,
           hrt1.direction_code as direction_code,
           hrt1.role as forward_role,
           hrt2.role as backward_role,
           hrt1.forward_rel_code as forward_rel_code,
           hrt1.backward_rel_code as backward_rel_code,
           hrt1.hierarchical_flag as hierarchical_flag,
           hrt1.create_party_flag as create_party_flag,
           hrt1.allow_relate_to_self_flag as allow_relate_to_self_flag,
           hrt1.allow_circular_relationships as allow_circular_relationships,
           hrt1.subject_type as subject_type,
           hrt1.object_type as object_type,
           hrt1.status as status,
           hrt1.created_by_module as created_by_module,
           hrt1.application_id as application_id,
           hrt1.multiple_parent_allowed as multiple_parent_allowed,
           hrt1.incl_unrelated_entities as incl_unrelated_entities
    from hz_relationship_types hrt1, hz_relationship_types hrt2
    where hrt1.relationship_type = hrt2.relationship_type
    and hrt1.subject_type = hrt2.object_type
    and hrt1.object_type = hrt2.subject_type
    and hrt1.forward_rel_code = hrt2.backward_rel_code
    and hrt1.backward_rel_code = hrt2.forward_rel_code
    and (hrt1.direction_code = 'P' or hrt1.direction_code = 'N')
    and hrt1.relationship_type = p_source_rel_type ;


BEGIN
                 savepoint copy_rel_type_only ;
                 -- INITIALIZE RETURN STATUS
                 x_return_status := FND_API.G_RET_STS_SUCCESS;

                -- initialize the temporary variable
                temp := -1;

                -- LOOP THROUGH THE CURSOR
                FOR rel_type_record IN c_get_rel_type_record
                LOOP

                        -- CREATE TWO LOOKUPS OR ONE LOOKUP, DEPENDING ON THE DIRECTION CODE.
                        -- THE ROLES WILL BE SYSTEM GENERATED IN ANY CASE.
                        -- WHEN DIRECTION IS 'P', CREATE TWO LOOKUPS ONE FOR EACH ROLE.
                        -- WHEN DIRECTION IS 'N', CREATE ONE LOOKUP AND USE IT FOR BOTH FORWARD AND BACKWARD ROLES.
                        IF rel_type_record.direction_code = 'P'
                        THEN
                            temp1 := p_dest_rel_type_role_prefix || get_meaning(rel_type_record.forward_role)
                                     || p_dest_rel_type_role_suffix ;
                            temp2 := p_dest_rel_type_role_prefix || get_description(rel_type_record.forward_role)
                                     || p_dest_rel_type_role_suffix  ;

                            -- if first time in the loop, temp is current time
                            -- else it is incremented by 1
                            IF temp = -1
                            THEN
                                temp := dbms_utility.get_time;
                            ELSE
                                temp := temp + 1;
                            END IF;

                            forward_role := 'USER_ROLE'|| to_char(temp) ;

                            -- dbms_output.put_line('forward role is' || forward_role);
                            -- dbms_output.put_line('meaning is' || temp1);
                            -- dbms_output.put_line('description is' || temp2);
                            -- dbms_output.put_line('forward_role is' || forward_role );
                            log('-------------------------------------------');
                            log('forward role code is ' || forward_role);
                            log('meaning is ' || temp1);
                            log('description is ' || temp2);
                            create_lookup(forward_role, temp1, temp2,x_return_status);
                            /* Bug 3620141 */
                            IF (x_return_status <> FND_API.G_RET_STS_SUCCESS )
                            THEN
                                RAISE CREATE_LOOKUP_EXCEPTION;
                            END IF;

                            temp1 := p_dest_rel_type_role_prefix || get_meaning(rel_type_record.backward_role)
                                     || p_dest_rel_type_role_suffix ;
                            temp2 := p_dest_rel_type_role_prefix || get_description(rel_type_record.backward_role)

                                     || p_dest_rel_type_role_suffix  ;

                            -- always increment by 1
                            temp := temp + 1;
                            backward_role := 'USER_ROLE'|| to_char(temp) ;

                            -- dbms_output.put_line('backward role is' || backward_role);
                            -- dbms_output.put_line('meaning is' || temp1);
                            -- dbms_output.put_line('description is' || temp2);
                            -- dbms_output.put_line('backward_role is' || backward_role );
                            log('-------------------------------------------');
                            log('backward role code is ' || backward_role);
                            log('meaning is ' || temp1);
                            log('description is ' || temp2);
                            create_lookup(backward_role, temp1, temp2, x_return_status);
                            /* Bug 3620141 */
                            IF (x_return_status <> FND_API.G_RET_STS_SUCCESS )
                            THEN
                                RAISE CREATE_LOOKUP_EXCEPTION;
                            END IF;

                        ELSIF rel_type_record.direction_code = 'N'
                        THEN
                            temp1 := p_dest_rel_type_role_prefix || get_meaning(rel_type_record.forward_role)
                                     || p_dest_rel_type_role_suffix ;
                            temp2 := p_dest_rel_type_role_prefix || get_description(rel_type_record.forward_role)
                                     || p_dest_rel_type_role_suffix  ;


                            -- if first time in the loop, temp is current time
                            -- else it is incremented by 1
                            IF temp = -1
                            THEN
                                temp := dbms_utility.get_time;
                            ELSE
                                temp := temp + 1;
                            END IF;

                            forward_role := 'USER_ROLE'|| to_char(temp) ;

                            -- dbms_output.put_line('fackward role and backward_role is' || forward_role);
                            -- dbms_output.put_line('meaning is' || temp1);
                            -- dbms_output.put_line('description is' || temp2);
                            -- dbms_output.put_line('forward_role is' || forward_role );
                            log('-------------------------------------------');
                            log('forward role code = backward role code = ' || forward_role);
                            log('meaning is ' || temp1);
                            log('description is ' || temp2);
                            create_lookup(forward_role, temp1, temp2,x_return_status);
                            /* Bug 3620141 */
                            IF (x_return_status <> FND_API.G_RET_STS_SUCCESS )
                            THEN
                                RAISE CREATE_LOOKUP_EXCEPTION;
                            END IF;
                            backward_role := forward_role;
                        END IF;


                        -- CREATE THE NEW RELATIONSHIP TYPE WITH THE CORRESPONDING ROLE - PHRASE PAIR
                        p_relationship_type_rec.relationship_type_id := NULL;
                        p_relationship_type_rec.relationship_type := p_dest_rel_type ;
                        p_relationship_type_rec.forward_rel_code := rel_type_record.forward_rel_code ;
                        p_relationship_type_rec.backward_rel_code := rel_type_record.backward_rel_code;
                        p_relationship_type_rec.direction_code := rel_type_record.direction_code;
                        p_relationship_type_rec.hierarchical_flag :=  rel_type_record.hierarchical_flag ;
                        p_relationship_type_rec.create_party_flag := rel_type_record.create_party_flag;
                        p_relationship_type_rec.allow_relate_to_self_flag := rel_type_record.allow_relate_to_self_flag ;
                        p_relationship_type_rec.allow_circular_relationships := rel_type_record.allow_circular_relationships ;
                        p_relationship_type_rec.subject_type := rel_type_record.subject_type ;
                        p_relationship_type_rec.object_type :=  rel_type_record.object_type;
                        p_relationship_type_rec.status := rel_type_record.status ;
                        p_relationship_type_rec.created_by_module := 'HZ_COPY_SCRIPT_CREATED' ;
                        p_relationship_type_rec.application_id := NULL;
                        p_relationship_type_rec.multiple_parent_allowed := rel_type_record.multiple_parent_allowed ;
                        p_relationship_type_rec.incl_unrelated_entities := rel_type_record.incl_unrelated_entities ;
                        p_relationship_type_rec.forward_role := forward_role ;
                        p_relationship_type_rec.backward_role := backward_role;

                        hz_relationship_type_v2pub.create_relationship_type('T',p_relationship_type_rec,
                                                                             x_relationship_type_id,x_return_status,
                                                                             x_msg_count,x_msg_data);
                         -- RAISE HELL WHEN return status is not success
                        IF x_return_status <> FND_API.G_RET_STS_SUCCESS
                        THEN
                                 FND_MESSAGE.SET_NAME('AR', 'HZ_COPY_REL_API_ERROR');
                                 FND_MESSAGE.SET_TOKEN('PROC' ,'HZ_RELATIONSHIP_TYPE_V2PUB.CREATE_RELATIONSHIP_TYPE');
                                 FND_MESSAGE.SET_TOKEN('ERROR' , SQLERRM);
                                 FND_MSG_PUB.ADD;
                                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                        END IF;

                END LOOP;


                EXCEPTION
                          WHEN CREATE_LOOKUP_EXCEPTION THEN
                                ROLLBACK TO copy_rel_type_only;
                                x_return_status := FND_API.G_RET_STS_ERROR;
                                FND_MSG_PUB.Count_And_Get(
                                                p_encoded => FND_API.G_FALSE,
                                                p_count => x_msg_count,
                                                p_data  => x_msg_data);


                          WHEN OTHERS THEN
                                rollback to copy_rel_type_only ;
                                x_return_status := FND_API.G_RET_STS_ERROR;
                                FND_MESSAGE.SET_NAME('AR', 'HZ_COPY_REL_API_ERROR');
                                FND_MESSAGE.SET_TOKEN('PROC' ,'COPY_REL_TYPE_ONLY');
                                FND_MESSAGE.SET_TOKEN('ERROR' , SQLERRM);
                                FND_MSG_PUB.ADD;
                                FND_MSG_PUB.Count_And_Get(
                                                p_encoded => FND_API.G_FALSE,
                                                p_count => x_msg_count,
                                                p_data  => x_msg_data);

END copy_rel_type_only ;





--------------------------------------------------------------------------------------
-- copy_rel_type_and_all_rels ::: This will take a relationship type A and create a relationship
--                   type B, which is a copy of A in the following sense:
--                   1. B will be identical to A in terms of all the properties( hierarchical type, circular flag
--                   etc., as seen in HZ_RELATIONSHIP_TYPES), that are
--                   associated with any relationship type.
--                   2. ALL THE RELATIONSHIPS UNDER A WILL BE CREATED UNDER B.
--------------------------------------------------------------------------------------

PROCEDURE copy_rel_type_and_all_rels (
   errbuf                       OUT     NOCOPY VARCHAR2
  ,Retcode                      OUT     NOCOPY VARCHAR2
  ,p_source_rel_type            IN      VARCHAR2
  ,p_dest_rel_type              IN      VARCHAR2
  ,p_dest_rel_type_role_prefix  IN      VARCHAR2
  ,p_dest_rel_type_role_suffix  IN      VARCHAR2
  ,p_rel_valid_date             IN      DATE
  )
  IS
  x_return_status  VARCHAR2(1);
  x_msg_count NUMBER;
  x_msg_data VARCHAR2(2000);
BEGIN

    savepoint copy_rel_type_and_all_rels ;

    G_RET_CODE := TRUE;

    -- return is status unless otherwise changed
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    log('-------------------------------------------');
    log('Passed in Source Rel Type is ' || p_source_rel_type );
    log('Passed in Destination Rel Type is ' || p_dest_rel_type );
    log('Passed in Prefix is ' || p_dest_rel_type_role_prefix  );
    log('Passed in Suffix is ' || p_dest_rel_type_role_suffix );
    log('Passed in Date is ' || p_rel_valid_date );

    -- CREATE RELATIONSHIP TYPE FIRST

    copy_rel_type_only(p_source_rel_type,p_dest_rel_type,p_dest_rel_type_role_prefix,
                       p_dest_rel_type_role_suffix,
                       x_return_status, x_msg_count, x_msg_data );




    -- RAISE HELL WHEN return status is not success
     IF x_return_status <> FND_API.G_RET_STS_SUCCESS
     THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;


    -- NOW, CREATE ALL THE RELATIONSHIPS FOR THE NEWLY CREATED RELATIONSHIP TYPE
    copy_relationships(p_source_rel_type, p_dest_rel_type, nvl(p_rel_valid_date,SYSDATE),
                       x_return_status, x_msg_count, x_msg_data);

     -- Bug 4288839
     -- If G_RET_CODE IS FALSE, then it means that some relationships could not be created.
     -- Error out the concurrent program and rollback all changes.


     -- RAISE HELL WHEN return status is not success
/*     IF x_return_status <> FND_API.G_RET_STS_SUCCESS
     THEN
          -- dbms_output.put_line('Return status after copy relationships is ' || x_return_status);
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;*/

     IF G_RET_CODE = FALSE THEN
	ROLLBACK TO copy_rel_type_and_all_rels;
	Retcode := 2;

     END IF;


    EXCEPTION
             WHEN OTHERS
             THEN
                 ROLLBACK TO copy_rel_type_and_all_rels ;
                 x_return_status := FND_API.G_RET_STS_ERROR;
                 FND_MESSAGE.SET_NAME('AR', 'HZ_COPY_REL_API_ERROR');
                 FND_MESSAGE.SET_TOKEN('PROC' ,'COPY_REL_TYPE_AND_ALL_RELS');
                 FND_MESSAGE.SET_TOKEN('ERROR' , SQLERRM);
                 FND_MSG_PUB.ADD;
                 FND_MSG_PUB.Count_And_Get(
                                        p_encoded => FND_API.G_FALSE,
                                        p_count => x_msg_count,
                                        p_data  => x_msg_data);


                 -- LOG MESSAGE TO FILE
                 /*
                 FOR I IN 1..FND_MSG_PUB.Count_Msg LOOP
                        log(FND_MSG_PUB.Get(p_encoded => FND_API.G_FALSE ));
                 END LOOP;
                 */
                 logerror;
                 FND_MESSAGE.CLEAR;

                 -- Bug 3651949: let concurrent program error out.
                 Retcode := 2;

END copy_rel_type_and_all_rels ;

----------------------------------------------------------------
-- WRAPPER ON TOP OF THE copy_rel_typ_and_all_relships PROCEDURE
-- SO THAT IT CAN BE CALLED AS A CONCURRENT PROGRAM
----------------------------------------------------------------


PROCEDURE submit_copy_rel_type_rels_conc (
  -- in parameters
   p_source_rel_type            IN      VARCHAR2
  ,p_dest_rel_type              IN      VARCHAR2
  ,p_dest_rel_type_role_prefix  IN      VARCHAR2
  ,p_dest_rel_type_role_suffix  IN      VARCHAR2
  ,p_rel_valid_date             IN      DATE
  ,x_request_id       OUT NOCOPY NUMBER
  ,x_return_status    OUT NOCOPY VARCHAR2
  ,x_msg_count        OUT NOCOPY NUMBER
  ,x_msg_data         OUT NOCOPY VARCHAR2 )
  IS
          l_request_id            NUMBER := NULL;

  BEGIN
                  x_return_status := FND_API.G_RET_STS_SUCCESS;


                  -- CALL THE PROCEDURE THAT IS RUN AS A CONCURRENT REQUEST
                  l_request_id := fnd_request.submit_request('AR','ARHCPRLA','Copy Rel Type and All Rels',
                                    to_char(sysdate,'DD-MON-YY HH24:MI:SS'),
                                    FALSE,p_source_rel_type,p_dest_rel_type,
                                    p_dest_rel_type_role_prefix,p_dest_rel_type_role_suffix,
                                    -- Bug 3651949: make sure the length of p_rel_valid_date is 9 characters.
                                    -- this is what we defined in the concurrent program.
                                    TO_CHAR(p_rel_valid_date, 'DD-MON-YY'));
                  -- COMPLAIN IF IT DOES NOT RETURN A PROPER REQUEST ID.
                  IF l_request_id = 0
                  THEN
                           FND_MESSAGE.SET_NAME('AR', 'AR_CUST_CONC_ERROR');
                           FND_MSG_PUB.ADD;
                           RAISE FND_API.G_EXC_ERROR;
                  END IF;

                  x_request_id := l_request_id;


  EXCEPTION
            WHEN OTHERS
            THEN
                 x_return_status := FND_API.G_RET_STS_ERROR;
                 FND_MESSAGE.SET_NAME('AR', 'HZ_COPY_REL_API_ERROR');
                 FND_MESSAGE.SET_TOKEN('PROC' ,'SUBMIT_COPY_REL_TYPE_RELS_CONC');
                 FND_MESSAGE.SET_TOKEN('ERROR' , SQLERRM);
                 FND_MSG_PUB.ADD;
                 FND_MSG_PUB.Count_And_Get(
                                        p_encoded => FND_API.G_FALSE,
                                        p_count => x_msg_count,
                                        p_data  => x_msg_data);

 END submit_copy_rel_type_rels_conc ;




--------------------------------------------------------------------------------------
-- copy_hierarchy ::: This will take 2 Hierarchical relationship types A, B and do the following:
--                    1. If B does not exist already, create B as a copy of A, in the sense of
--                       copy_rel_type_only, mentioned above.
--                    2. Given a party id P, copy the complete hierarchy tree under P in A, to B.
--                       In other words, copy all relationships under A, that pertain to P's
--                       Hierarchy tree ( ie., the tree starting from P and going down) to B.
--                       If B exists already, this would mean that, when ever we create relationships in B,
--                       we need to make sure, that they do not already exist in A.
--
--                       IT SHOULD BE NOTED THAT IF B EXISTS ALREADY, THEN ALL THE PHRASE PAIRS
--                       PERTAINING TO A THAT DO NOT ALREADY EXIST IN B, SHOULD BE FIRST CREATED IN B,
--                       BEFORE PROCEEDING TO STEP 2.
--------------------------------------------------------------------------------------

PROCEDURE copy_hierarchy (
   errbuf                       OUT     NOCOPY VARCHAR2
  ,Retcode                      OUT     NOCOPY VARCHAR2
  ,p_source_rel_type            IN      VARCHAR2
  ,p_dest_rel_type              IN      VARCHAR2
  ,p_dest_rel_type_role_prefix  IN      VARCHAR2
  ,p_dest_rel_type_role_suffix  IN      VARCHAR2
  ,p_rel_valid_date             IN      DATE
  ,p_party_id                   IN      NUMBER
  )
  IS
  x_return_status   VARCHAR2(1);
  x_msg_count NUMBER;
  x_msg_data VARCHAR2(2000);
  -- GET ALL THE PHRASE PAIRS THAT ARE IN SOURCE BUT NOT IN DESTINATION
  cursor c0
  is
  select * from
  hz_relationship_types
  where relationship_type = p_source_rel_type
  and (direction_code = 'P' or direction_code = 'N')
  and (forward_rel_code, backward_rel_code, subject_type, object_type) not in
   (select forward_rel_code, backward_rel_code, subject_type, object_type
  from hz_relationship_types
  where relationship_type = p_dest_rel_type );
BEGIN
        -- save and be ready to rollback
        savepoint copy_hierarchy ;

        G_RET_CODE := TRUE;

        -- return is status unless otherwise changed
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        log('-------------------------------------------');
        log('Passed in Source Rel Type is ' || p_source_rel_type );
        log('Passed in Destination Rel Type is ' || p_dest_rel_type );
        log('Passed in Prefix is ' || p_dest_rel_type_role_prefix  );
        log('Passed in Suffix is ' || p_dest_rel_type_role_suffix );
        log('Passed in Date is ' || p_rel_valid_date );
        log('Passed in Party ID is ' || p_party_id );

        -- FIRST COPY THOSE SPECIFIC PHRASE PAIRS FROM SOURCE TO DESTINATION
        FOR rel_type_rec in c0
        LOOP
            copy_selected_phrase_pair(p_source_rel_type,p_dest_rel_type,
                                                   p_dest_rel_type_role_prefix, p_dest_rel_type_role_suffix,
                                                   rel_type_rec.forward_rel_code, rel_type_rec.backward_rel_code,
                                                   rel_type_rec.subject_type, rel_type_rec.object_type,
                                                   x_return_status, x_msg_count, x_msg_data );

        END LOOP;

     -- RAISE HELL WHEN return status is not success
     IF x_return_status <> FND_API.G_RET_STS_SUCCESS
     THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

        -- COPY THE HIERARCHY (STARTING FROM P AND GOING BELOW) FROM SOURCE TO DESTINATION,
        -- BY CREATING ALL NECESSARY RELATIONSHIPS IN B.
           create_hierarchy(p_party_id, p_source_rel_type, p_dest_rel_type,
                                      p_dest_rel_type_role_prefix, p_dest_rel_type_role_suffix,
                                      nvl(p_rel_valid_date,SYSDATE), x_return_status, x_msg_count, x_msg_data );

     -- Bug 4288839
     -- If G_RET_CODE IS FALSE, then it means that some relationships could not be created.
     -- Error out the concurrent program and rollback all changes.
    /*
     -- RAISE HELL WHEN return status is not success
     IF x_return_status <> FND_API.G_RET_STS_SUCCESS
     THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;
    */
     IF G_RET_CODE = FALSE THEN
	 rollback to copy_hierarchy;
         Retcode := 2;
     END IF;

     EXCEPTION
            WHEN OTHERS
            THEN
                 -- rollback if you get this far
                 rollback to copy_hierarchy ;
                 x_return_status := FND_API.G_RET_STS_ERROR;
                 FND_MESSAGE.SET_NAME('AR', 'HZ_COPY_REL_API_ERROR');
                 FND_MESSAGE.SET_TOKEN('PROC' ,'COPY_HIERARCHY');
                 FND_MESSAGE.SET_TOKEN('ERROR' , SQLERRM);
                 FND_MSG_PUB.ADD;
                 FND_MSG_PUB.Count_And_Get(
                                        p_encoded => FND_API.G_FALSE,
                                        p_count => x_msg_count,
                                        p_data  => x_msg_data);

                 -- LOG MESSAGE TO FILE
                 /*
                 FOR I IN 1..FND_MSG_PUB.Count_Msg LOOP
                        log(FND_MSG_PUB.Get(p_encoded => FND_API.G_FALSE ));
                 END LOOP;
                 */
                 logerror;

END copy_hierarchy;




----------------------------------------------------------------
-- WRAPPER ON TOP OF THE copy_hierarchy PROCEDURE
-- SO THAT IT CAN BE CALLED AS A CONCURRENT PROGRAM
----------------------------------------------------------------

PROCEDURE submit_copy_hierarchy_conc (
  -- in parameters
   p_source_rel_type            IN      VARCHAR2
  ,p_dest_rel_type              IN      VARCHAR2
  ,p_dest_rel_type_role_prefix  IN      VARCHAR2
  ,p_dest_rel_type_role_suffix  IN      VARCHAR2
  ,p_rel_valid_date             IN      DATE
  ,p_party_id                   IN      NUMBER
  ,x_request_id       OUT NOCOPY NUMBER
  ,x_return_status    OUT NOCOPY VARCHAR2
  ,x_msg_count        OUT NOCOPY NUMBER
  ,x_msg_data         OUT NOCOPY VARCHAR2 )
  IS
          l_request_id            NUMBER := NULL;

  BEGIN
                  x_return_status := FND_API.G_RET_STS_SUCCESS;



                  -- CALL THE PROCEDURE THAT IS RUN AS A CONCURRENT REQUEST
                  l_request_id := fnd_request.submit_request('AR','ARHCPRLH','Copy Hierarchy of a Given Party',sysdate,
                                    FALSE,p_source_rel_type,p_dest_rel_type,
                                    p_dest_rel_type_role_prefix,p_dest_rel_type_role_suffix,p_rel_valid_date,p_party_id );

                  -- COMPLAIN IF IT DOES NOT RETURN A PROPER REQUEST ID.
                  IF l_request_id = 0
                  THEN
                           FND_MESSAGE.SET_NAME('AR', 'AR_CUST_CONC_ERROR');
                           FND_MSG_PUB.ADD;
                           RAISE FND_API.G_EXC_ERROR;
                  END IF;

                  x_request_id := l_request_id;


  EXCEPTION
         WHEN OTHERS
         THEN
                 x_return_status := FND_API.G_RET_STS_ERROR;
                 FND_MESSAGE.SET_NAME('AR', 'HZ_COPY_REL_API_ERROR');
                 FND_MESSAGE.SET_TOKEN('PROC' ,'SUBMIT_COPY_HIERARCHY_CONC');
                 FND_MESSAGE.SET_TOKEN('ERROR' , SQLERRM);
                 FND_MSG_PUB.ADD;
                 FND_MSG_PUB.Count_And_Get(
                                        p_encoded => FND_API.G_FALSE,
                                        p_count => x_msg_count,
                                        p_data  => x_msg_data);
 END submit_copy_hierarchy_conc ;

 ------------------------------------------------------------------------
-- This procedure will convert a non-hierarchical relationship type to a
-- hierarchical relationship type.
--
-- Bug 3615970: fixed various issues
------------------------------------------------------------------------

PROCEDURE convert_rel_type (
    errbuf                       OUT     NOCOPY VARCHAR2
   ,Retcode                      OUT     NOCOPY VARCHAR2
   ,p_rel_type                   IN      VARCHAR2
)
IS

    -- Bug 3615970: point 8
    --
    CURSOR c1 IS
    SELECT r.relationship_id,
           r.status,
           r.subject_id,
           r.subject_table_name,
           r.subject_type,
           r.object_id,
           r.object_table_name,
           r.object_type,
           r.start_date,
           r.end_date,
           r.relationship_code,
           t.backward_rel_code
    FROM   hz_relationships r,
           hz_relationship_types t
    WHERE  r.relationship_type = p_rel_type
    AND    r.relationship_type = t.relationship_type
    AND    t.relationship_type = p_rel_type
    AND    r.relationship_code = t.forward_rel_code
    AND    r.subject_type = t.subject_type
    AND    r.object_type = t.object_type
    AND    t.direction_code = 'P';

    -- Bug 3615970: point 9. removed cursor c2.
    --

    -- Bug 3615970: moved the circularity check to do_circularity_check

    l_hierarchy_rec                   HZ_HIERARCHY_PUB.HIERARCHY_NODE_REC_TYPE;
    l_return_status                   VARCHAR2(1);
    l_msg_count                       NUMBER;
    l_msg_data                        VARCHAR2(2000);

    i_relationship_id                 t_number_tbl;
    i_status                          t_varchar30_tbl;
    i_parent_id                       t_number_tbl;
    i_parent_type                     t_varchar30_tbl;
    i_parent_table_name               t_varchar30_tbl;
    i_child_id                        t_number_tbl;
    i_child_type                      t_varchar30_tbl;
    i_child_table_name                t_varchar30_tbl;
    i_start_date                      t_date_tbl;
    i_end_date                        t_date_tbl;
    i_relationship_code               t_varchar30_tbl;
    i_backward_rel_code               t_varchar30_tbl;

    l_create_hierarchy_link           VARCHAR2(1) := 'Y';
    l_id                              NUMBER;
    l_meaning                         VARCHAR2(400);
    x_return_status                   VARCHAR2(1);

    rows                              NUMBER := 1000;
    l_last_fetch                      BOOLEAN := FALSE;

BEGIN

    -- save and be ready to rollback
    savepoint convert_rel_type ;

    -- initialize return status
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Bug 3615970: point 2
    -- clean up hierarchy nodes table
    DELETE hz_hierarchy_nodes
    WHERE  hierarchy_type = p_rel_type;

    -- get all the relationships for this relationship type
    OPEN c1;
    LOOP
      FETCH c1 BULK COLLECT INTO
        i_relationship_id, i_status,
        i_parent_id, i_parent_table_name, i_parent_type,
        i_child_id, i_child_table_name, i_child_type,
        i_start_date, i_end_date,
        i_relationship_code, i_backward_rel_code
        LIMIT rows;

      IF c1%NOTFOUND THEN
        l_last_fetch := TRUE;
      END IF;
      IF i_relationship_id.COUNT = 0 AND l_last_fetch THEN
        EXIT;
      END IF;

      -- for each relationship
      --
      FOR i IN 1..i_relationship_id.COUNT LOOP

        log('relationship_id = '||i_relationship_id(i)||' , '||
            'subject_id = '||i_parent_id(i)||' , '||
            'object_id = '||i_child_id(i));

        g_parent_nodes_tbl.DELETE;
        g_relationship_id_tbl.DELETE;

        -- Bug 3615970: point 3, 4

        do_circularity_check (
          i_child_id(i),
          i_child_table_name(i),
          i_child_type(i),
          p_rel_type,
          i_start_date(i),
          i_end_date(i),
          x_return_status
        );

        log('main: x_return_status = '||x_return_status);

        IF x_return_status = 'S' THEN
          FOR i IN 1..g_parent_nodes_tbl.COUNT LOOP
            l_id := SUBSTRB(g_parent_nodes_tbl(i), 1, INSTRB(g_parent_nodes_tbl(i), '#')-1);
            g_passed_nodes_tbl(l_id) := g_parent_nodes_tbl(i);
          END LOOP;

        ELSE
          FOR i IN 1..g_parent_nodes_tbl.COUNT LOOP
            l_id := SUBSTRB(g_parent_nodes_tbl(i), 1, INSTRB(g_parent_nodes_tbl(i), '#')-1);
            g_failed_nodes_tbl(l_id) := g_parent_nodes_tbl(i);
          END LOOP;

          -- as long as there is one circularity check failed, the
          -- concurrent program will do circularity check only to
          -- report all of errors
          --
          IF l_create_hierarchy_link = 'Y' THEN
            ROLLBACK TO convert_rel_type ;

            l_create_hierarchy_link := 'N';
          END IF;

        END IF;

        IF l_create_hierarchy_link = 'Y' THEN
          l_hierarchy_rec.hierarchy_type := p_rel_type;
          l_hierarchy_rec.parent_id := i_parent_id(i);
          l_hierarchy_rec.parent_table_name := i_parent_table_name(i);
          l_hierarchy_rec.parent_object_type := i_parent_type(i);
          l_hierarchy_rec.child_id := i_child_id(i);
          l_hierarchy_rec.child_table_name := i_child_table_name(i);
          l_hierarchy_rec.child_object_type := i_child_type(i);
          l_hierarchy_rec.effective_start_date := i_start_date(i);
          l_hierarchy_rec.effective_end_date := NVL(i_end_date(i), TO_DATE('31-12-4712 00:00:01', 'DD-MM-YYYY HH24:MI:SS'));
          l_hierarchy_rec.relationship_id := i_relationship_id(i);
          l_hierarchy_rec.status := NVL(i_status(i), 'A');

          HZ_HIERARCHY_PUB.create_link(
            p_init_msg_list           => FND_API.G_FALSE,
            p_hierarchy_node_rec      => l_hierarchy_rec,
            x_return_status           => l_return_status,
            x_msg_count               => l_msg_count,
            x_msg_data                => l_msg_data
          );

          -- RAISE HELL WHEN return status is not success
          IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            FND_MESSAGE.SET_NAME('AR', 'HZ_CONVERT_REL_API_ERROR');
            FND_MESSAGE.SET_TOKEN('PROC' ,'HZ_HIERARCHY_PUB.CREATE_LINK');
            FND_MESSAGE.SET_TOKEN('ERROR' , SQLERRM);
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

            ROLLBACK TO convert_rel_type ;

            l_create_hierarchy_link := 'N';
          END IF;

          -- Bug 3615970: can not assume direction code has value.
          -- it may be null because we don't have data fix script
          -- when the new column is introduced.
          --
          UPDATE hz_relationships
          SET    direction_code = 'P'
          WHERE  direction_code IS NULL
          AND    relationship_id = i_relationship_id(i)
          AND    relationship_type = p_rel_type
          AND    relationship_code = i_relationship_code(i)
          AND    subject_type = i_parent_type(i)
          AND    object_type = i_child_type(i);

          UPDATE hz_relationships
          SET    direction_code = 'C'
          WHERE  direction_code IS NULL
          AND    relationship_id = i_relationship_id(i)
          AND    relationship_type = p_rel_type
          AND    relationship_code = i_backward_rel_code(i)
          AND    subject_type = i_child_type(i)
          AND    object_type = i_parent_type(i);

        END IF;

      END LOOP;

      IF l_last_fetch = TRUE THEN
        EXIT;
      END IF;
    END LOOP;

    CLOSE c1;

    IF l_create_hierarchy_link = 'N' THEN
      -- Bug 3615970: point 7

      -- prepare output file
      --
      SELECT meaning
      INTO   l_meaning
      FROM   ar_lookups
      WHERE  lookup_type = 'HZ_RELATIONSHIP_TYPE'
      AND    lookup_code = p_rel_type;

      FND_MESSAGE.SET_NAME('AR', 'HZ_CIRCULAR_REL_EXIST_FMT1');
      FND_MESSAGE.SET_TOKEN('RELTYPE' , l_meaning);

      FND_FILE.PUT_LINE(FND_FILE.OUTPUT, FND_MESSAGE.GET()||fnd_global.NEWLINE);

      FOR i IN 1..g_message_fmt1.COUNT LOOP
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, i||' : ');
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, g_message_fmt1(i)||fnd_global.NEWLINE);
      END LOOP;

      -- prepare log file
      --
      FND_MESSAGE.SET_NAME('AR', 'HZ_CIRCULAR_REL_EXIST_FMT2');
      FND_MESSAGE.SET_TOKEN('RELTYPE' , p_rel_type);

      log('===================================================================');
      log(fnd_global.NEWLINE||fnd_global.NEWLINE||FND_MESSAGE.GET()||fnd_global.NEWLINE);

      FOR i IN 1..g_message_fmt2.COUNT LOOP
        log(i||' : ');
        log(g_message_fmt2(i)||fnd_global.NEWLINE);
      END LOOP;

      -- Bug 3615970: point 6
      Retcode := 2;

    ELSE

      UPDATE HZ_RELATIONSHIP_TYPES
      SET    HIERARCHICAL_FLAG = 'Y',
             MULTIPLE_PARENT_ALLOWED = 'N',
             INCL_UNRELATED_ENTITIES = 'N',
             ALLOW_CIRCULAR_RELATIONSHIPS = 'N',
             -- Bug 3615970: point 5
             ALLOW_RELATE_TO_SELF_FLAG = 'N',
             -- Bug 3615905: set DO_NOT_ALLOW_CONVERT
             DO_NOT_ALLOW_CONVERT = 'Y'
      WHERE RELATIONSHIP_TYPE = p_rel_type;

      COMMIT;

    END IF;

EXCEPTION
    WHEN OTHERS THEN
      -- rollback if this happens
      rollback to convert_rel_type ;

      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MESSAGE.SET_NAME('AR', 'HZ_CONVERT_REL_API_ERROR');
      FND_MESSAGE.SET_TOKEN('PROC' ,'CONVERT_REL_TYPE');
      FND_MESSAGE.SET_TOKEN('ERROR' , SQLERRM);
      FND_MSG_PUB.ADD;
      FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count   => l_msg_count,
        p_data    => l_msg_data);

      logerror;
      FND_MESSAGE.CLEAR;

      -- Bug 3615970: point 6
      Retcode := 2;

END convert_rel_type;

----------------------------------------------------------------
-- WRAPPER ON TOP OF THE convert_rel_type PROCEDURE
-- SO THAT IT CAN BE CALLED AS A CONCURRENT PROGRAM
----------------------------------------------------------------

PROCEDURE submit_convert_rel_type_conc (
  -- in parameters
    p_rel_type                   IN            VARCHAR2
    -- out NOCOPY parameters
    ,x_request_id                OUT NOCOPY    NUMBER
    ,x_return_status             OUT NOCOPY    VARCHAR2
    ,x_msg_count                 OUT NOCOPY    NUMBER
    ,x_msg_data                  OUT NOCOPY    VARCHAR2
)
IS
          l_request_id            NUMBER := NULL;

  BEGIN
                  x_return_status := FND_API.G_RET_STS_SUCCESS;



                  -- CALL THE PROCEDURE THAT IS RUN AS A CONCURRENT REQUEST
                  l_request_id := fnd_request.submit_request(
                                    'AR','ARHCPRLC',
                                    -- Bug 3615970: point 1
                                    'Convert a Relationship Type to Hierarchical',
                                    to_char(sysdate,'DD-MON-YY HH24:MI:SS'),
                                    FALSE, p_rel_type );

                  -- COMPLAIN IF IT DOES NOT RETURN A PROPER REQUEST ID.
                  IF l_request_id = 0
                  THEN
                           FND_MESSAGE.SET_NAME('AR', 'AR_CUST_CONC_ERROR');
                           FND_MSG_PUB.ADD;
                           RAISE FND_API.G_EXC_ERROR;
                  END IF;

                  x_request_id := l_request_id;

                  EXCEPTION
                            WHEN OTHERS
                            THEN
                               x_return_status := FND_API.G_RET_STS_ERROR;
                               FND_MESSAGE.SET_NAME('AR', 'HZ_CONVERT_REL_API_ERROR');
                               FND_MESSAGE.SET_TOKEN('PROC' ,'SUBMIT_CONVERT_REL_TYPE_CONC');
                               FND_MESSAGE.SET_TOKEN('ERROR' , SQLERRM);
                               FND_MSG_PUB.ADD;
                               FND_MSG_PUB.Count_And_Get(
                                                      p_encoded => FND_API.G_FALSE,
                                                      p_count => x_msg_count,
                                                      p_data  => x_msg_data);

END submit_convert_rel_type_conc ;
END HZ_COPY_REL_PVT ;

/
