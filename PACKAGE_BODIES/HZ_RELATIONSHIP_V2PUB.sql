--------------------------------------------------------
--  DDL for Package Body HZ_RELATIONSHIP_V2PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_RELATIONSHIP_V2PUB" AS
/*$Header: ARH2RESB.pls 120.32.12010000.3 2009/02/17 07:30:06 rgokavar ship $ */

----------------------------------
-- declaration of global variables
----------------------------------

G_PKG_NAME CONSTANT                 VARCHAR2(30) := 'HZ_RELATIONSHIP_V2PUB';

G_DEBUG_COUNT                       NUMBER := 0;
--G_DEBUG                             BOOLEAN := FALSE;

-- Bug 2197181: added for mix-n-match project.

g_rel_mixnmatch_enabled             VARCHAR2(1);
g_rel_selected_datasources          VARCHAR2(255);
g_rel_is_datasource_selected        VARCHAR2(1) := 'N';
g_rel_entity_attr_id                NUMBER;

------------------------------------
-- declaration of private procedures
------------------------------------

/*PROCEDURE enable_debug;

PROCEDURE disable_debug;
*/


PROCEDURE do_create_rel(
    p_relationship_rec              IN OUT NOCOPY RELATIONSHIP_REC_TYPE,
    x_created_party                 OUT NOCOPY    VARCHAR2,
    x_relationship_id               OUT NOCOPY    NUMBER,
    x_party_id                      OUT NOCOPY    NUMBER,
    x_party_number                  OUT NOCOPY    VARCHAR2,
    x_return_status                 IN OUT NOCOPY VARCHAR2,
    p_create_org_contact            IN     VARCHAR2,
    p_contact_party_id         IN     NUMBER,
    p_contact_party_usage_code IN     VARCHAR2
);

PROCEDURE do_update_rel(
    p_relationship_rec              IN OUT NOCOPY RELATIONSHIP_REC_TYPE,
    p_old_relationship_rec          IN     RELATIONSHIP_REC_TYPE,
    p_object_version_number         IN OUT NOCOPY NUMBER,
    p_party_object_version_number   IN OUT NOCOPY NUMBER,
    x_return_status                 IN OUT NOCOPY VARCHAR2
);

PROCEDURE do_create_party(
    p_party_type                    IN     VARCHAR2,
    p_relationship_rec              IN     RELATIONSHIP_REC_TYPE,
    x_party_id                      OUT NOCOPY    NUMBER,
    x_party_number                  OUT NOCOPY    VARCHAR2,
    x_profile_id                    OUT NOCOPY    NUMBER,
    x_return_status                 IN OUT NOCOPY VARCHAR2
);

PROCEDURE do_update_party(
    p_party_type                    IN     VARCHAR2,
    p_relationship_rec              IN     RELATIONSHIP_REC_TYPE,
    p_old_relationship_rec          IN     RELATIONSHIP_REC_TYPE,
    p_party_object_version_number   IN OUT NOCOPY NUMBER,
    x_profile_id                    OUT NOCOPY    NUMBER,
    x_return_status                 IN OUT NOCOPY VARCHAR2
);

PROCEDURE do_update_party_flags(
    p_relationship_rec              IN     RELATIONSHIP_REC_TYPE,
    p_party_id                      IN     NUMBER
);

-----------------------------
-- body of private procedures
-----------------------------


/**
 * PRIVATE PROCEDURE do_circularity_check
 *
 * DESCRIPTION
 *
 *     Performs a circularity check on a relationship network (check for a circuit).
 *
 *     A circuit is detected if a starting node is found again while traversing
 *     the network from that starting point.
 *
 *     Because relationships are date-effective, date checking comes into play.
 *     The circuit must exist for a given point in time - there must be date overlap
 *     between *all* the relationships in the circuit.  Otherwise it's not a circuit.
 *
 *     The implementation of the date checking is slightly complex.  A method to
 *     determine whether there's a common date range to a set of dates is to
 *     simply take the max of the start dates and the min of the end dates.
 *     If this is a valid date range (max start date <= min end date) then this
 *     date range represents a range that is valid for all the dates in the set.
 *     That logic is employed in this procedure.
 *
 *     However, the complication:
 *
 *     Since we may be traversing multiple paths in order to find the circuit,
 *     we must only be comparing dates to all the relationships *in the current path*.
 *     Therefore, we must maintain a "stack" of the max start/min end dates so that
 *     when we start travering a new path, we can restore state to that point.
 *
 *
 * MODIFICATION HISTORY
 *
 *   02-12-2003    Chris Saulit    o Created.
 *
 */

PROCEDURE do_circularity_check(
    p_relationship_id      IN VARCHAR2 DEFAULT NULL,
    p_relationship_type    IN VARCHAR2,
    p_start_date           IN DATE,
    p_end_date             IN DATE,
    p_subject_id           IN VARCHAR2,
    p_object_id            IN VARCHAR2,
    p_object_type          IN VARCHAR2,
    p_object_table_name    IN VARCHAR2
) IS
    l_start_date DATE;
    l_end_date   DATE;

    TYPE t_datestack IS TABLE OF DATE INDEX BY BINARY_INTEGER;

    l_min_end_date_stack    t_datestack;
    l_max_start_date_stack  t_datestack;

    -- This cursor recursively retrieves all the ancestors for a given child in a particular hierarchy.

    CURSOR c_parent (
      p_parent_id NUMBER, p_parent_table_name VARCHAR2, p_parent_object_type VARCHAR2,
      p_relationship_type VARCHAR2, p_relationship_id NUMBER,
      p_start_date DATE, p_end_date DATE)
    IS
    SELECT LEVEL, RELATIONSHIP_ID, SUBJECT_ID, OBJECT_ID, STATUS, START_DATE, END_DATE,
      SUBJECT_TABLE_NAME, SUBJECT_TYPE
    FROM   HZ_RELATIONSHIPS
    WHERE  RELATIONSHIP_ID <> p_relationship_id
    START WITH OBJECT_ID = p_parent_id
          AND OBJECT_TABLE_NAME = p_parent_table_name
          AND OBJECT_TYPE = p_parent_object_type
          AND DIRECTION_CODE = 'P'
          AND RELATIONSHIP_TYPE = p_relationship_type
          AND RELATIONSHIP_ID <> p_relationship_id
        -- check for intersection with base relationship
          AND START_DATE <= p_end_date
          AND END_DATE >= p_start_date
-- Bug 3364626 : Added status='A' condition
          AND STATUS='A'

    CONNECT BY OBJECT_ID = PRIOR SUBJECT_ID AND OBJECT_TYPE = PRIOR SUBJECT_TYPE AND OBJECT_TABLE_NAME = PRIOR SUBJECT_TABLE_NAME
           AND DIRECTION_CODE = 'P' AND RELATIONSHIP_TYPE =  p_relationship_type
           AND RELATIONSHIP_ID <> p_relationship_id
           -- check for intersection against prior relationship
           AND START_DATE <= PRIOR END_DATE
           AND END_DATE >= PRIOR START_DATE
           -- check for intersection against base relationship
           AND START_DATE <= p_end_date
           AND END_DATE >= p_start_date
-- Bug 3364626 : Added status='A' condition
          AND STATUS='A';


     v_rel c_parent%ROWTYPE;
BEGIN
  l_start_date := NVL(p_start_date,SYSDATE);
  l_end_date   := NVL(p_end_date,TO_DATE('4712.12.31 00:01','YYYY.MM.DD HH24:MI'));

  l_max_start_date_stack(1) := l_start_date;
  l_min_end_date_stack(1)   := l_end_date;

  OPEN c_parent (
    p_parent_id          => p_object_id,
    p_parent_table_name  => p_object_table_name,
    p_parent_object_type => p_object_type,
    p_relationship_type  => p_relationship_type,
    p_relationship_id    => NVL(p_relationship_id,-1),
    p_start_date         => l_start_date,
    p_end_date           => l_end_date
  );

  LOOP
    FETCH c_parent INTO v_rel;
    IF c_parent%NOTFOUND THEN
      EXIT;
    END IF;

    -- The following is a pseudo-stack.
    -- We either went down a level, or came back up 1 or more levels.
    -- Need to obtain the max start and min end dates as per the previous
    -- parent relationship in the branch (or new branch) being traversed.

    IF l_max_start_date_stack.COUNT > v_rel.level THEN
      -- we came up n levels, so pop the unneeded dates off the stack and throw away
      l_max_start_date_stack.DELETE(v_rel.level+1,l_max_start_date_stack.COUNT);
      l_min_end_date_stack.DELETE(v_rel.level+1,l_min_end_date_stack.COUNT);
    END IF;
    IF l_max_start_date_stack.COUNT <= v_rel.level+1 THEN
      -- we went down a level, so push the dates down one level too
      l_max_start_date_stack(v_rel.level+1) := l_max_start_date_stack(v_rel.level);
      l_min_end_date_stack(v_rel.level+1) := l_min_end_date_stack(v_rel.level);
    END IF;

    -- Compare and Save

    IF v_rel.start_date > l_max_start_date_stack(v_rel.level+1) THEN
      l_max_start_date_stack(v_rel.level+1) := v_rel.start_date;
    END IF;
    IF v_rel.end_date < l_min_end_date_stack(v_rel.level+1) THEN
      l_min_end_date_stack(v_rel.level+1) := v_rel.end_date;
    END IF;

    IF v_rel.subject_id = p_subject_id THEN
      -- If the "date tunnel" in the path intersects with the current relationship
      -- then we have a circuit
      IF l_max_start_date_stack(v_rel.level+1) <= l_min_end_date_stack(v_rel.level+1)
         AND
         -- check if the tunnel intersects with current relationship
         l_max_start_date_stack(v_rel.level+1) <= p_end_date
         AND l_min_end_date_stack(v_rel.level+1) >= p_start_date
      THEN
        CLOSE c_parent;
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_CIRCULAR_REL');
        FND_MESSAGE.SET_TOKEN('RELTYPE', p_relationship_type);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;

  END LOOP;

  CLOSE c_parent;

END do_circularity_check;


/**
 * PRIVATE PROCEDURE enable_debug
 *
 * DESCRIPTION
 *     Turn on debug mode.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *     HZ_UTILITY_V2PUB.enable_debug
 *
 * MODIFICATION HISTORY
 *
 *   07-23-2001    Jianying Huang      o Created.
 *
 */

/*PROCEDURE enable_debug IS

BEGIN

    G_DEBUG_COUNT := G_DEBUG_COUNT + 1;

    IF G_DEBUG_COUNT = 1 THEN
        IF FND_PROFILE.value( 'HZ_API_FILE_DEBUG_ON' ) = 'Y' OR
           FND_PROFILE.value( 'HZ_API_DBMS_DEBUG_ON' ) = 'Y'
        THEN
           HZ_UTILITY_V2PUB.enable_debug;
           G_DEBUG := TRUE;
        END IF;
    END IF;

END enable_debug;
*/

/**
 * PRIVATE PROCEDURE disable_debug
 *
 * DESCRIPTION
 *     Turn off debug mode.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *     HZ_UTILITY_V2PUB.disable_debug
 *
 * MODIFICATION HISTORY
 *
 *   07-23-2001    Jianying Huang      o Created.
 *
 */

/*PROCEDURE disable_debug IS

BEGIN

    IF G_DEBUG THEN
        G_DEBUG_COUNT := G_DEBUG_COUNT - 1;

        IF G_DEBUG_COUNT = 0 THEN
            HZ_UTILITY_V2PUB.disable_debug;
            G_DEBUG := FALSE;
        END IF;
    END IF;

END disable_debug;
*/

/*===========================================================================+
 | PROCEDURE
 |              do_create_rel
 |
 | DESCRIPTION
 |              Creates relationship and party for party_relationship.
 |
 | SCOPE - PRIVATE
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                    p_create_party
 |              OUT:
 |                    x_party_relationship_id
 |                    x_party_id
 |                    x_party_number
 |          IN/ OUT:
 |                    p_party_rel_rec
 |                    x_return_status
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |
 |  19-FEB-2004   Rajib Ranjan Borah   o Bug 3306941.The meaning is to be
 |                                       displayed instead of the lookup_code
 |                                       in error message HZ_API_MULTIPLE_PARENT.
 |  04-JAN-2005   Rajib Ranjan Borah   o SSM SST Integration and Extension.
 |                                       For non-profile entities, the concept of select
 |                                       /de-select data-sources is obsoleted.
 +===========================================================================*/

PROCEDURE do_create_rel(
    p_relationship_rec         IN OUT NOCOPY RELATIONSHIP_REC_TYPE,
    x_created_party            OUT    NOCOPY     VARCHAR2,
    x_relationship_id          OUT    NOCOPY     NUMBER,
    x_party_id                 OUT    NOCOPY     NUMBER,
    x_party_number             OUT    NOCOPY     VARCHAR2,
    x_return_status            IN     OUT NOCOPY  VARCHAR2,
    p_create_org_contact       IN     VARCHAR2,
    p_contact_party_id         IN     NUMBER,
    p_contact_party_usage_code IN     VARCHAR2
) IS

    -- this cursor will uniquely identify a record
    -- in hz_relationship_types package
    CURSOR c_rel_type
    IS
    SELECT RELATIONSHIP_TYPE,
           FORWARD_REL_CODE,
           BACKWARD_REL_CODE,
           CREATE_PARTY_FLAG,
           ALLOW_RELATE_TO_SELF_FLAG,
           HIERARCHICAL_FLAG,
           ALLOW_CIRCULAR_RELATIONSHIPS,
           DIRECTION_CODE,
           RELATIONSHIP_TYPE_ID,
           NVL(MULTIPLE_PARENT_ALLOWED, 'N') MULTIPLE_PARENT_ALLOWED
    FROM   HZ_RELATIONSHIP_TYPES
    WHERE  RELATIONSHIP_TYPE = p_relationship_rec.relationship_type
    AND    FORWARD_REL_CODE = p_relationship_rec.relationship_code
    AND    SUBJECT_TYPE = p_relationship_rec.subject_type
    AND    OBJECT_TYPE = p_relationship_rec.object_type
    AND    STATUS = 'A';

    r_rel_type c_rel_type%ROWTYPE;

    l_relationship_id                 NUMBER := p_relationship_rec.relationship_id;
    l_rowid                           ROWID := NULL;
    l_count                           NUMBER;
    l_profile_id                      NUMBER;
    l_directional_flag                VARCHAR2(1);
    l_back_direction                  VARCHAR2(30);
    l_msg_count                       NUMBER;
    l_msg_data                        VARCHAR2(2000);
    l_end_date                        DATE;
    l_party_rel_rec                   RELATIONSHIP_REC_TYPE;
    l_dummy                           VARCHAR2(1) := 'Y';
    l_debug_prefix                    VARCHAR2(30) := '';
    l_hierarchy_rec                   HZ_HIERARCHY_PUB.HIERARCHY_NODE_REC_TYPE;
    l_parent_id                       NUMBER;
    l_parent_object_type              VARCHAR2(30);
    l_parent_table_name               VARCHAR2(30);
    l_child_id                        NUMBER;
    l_child_object_type               VARCHAR2(30);
    l_child_table_name                VARCHAR2(30);
    l_temp_parent_id                  NUMBER;
    l_temp_parent_table_name          VARCHAR2(30);
    l_temp_parent_object_type         VARCHAR2(30);
    l_parent_flag                     VARCHAR2(1);
    p_org_contact_rec                 HZ_PARTY_CONTACT_V2PUB.org_contact_rec_type;
    l_contact_number                  VARCHAR2(30) := p_org_contact_rec.contact_number;
    l_gen_contact_number              VARCHAR2(1);
    -- Bug 3306941.
    l_meaning                         VARCHAR2(80);

    l_party_usg_assignment_rec        HZ_PARTY_USG_ASSIGNMENT_PVT.party_usg_assignment_rec_type;
    l_party_usage_validation_level    NUMBER;
    TYPE t_number15_table IS TABLE OF NUMBER(15);
    TYPE t_varchar30_table IS TABLE OF VARCHAR2(30);
    l_party_id_tbl                    t_number15_table := t_number15_table();
    l_party_usage_code_tbl            t_varchar30_table := t_varchar30_table();

BEGIN

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'do_create_rel (+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- Generate primary key from sequence if not passed in. If this values already exists in
    -- the database, keep generating till a unique value is found.
    -- If primary key value is passed, check for uniqueness.

    IF l_relationship_id = FND_API.G_MISS_NUM
       OR
       l_relationship_id IS NULL
    THEN
        WHILE l_dummy = 'Y' LOOP
            BEGIN
                SELECT HZ_RELATIONSHIPS_S.NEXTVAL
                INTO   l_relationship_id
                FROM   DUAL;

                SELECT 'Y'
                INTO   l_dummy
                FROM   HZ_RELATIONSHIPS
                WHERE  RELATIONSHIP_ID = l_relationship_id
                AND    DIRECTIONAL_FLAG = 'F';

            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    l_dummy := 'N';
            END;
        END LOOP;

    ELSE
        BEGIN
            SELECT 'Y'
            INTO   l_dummy
            FROM   HZ_RELATIONSHIPS
            WHERE  RELATIONSHIP_ID = l_relationship_id
            AND    DIRECTIONAL_FLAG = 'F';

            FND_MESSAGE.SET_NAME('AR', 'HZ_API_DUPLICATE_COLUMN');
            FND_MESSAGE.SET_TOKEN('COLUMN', 'relationship_id');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;

        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                NULL;
        END;

    END IF;

    x_relationship_id := l_relationship_id;

    -- Debug info.
    IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_message=>'Obtained relationship_id : '||x_relationship_id,
                                  p_prefix =>l_debug_prefix,
                                  p_msg_level=>fnd_log.level_statement);
    END IF;


    -- validate the relationship record
    HZ_REGISTRY_VALIDATE_V2PUB.validate_relationship(
                                                   'C',
                                                   p_relationship_rec,
                                                   l_rowid,
                                                   x_return_status);

    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- default end date to 31-DEC-4712
    IF p_relationship_rec.end_date IS NULL
       OR
       p_relationship_rec.end_date = FND_API.G_MISS_DATE
    THEN
        l_end_date := to_date('31-12-4712 00:00:01', 'DD-MM-YYYY HH24:MI:SS');
    ELSE
        l_end_date := p_relationship_rec.end_date;
    END IF;

    -- Open the relationship_type record and get all the info
    OPEN c_rel_type;
    FETCH c_rel_type INTO r_rel_type;
    CLOSE c_rel_type;

    -- if no relationship type record found, then error out NOCOPY
    IF r_rel_type.relationship_type is null THEN
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_INVALID_FK');
        FND_MESSAGE.SET_TOKEN('FK', 'relationship_code, subject_type, object_type');
        FND_MESSAGE.SET_TOKEN('COLUMN', 'forward_rel_code, subject_type, object_type');
        FND_MESSAGE.SET_TOKEN('TABLE', 'hz_relationship_types');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- Debug info.
    IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_message=>'relationship type record found',
                                  p_prefix =>l_debug_prefix,
                                  p_msg_level=>fnd_log.level_statement);
    END IF;


    -- decide who is parent and who is child in this relationship.
    -- if relationship type record is 'P' type, then subject is parent, else object
    IF r_rel_type.direction_code = 'P' THEN
        l_parent_id := p_relationship_rec.subject_id;
        l_parent_table_name := p_relationship_rec.subject_table_name;
        l_parent_object_type := p_relationship_rec.subject_type;
        l_child_id := p_relationship_rec.object_id;
        l_child_table_name := p_relationship_rec.object_table_name;
        l_child_object_type := p_relationship_rec.object_type;
    ELSIF r_rel_type.direction_code = 'C' THEN
        l_parent_id := p_relationship_rec.object_id;
        l_parent_table_name := p_relationship_rec.object_table_name;
        l_parent_object_type := p_relationship_rec.object_type;
        l_child_id := p_relationship_rec.subject_id;
        l_child_table_name := p_relationship_rec.subject_table_name;
        l_child_object_type := p_relationship_rec.subject_type;
    END IF;

    -- if the relationship type is hierarchical, then we have to check
    -- whether there is already a parent present for the child in the same
    -- hierarchy/relationship type. if so, then we would not allow creation.
    IF r_rel_type.hierarchical_flag = 'Y' THEN
        -- it needs to be done if multiple_parent_allowed is 'N'
        IF r_rel_type.multiple_parent_allowed = 'N' THEN
            BEGIN
                SELECT 1 INTO l_count
                FROM   HZ_RELATIONSHIPS
                WHERE  OBJECT_ID = l_child_id
                AND    OBJECT_TABLE_NAME = l_child_table_name
                AND    OBJECT_TYPE = l_child_object_type
                AND    RELATIONSHIP_TYPE = p_relationship_rec.relationship_type
                AND    DIRECTION_CODE = 'P'
--  Bug 3817438 : Added condition to check only active relationships
                AND    STATUS= 'A'
                AND    (START_DATE BETWEEN NVL(p_relationship_rec.start_date, SYSDATE)
                                      AND NVL(p_relationship_rec.end_date, TO_DATE('31-12-4712 00:00:01', 'DD-MM-YYYY HH24:MI:SS'))
                       OR
                       END_DATE BETWEEN NVL(p_relationship_rec.start_date, SYSDATE)
                                      AND NVL(p_relationship_rec.end_date, TO_DATE('31-12-4712 00:00:01', 'DD-MM-YYYY HH24:MI:SS'))
                       OR
                       NVL(p_relationship_rec.start_date, SYSDATE) BETWEEN START_DATE AND END_DATE
                       OR
                       NVL(p_relationship_rec.end_date, TO_DATE('31-12-4712 00:00:01', 'DD-MM-YYYY HH24:MI:SS')) BETWEEN START_DATE AND END_DATE
                       )
-- Bug 3294936 : Added ROWNUM=1 condition
                AND ROWNUM=1;


                -- there is already a parent, so raise error
                --Bug 3306941.The meaning is to be displayed instead of the lookup_code.
                SELECT MEANING
                INTO   l_meaning
-- Bug 3664939 : Use fnd_lookup_values_vl to get lookup meaning
                FROM   FND_LOOKUP_VALUES_VL
                WHERE  LOOKUP_TYPE = 'HZ_RELATIONSHIP_TYPE'
                AND    LOOKUP_CODE = p_relationship_rec.relationship_type
                AND    VIEW_APPLICATION_ID = 222
                AND    ROWNUM =1;

                FND_MESSAGE.SET_NAME('AR', 'HZ_API_MULTIPLE_PARENT');
                FND_MESSAGE.SET_TOKEN('RELTYPE', l_meaning);
                FND_MSG_PUB.ADD;
                RAISE FND_API.G_EXC_ERROR;

            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    -- no parent found, proceed
                    NULL;
            END;
        END IF;
    END IF;



    -- Bug 2797506 begin.  Circularity check logic is in a new procedure.

    IF r_rel_type.hierarchical_flag = 'Y' OR r_rel_type.allow_circular_relationships = 'N'
    THEN
      -- check for circularity.  This procedure will raise exception if found.
      do_circularity_check(
        p_relationship_id      => NULL,  -- relationship has not been created yet!
        p_relationship_type    => r_rel_type.relationship_type,
        p_start_date           => NVL(p_relationship_rec.start_date, SYSDATE),
        p_end_date             => NVL(p_relationship_rec.end_date, TO_DATE('31-12-4712 00:00:01', 'DD-MM-YYYY HH24:MI:SS')),
        p_subject_id           => l_child_id,
        p_object_id            => l_parent_id,
        p_object_type          => l_parent_object_type,
        p_object_table_name    => l_parent_table_name
      );
    END IF;

    -- Bug 2797506 end.

      -- subject_id and object_id must not have the same value, unless relationship type allows
    IF r_rel_type.allow_relate_to_self_flag = 'N'
       AND
       p_relationship_rec.subject_id = p_relationship_rec.object_id
    THEN
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_SUBJECT_OBJECT_IDS');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- build the record for creation of relationship party record
    l_party_rel_rec.party_rec := p_relationship_rec.party_rec;
    l_party_rel_rec.subject_id := p_relationship_rec.subject_id;
    l_party_rel_rec.object_id := p_relationship_rec.object_id;
    l_party_rel_rec.created_by_module := p_relationship_rec.created_by_module;
    l_party_rel_rec.application_id := p_relationship_rec.application_id;

    -- the PARTY_RELATIONSHIP type party will be created if
    -- the relationship type has create_party_flag = 'Y' and
    -- both the subject_table_name and object_table_name are
    -- 'HZ_PARTIES'
    IF r_rel_type.create_party_flag = 'Y'
       AND
       p_relationship_rec.subject_table_name = 'HZ_PARTIES'
       AND
       p_relationship_rec.object_table_name = 'HZ_PARTIES'
    THEN

        -- Debug info.
        IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_message=>'creating relationship party',
                                  p_prefix =>l_debug_prefix,
                                  p_msg_level=>fnd_log.level_statement);
        END IF;


        x_created_party := 'Y';
        do_create_party(
            p_party_type       => 'PARTY_RELATIONSHIP',
            p_relationship_rec => l_party_rel_rec,
            x_party_id         => x_party_id,
            x_party_number     => x_party_number,
            x_profile_id       => l_profile_id,
            x_return_status    => x_return_status
           );
        p_relationship_rec.party_rec.party_id := x_party_id;
        p_relationship_rec.party_rec.party_number := x_party_number;

    ELSE
        x_created_party := 'N';
    END IF;

    -- Denormalize flags to HZ_PARTIES:
    --      COMPETITOR_FLAG
    --      REFERENCE_USE_FLAG
    --      THIRD_PARTY_FLAG
    -- Denormalization will be done only if content_source_type
    -- is 'USER_ENTERED' and both subject_table_name and
    -- object_table_name are 'HZ_PARTIES'

    -- Bug 2197181: added for mix-n-match project. Denormalize
    -- the three flags when the data source is visible (i.e.
    -- selected).

    -- SSM SST Integration and Extension
    -- For non-profile entities, the concept of select/de-select data-sources is obsoleted.
    -- There is no need to check if the data-source is selected.

    IF p_relationship_rec.relationship_code IN
             ('COMPETITOR_OF', 'REFERENCE_FOR', 'PARTNER_OF') AND
     /*  g_rel_is_datasource_selected = 'Y' AND */
       /*
       (p_relationship_rec.content_source_type = 'USER_ENTERED'
        OR
        p_relationship_rec.content_source_type IS NULL
       )
       */
       p_relationship_rec.subject_table_name = 'HZ_PARTIES'
       AND
       p_relationship_rec.object_table_name = 'HZ_PARTIES'
    THEN

        -- Debug info.
        IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_message=>'denormalizing to hz_parties',
                                  p_prefix =>l_debug_prefix,
                                  p_msg_level=>fnd_log.level_statement);
       END IF;


        do_update_party_flags(
                              p_relationship_rec,
                              p_relationship_rec.subject_id);
    END IF;

    p_relationship_rec.relationship_id := l_relationship_id;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'HZ_RELATIONSHIPS_PKG.Insert_Row-1 (+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- Call table-handler to create the forward record.
    HZ_RELATIONSHIPS_PKG.Insert_Row (
        X_RELATIONSHIP_ID                       => p_relationship_rec.relationship_id,
        X_SUBJECT_ID                            => p_relationship_rec.subject_id,
        X_SUBJECT_TYPE                          => p_relationship_rec.subject_type,
        X_SUBJECT_TABLE_NAME                    => p_relationship_rec.subject_table_name,
        X_OBJECT_ID                             => p_relationship_rec.object_id,
        X_OBJECT_TYPE                           => p_relationship_rec.object_type,
        X_OBJECT_TABLE_NAME                     => p_relationship_rec.object_table_name,
        X_PARTY_ID                              => x_party_id,
        X_RELATIONSHIP_CODE                     => p_relationship_rec.relationship_code,
        X_DIRECTIONAL_FLAG                      => 'F',
        X_COMMENTS                              => p_relationship_rec.comments,
        X_START_DATE                            => p_relationship_rec.start_date,
        X_END_DATE                              => l_end_date,
        X_STATUS                                => p_relationship_rec.status,
        X_ATTRIBUTE_CATEGORY                    => p_relationship_rec.attribute_category,
        X_ATTRIBUTE1                            => p_relationship_rec.attribute1,
        X_ATTRIBUTE2                            => p_relationship_rec.attribute2,
        X_ATTRIBUTE3                            => p_relationship_rec.attribute3,
        X_ATTRIBUTE4                            => p_relationship_rec.attribute4,
        X_ATTRIBUTE5                            => p_relationship_rec.attribute5,
        X_ATTRIBUTE6                            => p_relationship_rec.attribute6,
        X_ATTRIBUTE7                            => p_relationship_rec.attribute7,
        X_ATTRIBUTE8                            => p_relationship_rec.attribute8,
        X_ATTRIBUTE9                            => p_relationship_rec.attribute9,
        X_ATTRIBUTE10                           => p_relationship_rec.attribute10,
        X_ATTRIBUTE11                           => p_relationship_rec.attribute11,
        X_ATTRIBUTE12                           => p_relationship_rec.attribute12,
        X_ATTRIBUTE13                           => p_relationship_rec.attribute13,
        X_ATTRIBUTE14                           => p_relationship_rec.attribute14,
        X_ATTRIBUTE15                           => p_relationship_rec.attribute15,
        X_ATTRIBUTE16                           => p_relationship_rec.attribute16,
        X_ATTRIBUTE17                           => p_relationship_rec.attribute17,
        X_ATTRIBUTE18                           => p_relationship_rec.attribute18,
        X_ATTRIBUTE19                           => p_relationship_rec.attribute19,
        X_ATTRIBUTE20                           => p_relationship_rec.attribute20,
        X_CONTENT_SOURCE_TYPE                   => p_relationship_rec.content_source_type,
        X_RELATIONSHIP_TYPE                     => p_relationship_rec.relationship_type,
        X_OBJECT_VERSION_NUMBER                 => 1,
        X_CREATED_BY_MODULE                     => p_relationship_rec.created_by_module,
        X_APPLICATION_ID                        => p_relationship_rec.application_id,
        X_ADDITIONAL_INFORMATION1               => p_relationship_rec.additional_information1,
        X_ADDITIONAL_INFORMATION2               => p_relationship_rec.additional_information2,
        X_ADDITIONAL_INFORMATION3               => p_relationship_rec.additional_information3,
        X_ADDITIONAL_INFORMATION4               => p_relationship_rec.additional_information4,
        X_ADDITIONAL_INFORMATION5               => p_relationship_rec.additional_information5,
        X_ADDITIONAL_INFORMATION6               => p_relationship_rec.additional_information6,
        X_ADDITIONAL_INFORMATION7               => p_relationship_rec.additional_information7,
        X_ADDITIONAL_INFORMATION8               => p_relationship_rec.additional_information8,
        X_ADDITIONAL_INFORMATION9               => p_relationship_rec.additional_information9,
        X_ADDITIONAL_INFORMATION10               => p_relationship_rec.additional_information10,
        X_ADDITIONAL_INFORMATION11               => p_relationship_rec.additional_information11,
        X_ADDITIONAL_INFORMATION12               => p_relationship_rec.additional_information12,
        X_ADDITIONAL_INFORMATION13               => p_relationship_rec.additional_information13,
        X_ADDITIONAL_INFORMATION14               => p_relationship_rec.additional_information14,
        X_ADDITIONAL_INFORMATION15               => p_relationship_rec.additional_information15,
        X_ADDITIONAL_INFORMATION16               => p_relationship_rec.additional_information16,
        X_ADDITIONAL_INFORMATION17               => p_relationship_rec.additional_information17,
        X_ADDITIONAL_INFORMATION18               => p_relationship_rec.additional_information18,
        X_ADDITIONAL_INFORMATION19               => p_relationship_rec.additional_information19,
        X_ADDITIONAL_INFORMATION20               => p_relationship_rec.additional_information20,
        X_ADDITIONAL_INFORMATION21               => p_relationship_rec.additional_information21,
        X_ADDITIONAL_INFORMATION22               => p_relationship_rec.additional_information22,
        X_ADDITIONAL_INFORMATION23               => p_relationship_rec.additional_information23,
        X_ADDITIONAL_INFORMATION24               => p_relationship_rec.additional_information24,
        X_ADDITIONAL_INFORMATION25               => p_relationship_rec.additional_information25,
        X_ADDITIONAL_INFORMATION26               => p_relationship_rec.additional_information26,
        X_ADDITIONAL_INFORMATION27               => p_relationship_rec.additional_information27,
        X_ADDITIONAL_INFORMATION28               => p_relationship_rec.additional_information28,
        X_ADDITIONAL_INFORMATION29               => p_relationship_rec.additional_information29,
        X_ADDITIONAL_INFORMATION30               => p_relationship_rec.additional_information30,
        X_DIRECTION_CODE                         => r_rel_type.direction_code,
        X_PERCENTAGE_OWNERSHIP                   => p_relationship_rec.percentage_ownership,
        X_ACTUAL_CONTENT_SOURCE                  => p_relationship_rec.actual_content_source
    );

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'HZ_RELATIONSHIPS_PKG.Insert_Row-1 (-) ' ||
            'x_relationship_id = ' || p_relationship_rec.relationship_id,
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'HZ_RELATIONSHIPS_PKG.Insert_Row-2 (+) ',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- determine the direction_code for the backward record
    IF r_rel_type.direction_code = 'P' THEN
        l_back_direction := 'C';
    ELSIF r_rel_type.direction_code = 'C' THEN
        l_back_direction := 'P';
    ELSE
        l_back_direction := 'N';
    END IF;

    -- Call table-handler again to create the backward record.
    -- This is done because for every relationship we want to
    -- create both forward and backward relationship.
    HZ_RELATIONSHIPS_PKG.Insert_Row (
        X_RELATIONSHIP_ID                       => p_relationship_rec.relationship_id,
        X_SUBJECT_ID                            => p_relationship_rec.object_id,
        X_SUBJECT_TYPE                          => p_relationship_rec.object_type,
        X_SUBJECT_TABLE_NAME                    => p_relationship_rec.object_table_name,
        X_OBJECT_ID                             => p_relationship_rec.subject_id,
        X_OBJECT_TYPE                           => p_relationship_rec.subject_type,
        X_OBJECT_TABLE_NAME                     => p_relationship_rec.subject_table_name,
        X_PARTY_ID                              => x_party_id,
        X_RELATIONSHIP_CODE                     => r_rel_type.backward_rel_code,
        X_DIRECTIONAL_FLAG                      => 'B',
        X_COMMENTS                              => p_relationship_rec.comments,
        X_START_DATE                            => p_relationship_rec.start_date,
        X_END_DATE                              => l_end_date,
        X_STATUS                                => p_relationship_rec.status,
        X_ATTRIBUTE_CATEGORY                    => p_relationship_rec.attribute_category,
        X_ATTRIBUTE1                            => p_relationship_rec.attribute1,
        X_ATTRIBUTE2                            => p_relationship_rec.attribute2,
        X_ATTRIBUTE3                            => p_relationship_rec.attribute3,
        X_ATTRIBUTE4                            => p_relationship_rec.attribute4,
        X_ATTRIBUTE5                            => p_relationship_rec.attribute5,
        X_ATTRIBUTE6                            => p_relationship_rec.attribute6,
        X_ATTRIBUTE7                            => p_relationship_rec.attribute7,
        X_ATTRIBUTE8                            => p_relationship_rec.attribute8,
        X_ATTRIBUTE9                            => p_relationship_rec.attribute9,
        X_ATTRIBUTE10                           => p_relationship_rec.attribute10,
        X_ATTRIBUTE11                           => p_relationship_rec.attribute11,
        X_ATTRIBUTE12                           => p_relationship_rec.attribute12,
        X_ATTRIBUTE13                           => p_relationship_rec.attribute13,
        X_ATTRIBUTE14                           => p_relationship_rec.attribute14,
        X_ATTRIBUTE15                           => p_relationship_rec.attribute15,
        X_ATTRIBUTE16                           => p_relationship_rec.attribute16,
        X_ATTRIBUTE17                           => p_relationship_rec.attribute17,
        X_ATTRIBUTE18                           => p_relationship_rec.attribute18,
        X_ATTRIBUTE19                           => p_relationship_rec.attribute19,
        X_ATTRIBUTE20                           => p_relationship_rec.attribute20,
        X_CONTENT_SOURCE_TYPE                   => p_relationship_rec.content_source_type,
        X_RELATIONSHIP_TYPE                     => r_rel_type.relationship_type,
        X_OBJECT_VERSION_NUMBER                 => 1,
        X_CREATED_BY_MODULE                     => p_relationship_rec.created_by_module,
        X_APPLICATION_ID                        => p_relationship_rec.application_id,
        X_ADDITIONAL_INFORMATION1               => p_relationship_rec.additional_information1,
        X_ADDITIONAL_INFORMATION2               => p_relationship_rec.additional_information2,
        X_ADDITIONAL_INFORMATION3               => p_relationship_rec.additional_information3,
        X_ADDITIONAL_INFORMATION4               => p_relationship_rec.additional_information4,
        X_ADDITIONAL_INFORMATION5               => p_relationship_rec.additional_information5,
        X_ADDITIONAL_INFORMATION6               => p_relationship_rec.additional_information6,
        X_ADDITIONAL_INFORMATION7               => p_relationship_rec.additional_information7,
        X_ADDITIONAL_INFORMATION8               => p_relationship_rec.additional_information8,
        X_ADDITIONAL_INFORMATION9               => p_relationship_rec.additional_information9,
        X_ADDITIONAL_INFORMATION10               => p_relationship_rec.additional_information10,
        X_ADDITIONAL_INFORMATION11               => p_relationship_rec.additional_information11,
        X_ADDITIONAL_INFORMATION12               => p_relationship_rec.additional_information12,
        X_ADDITIONAL_INFORMATION13               => p_relationship_rec.additional_information13,
        X_ADDITIONAL_INFORMATION14               => p_relationship_rec.additional_information14,
        X_ADDITIONAL_INFORMATION15               => p_relationship_rec.additional_information15,
        X_ADDITIONAL_INFORMATION16               => p_relationship_rec.additional_information16,
        X_ADDITIONAL_INFORMATION17               => p_relationship_rec.additional_information17,
        X_ADDITIONAL_INFORMATION18               => p_relationship_rec.additional_information18,
        X_ADDITIONAL_INFORMATION19               => p_relationship_rec.additional_information19,
        X_ADDITIONAL_INFORMATION20               => p_relationship_rec.additional_information20,
        X_ADDITIONAL_INFORMATION21               => p_relationship_rec.additional_information21,
        X_ADDITIONAL_INFORMATION22               => p_relationship_rec.additional_information22,
        X_ADDITIONAL_INFORMATION23               => p_relationship_rec.additional_information23,
        X_ADDITIONAL_INFORMATION24               => p_relationship_rec.additional_information24,
        X_ADDITIONAL_INFORMATION25               => p_relationship_rec.additional_information25,
        X_ADDITIONAL_INFORMATION26               => p_relationship_rec.additional_information26,
        X_ADDITIONAL_INFORMATION27               => p_relationship_rec.additional_information27,
        X_ADDITIONAL_INFORMATION28               => p_relationship_rec.additional_information28,
        X_ADDITIONAL_INFORMATION29               => p_relationship_rec.additional_information29,
        X_ADDITIONAL_INFORMATION30               => p_relationship_rec.additional_information30,
        X_DIRECTION_CODE                         => l_back_direction,
        X_PERCENTAGE_OWNERSHIP                   => p_relationship_rec.percentage_ownership,
        X_ACTUAL_CONTENT_SOURCE                  => p_relationship_rec.actual_content_source
    );

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'HZ_RELATIONSHIPS_PKG.Insert_Row-2 (-) ' ||
                                 'x_relationship_id = ' || p_relationship_rec.relationship_id,
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- maintain hierarchy of relationships
    -- check if the relationship type is hierarchical
    IF r_rel_type.hierarchical_flag = 'Y' THEN
        -- check if relationship type is parent one
        IF r_rel_type.direction_code = 'P' THEN
            -- assign the subject to parent for hierarchy
            l_hierarchy_rec.hierarchy_type := r_rel_type.relationship_type;
            l_hierarchy_rec.parent_id := p_relationship_rec.subject_id;
            l_hierarchy_rec.parent_table_name := p_relationship_rec.subject_table_name;
            l_hierarchy_rec.parent_object_type := p_relationship_rec.subject_type;
            l_hierarchy_rec.child_id := p_relationship_rec.object_id;
            l_hierarchy_rec.child_table_name := p_relationship_rec.object_table_name;
            l_hierarchy_rec.child_object_type := p_relationship_rec.object_type;
            l_hierarchy_rec.effective_start_date := NVL(p_relationship_rec.start_date,SYSDATE);
            l_hierarchy_rec.effective_end_date := l_end_date;
            l_hierarchy_rec.relationship_id := p_relationship_rec.relationship_id;
            l_hierarchy_rec.status := NVL(p_relationship_rec.status, 'A');
        ELSIF r_rel_type.direction_code = 'C' THEN
            -- assign the object to parent
            l_hierarchy_rec.hierarchy_type := r_rel_type.relationship_type;
            l_hierarchy_rec.parent_id := p_relationship_rec.object_id;
            l_hierarchy_rec.parent_table_name := p_relationship_rec.object_table_name;
            l_hierarchy_rec.parent_object_type := p_relationship_rec.object_type;
            l_hierarchy_rec.child_id := p_relationship_rec.subject_id;
            l_hierarchy_rec.child_table_name := p_relationship_rec.subject_table_name;
            l_hierarchy_rec.child_object_type := p_relationship_rec.subject_type;
/* Put in the NVL since otherwise insert to hz_hierarchy_nodes was failing */
            l_hierarchy_rec.effective_start_date := NVL(p_relationship_rec.start_date,SYSDATE);
            l_hierarchy_rec.effective_end_date := l_end_date;
            l_hierarchy_rec.relationship_id := p_relationship_rec.relationship_id;
            l_hierarchy_rec.status := NVL(p_relationship_rec.status, 'A');
        END IF;

        HZ_HIERARCHY_PUB.create_link(
            p_init_msg_list           => FND_API.G_FALSE,
            p_hierarchy_node_rec      => l_hierarchy_rec,
            x_return_status           => x_return_status,
            x_msg_count               => l_msg_count,
            x_msg_data                => l_msg_data
           );

        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
            ELSE
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
        END IF;

    END IF;
/*****************************************************************************
                      Create Org Contact
*****************************************************************************/
-- Check whether the relationship has SUBJECT_TYPE = 'PERSON' or OBJECTTYPE = 'PERSON'
-- and the other entity is a 'PERSON' or 'ORGANIZATION' or 'GROUP'.

IF ( ((p_relationship_rec.object_type  = 'PERSON' AND
       p_relationship_rec.subject_type IN ('ORGANIZATION','PERSON','GROUP')) OR
     (p_relationship_rec.subject_type =  'PERSON' AND
       p_relationship_rec.object_type IN ('ORGANIZATION','GROUP')))
     OR
     ((p_relationship_rec.object_type  = 'ORGANIZATION' AND
      p_relationship_rec.subject_type IN ('ORGANIZATION','PERSON','GROUP')) OR
     (p_relationship_rec.subject_type =  'ORGANIZATION' AND
      p_relationship_rec.object_type IN ('PERSON','GROUP')))
    OR
     ((p_relationship_rec.object_type  = 'GROUP' AND
      p_relationship_rec.subject_type IN ('ORGANIZATION','PERSON','GROUP')) OR
     (p_relationship_rec.subject_type =  'GROUP' AND
      p_relationship_rec.object_type IN ('PERSON','ORGANIZATION')))
   )
THEN
   IF p_create_org_contact = 'Y' THEN
      IF l_contact_number = FND_API.G_MISS_CHAR OR l_contact_number IS NULL THEN
            l_count := 1;
            WHILE l_count > 0 LOOP
                SELECT to_char(hz_contact_numbers_s.nextval)
                INTO l_contact_number FROM dual;

                BEGIN
                    SELECT 1
                    INTO   l_count
                    FROM   HZ_ORG_CONTACTS
                    WHERE  CONTACT_NUMBER = l_contact_number;
                    l_count := 1;

                EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                        l_count := 0;
                END;

            END LOOP;
        END IF;
        p_org_contact_rec.created_by_module    := p_relationship_rec.created_by_module;
        p_org_contact_rec.application_id       := p_relationship_rec.application_id;
        p_org_contact_rec.party_rel_rec.status := p_relationship_rec.status;
        p_org_contact_rec.contact_number       := l_contact_number;
    HZ_ORG_CONTACTS_PKG.Insert_Row (
        X_ORG_CONTACT_ID                        => p_org_contact_rec.org_contact_id,
        X_PARTY_RELATIONSHIP_ID                 => p_relationship_rec.relationship_id,
        X_COMMENTS                              => p_org_contact_rec.comments,
        X_CONTACT_NUMBER                        => p_org_contact_rec.contact_number,
        X_DEPARTMENT_CODE                       => p_org_contact_rec.department_code,
        X_DEPARTMENT                            => p_org_contact_rec.department,
        X_TITLE                                 => p_org_contact_rec.title,
        X_JOB_TITLE                             => p_org_contact_rec.job_title,
        X_DECISION_MAKER_FLAG                   => p_org_contact_rec.decision_maker_flag,
        X_JOB_TITLE_CODE                        => p_org_contact_rec.job_title_code,
        X_REFERENCE_USE_FLAG                    => p_org_contact_rec.reference_use_flag,
        X_RANK                                  => p_org_contact_rec.rank,
        X_ORIG_SYSTEM_REFERENCE                 => p_org_contact_rec.orig_system_reference,
        X_ATTRIBUTE_CATEGORY                    => p_org_contact_rec.attribute_category,
        X_ATTRIBUTE1                            => p_org_contact_rec.attribute1,
        X_ATTRIBUTE2                            => p_org_contact_rec.attribute2,
        X_ATTRIBUTE3                            => p_org_contact_rec.attribute3,
        X_ATTRIBUTE4                            => p_org_contact_rec.attribute4,
        X_ATTRIBUTE5                            => p_org_contact_rec.attribute5,
        X_ATTRIBUTE6                            => p_org_contact_rec.attribute6,
        X_ATTRIBUTE7                            => p_org_contact_rec.attribute7,
        X_ATTRIBUTE8                            => p_org_contact_rec.attribute8,
        X_ATTRIBUTE9                            => p_org_contact_rec.attribute9,
        X_ATTRIBUTE10                           => p_org_contact_rec.attribute10,
        X_ATTRIBUTE11                           => p_org_contact_rec.attribute11,
        X_ATTRIBUTE12                           => p_org_contact_rec.attribute12,
        X_ATTRIBUTE13                           => p_org_contact_rec.attribute13,
        X_ATTRIBUTE14                           => p_org_contact_rec.attribute14,
        X_ATTRIBUTE15                           => p_org_contact_rec.attribute15,
        X_ATTRIBUTE16                           => p_org_contact_rec.attribute16,
        X_ATTRIBUTE17                           => p_org_contact_rec.attribute17,
        X_ATTRIBUTE18                           => p_org_contact_rec.attribute18,
        X_ATTRIBUTE19                           => p_org_contact_rec.attribute19,
        X_ATTRIBUTE20                           => p_org_contact_rec.attribute20,
        X_ATTRIBUTE21                           => p_org_contact_rec.attribute21,
        X_ATTRIBUTE22                           => p_org_contact_rec.attribute22,
        X_ATTRIBUTE23                           => p_org_contact_rec.attribute23,
        X_ATTRIBUTE24                           => p_org_contact_rec.attribute24,
        X_PARTY_SITE_ID                         => p_org_contact_rec.party_site_id,
        X_OBJECT_VERSION_NUMBER                 => 1,
        X_CREATED_BY_MODULE                     => p_org_contact_rec.created_by_module,
        X_APPLICATION_ID                        => p_org_contact_rec.application_id,
        X_STATUS                                => p_org_contact_rec.party_rel_rec.status
    );

      IF(HZ_UTILITY_V2PUB.G_EXECUTE_API_CALLOUTS in ('EVENTS_ENABLED', 'Y')) THEN
        -- Invoke business event system.
        HZ_BUSINESS_EVENT_V2PVT.create_org_contact_event (p_org_contact_rec);
      END IF;

      IF(HZ_UTILITY_V2PUB.G_EXECUTE_API_CALLOUTS in ('EVENTS_ENABLED', 'BO_EVENTS_ENABLED')) THEN
        IF(p_relationship_rec.subject_type  = 'PERSON' AND p_relationship_rec.object_type = 'ORGANIZATION') THEN
          HZ_POPULATE_BOT_PKG.pop_hz_org_contacts(
            p_operation      => 'I',
            p_org_contact_id => p_org_contact_rec.org_contact_id);
        END IF;
      END IF;

   -- Call to indicate Org Contact creation to DQM
      HZ_DQM_SYNC.sync_contact(p_org_contact_rec.org_contact_id, 'C');

   END IF;
END IF;


    --
    -- added for R12 party usage project
    --
    IF (p_relationship_rec.subject_type = 'PERSON' AND
        p_relationship_rec.object_type IN ('PERSON', 'ORGANIZATION') OR
        p_relationship_rec.object_type = 'PERSON' AND
        p_relationship_rec.subject_type IN ('PERSON', 'ORGANIZATION')) AND
       p_relationship_rec.subject_table_name = 'HZ_PARTIES' AND
       p_relationship_rec.object_table_name = 'HZ_PARTIES'
    THEN
      IF (p_contact_party_id IS NOT NULL AND
          p_contact_party_id <> FND_API.G_MISS_NUM AND
          (p_contact_party_usage_code IS NULL OR
           p_contact_party_usage_code = FND_API.G_MISS_CHAR)) OR
         (p_contact_party_usage_code IS NOT NULL AND
          p_contact_party_usage_code <> FND_API.G_MISS_CHAR AND
          (p_contact_party_id IS NULL OR
           p_contact_party_id = FND_API.G_MISS_NUM))
      THEN
        fnd_message.set_name('AR', 'HZ_PU_REL_MISSING_COLUMN');
        fnd_msg_pub.add;
        RAISE FND_API.G_EXC_ERROR;
      ELSIF p_contact_party_id IS NOT NULL AND
            (p_contact_party_id <> p_relationship_rec.subject_id AND
             p_contact_party_id <> p_relationship_rec.object_id OR
             p_contact_party_id = p_relationship_rec.subject_id AND
             p_relationship_rec.subject_type <> 'PERSON' OR
             p_contact_party_id = p_relationship_rec.object_id AND
             p_relationship_rec.object_type <> 'PERSON')
      THEN
        fnd_message.set_name('AR', 'HZ_PU_REL_INVALID_CONTACT_ID');
        fnd_msg_pub.add;
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      l_party_id_tbl.extend(1);
      l_party_usage_code_tbl.extend(1);

      IF p_contact_party_usage_code IS NOT NULL THEN
        l_party_id_tbl(1) := p_contact_party_id;
        l_party_usage_code_tbl(1) := p_contact_party_usage_code;
        l_party_usg_assignment_rec.created_by_module := p_relationship_rec.created_by_module;
        l_party_usage_validation_level := HZ_PARTY_USG_ASSIGNMENT_PVT.G_VALID_LEVEL_MEDIUM;
      ELSE
        l_party_usage_code_tbl(1) := 'ORG_CONTACT';
        l_party_usg_assignment_rec.created_by_module := 'TCA_V2_API';
        l_party_usage_validation_level := HZ_PARTY_USG_ASSIGNMENT_PVT.G_VALID_LEVEL_LOW;

        IF p_relationship_rec.subject_type = 'PERSON' AND
           p_relationship_rec.object_type = 'ORGANIZATION'
        THEN
          l_party_id_tbl(1) := p_relationship_rec.subject_id;
        ELSIF p_relationship_rec.subject_type = 'ORGANIZATION' AND
              p_relationship_rec.object_type = 'PERSON'
        THEN
          l_party_id_tbl(1) := p_relationship_rec.object_id;
        ELSIF p_relationship_rec.subject_type = 'PERSON' AND
              p_relationship_rec.object_type = 'PERSON'
        THEN
          l_party_id_tbl(1) := p_relationship_rec.subject_id;
          l_party_usage_code_tbl(1) := 'RELATED_PERSON';

          IF p_relationship_rec.subject_id <> p_relationship_rec.object_id THEN
            l_party_id_tbl.extend(1);
            l_party_usage_code_tbl.extend(1);
            l_party_id_tbl(2) := p_relationship_rec.object_id;
            l_party_usage_code_tbl(2) := 'RELATED_PERSON';
          END IF;
        END IF;
      END IF;

      l_party_usg_assignment_rec.owner_table_name := 'HZ_RELATIONSHIPS';
      l_party_usg_assignment_rec.owner_table_id := p_relationship_rec.relationship_id;
      l_party_usg_assignment_rec.effective_start_date := p_relationship_rec.start_date;
      l_party_usg_assignment_rec.effective_end_date := p_relationship_rec.end_date;

      IF p_relationship_rec.status = 'I' THEN
        IF p_relationship_rec.start_date IS NULL OR
           p_relationship_rec.start_date = fnd_api.g_miss_date OR
           trunc(p_relationship_rec.start_date) > trunc(sysdate)
        THEN
          l_party_usg_assignment_rec.effective_start_date := trunc(sysdate);
        END IF;

        IF p_relationship_rec.end_date IS NULL OR
           p_relationship_rec.end_date = fnd_api.g_miss_date OR
           trunc(p_relationship_rec.end_date) > trunc(sysdate)
        THEN
          l_party_usg_assignment_rec.effective_end_date := trunc(sysdate);
        END IF;
      END IF;

      FOR i IN 1..l_party_usage_code_tbl.count LOOP
        l_party_usg_assignment_rec.party_id := l_party_id_tbl(i);
        l_party_usg_assignment_rec.party_usage_code := l_party_usage_code_tbl(i);

        HZ_PARTY_USG_ASSIGNMENT_PVT.assign_party_usage (
          p_validation_level          => l_party_usage_validation_level,
          p_party_usg_assignment_rec  => l_party_usg_assignment_rec,
          x_return_status             => x_return_status,
          x_msg_count                 => l_msg_count,
          x_msg_data                  => l_msg_data
        );

        IF x_return_status <> fnd_api.g_ret_sts_success THEN
          RAISE fnd_api.g_exc_error;
        END IF;
      END LOOP;
    END IF;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'do_create_rel (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

END do_create_rel;

/*===========================================================================+
 | PROCEDURE
 |              do_update_rel
 |
 | DESCRIPTION
 |              Updates relationship and party for party_relationship.
 |
 | SCOPE - PRIVATE
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |             OUT:
 |          IN/OUT:
 |                    p_party_rel_rec
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |   09-DEC-2003   Rajib Ranjan Borah  o Bug 3274236.Start date and end date were not
 |                                       getting updated if the user passed FND_API.G_MISS_CHAR.
 |                                     o Modified some previous code to remove redundancy.
 |   19-FEB-2004   Rajib Ranjan Borah  o Bug 3306941.The meaning should be passed as token
 |                                       for the error message HZ_API_MULTIPLE_PARENT  instead
 |                                       of the relationsihp_type.
 |  04-JAN-2005   Rajib Ranjan Borah   o SSM SST Integration and Extension.
 |                                       For non-profile entities, the concept of select
 |                                       /de-select data-sources is obsoleted.
 |  17-FEB-2009   Sudhir Gokavarapu    o Bug8241997 :l_party_id was not containing proper value
 |                                       of Party Id. Getting it from Old Relation Record istead
 |                                       of present Record.
 +===========================================================================*/

PROCEDURE do_update_rel(
    p_relationship_rec              IN OUT  NOCOPY RELATIONSHIP_REC_TYPE,
    p_old_relationship_rec          IN      RELATIONSHIP_REC_TYPE,
    p_object_version_number         IN OUT NOCOPY  NUMBER,
    p_party_object_version_number   IN OUT NOCOPY  NUMBER,
    x_return_status                 IN OUT NOCOPY  VARCHAR2
) IS

    l_object_version_number                          NUMBER;
    l_party_object_version_number                    NUMBER;
    l_rowid                                          ROWID;
--    l_party_id                                       NUMBER := p_relationship_rec.party_rec.party_id;
    l_party_id                                       NUMBER := p_old_relationship_rec.party_rec.party_id;
    l_profile_id                                     NUMBER;
    l_rel_rec                                        RELATIONSHIP_REC_TYPE ;
    l_organization_rec                               HZ_PARTY_V2PUB.ORGANIZATION_REC_TYPE;
    l_group_rec                                      HZ_PARTY_V2PUB.GROUP_REC_TYPE;
    l_person_rec                                     HZ_PARTY_V2PUB.PERSON_REC_TYPE;
    l_party_rel_rec                                  RELATIONSHIP_REC_TYPE := p_relationship_rec;
    l_old_rel_rec                                    RELATIONSHIP_REC_TYPE;
    l_msg_count                                      NUMBER;
    l_msg_data                                       VARCHAR2(2000);
    l_content_source_type                            VARCHAR2(30);
    l_subject_table_name                             VARCHAR2(30);
    l_object_table_name                              VARCHAR2(30);
    l_debug_prefix                                   VARCHAR2(30) := '';
    l_subject_id                                     NUMBER;
    l_object_id                                      NUMBER;
    l_relationship_code                              VARCHAR2(30);
    l_start_date                                     DATE;
    l_end_date                                       DATE;
    l_relationship_type                              VARCHAR2(30);
    l_hierarchical_flag                              VARCHAR2(1) := 'N';
    l_direction_code                                 VARCHAR2(30);
    l_subject_type                                   VARCHAR2(30);
    l_object_type                                    VARCHAR2(30);
    l_status                                         VARCHAR2(1);
    l_hierarchy_rec                                  HZ_HIERARCHY_PUB.HIERARCHY_NODE_REC_TYPE;
    l_allow_circular_relationships                   VARCHAR2(1);
    l_mult_parent_allowed                            VARCHAR2(1);
    l_parent_id                                      NUMBER;
    l_parent_object_type                             VARCHAR2(30);
    l_parent_table_name                              VARCHAR2(30);
    l_child_id                                       NUMBER;
    l_child_object_type                              VARCHAR2(30);
    l_child_table_name                               VARCHAR2(30);
    l_temp_parent_id                                 NUMBER;
    l_temp_parent_table_name                         VARCHAR2(30);
    l_temp_parent_object_type                        VARCHAR2(30);
    l_parent_flag                                    VARCHAR2(1);
    l_count                                          NUMBER;
    l_new_start_date                                 DATE;
    l_new_end_date                                   DATE;
    e_loop                                           EXCEPTION;
    pragma                                           exception_init(e_loop, -01436);
    --Bug 3306941.
    l_meaning                                        VARCHAR2(80);

    -- Bug 2197181: added for mix-n-match project.
    db_actual_content_source        hz_relationships.actual_content_source%TYPE;

    l_party_usg_assignment_rec        HZ_PARTY_USG_ASSIGNMENT_PVT.party_usg_assignment_rec_type;

--  Bug 4693719 : Added for local assignment
    l_acs hz_relationships.actual_content_source%TYPE;

    --  Bug 4873016 : Added to select directional_flag
    l_directional_flag hz_relationships.directional_flag%TYPE;

BEGIN

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'do_update_rel (+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

/* Bug 4873016 : Select the record from hz_relationships based on
 * the values passed by the user to this API. If there is no record
 * found, it means that user is trying to update any of the non-updateable
 * columns. In this case, we continue to selecte the forward relationship
 * record and error will be raised from the validate_relationship call.
 * If a record is found, user the selected directional_flag to update
 * the reciprocal record
 */
  BEGIN
        SELECT OBJECT_VERSION_NUMBER,
               ROWID,
               CONTENT_SOURCE_TYPE,
               SUBJECT_TABLE_NAME,
               OBJECT_TABLE_NAME,
               SUBJECT_ID,
               OBJECT_ID,
               SUBJECT_TYPE,
               OBJECT_TYPE,
               RELATIONSHIP_TYPE,
               RELATIONSHIP_CODE,
               START_DATE,
               END_DATE,
               DIRECTION_CODE,
               STATUS,
               actual_content_source,
               DIRECTIONAL_FLAG
        INTO   l_object_version_number,
               l_rowid,
               l_content_source_type,
               l_subject_table_name,
               l_object_table_name,
               l_subject_id,
               l_object_id,
               l_subject_type,
               l_object_type,
               l_relationship_type,
               l_relationship_code,
               l_start_date,
               l_end_date,
               l_direction_code,
               l_status,
               db_actual_content_source,
               l_directional_flag
        FROM   HZ_RELATIONSHIPS
        WHERE  RELATIONSHIP_ID = p_relationship_rec.relationship_id
        AND    SUBJECT_TABLE_NAME = nvl(p_relationship_rec.SUBJECT_TABLE_NAME, SUBJECT_TABLE_NAME)
        AND    OBJECT_TABLE_NAME = nvl(p_relationship_rec.OBJECT_TABLE_NAME, OBJECT_TABLE_NAME)
	AND    SUBJECT_ID = nvl(p_relationship_rec.SUBJECT_ID, SUBJECT_ID)
	AND    OBJECT_ID = nvl(p_relationship_rec.OBJECT_ID, OBJECT_ID)
	AND    SUBJECT_TYPE = nvl(p_relationship_rec.SUBJECT_TYPE, SUBJECT_TYPE)
	AND    OBJECT_TYPE = nvl(p_relationship_rec.OBJECT_TYPE, OBJECT_TYPE)
	AND    RELATIONSHIP_TYPE = nvl(p_relationship_rec.RELATIONSHIP_TYPE, RELATIONSHIP_TYPE)
	AND    RELATIONSHIP_CODE = nvl(p_relationship_rec.RELATIONSHIP_CODE, RELATIONSHIP_CODE)
        AND    ROWNUM = 1
        FOR    UPDATE OF RELATIONSHIP_ID NOWAIT;

        IF NOT
            (
             ( p_object_version_number IS NULL AND l_object_version_number IS NULL )
             OR
             ( p_object_version_number IS NOT NULL AND
               l_object_version_number IS NOT NULL AND
               p_object_version_number = l_object_version_number
             )
            )
        THEN
            FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_RECORD_CHANGED' );
            FND_MESSAGE.SET_TOKEN( 'TABLE', 'hz_relationships' );
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
        END IF;

        p_object_version_number := NVL( l_object_version_number, 1 ) + 1;

  EXCEPTION
        WHEN NO_DATA_FOUND THEN

    -- Check whether record has been updated by another user. If not, lock it.

    -- Bug 2197181: selecting actual_content_source for mix-n-match project.

    BEGIN
        SELECT OBJECT_VERSION_NUMBER,
               ROWID,
               CONTENT_SOURCE_TYPE,
               SUBJECT_TABLE_NAME,
               OBJECT_TABLE_NAME,
               SUBJECT_ID,
               OBJECT_ID,
               SUBJECT_TYPE,
               OBJECT_TYPE,
               RELATIONSHIP_TYPE,
               RELATIONSHIP_CODE,
               START_DATE,
               END_DATE,
               DIRECTION_CODE,
               STATUS,
               actual_content_source,
        --  Bug 4873016 : select DIRECTIONAL_FLAG also
               DIRECTIONAL_FLAG
        INTO   l_object_version_number,
               l_rowid,
               l_content_source_type,
               l_subject_table_name,
               l_object_table_name,
               l_subject_id,
               l_object_id,
               l_subject_type,
               l_object_type,
               l_relationship_type,
               l_relationship_code,
               l_start_date,
               l_end_date,
               l_direction_code,
               l_status,
               db_actual_content_source,
               l_directional_flag
        FROM   HZ_RELATIONSHIPS
        WHERE  RELATIONSHIP_ID = p_relationship_rec.relationship_id
        AND    DIRECTIONAL_FLAG = 'F'
        FOR    UPDATE OF RELATIONSHIP_ID NOWAIT;

        IF NOT
            (
             ( p_object_version_number IS NULL AND l_object_version_number IS NULL )
             OR
             ( p_object_version_number IS NOT NULL AND
               l_object_version_number IS NOT NULL AND
               p_object_version_number = l_object_version_number
             )
            )
        THEN
            FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_RECORD_CHANGED' );
            FND_MESSAGE.SET_TOKEN( 'TABLE', 'hz_relationships' );
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
        END IF;

        p_object_version_number := NVL( l_object_version_number, 1 ) + 1;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_NO_RECORD' );
            FND_MESSAGE.SET_TOKEN( 'RECORD', 'relationship' );
            FND_MESSAGE.SET_TOKEN( 'VALUE', NVL(TO_CHAR( p_relationship_rec.relationship_id ),'null'));
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
    END;
  END;

    -- Debug info.
    IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_message=>'Done with locking',
                                  p_prefix =>l_debug_prefix,
                                  p_msg_level=>fnd_log.level_statement);
    END IF;

    -- get the relationship type for its attributes
    SELECT HIERARCHICAL_FLAG,
           ALLOW_CIRCULAR_RELATIONSHIPS,
           NVL(MULTIPLE_PARENT_ALLOWED, 'N') MULTIPLE_PARENT_ALLOWED
    INTO   l_hierarchical_flag,
           l_allow_circular_relationships,
           l_mult_parent_allowed
    FROM   HZ_RELATIONSHIP_TYPES
    WHERE  RELATIONSHIP_TYPE = l_relationship_type
    AND    ROWNUM = 1;

    -- decide who is parent and who is child in this relationship.
    -- if relationship type record is 'P' type, then subject is parent, else object
    IF l_direction_code = 'P' THEN
        l_parent_id := l_subject_id;
        l_parent_table_name := l_subject_table_name;
        l_parent_object_type := l_subject_type;
        l_child_id := l_object_id;
        l_child_table_name := l_object_table_name;
        l_child_object_type := l_object_type;
    ELSIF l_direction_code = 'C' THEN
        l_parent_id := l_object_id;
        l_parent_table_name := l_object_table_name;
        l_parent_object_type := l_object_type;
        l_child_id := l_subject_id;
        l_child_table_name := l_subject_table_name;
        l_child_object_type := l_subject_type;
    END IF;

    IF p_relationship_rec.start_date IS NOT NULL THEN
        IF p_relationship_rec.start_date = FND_API.G_MISS_DATE THEN
            l_new_start_date := sysdate;
        ELSE
            l_new_start_date := p_relationship_rec.start_date;
        END IF;
    ELSE
        l_new_start_date := l_start_date;
    END IF;

    IF p_relationship_rec.end_date IS NOT NULL THEN
        IF p_relationship_rec.end_date = FND_API.G_MISS_DATE THEN
            l_new_end_date := to_date('31-12-4712 00:00:01', 'DD-MM-YYYY HH24:MI:SS');
        ELSE
            l_new_end_date := p_relationship_rec.end_date;
        END IF;
    ELSE
        l_new_end_date := l_end_date;
    END IF;


    -- Bug 2797506 begin.  Circularity check logic is in a new procedure.

    IF l_hierarchical_flag = 'Y' OR l_allow_circular_relationships = 'N'
    THEN
      -- check for circularity.  This procedure will raise exception if found.
      do_circularity_check(
        p_relationship_id      => p_relationship_rec.relationship_id,
        p_relationship_type    => l_relationship_type,
        p_start_date           => l_new_start_date,
        p_end_date             => l_new_end_date,
        p_subject_id           => l_child_id,
        p_object_id            => l_parent_id,
        p_object_type          => l_parent_object_type,
        p_object_table_name    => l_parent_table_name
      );
    END IF;

    -- Bug 2797506 end.


    -- check for multiple parent
    IF l_hierarchical_flag = 'Y' AND l_mult_parent_allowed = 'N'
       AND
       (l_start_date <> NVL(p_relationship_rec.start_date, l_start_date) OR
        l_end_date <> NVL(p_relationship_rec.end_date, l_end_date)
       )
    THEN
        -- code for multiple parent check
        BEGIN
            SELECT 1 INTO l_count
            FROM   HZ_RELATIONSHIPS
            WHERE  OBJECT_ID = l_child_id
            AND    OBJECT_TABLE_NAME = l_child_table_name
            AND    OBJECT_TYPE = l_child_object_type
            AND    RELATIONSHIP_TYPE = l_relationship_type
            AND    DIRECTION_CODE = 'P'
            AND    RELATIONSHIP_ID <> p_relationship_rec.relationship_id
--  Bug 3817438 : Added condition to check only active relationships
            AND    STATUS= 'A'
            AND    (START_DATE BETWEEN NVL(p_relationship_rec.start_date, l_start_date)
                                  AND NVL(p_relationship_rec.end_date, l_end_date)
                   OR
                   END_DATE BETWEEN NVL(p_relationship_rec.start_date, l_start_date)
                                  AND NVL(p_relationship_rec.end_date, l_end_date)
                   OR
                   NVL(p_relationship_rec.start_date, l_start_date) BETWEEN START_DATE AND END_DATE
                   OR
                   NVL(p_relationship_rec.end_date, l_end_date) BETWEEN START_DATE AND END_DATE
                   )
            AND ROWNUM = 1;

            -- there is already a parent, so raise error
            --Bug 3306941.Display meaning instead of relationship_type.
            SELECT MEANING
            INTO   l_meaning
-- Bug 3664939 : Use fnd_lookup_values_vl to get lookup meaning
            FROM   FND_LOOKUP_VALUES_VL
            WHERE  LOOKUP_TYPE='HZ_RELATIONSHIP_TYPE'
            AND    LOOKUP_CODE = l_relationship_type
            AND    VIEW_APPLICATION_ID = 222
            AND    ROWNUM = 1;

            FND_MESSAGE.SET_NAME('AR', 'HZ_API_MULTIPLE_PARENT');
            FND_MESSAGE.SET_TOKEN('RELTYPE', l_meaning);
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;

        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                -- no parent found, proceed
                NULL;
        END;
    END IF;

    -- Call for validations.
--Bug 2133648
--  Bug 4873016 : user values passed to API if not NULL
    p_relationship_rec.subject_id := nvl(p_relationship_rec.SUBJECT_ID, l_subject_id);
    p_relationship_rec.object_id := nvl(p_relationship_rec.OBJECT_ID, l_object_id);
    p_relationship_rec.relationship_code := nvl(p_relationship_rec.RELATIONSHIP_CODE, l_relationship_code);
    --2226526,passed object_type
    p_relationship_rec.object_type := nvl(p_relationship_rec.OBJECT_TYPE, l_object_type);
    -- Bug 3274236 l_rel_rec := p_relationship_rec;


    IF p_relationship_rec.start_date IS NULL OR
       p_relationship_rec.start_date = FND_API.G_MISS_DATE
    THEN
       -- Bug 3274236 p_relationship_rec.start_date := l_start_date;
       p_relationship_rec.start_date := l_new_start_date;
    END IF;

    IF p_relationship_rec.end_date IS NULL OR
       p_relationship_rec.end_date = FND_API.G_MISS_DATE
    THEN
       -- Bug 3274236 p_relationship_rec.end_date := l_end_date;
       p_relationship_rec.end_date := l_new_end_date;
    END IF;

    -- Bug 3274236
    l_rel_rec := p_relationship_rec ;

    HZ_REGISTRY_VALIDATE_V2PUB.validate_relationship(
                                                   'U',
                                                   p_relationship_rec,
                                                   l_rowid,
                                                   x_return_status);

    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    --start_date of hz_party_relationships has been changed
    --to be updateable. We need to pass in the new start_date when we
    --denormalize flags.
/* Bug 3274236.This code is redundant as l_rel_rec is now assigned after
   making the changes to p_relationship_rec.

    IF p_relationship_rec.start_date IS NULL OR
       p_relationship_rec.start_date <> FND_API.G_MISS_DATE
    THEN
        l_rel_rec.start_date := p_relationship_rec.start_date;
    END IF;

    IF p_relationship_rec.end_date IS NULL OR
       p_relationship_rec.end_date <> FND_API.G_MISS_DATE
    THEN
        l_rel_rec.end_date := p_relationship_rec.end_date;
    END IF;
*/
    -- Denormalization will be done only if content_source_type
    -- is 'USER_ENTERED' and both subject_table_name and
    -- object_table_name are 'HZ_PARTIES'

    -- Bug 2197181: added for mix-n-match project. Denormalize
    -- the three flags when the data source is visible (i.e.
    -- selected).

    -- SSM SST Integration and Extension
    -- For non-profile entities, the concept of select/de-select data-sources is obsoleted.
    -- There is no need to check if the data-source is selected.

    IF l_relationship_code IN
         ('COMPETITOR_OF', 'REFERENCE_FOR', 'PARTNER_OF') AND
      /* g_rel_is_datasource_selected = 'Y' AND */
       /*
       l_content_source_type = 'USER_ENTERED'
       AND
       */
       l_subject_table_name = 'HZ_PARTIES'
       AND
       l_object_table_name = 'HZ_PARTIES'
    THEN

        -- Debug info.
        IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_message=>'denormalizing to hz_parties',
                                  p_prefix =>l_debug_prefix,
                                  p_msg_level=>fnd_log.level_statement);
       END IF;

        do_update_party_flags(l_rel_rec,
                              l_rel_rec.subject_id);
    END IF;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'HZ_RELATIONSHIPS_PKG.Update_Row-1 (+) ',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

--  Bug 4693719 : pass NULL if the secure data is not updated
   IF HZ_UTILITY_V2PUB.G_UPDATE_ACS = 'Y' THEN
       l_acs := nvl(p_relationship_rec.actual_content_source, 'USER_ENTERED');
   ELSE
       l_acs := NULL;
   END IF;


    --Call to table-handler.
    HZ_RELATIONSHIPS_PKG.Update_Row (
        X_Rowid                                 => l_rowid,
        X_RELATIONSHIP_ID                       => p_relationship_rec.relationship_id,
--  Bug 4873016 : pass NULL for non updateable columns
/*
        X_SUBJECT_ID                            => p_relationship_rec.subject_id,
        X_SUBJECT_TYPE                          => p_relationship_rec.subject_type,
        X_SUBJECT_TABLE_NAME                    => p_relationship_rec.subject_table_name,
        X_OBJECT_ID                             => p_relationship_rec.object_id,
        X_OBJECT_TYPE                           => p_relationship_rec.object_type,
        X_OBJECT_TABLE_NAME                     => p_relationship_rec.object_table_name,
        X_PARTY_ID                              => NULL,
        X_RELATIONSHIP_CODE                     => p_relationship_rec.relationship_code,
*/
        X_SUBJECT_ID                            => NULL,
        X_SUBJECT_TYPE                          => NULL,
        X_SUBJECT_TABLE_NAME                    => NULL,
        X_OBJECT_ID                             => NULL,
        X_OBJECT_TYPE                           => NULL,
        X_OBJECT_TABLE_NAME                     => NULL,
        X_PARTY_ID                              => NULL,
        X_RELATIONSHIP_CODE                     => NULL,
        X_DIRECTIONAL_FLAG                      => NULL,
        X_COMMENTS                              => p_relationship_rec.comments,
        X_START_DATE                            => p_relationship_rec.start_date,
        X_END_DATE                              => p_relationship_rec.end_date,
        X_STATUS                                => p_relationship_rec.status,
        X_ATTRIBUTE_CATEGORY                    => p_relationship_rec.attribute_category,
        X_ATTRIBUTE1                            => p_relationship_rec.attribute1,
        X_ATTRIBUTE2                            => p_relationship_rec.attribute2,
        X_ATTRIBUTE3                            => p_relationship_rec.attribute3,
        X_ATTRIBUTE4                            => p_relationship_rec.attribute4,
        X_ATTRIBUTE5                            => p_relationship_rec.attribute5,
        X_ATTRIBUTE6                            => p_relationship_rec.attribute6,
        X_ATTRIBUTE7                            => p_relationship_rec.attribute7,
        X_ATTRIBUTE8                            => p_relationship_rec.attribute8,
        X_ATTRIBUTE9                            => p_relationship_rec.attribute9,
        X_ATTRIBUTE10                           => p_relationship_rec.attribute10,
        X_ATTRIBUTE11                           => p_relationship_rec.attribute11,
        X_ATTRIBUTE12                           => p_relationship_rec.attribute12,
        X_ATTRIBUTE13                           => p_relationship_rec.attribute13,
        X_ATTRIBUTE14                           => p_relationship_rec.attribute14,
        X_ATTRIBUTE15                           => p_relationship_rec.attribute15,
        X_ATTRIBUTE16                           => p_relationship_rec.attribute16,
        X_ATTRIBUTE17                           => p_relationship_rec.attribute17,
        X_ATTRIBUTE18                           => p_relationship_rec.attribute18,
        X_ATTRIBUTE19                           => p_relationship_rec.attribute19,
        X_ATTRIBUTE20                           => p_relationship_rec.attribute20,
        -- Bug 2197181 : content_source_type is obsolete and it is non-updateable.
        X_CONTENT_SOURCE_TYPE                   => NULL,
        X_RELATIONSHIP_TYPE                     => p_relationship_rec.relationship_type,
        X_OBJECT_VERSION_NUMBER                 => p_object_version_number,
        X_CREATED_BY_MODULE                     => p_relationship_rec.created_by_module,
        X_APPLICATION_ID                        => p_relationship_rec.application_id,
        X_ADDITIONAL_INFORMATION1               => p_relationship_rec.additional_information1,
        X_ADDITIONAL_INFORMATION2               => p_relationship_rec.additional_information2,
        X_ADDITIONAL_INFORMATION3               => p_relationship_rec.additional_information3,
        X_ADDITIONAL_INFORMATION4               => p_relationship_rec.additional_information4,
        X_ADDITIONAL_INFORMATION5               => p_relationship_rec.additional_information5,
        X_ADDITIONAL_INFORMATION6               => p_relationship_rec.additional_information6,
        X_ADDITIONAL_INFORMATION7               => p_relationship_rec.additional_information7,
        X_ADDITIONAL_INFORMATION8               => p_relationship_rec.additional_information8,
        X_ADDITIONAL_INFORMATION9               => p_relationship_rec.additional_information9,
        X_ADDITIONAL_INFORMATION10               => p_relationship_rec.additional_information10,
        X_ADDITIONAL_INFORMATION11               => p_relationship_rec.additional_information11,
        X_ADDITIONAL_INFORMATION12               => p_relationship_rec.additional_information12,
        X_ADDITIONAL_INFORMATION13               => p_relationship_rec.additional_information13,
        X_ADDITIONAL_INFORMATION14               => p_relationship_rec.additional_information14,
        X_ADDITIONAL_INFORMATION15               => p_relationship_rec.additional_information15,
        X_ADDITIONAL_INFORMATION16               => p_relationship_rec.additional_information16,
        X_ADDITIONAL_INFORMATION17               => p_relationship_rec.additional_information17,
        X_ADDITIONAL_INFORMATION18               => p_relationship_rec.additional_information18,
        X_ADDITIONAL_INFORMATION19               => p_relationship_rec.additional_information19,
        X_ADDITIONAL_INFORMATION20               => p_relationship_rec.additional_information20,
        X_ADDITIONAL_INFORMATION21               => p_relationship_rec.additional_information21,
        X_ADDITIONAL_INFORMATION22               => p_relationship_rec.additional_information22,
        X_ADDITIONAL_INFORMATION23               => p_relationship_rec.additional_information23,
        X_ADDITIONAL_INFORMATION24               => p_relationship_rec.additional_information24,
        X_ADDITIONAL_INFORMATION25               => p_relationship_rec.additional_information25,
        X_ADDITIONAL_INFORMATION26               => p_relationship_rec.additional_information26,
        X_ADDITIONAL_INFORMATION27               => p_relationship_rec.additional_information27,
        X_ADDITIONAL_INFORMATION28               => p_relationship_rec.additional_information28,
        X_ADDITIONAL_INFORMATION29               => p_relationship_rec.additional_information29,
        X_ADDITIONAL_INFORMATION30               => p_relationship_rec.additional_information30,
        X_DIRECTION_CODE                         => NULL,
        X_PERCENTAGE_OWNERSHIP                   => p_relationship_rec.percentage_ownership,
   --  Bug 4693719 : Pass correct value for ACS
        X_ACTUAL_CONTENT_SOURCE                  => l_acs
    );

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'HZ_RELATIONSHIPS_PKG.Update_Row-1 (-) ',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- get the reciprocal record information
    SELECT ROWID
    INTO   l_rowid
    FROM   HZ_RELATIONSHIPS
    WHERE  RELATIONSHIP_ID = p_relationship_rec.relationship_id
    /*  Bug 4873016 : query the reciprocal record based on previously
     *  selected directional flag. If it was 'F' select 'B'
     *  if it was 'B' select 'F'
     */
    AND    DIRECTIONAL_FLAG = decode(l_directional_flag, 'F', 'B','B', 'F');

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'HZ_RELATIONSHIPS_PKG.Update_Row-2 (+) ',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

  -- update the reciprocal record
    HZ_RELATIONSHIPS_PKG.Update_Row (
        X_Rowid                                 => l_rowid,
        X_RELATIONSHIP_ID                       => p_relationship_rec.relationship_id,
        X_SUBJECT_ID                            => NULL,
        X_SUBJECT_TYPE                          => NULL,
        X_SUBJECT_TABLE_NAME                    => NULL,
        X_OBJECT_ID                             => NULL,
        X_OBJECT_TYPE                           => NULL,
        X_OBJECT_TABLE_NAME                     => NULL,
        X_PARTY_ID                              => NULL,
        X_RELATIONSHIP_CODE                     => NULL,
        X_DIRECTIONAL_FLAG                      => NULL,
        X_COMMENTS                              => p_relationship_rec.comments,
        X_START_DATE                            => p_relationship_rec.start_date,
        X_END_DATE                              => p_relationship_rec.end_date,
        X_STATUS                                => p_relationship_rec.status,
        X_ATTRIBUTE_CATEGORY                    => p_relationship_rec.attribute_category,
        X_ATTRIBUTE1                            => p_relationship_rec.attribute1,
        X_ATTRIBUTE2                            => p_relationship_rec.attribute2,
        X_ATTRIBUTE3                            => p_relationship_rec.attribute3,
        X_ATTRIBUTE4                            => p_relationship_rec.attribute4,
        X_ATTRIBUTE5                            => p_relationship_rec.attribute5,
        X_ATTRIBUTE6                            => p_relationship_rec.attribute6,
        X_ATTRIBUTE7                            => p_relationship_rec.attribute7,
        X_ATTRIBUTE8                            => p_relationship_rec.attribute8,
        X_ATTRIBUTE9                            => p_relationship_rec.attribute9,
        X_ATTRIBUTE10                           => p_relationship_rec.attribute10,
        X_ATTRIBUTE11                           => p_relationship_rec.attribute11,
        X_ATTRIBUTE12                           => p_relationship_rec.attribute12,
        X_ATTRIBUTE13                           => p_relationship_rec.attribute13,
        X_ATTRIBUTE14                           => p_relationship_rec.attribute14,
        X_ATTRIBUTE15                           => p_relationship_rec.attribute15,
        X_ATTRIBUTE16                           => p_relationship_rec.attribute16,
        X_ATTRIBUTE17                           => p_relationship_rec.attribute17,
        X_ATTRIBUTE18                           => p_relationship_rec.attribute18,
        X_ATTRIBUTE19                           => p_relationship_rec.attribute19,
        X_ATTRIBUTE20                           => p_relationship_rec.attribute20,
        X_CONTENT_SOURCE_TYPE                   => NULL,
        X_RELATIONSHIP_TYPE                     => NULL,
        X_OBJECT_VERSION_NUMBER                 => p_object_version_number,
        X_CREATED_BY_MODULE                     => p_relationship_rec.created_by_module,
        X_APPLICATION_ID                        => p_relationship_rec.application_id,
        X_ADDITIONAL_INFORMATION1               => p_relationship_rec.additional_information1,
        X_ADDITIONAL_INFORMATION2               => p_relationship_rec.additional_information2,
        X_ADDITIONAL_INFORMATION3               => p_relationship_rec.additional_information3,
        X_ADDITIONAL_INFORMATION4               => p_relationship_rec.additional_information4,
        X_ADDITIONAL_INFORMATION5               => p_relationship_rec.additional_information5,
        X_ADDITIONAL_INFORMATION6               => p_relationship_rec.additional_information6,
        X_ADDITIONAL_INFORMATION7               => p_relationship_rec.additional_information7,
        X_ADDITIONAL_INFORMATION8               => p_relationship_rec.additional_information8,
        X_ADDITIONAL_INFORMATION9               => p_relationship_rec.additional_information9,
        X_ADDITIONAL_INFORMATION10               => p_relationship_rec.additional_information10,
        X_ADDITIONAL_INFORMATION11               => p_relationship_rec.additional_information11,
        X_ADDITIONAL_INFORMATION12               => p_relationship_rec.additional_information12,
        X_ADDITIONAL_INFORMATION13               => p_relationship_rec.additional_information13,
        X_ADDITIONAL_INFORMATION14               => p_relationship_rec.additional_information14,
        X_ADDITIONAL_INFORMATION15               => p_relationship_rec.additional_information15,
        X_ADDITIONAL_INFORMATION16               => p_relationship_rec.additional_information16,
        X_ADDITIONAL_INFORMATION17               => p_relationship_rec.additional_information17,
        X_ADDITIONAL_INFORMATION18               => p_relationship_rec.additional_information18,
        X_ADDITIONAL_INFORMATION19               => p_relationship_rec.additional_information19,
        X_ADDITIONAL_INFORMATION20               => p_relationship_rec.additional_information20,
        X_ADDITIONAL_INFORMATION21               => p_relationship_rec.additional_information21,
        X_ADDITIONAL_INFORMATION22               => p_relationship_rec.additional_information22,
        X_ADDITIONAL_INFORMATION23               => p_relationship_rec.additional_information23,
        X_ADDITIONAL_INFORMATION24               => p_relationship_rec.additional_information24,
        X_ADDITIONAL_INFORMATION25               => p_relationship_rec.additional_information25,
        X_ADDITIONAL_INFORMATION26               => p_relationship_rec.additional_information26,
        X_ADDITIONAL_INFORMATION27               => p_relationship_rec.additional_information27,
        X_ADDITIONAL_INFORMATION28               => p_relationship_rec.additional_information28,
        X_ADDITIONAL_INFORMATION29               => p_relationship_rec.additional_information29,
        X_ADDITIONAL_INFORMATION30               => p_relationship_rec.additional_information30,
        X_DIRECTION_CODE                         => NULL,
        X_PERCENTAGE_OWNERSHIP                   => p_relationship_rec.percentage_ownership,
        X_ACTUAL_CONTENT_SOURCE                  => p_relationship_rec.actual_content_source
    );

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'HZ_RELATIONSHIPS_PKG.Update_Row-2 (-) ',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- Check if party exists for party_relationship. If yes, update party.
    -- build the record for creation of relationship party record
    l_party_rel_rec.relationship_id := p_relationship_rec.relationship_id;
    l_party_rel_rec.subject_id := p_relationship_rec.subject_id;
    l_party_rel_rec.object_id := p_relationship_rec.object_id;
    l_party_rel_rec.party_rec := p_relationship_rec.party_rec;
    l_party_rel_rec.party_rec.party_id := l_party_id;
    l_party_rel_rec.created_by_module := p_relationship_rec.created_by_module;
    l_party_rel_rec.application_id := p_relationship_rec.application_id;

--Bug 6732835 Start of changes
--The status of the party must be in sync with the status of
--the corresponding relationship record
--Bug 7280211 added status 'M' into list
    IF (l_party_rel_rec.status IN ('I','A','M'))
    THEN
       l_party_rel_rec.party_rec.status := p_relationship_rec.status;
    ELSE
       l_party_rel_rec.party_rec.status := p_relationship_rec.party_rec.status;
    END IF;
--Bug 6732835 End of changes

    IF nvl(p_party_object_version_number,1) <> FND_API.G_MISS_NUM
    THEN
        IF l_party_id IS NOT NULL THEN

            -- Debug info.
            IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
                 hz_utility_v2pub.debug(p_message=>'updating party record',
                                  p_prefix =>l_debug_prefix,
                                  p_msg_level=>fnd_log.level_statement);
            END IF;

            IF p_party_object_version_number IS NULL THEN
                l_party_object_version_number := 1;
            ELSE
               l_party_object_version_number := p_party_object_version_number;
            END IF;
            do_update_party(
                p_party_type                  => 'PARTY_RELATIONSHIP',
                p_relationship_rec            => l_party_rel_rec,
                p_old_relationship_rec        => p_old_relationship_rec,
                p_party_object_version_number => l_party_object_version_number,
                x_profile_id                  => l_profile_id,
                x_return_status               => x_return_status
               );
            p_party_object_version_number := l_party_object_version_number;
        END IF;
    END IF;

    -- maintain hierarchy information
    -- hierarchy needs to be maintained if the relationship type used
    -- is hierarchical and the update is trying to change start_date,
    -- end_date or status of the relationship
    IF l_hierarchical_flag = 'Y' AND
       (NVL(p_relationship_rec.start_date, l_start_date) <> l_start_date OR
        NVL(p_relationship_rec.end_date, l_end_date) <> l_end_date OR
        NVL(p_relationship_rec.status, l_status) <> l_status
       )
    THEN
        -- check if relationship type is parent one
        IF l_direction_code = 'P' THEN
            -- assign the subject to parent for hierarchy
            l_hierarchy_rec.hierarchy_type := l_relationship_type;
            l_hierarchy_rec.parent_id := l_subject_id;
            l_hierarchy_rec.parent_table_name := l_subject_table_name;
            l_hierarchy_rec.parent_object_type := l_subject_type;
            l_hierarchy_rec.child_id := l_object_id;
            l_hierarchy_rec.child_table_name := l_object_table_name;
            l_hierarchy_rec.child_object_type := l_object_type;
            l_hierarchy_rec.effective_start_date := NVL(p_relationship_rec.start_date, l_start_date);
            l_hierarchy_rec.effective_end_date := NVL(p_relationship_rec.end_date, l_end_date);
            l_hierarchy_rec.relationship_id := p_relationship_rec.relationship_id;
            l_hierarchy_rec.status := NVL(p_relationship_rec.status, l_status);
        ELSIF l_direction_code = 'C' THEN
            -- assign the object to parent
            l_hierarchy_rec.hierarchy_type := l_relationship_type;
            l_hierarchy_rec.parent_id := l_object_id;
            l_hierarchy_rec.parent_table_name := l_object_table_name;
            l_hierarchy_rec.parent_object_type := l_object_type;
            l_hierarchy_rec.child_id := l_subject_id;
            l_hierarchy_rec.child_table_name := l_subject_table_name;
            l_hierarchy_rec.child_object_type := l_subject_type;
            l_hierarchy_rec.effective_start_date := NVL(p_relationship_rec.start_date, l_start_date);
            l_hierarchy_rec.effective_end_date := NVL(p_relationship_rec.end_date, l_end_date);
            l_hierarchy_rec.relationship_id := p_relationship_rec.relationship_id;
            l_hierarchy_rec.status := NVL(p_relationship_rec.status, l_status);
        END IF;

        HZ_HIERARCHY_PUB.update_link(
            p_init_msg_list           => FND_API.G_FALSE,
            p_hierarchy_node_rec      => l_hierarchy_rec,
            x_return_status           => x_return_status,
            x_msg_count               => l_msg_count,
            x_msg_data                => l_msg_data
           );

        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
            ELSE
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
        END IF;

    END IF;

    --
    -- added for R12 party usage project
    --
    IF ((p_relationship_rec.status IS NULL OR
         p_relationship_rec.status  = 'A') AND
         l_status = 'A' AND
        (p_relationship_rec.start_date IS NOT NULL AND
         p_relationship_rec.start_date <> l_start_date AND
         p_relationship_rec.start_date <> fnd_api.g_miss_date OR
         p_relationship_rec.end_date IS NOT NULL AND
         p_relationship_rec.end_date <> l_end_date AND
         p_relationship_rec.end_date <> fnd_api.g_miss_date) OR
        p_relationship_rec.status = 'I' AND
        l_status = 'A' OR
        p_relationship_rec.status = 'A' AND
        l_status = 'I') AND
       (l_subject_type = 'PERSON' AND
        l_object_type IN ('PERSON', 'ORGANIZATION') OR
        l_object_type = 'PERSON' AND
        l_subject_type IN ('PERSON', 'ORGANIZATION')) AND
       l_subject_table_name = 'HZ_PARTIES' AND
       l_object_table_name = 'HZ_PARTIES'
    THEN
      l_party_usg_assignment_rec.owner_table_name := 'HZ_RELATIONSHIPS';
      l_party_usg_assignment_rec.owner_table_id := p_relationship_rec.relationship_id;
      l_party_usg_assignment_rec.effective_start_date := p_relationship_rec.start_date;
      l_party_usg_assignment_rec.effective_end_date := p_relationship_rec.end_date;

      IF p_relationship_rec.status = 'A' AND l_status = 'I' THEN
        IF p_relationship_rec.start_date IS NULL THEN
          l_party_usg_assignment_rec.effective_start_date := l_start_date;
        END IF;

        IF p_relationship_rec.end_date IS NULL THEN
          l_party_usg_assignment_rec.effective_end_date := l_end_date;
        END IF;
      ELSIF p_relationship_rec.status = 'I' AND l_status = 'A' THEN
        IF p_relationship_rec.start_date IS NULL AND
           trunc(l_start_date) > trunc(sysdate) OR
           p_relationship_rec.start_date IS NOT NULL AND
           trunc(p_relationship_rec.start_date) > trunc(sysdate)
        THEN
          l_party_usg_assignment_rec.effective_start_date := trunc(sysdate);
        END IF;

        IF p_relationship_rec.end_date IS NULL AND
           trunc(l_end_date) > trunc(sysdate) OR
           p_relationship_rec.end_date IS NOT NULL AND
           trunc(p_relationship_rec.end_date) > trunc(sysdate)
        THEN
          l_party_usg_assignment_rec.effective_end_date := trunc(sysdate);
        END IF;
      END IF;

      HZ_PARTY_USG_ASSIGNMENT_PVT.update_usg_assignment (
        p_validation_level          => HZ_PARTY_USG_ASSIGNMENT_PVT.G_VALID_LEVEL_NONE,
        p_party_usg_assignment_rec  => l_party_usg_assignment_rec,
        x_return_status             => x_return_status,
        x_msg_count                 => l_msg_count,
        x_msg_data                  => l_msg_data
      );

      IF x_return_status <> fnd_api.g_ret_sts_success THEN
        RAISE fnd_api.g_exc_error;
      END IF;
    END IF;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'do_update_rel (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

END do_update_rel;


/*===========================================================================+
 | PROCEDURE
 |              do_update_party_flags
 |
 | DESCRIPTION
 |              Denormalize flags to hz_parties:
 |              COMPETITOR_FLAG, REFERENCE_USE_FLAG, THIRD_PARTY_FLAG
 |
 | SCOPE - PRIVATE
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |              OUT:
 |          IN/ OUT:
 |                    p_relationship_rec
 |                    p_party_id
 |
 | RETURNS    : NONE
 |
 | NOTES
 |           If the end_date is today, we will denormailize the flags to 'N'
 |
 | MODIFICATION HISTORY
 |
 +===========================================================================*/

PROCEDURE do_update_party_flags(
    p_relationship_rec      IN      RELATIONSHIP_REC_TYPE,
    p_party_id              IN      NUMBER
) IS

    l_party_id                      NUMBER;
    l_reference_use_flag            VARCHAR2(1) := 'N';
    l_third_party_flag              VARCHAR2(1) := 'N';
    l_competitor_flag               VARCHAR2(1) := 'N';
    l_end_date                      DATE := p_relationship_rec.end_date;
    l_status                        VARCHAR2(1) := p_relationship_rec.status;

BEGIN

    --check if party record is locked by any one else.
    BEGIN
        SELECT party_id INTO l_party_id
        FROM hz_parties
        WHERE party_id = p_party_id
        FOR UPDATE NOWAIT;
    EXCEPTION WHEN OTHERS THEN
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_RECORD_CHANGED');
        FND_MESSAGE.SET_TOKEN('TABLE', 'HZ_PARTIES');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END;

    IF l_end_date IS NULL
       OR l_end_date = FND_API.G_MISS_DATE
    THEN
        l_end_date := to_date('31-12-4712 00:00:01', 'DD-MM-YYYY HH24:MI:SS');
    ELSIF l_end_date = sysdate THEN
        l_end_date := sysdate-1;
    END IF;

    IF l_status IS NULL
       OR l_status = FND_API.G_MISS_CHAR
    THEN
       l_status := 'A';
    END IF;

    IF p_relationship_rec.relationship_code = 'COMPETITOR_OF' THEN
        IF l_status = 'A'
           AND
           (SYSDATE BETWEEN p_relationship_rec.start_date AND l_end_date)
        THEN
            l_competitor_flag := 'Y';
        END IF;

        UPDATE HZ_PARTIES
        SET    COMPETITOR_FLAG         = l_competitor_flag
        WHERE  PARTY_ID = p_party_id;

    ELSIF p_relationship_rec.relationship_code = 'REFERENCE_FOR' THEN
        IF l_status = 'A'
           AND
           (SYSDATE BETWEEN p_relationship_rec.start_date AND l_end_date)
        THEN
            l_reference_use_flag := 'Y';
        END IF;

        UPDATE HZ_PARTIES
        SET    REFERENCE_USE_FLAG    = l_reference_use_flag
        WHERE  PARTY_ID = p_party_id;

    ELSIF p_relationship_rec.relationship_code = 'PARTNER_OF' THEN
        IF l_status = 'A'
           AND (SYSDATE BETWEEN p_relationship_rec.start_date AND l_end_date)
        THEN
            l_third_party_flag := 'Y';
        END IF;

        UPDATE HZ_PARTIES
        SET    THIRD_PARTY_FLAG      = l_third_party_flag
        WHERE  PARTY_ID = p_party_id;

    END IF;

END do_update_party_flags;


/*===========================================================================+
 | PROCEDURE
 |              do_create_party
 |
 | DESCRIPTION
 |              Creates party.
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                    p_party_type
 |
 |              OUT:
 |                    x_party_id
 |              x_party_number
 |              x_profile_id
 |          IN/ OUT:
 |                    p_person_rec
 |                    p_organization_rec
 |                    p_group_rec
 |                    p_party_rel_rec
 |                    x_return_status
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |
 |  06-APR-2005     Rajib Ranjan Borah     o Bug 4284731. If profile option for
 |                                           generating party number is set to NO,
 |                                           and no value is passed for party_number,
 |                                           then donot throw any error. Instead generate
 |                                           party_number from sequence.
 +===========================================================================*/


PROCEDURE do_create_party(
    p_party_type                IN      VARCHAR2,
    p_relationship_rec          IN      RELATIONSHIP_REC_TYPE,
    x_party_id                 OUT NOCOPY      NUMBER,
    x_party_number             OUT NOCOPY      VARCHAR2,
    x_profile_id               OUT NOCOPY      NUMBER,
    x_return_status         IN OUT NOCOPY      VARCHAR2
) IS

    l_party_id                          NUMBER;
    l_party_number                      VARCHAR2(30);
    l_generate_party_number             VARCHAR2(1);
    l_rowid                             ROWID := NULL;
    l_count                             NUMBER;
    l_party_rec                         HZ_PARTY_V2PUB.PARTY_REC_TYPE := p_relationship_rec.party_rec;
    l_party_name                        HZ_PARTIES.PARTY_NAME%TYPE;
    l_subject_name                      HZ_PARTIES.PARTY_NAME%TYPE;
    l_object_name                       HZ_PARTIES.PARTY_NAME%TYPE;
    l_customer_key                      HZ_PARTIES.CUSTOMER_KEY%TYPE;
    l_code_assignment_id                NUMBER;
    l_msg_count                         NUMBER;
    l_msg_data                          VARCHAR2(2000);
    l_dummy                             VARCHAR2(1);
    l_debug_prefix                      VARCHAR2(30) := '';

BEGIN

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'do_create_party (+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    l_party_id := l_party_rec.party_id;
    l_party_number := l_party_rec.party_number;

    -- if primary key value is passed, check for uniqueness.
    IF l_party_id IS NOT NULL AND
        l_party_id <> FND_API.G_MISS_NUM
    THEN
        BEGIN
            SELECT 'Y'
            INTO   l_dummy
            FROM   HZ_PARTIES
            WHERE  PARTY_ID = l_party_id;

            FND_MESSAGE.SET_NAME('AR', 'HZ_API_DUPLICATE_COLUMN');
            FND_MESSAGE.SET_TOKEN('COLUMN', 'party_id');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;

        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                NULL;
        END;
    END IF;

    x_party_id := l_party_id;

    -- if GENERATE_PARTY_NUMBER is 'N', then if party_number is not passed or is
    -- a duplicate raise error.
    l_generate_party_number := fnd_profile.value('HZ_GENERATE_PARTY_NUMBER');

    IF l_generate_party_number = 'N' THEN
        IF l_party_number = FND_API.G_MISS_CHAR
           OR
           l_party_number IS NULL
        THEN
            -- Bug 4284731. If no party_number is passed in, do_not throw any error.
            -- Parties of type 'PARTY_RELATIONSHIP' are mostly an internal TCA concept.
            -- Even if such parties are used by other teams, the party number of such
            -- parties will not be displayed on the UI.
            NULL;

/*          FND_MESSAGE.SET_NAME('AR', 'HZ_API_MISSING_COLUMN');
            FND_MESSAGE.SET_TOKEN('COLUMN', 'party number');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
        END IF;
*/
        ELSE

        -- Bug 4284731. No changes have been made as the user is explicitely passing a duplicate value.

            BEGIN
                SELECT 'Y'
                INTO   l_dummy
                FROM   HZ_PARTIES
                WHERE  PARTY_NUMBER = l_party_number;

                FND_MESSAGE.SET_NAME('AR', 'HZ_API_DUPLICATE_COLUMN');
                FND_MESSAGE.SET_TOKEN('COLUMN', 'party_number');
                FND_MSG_PUB.ADD;
                RAISE FND_API.G_EXC_ERROR;

            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    NULL;
            END;
        END IF;
    ELSIF l_generate_party_number = 'Y'
          OR
          l_generate_party_number IS NULL
    THEN

        IF l_party_number <> FND_API.G_MISS_CHAR
           AND
           l_party_number IS NOT NULL
        THEN
            -- Bug 4284731. No changes were made here as party_number was explicitly
            -- passed despite the fact that auto numbering is on.

            FND_MESSAGE.SET_NAME('AR', 'HZ_API_PARTY_NUMBER_AUTO_ON');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
        END IF;

    END IF;

    x_party_number := l_party_number;

    HZ_REGISTRY_VALIDATE_V2PUB.validate_party(
                                     'C',
                                     l_party_rec,
                                     NULL, NULL,
                                     x_return_status);

    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    l_party_rec.party_id := l_party_id;
    l_party_rec.party_number := l_party_number;

    -- build the party_name for relationship party
    SELECT PARTY_NAME
    INTO   l_subject_name
    FROM   HZ_PARTIES
    WHERE  PARTY_ID = p_relationship_rec.subject_id;

    SELECT PARTY_NAME
    INTO   l_object_name
    FROM   HZ_PARTIES
    WHERE  PARTY_ID = p_relationship_rec.object_id;

    l_party_name := SUBSTRB(l_subject_name || '-' ||
                                l_object_name  || '-' ||
                                l_party_number, 1, 360);

    -- this is for orig_system_defaulting
    IF l_party_rec.party_id = FND_API.G_MISS_NUM THEN
        l_party_rec.party_id := NULL;
    END IF;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'HZ_PARTIES_PKG.Insert_Row (+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    HZ_PARTIES_PKG.Insert_Row (
        X_PARTY_ID                              => l_party_rec.party_id,
        X_PARTY_NUMBER                          => l_party_rec.party_number,
        X_PARTY_NAME                            => l_party_name,
        X_PARTY_TYPE                            => p_party_type,
        X_VALIDATED_FLAG                        => l_party_rec.validated_flag,
        X_ATTRIBUTE_CATEGORY                    => l_party_rec.attribute_category,
        X_ATTRIBUTE1                            => l_party_rec.attribute1,
        X_ATTRIBUTE2                            => l_party_rec.attribute2,
        X_ATTRIBUTE3                            => l_party_rec.attribute3,
        X_ATTRIBUTE4                            => l_party_rec.attribute4,
        X_ATTRIBUTE5                            => l_party_rec.attribute5,
        X_ATTRIBUTE6                            => l_party_rec.attribute6,
        X_ATTRIBUTE7                            => l_party_rec.attribute7,
        X_ATTRIBUTE8                            => l_party_rec.attribute8,
        X_ATTRIBUTE9                            => l_party_rec.attribute9,
        X_ATTRIBUTE10                           => l_party_rec.attribute10,
        X_ATTRIBUTE11                           => l_party_rec.attribute11,
        X_ATTRIBUTE12                           => l_party_rec.attribute12,
        X_ATTRIBUTE13                           => l_party_rec.attribute13,
        X_ATTRIBUTE14                           => l_party_rec.attribute14,
        X_ATTRIBUTE15                           => l_party_rec.attribute15,
        X_ATTRIBUTE16                           => l_party_rec.attribute16,
        X_ATTRIBUTE17                           => l_party_rec.attribute17,
        X_ATTRIBUTE18                           => l_party_rec.attribute18,
        X_ATTRIBUTE19                           => l_party_rec.attribute19,
        X_ATTRIBUTE20                           => l_party_rec.attribute20,
        X_ATTRIBUTE21                           => l_party_rec.attribute21,
        X_ATTRIBUTE22                           => l_party_rec.attribute22,
        X_ATTRIBUTE23                           => l_party_rec.attribute23,
        X_ATTRIBUTE24                           => l_party_rec.attribute24,
        X_ORIG_SYSTEM_REFERENCE                 => l_party_rec.orig_system_reference,
        X_SIC_CODE                              => null,
        X_HQ_BRANCH_IND                         => null,
        X_CUSTOMER_KEY                          => null,
        X_TAX_REFERENCE                         => null,
        X_JGZZ_FISCAL_CODE                      => null,
        X_PERSON_PRE_NAME_ADJUNCT               => null,
        X_PERSON_FIRST_NAME                     => null,
        X_PERSON_MIDDLE_NAME                    => null,
        X_PERSON_LAST_NAME                      => null,
        X_PERSON_NAME_SUFFIX                    => null,
        X_PERSON_TITLE                          => null,
        X_PERSON_ACADEMIC_TITLE                 => null,
        X_PERSON_PREVIOUS_LAST_NAME             => null,
        X_KNOWN_AS                              => null,
        X_PERSON_IDEN_TYPE                      => null,
        X_PERSON_IDENTIFIER                     => null,
        X_GROUP_TYPE                            => null,
        X_COUNTRY                               => NULL,
        X_ADDRESS1                              => NULL,
        X_ADDRESS2                              => NULL,
        X_ADDRESS3                              => NULL,
        X_ADDRESS4                              => NULL,
        X_CITY                                  => NULL,
        X_POSTAL_CODE                           => NULL,
        X_STATE                                 => NULL,
        X_PROVINCE                              => NULL,
        X_STATUS                                => l_party_rec.status,
        X_COUNTY                                => NULL,
        X_SIC_CODE_TYPE                         => null,
        X_URL                                   => NULL,
        X_EMAIL_ADDRESS                         => NULL,
        X_ANALYSIS_FY                           => null,
        X_FISCAL_YEAREND_MONTH                  => null,
        X_EMPLOYEES_TOTAL                       => null,
        X_CURR_FY_POTENTIAL_REVENUE             => null,
        X_NEXT_FY_POTENTIAL_REVENUE             => null,
        X_YEAR_ESTABLISHED                      => null,
        X_GSA_INDICATOR_FLAG                    => null,
        X_MISSION_STATEMENT                     => null,
        X_ORGANIZATION_NAME_PHONETIC            => null,
        X_PERSON_FIRST_NAME_PHONETIC            => null,
        X_PERSON_LAST_NAME_PHONETIC             => null,
        X_LANGUAGE_NAME                         => NULL,
        X_CATEGORY_CODE                         => l_party_rec.category_code,
        X_SALUTATION                            => l_party_rec.salutation,
        X_KNOWN_AS2                             => null,
        X_KNOWN_AS3                             => null,
        X_KNOWN_AS4                             => null,
        X_KNOWN_AS5                             => null,
        X_OBJECT_VERSION_NUMBER                 => 1,
        X_DUNS_NUMBER_C                         => null,
        X_CREATED_BY_MODULE                     => p_relationship_rec.created_by_module,
        X_APPLICATION_ID                        => p_relationship_rec.application_id
    );

    x_party_id := l_party_rec.party_id;
    x_party_number := l_party_rec.party_number;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'HZ_PARTIES_PKG.Insert_Row (-) ' ||
                                'x_party_id = ' || x_party_id,
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- update the party_name
    l_party_name := SUBSTRB(l_subject_name || '-' ||
                                l_object_name  || '-' ||
                                x_party_number, 1, 360);

    UPDATE HZ_PARTIES SET PARTY_NAME = l_party_name WHERE PARTY_ID = x_party_id;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'do_create_party (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

END do_create_party;


/*===========================================================================+
 | PROCEDURE
 |              do_update_party
 |
 | DESCRIPTION
 |              Updates person and party for person.
 |
 | SCOPE - PRIVATE
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                    p_party_type
 |              OUT:
 |              x_profile_id
 |          IN/ OUT:
 |                    p_person_rec
 |                    p_organization_rec
 |                    p_group_rec
 |                    p_party_rel_rec
 |                    x_return_status
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |
 +===========================================================================*/

PROCEDURE do_update_party(
    p_party_type                          IN     VARCHAR2,
    p_relationship_rec                    IN     RELATIONSHIP_REC_TYPE,
    p_old_relationship_rec                IN     RELATIONSHIP_REC_TYPE,
    p_party_object_version_number     IN OUT NOCOPY     NUMBER,
    x_profile_id                         OUT NOCOPY     NUMBER,
    x_return_status                   IN OUT NOCOPY     VARCHAR2
) IS

    l_party_rec                                  HZ_PARTY_V2PUB.PARTY_REC_TYPE := p_relationship_rec.party_rec;
    l_rowid                                      ROWID;
    l_party_name                                 HZ_PARTIES.PARTY_NAME%TYPE := FND_API.G_MISS_CHAR;
    l_first_name                                 HZ_PARTIES.PERSON_FIRST_NAME%TYPE;
    l_last_name                                  HZ_PARTIES.PERSON_LAST_NAME%TYPE;
    l_profile_id                                 NUMBER;
    l_effective_start_date                       DATE;
    l_code_assignment_id                         NUMBER;
    l_sic_code                                   HZ_PARTIES.SIC_CODE%TYPE;
    l_sic_code_type                              HZ_PARTIES.SIC_CODE_TYPE%TYPE;
    l_content_source_type                        HZ_RELATIONSHIPS.CONTENT_SOURCE_TYPE%TYPE;
    l_msg_count                                  NUMBER;
    l_msg_data                                   VARCHAR2(2000);
    l_party_object_version_number                NUMBER;
    l_debug_prefix                               VARCHAR2(30);

    db_created_by_module                         HZ_PARTIES.CREATED_BY_MODULE%TYPE;

BEGIN

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'do_update_party (+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- check whether record has been updated by another user.
    BEGIN
        SELECT NVL(OBJECT_VERSION_NUMBER,1),
               ROWID,
               CREATED_BY_MODULE
        INTO   l_party_object_version_number,
               l_rowid,
               db_created_by_module
        FROM   HZ_PARTIES
        WHERE  PARTY_ID = l_party_rec.party_id
        FOR UPDATE OF PARTY_ID NOWAIT;

        -- lock the current record. if the record is locked by some one else,
        -- error out NOCOPY with mesasge indicating that the record has been changed.
        -- get the value of profile_id for the current record in the database.

        IF NOT
            (
             ( p_party_object_version_number IS NULL AND l_party_object_version_number IS NULL )
             OR
             ( p_party_object_version_number IS NOT NULL AND
               l_party_object_version_number IS NOT NULL AND
               p_party_object_version_number = l_party_object_version_number
             )
            )
        THEN
            FND_MESSAGE.SET_NAME('AR', 'HZ_API_RECORD_CHANGED');
            FND_MESSAGE.SET_TOKEN('TABLE', 'hz_parties');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
        END IF;

        p_party_object_version_number := nvl(l_party_object_version_number, 1) + 1;

    EXCEPTION WHEN NO_DATA_FOUND THEN
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_NO_RECORD');
        FND_MESSAGE.SET_TOKEN('RECORD', 'parties');
        FND_MESSAGE.SET_TOKEN('VALUE', NVL(TO_CHAR(l_party_rec.party_id),'null'));
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END;


    HZ_REGISTRY_VALIDATE_V2PUB.validate_party(
                                     'U',
                                     l_party_rec,
                                     p_old_relationship_rec.party_rec,
                                     NVL(db_created_by_module, fnd_api.g_miss_char),
                                     x_return_status);

    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'HZ_PARTIES_PKG.Update_Row (+) ',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- call table handler to update the record
    HZ_PARTIES_PKG.Update_Row (
        X_Rowid                                 => l_rowid,
        X_PARTY_ID                              => l_party_rec.party_id,
        X_PARTY_NUMBER                          => NULL,
        X_PARTY_NAME                            => NULL,
--      X_VALIDATED_FLAG                        => l_party_rec.validated_flag,   -- Bug #6341070
        X_VALIDATED_FLAG                        => NULL,                         -- Set NULL value as per Bug #6341070
        X_PARTY_TYPE                            => p_party_type,
        X_ATTRIBUTE_CATEGORY                    => l_party_rec.attribute_category,
        X_ATTRIBUTE1                            => l_party_rec.attribute1,
        X_ATTRIBUTE2                            => l_party_rec.attribute2,
        X_ATTRIBUTE3                            => l_party_rec.attribute3,
        X_ATTRIBUTE4                            => l_party_rec.attribute4,
        X_ATTRIBUTE5                            => l_party_rec.attribute5,
        X_ATTRIBUTE6                            => l_party_rec.attribute6,
        X_ATTRIBUTE7                            => l_party_rec.attribute7,
        X_ATTRIBUTE8                            => l_party_rec.attribute8,
        X_ATTRIBUTE9                            => l_party_rec.attribute9,
        X_ATTRIBUTE10                           => l_party_rec.attribute10,
        X_ATTRIBUTE11                           => l_party_rec.attribute11,
        X_ATTRIBUTE12                           => l_party_rec.attribute12,
        X_ATTRIBUTE13                           => l_party_rec.attribute13,
        X_ATTRIBUTE14                           => l_party_rec.attribute14,
        X_ATTRIBUTE15                           => l_party_rec.attribute15,
        X_ATTRIBUTE16                           => l_party_rec.attribute16,
        X_ATTRIBUTE17                           => l_party_rec.attribute17,
        X_ATTRIBUTE18                           => l_party_rec.attribute18,
        X_ATTRIBUTE19                           => l_party_rec.attribute19,
        X_ATTRIBUTE20                           => l_party_rec.attribute20,
        X_ATTRIBUTE21                           => l_party_rec.attribute21,
        X_ATTRIBUTE22                           => l_party_rec.attribute22,
        X_ATTRIBUTE23                           => l_party_rec.attribute23,
        X_ATTRIBUTE24                           => l_party_rec.attribute24,
        X_ORIG_SYSTEM_REFERENCE                 => l_party_rec.orig_system_reference,
        X_SIC_CODE                              => null,
        X_HQ_BRANCH_IND                         => null,
        X_CUSTOMER_KEY                          => null,
        X_TAX_REFERENCE                         => null,
        X_JGZZ_FISCAL_CODE                      => null,
        X_PERSON_PRE_NAME_ADJUNCT               => null,
        X_PERSON_FIRST_NAME                     => null,
        X_PERSON_MIDDLE_NAME                    => null,
        X_PERSON_LAST_NAME                      => null,
        X_PERSON_NAME_SUFFIX                    => null,
        X_PERSON_TITLE                          => null,
        X_PERSON_ACADEMIC_TITLE                 => null,
        X_PERSON_PREVIOUS_LAST_NAME             => null,
        X_KNOWN_AS                              => null,
        X_PERSON_IDEN_TYPE                      => null,
        X_PERSON_IDENTIFIER                     => null,
        X_GROUP_TYPE                            => null,
        X_COUNTRY                               => NULL,
        X_ADDRESS1                              => NULL,
        X_ADDRESS2                              => NULL,
        X_ADDRESS3                              => NULL,
        X_ADDRESS4                              => NULL,
        X_CITY                                  => NULL,
        X_POSTAL_CODE                           => NULL,
        X_STATE                                 => NULL,
        X_PROVINCE                              => NULL,
        X_STATUS                                => l_party_rec.status,
        X_COUNTY                                => NULL,
        X_SIC_CODE_TYPE                         => null,
        X_URL                                   => NULL,
        X_EMAIL_ADDRESS                         => NULL,
        X_ANALYSIS_FY                           => null,
        X_FISCAL_YEAREND_MONTH                  => null,
        X_EMPLOYEES_TOTAL                       => null,
        X_CURR_FY_POTENTIAL_REVENUE             => null,
        X_NEXT_FY_POTENTIAL_REVENUE             => null,
        X_YEAR_ESTABLISHED                      => null,
        X_GSA_INDICATOR_FLAG                    => null,
        X_MISSION_STATEMENT                     => null,
        X_ORGANIZATION_NAME_PHONETIC            => null,
        X_PERSON_FIRST_NAME_PHONETIC            => null,
        X_PERSON_LAST_NAME_PHONETIC             => null,
        X_LANGUAGE_NAME                         => NULL,
        X_CATEGORY_CODE                         => l_party_rec.category_code,
        X_SALUTATION                            => l_party_rec.salutation,
        X_KNOWN_AS2                             => null,
        X_KNOWN_AS3                             => null,
        X_KNOWN_AS4                             => null,
        X_KNOWN_AS5                             => null,
        X_OBJECT_VERSION_NUMBER                 => p_party_object_version_number,
        X_DUNS_NUMBER_C                         => null,
        X_CREATED_BY_MODULE                     => p_relationship_rec.created_by_module,
        X_APPLICATION_ID                        => p_relationship_rec.application_id
    );

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'HZ_PARTIES_PKG.Update_Row (-) ',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'do_update_party (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

END do_update_party;


----------------------------
-- body of public procedures
----------------------------

/*===========================================================================+
 | PROCEDURE
 |              create_relationship
 |
 | DESCRIPTION
 |              Creates relationship and party for party_relationship
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                    p_init_msg_list
 |                    p_relationship_rec
 |                    p_create_org_contact
 |                    p_party_usage_code
 |              OUT:
 |                    x_return_status
 |                    x_msg_count
 |                    x_msg_data
 |                    x_party_relationship_id
 |                    x_party_id
 |                    x_party_number
 |          IN/ OUT:
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |    07-DEC-2004.     V.Ravichandran       Bug 3801870. Removed defaulting
 |                                          for the overloading the procedure
 |                                          create_relationship.
 |    04-JAN-2005      Rajib Ranjan Borah   SSM SST Integration and Extension.
 |                                          For non-profile entities, the concept of select
 |                                          /de-select data-sources is obsoleted.
 +===========================================================================*/

PROCEDURE create_relationship (
    p_init_msg_list              IN     VARCHAR2:= FND_API.G_FALSE,
    p_relationship_rec           IN     RELATIONSHIP_REC_TYPE,
    x_relationship_id            OUT    NOCOPY NUMBER,
    x_party_id                   OUT    NOCOPY NUMBER,
    x_party_number               OUT    NOCOPY VARCHAR2,
    x_return_status              OUT    NOCOPY VARCHAR2,
    x_msg_count                  OUT    NOCOPY NUMBER,
    x_msg_data                   OUT    NOCOPY VARCHAR2
) IS

BEGIN

    create_relationship_with_usg (
      p_init_msg_list             => p_init_msg_list,
      p_relationship_rec          => p_relationship_rec,
      p_contact_party_id          => null,
      p_contact_party_usage_code  => null,
      p_create_org_contact        => 'Y',
      x_relationship_id           => x_relationship_id,
      x_party_id                  => x_party_id,
      x_party_number              => x_party_number,
      x_return_status             => x_return_status,
      x_msg_count                 => x_msg_count,
      x_msg_data                  => x_msg_data
    );

END create_relationship;


/*===========================================================================+
 | PROCEDURE
 |              create_relationship
 |
 | DESCRIPTION
 |              Creates relationship and party for party_relationship.
 |              This is the overloaded procedure which accepts the
 |              old signature that doesnt expect the parameter
 |              p_create_org_contact.
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                    p_init_msg_list
 |                    p_relationship_rec
 |                    p_create_org_contact
 |              OUT:
 |                    x_return_status
 |                    x_msg_count
 |                    x_msg_data
 |                    x_relationship_id
 |                    x_party_id
 |                    x_party_number
 |          IN/ OUT:
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |
 |
 +===========================================================================*/

PROCEDURE create_relationship (
    p_init_msg_list              IN     VARCHAR2:= FND_API.G_FALSE,
    p_relationship_rec           IN     RELATIONSHIP_REC_TYPE,
    x_relationship_id            OUT    NOCOPY NUMBER,
    x_party_id                   OUT    NOCOPY NUMBER,
    x_party_number               OUT    NOCOPY VARCHAR2,
    x_return_status              OUT    NOCOPY VARCHAR2,
    x_msg_count                  OUT    NOCOPY NUMBER,
    x_msg_data                   OUT    NOCOPY VARCHAR2,
    p_create_org_contact         IN     VARCHAR2
) IS

BEGIN

    create_relationship_with_usg (
      p_init_msg_list             => p_init_msg_list,
      p_relationship_rec          => p_relationship_rec,
      p_contact_party_id          => null,
      p_contact_party_usage_code  => null,
      p_create_org_contact        => p_create_org_contact,
      x_relationship_id           => x_relationship_id,
      x_party_id                  => x_party_id,
      x_party_number              => x_party_number,
      x_return_status             => x_return_status,
      x_msg_count                 => x_msg_count,
      x_msg_data                  => x_msg_data
    );

END create_relationship;


/*===========================================================================+
 | PROCEDURE
 |              create_relationship_with_usg
 |
 | DESCRIPTION
 |              Creates relationship and party for party_relationship.
 |              It also creates party usage assignment.
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                    p_init_msg_list
 |                    p_relationship_rec
 |                    p_contact_party_id
 |                    p_contact_party_usage_code
 |                    p_create_org_contact
 |              OUT:
 |                    x_return_status
 |                    x_msg_count
 |                    x_msg_data
 |                    x_relationship_id
 |                    x_party_id
 |                    x_party_number
 |          IN/ OUT:
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |
 |
 +===========================================================================*/

PROCEDURE create_relationship_with_usg (
    p_init_msg_list              IN     VARCHAR2:= FND_API.G_FALSE,
    p_relationship_rec           IN     RELATIONSHIP_REC_TYPE,
    p_contact_party_id           IN     NUMBER,
    p_contact_party_usage_code   IN     VARCHAR2,
    p_create_org_contact         IN     VARCHAR2,
    x_relationship_id            OUT    NOCOPY NUMBER,
    x_party_id                   OUT    NOCOPY NUMBER,
    x_party_number               OUT    NOCOPY VARCHAR2,
    x_return_status              OUT    NOCOPY VARCHAR2,
    x_msg_count                  OUT    NOCOPY NUMBER,
    x_msg_data                   OUT    NOCOPY VARCHAR2
) IS

    l_rel_rec                          RELATIONSHIP_REC_TYPE := p_relationship_rec;
    l_created_party                    VARCHAR2(1);

    dss_return_status VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
    dss_msg_count     NUMBER := 0;
    dss_msg_data      VARCHAR2(2000):= null;
    l_test_security   VARCHAR2(1):= 'F';
    l_debug_prefix    VARCHAR2(30) := '';

    -- Bug 3801870.
    l_create_org_contact VARCHAR2(1) := NVL(p_create_org_contact,'Y');

BEGIN

    -- Standard start of API savepoint
    SAVEPOINT create_relationship;

    -- Check if API is called in debug mode. If yes, enable debug.
    --enable_debug;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'create_relationship (+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- Initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;


    -- Bug 2197181: added for mix-n-match project. first load data
    -- sources for this entity. Then assign the actual_content_source
    -- to the real data source. The value of content_source_type is
    -- depended on if data source is seleted. If it is selected, we reset
    -- content_source_type to user-entered. We also check if user
    -- has the privilege to create user-entered data if mix-n-match
    -- is enabled.

    -- Bug 2444678: Removed caching.

    -- IF g_rel_mixnmatch_enabled IS NULL THEN
/* SSM SST Integration and Extension
 * For non-profile entities, the concept of select/de-select data-sources is obsoleted.

    HZ_MIXNM_UTILITY.LoadDataSources(
      p_entity_name                    => 'HZ_RELATIONSHIPS',
      p_entity_attr_id                 => g_rel_entity_attr_id,
      p_mixnmatch_enabled              => g_rel_mixnmatch_enabled,
      p_selected_datasources           => g_rel_selected_datasources );
*/
    -- END IF;

    HZ_MIXNM_UTILITY.AssignDataSourceDuringCreation (
      p_entity_name                    => 'HZ_RELATIONSHIPS',
      p_entity_attr_id                 => g_rel_entity_attr_id,
      p_mixnmatch_enabled              => g_rel_mixnmatch_enabled,
      p_selected_datasources           => g_rel_selected_datasources,
      p_content_source_type            => l_rel_rec.content_source_type,
      p_actual_content_source          => l_rel_rec.actual_content_source,
      x_is_datasource_selected         => g_rel_is_datasource_selected,
      x_return_status                  => x_return_status );

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- Call to business logic.
    do_create_rel(
                  l_rel_rec,
                  l_created_party,
                  x_relationship_id,
                  x_party_id,
                  x_party_number,
                  x_return_status,
                  -- 3801870.
                  l_create_org_contact,
                  p_contact_party_id,
                  p_contact_party_usage_code);

    --
    -- Bug 2486394 -Check if the DSS security is granted to the user
    -- Bug 3818648: do dss check in party context only. check dss
    -- profile before call test_instance.
    --
    IF NVL(fnd_profile.value('HZ_DSS_ENABLED'), 'N') = 'Y' AND
       (l_rel_rec.subject_table_name = 'HZ_PARTIES' OR
        l_rel_rec.object_table_name = 'HZ_PARTIES')
    THEN
      l_test_security :=
           hz_dss_util_pub.test_instance(
                  p_operation_code     => 'INSERT',
                  p_db_object_name     => 'HZ_RELATIONSHIPS',
                  p_instance_pk1_value => x_relationship_id,
                  p_instance_pk2_value => 'F',
                  p_user_name          => fnd_global.user_name,
                  x_return_status      => dss_return_status,
                  x_msg_count          => dss_msg_count,
                  x_msg_data           => dss_msg_data);

       if dss_return_status <> fnd_api.g_ret_sts_success THEN
         RAISE FND_API.G_EXC_ERROR;
       end if;

       if (l_test_security <> 'T' OR l_test_security <> FND_API.G_TRUE) then
        --
        -- Bug 3835601: replaced the dss message with a more user friendly message
        --
        FND_MESSAGE.SET_NAME('AR', 'HZ_DSS_NO_INSERT_PRIVILEGE');
        FND_MESSAGE.SET_TOKEN('ENTITY_NAME',
                              hz_dss_util_pub.get_display_name('HZ_RELATIONSHIPS', null));
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
      end if;
    END IF;


    -- Invoke business event system.

    -- SSM SST Integration and Extension
    -- For non-profile entities, the concept of select/de-select data-sources is obsoleted.
    -- There is no need to check if the data-source is selected.
    IF x_return_status = FND_API.G_RET_STS_SUCCESS /* AND
       -- Bug 2197181: Added below condition for Mix-n-Match
       g_rel_is_datasource_selected = 'Y' */
    THEN
      IF(HZ_UTILITY_V2PUB.G_EXECUTE_API_CALLOUTS in ('EVENTS_ENABLED', 'Y')) THEN
        HZ_BUSINESS_EVENT_V2PVT.create_relationship_event (
          l_rel_rec, l_created_party );
      END IF;

      IF(HZ_UTILITY_V2PUB.G_EXECUTE_API_CALLOUTS in ('EVENTS_ENABLED', 'BO_EVENTS_ENABLED')) THEN
        -- populate function for integration service
        HZ_POPULATE_BOT_PKG.pop_hz_relationships(
          p_operation       => 'I',
          p_RELATIONSHIP_ID => x_relationship_id );
      END IF;
    END IF;

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data  => x_msg_data);

    -- Debug info.
    IF fnd_log.level_exception>=fnd_log.g_current_runtime_level THEN
         hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'WARNING',
                               p_msg_level=>fnd_log.level_exception);
    END IF;
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
                 hz_utility_v2pub.debug(p_message=>'create_relationship (-)',
                                        p_prefix=>l_debug_prefix,
                                        p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- Check if API is called in debug mode. If yes, disable debug.
    --disable_debug;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO create_relationship;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

        -- Debug info.
        IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'ERROR',
                               p_msg_level=>fnd_log.level_error);

        END IF;
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
            hz_utility_v2pub.debug(p_message=>'create_relationship (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
        END IF;

        -- Check if API is called in debug mode. If yes, disable debug.
        --disable_debug;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO create_relationship;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

        -- Debug info.
        IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'UNEXPECTED ERROR',
                               p_msg_level=>fnd_log.level_error);

        END IF;
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
            hz_utility_v2pub.debug(p_message=>'create_relationship (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
        END IF;

        -- Check if API is called in debug mode. If yes, disable debug.
        --disable_debug;

    WHEN OTHERS THEN
        ROLLBACK TO create_relationship;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
        FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
        FND_MSG_PUB.ADD;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

        -- Debug info.
        IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'SQL ERROR',
                               p_msg_level=>fnd_log.level_error);

        END IF;
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
            hz_utility_v2pub.debug(p_message=>'create_relationship (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
        END IF;

        -- Check if API is called in debug mode. If yes, disable debug.
        --disable_debug;

END create_relationship_with_usg;


/*===========================================================================+
 | PROCEDURE
 |              update_relationship
 |
 | DESCRIPTION
 |              Updates relationship and party for party_relationship.
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                    p_init_msg_list
 |                    p_party_rel_rec
 |              OUT:
 |                    x_return_status
 |                    x_msg_count
 |                    x_msg_data
 |          IN/ OUT:
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |
 |    04-JAN-2005      Rajib Ranjan Borah   o SSM SST Integration and Extension.
 |                                            For non-profile entities, the concept of select
 |                                            /de-select data-sources is obsoleted.
 +===========================================================================*/

PROCEDURE update_relationship (
    p_init_msg_list                  IN      VARCHAR2:= FND_API.G_FALSE,
    p_relationship_rec               IN      RELATIONSHIP_REC_TYPE,
    p_object_version_number          IN OUT NOCOPY  NUMBER,
    p_party_object_version_number    IN OUT NOCOPY  NUMBER,
    x_return_status                  OUT NOCOPY     VARCHAR2,
    x_msg_count                      OUT NOCOPY     NUMBER,
    x_msg_data                       OUT NOCOPY     VARCHAR2
) IS

    l_rel_rec                        RELATIONSHIP_REC_TYPE := p_relationship_rec;
    l_old_rel_rec                    RELATIONSHIP_REC_TYPE;
    l_data_source_from               VARCHAR2(30);

    dss_return_status VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
    dss_msg_count     NUMBER := 0;
    dss_msg_data      VARCHAR2(2000):= null;
    l_test_security   VARCHAR2(1):= 'F';
    l_debug_prefix    VARCHAR2(30) := '';

BEGIN

    -- Standard start of API savepoint
    SAVEPOINT update_relationship;

    -- Check if API is called in debug mode. If yes, enable debug.
    --enable_debug;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'update_relationship (+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- Initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Get old records. Will be used by business event system.
    get_relationship_rec (
        p_relationship_id                    => l_rel_rec.relationship_id,
        p_directional_flag                   => 'F',
        x_rel_rec                            => l_old_rel_rec,
        x_return_status                      => x_return_status,
        x_msg_count                          => x_msg_count,
        x_msg_data                           => x_msg_data );

    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    --
    -- Bug 2486394 -Check if the DSS security is granted to the user
    -- Bug 3818648: do dss check in party context only. check dss
    -- profile before call test_instance.
    --
    IF NVL(fnd_profile.value('HZ_DSS_ENABLED'), 'N') = 'Y' AND
       (l_old_rel_rec.subject_table_name = 'HZ_PARTIES' OR
        l_old_rel_rec.object_table_name = 'HZ_PARTIES')
    THEN
      l_test_security :=
           hz_dss_util_pub.test_instance(
                  p_operation_code     => 'UPDATE',
                  p_db_object_name     => 'HZ_RELATIONSHIPS',
                  p_instance_pk1_value => l_rel_rec.relationship_id,
                  p_instance_pk2_value => 'F',
                  p_user_name          => fnd_global.user_name,
                  x_return_status      => dss_return_status,
                  x_msg_count          => dss_msg_count,
                  x_msg_data           => dss_msg_data);

      if dss_return_status <> fnd_api.g_ret_sts_success THEN
         RAISE FND_API.G_EXC_ERROR;
      end if;

      if (l_test_security <> 'T' OR l_test_security <> FND_API.G_TRUE) then
        --
        -- Bug 3835601: replaced the dss message with a more user friendly message
        --
        FND_MESSAGE.SET_NAME('AR', 'HZ_DSS_NO_UPDATE_PRIVILEGE');
        FND_MESSAGE.SET_TOKEN('ENTITY_NAME',
                              hz_dss_util_pub.get_display_name('HZ_RELATIONSHIPS', null));
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
      end if;
    END IF;

    -- Bug 2197181: added for mix-n-match project. first load data
    -- sources for this entity.

    -- Bug 2444678: Removed caching.

/* SSM SST Integration and Extension
 * For non-profile entities, the concept of select/de-select data-sources is obsoleted.
 * There is no need to check if the data-source is selected.
    -- IF g_rel_mixnmatch_enabled IS NULL THEN
    HZ_MIXNM_UTILITY.LoadDataSources(
      p_entity_name                    => 'HZ_RELATIONSHIPS',
      p_entity_attr_id                 => g_rel_entity_attr_id,
      p_mixnmatch_enabled              => g_rel_mixnmatch_enabled,
      p_selected_datasources           => g_rel_selected_datasources );
    -- END IF;

    -- Bug 2197181: added for mix-n-match project.
    -- check if the data source is seleted.

    g_rel_is_datasource_selected :=
      HZ_MIXNM_UTILITY.isDataSourceSelected (
        p_selected_datasources           => g_rel_selected_datasources,
        p_actual_content_source          => l_old_rel_rec.actual_content_source );
*/
    -- Call to business logic.
    do_update_rel(
                  l_rel_rec,
                  l_old_rel_rec,
                  p_object_version_number,
                  p_party_object_version_number,
                  x_return_status);

    -- Call to indicate relationship update to DQM
    HZ_DQM_SYNC.sync_relationship(l_rel_rec.relationship_id, 'U');

    -- Invoke business event system.

    -- SSM SST Integration and Extension
    -- For non-profile entities, the concept of select/de-select data-sources is obsoleted.
    -- There is no need to check if the data-source is selected.

    IF x_return_status = FND_API.G_RET_STS_SUCCESS /* AND
       -- Bug 2197181: Added below condition for Mix-n-Match
       g_rel_is_datasource_selected = 'Y' */
    THEN
      IF(HZ_UTILITY_V2PUB.G_EXECUTE_API_CALLOUTS in ('EVENTS_ENABLED', 'Y')) THEN
        HZ_BUSINESS_EVENT_V2PVT.update_relationship_event (
          l_rel_rec, l_old_rel_rec );
      END IF;

      IF(HZ_UTILITY_V2PUB.G_EXECUTE_API_CALLOUTS in ('EVENTS_ENABLED', 'BO_EVENTS_ENABLED')) THEN
        -- populate function for integration service
        HZ_POPULATE_BOT_PKG.pop_hz_relationships(
          p_operation       => 'U',
          p_RELATIONSHIP_ID => l_rel_rec.relationship_id );
      END IF;
    END IF;

    HZ_UTILITY_V2PUB.G_UPDATE_ACS := NULL;
    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data  => x_msg_data);

    -- Debug info.
    IF fnd_log.level_exception>=fnd_log.g_current_runtime_level THEN
         hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'WARNING',
                               p_msg_level=>fnd_log.level_exception);
    END IF;
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
                 hz_utility_v2pub.debug(p_message=>'update_relationship (-)',
                                        p_prefix=>l_debug_prefix,
                                        p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- Check if API is called in debug mode. If yes, disable debug.
    --disable_debug;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO update_relationship;
        HZ_UTILITY_V2PUB.G_UPDATE_ACS := NULL;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

        -- Debug info.
        IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'ERROR',
                               p_msg_level=>fnd_log.level_error);

        END IF;
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
            hz_utility_v2pub.debug(p_message=>'update_relationship (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
        END IF;

        -- Check if API is called in debug mode. If yes, disable debug.
        --disable_debug;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO update_relationship;
        HZ_UTILITY_V2PUB.G_UPDATE_ACS := NULL;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

        -- Debug info.
        IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'UNEXPECTED ERROR',
                               p_msg_level=>fnd_log.level_error);

        END IF;
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
            hz_utility_v2pub.debug(p_message=>'update_relationship (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
        END IF;

        -- Check if API is called in debug mode. If yes, disable debug.
        --disable_debug;

    WHEN OTHERS THEN
        ROLLBACK TO update_relationship;
        HZ_UTILITY_V2PUB.G_UPDATE_ACS := NULL;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
        FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
        FND_MSG_PUB.ADD;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

        -- Debug info.
        IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'SQL ERROR',
                               p_msg_level=>fnd_log.level_error);

        END IF;
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
            hz_utility_v2pub.debug(p_message=>'update_relationship (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
        END IF;
        -- Check if API is called in debug mode. If yes, disable debug.
        --disable_debug;

END update_relationship;

/*===========================================================================+
 | PROCEDURE
 |              get_relationship_rec
 |
 | DESCRIPTION
 |              Gets relationship and party for party_relationship.
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                    p_init_msg_list
 |                    p_party_rel_rec
 |              OUT:
 |                    x_return_status
 |                    x_msg_count
 |                    x_msg_data
 |          IN/ OUT:
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |
 +===========================================================================*/

PROCEDURE get_relationship_rec (
    p_init_msg_list                         IN     VARCHAR2 := FND_API.G_FALSE,
    p_relationship_id                       IN     NUMBER,
    p_directional_flag                      IN     VARCHAR2 := 'F',
    x_rel_rec                               OUT    NOCOPY RELATIONSHIP_REC_TYPE,
    x_return_status                         OUT NOCOPY    VARCHAR2,
    x_msg_count                             OUT NOCOPY    NUMBER,
    x_msg_data                              OUT NOCOPY    VARCHAR2
) IS

    l_party_id                                       NUMBER;
    l_directional_flag                               VARCHAR2(1);
    l_direction_code                                 VARCHAR2(1);
    l_debug_prefix                                   VARCHAR2(30) := '';

BEGIN

    -- Check if API is called in debug mode. If yes, enable debug.
    --enable_debug;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'get_relationship_rec (+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;


    --Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    --Initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --Check whether primary key has been passed in.
    IF p_relationship_id IS NULL OR
       p_relationship_id = FND_API.G_MISS_NUM THEN
        FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_MISSING_COLUMN' );
        FND_MESSAGE.SET_TOKEN( 'COLUMN', 'relationship_id' );
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    x_rel_rec.relationship_id := p_relationship_id;
    IF p_directional_flag <> 'F'
       AND
       p_directional_flag <> 'B'
    THEN
        l_directional_flag := 'F';
    ELSE
        l_directional_flag := NVL(p_directional_flag, 'F');
    END IF;

    -- Debug info.
    IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_message=>'HZ_RELATIONSHIPS_PKG.Select_Row',
                                  p_prefix =>l_debug_prefix,
                                  p_msg_level=>fnd_log.level_statement);
    END IF;

    HZ_RELATIONSHIPS_PKG.Select_Row (
        X_RELATIONSHIP_ID                       => x_rel_rec.relationship_id,
        X_DIRECTIONAL_FLAG                      => l_directional_flag,
        X_SUBJECT_ID                            => x_rel_rec.subject_id,
        X_SUBJECT_TYPE                          => x_rel_rec.subject_type,
        X_SUBJECT_TABLE_NAME                    => x_rel_rec.subject_table_name,
        X_OBJECT_ID                             => x_rel_rec.object_id,
        X_OBJECT_TYPE                           => x_rel_rec.object_type,
        X_OBJECT_TABLE_NAME                     => x_rel_rec.object_table_name,
        X_PARTY_ID                              => l_party_id,
        X_RELATIONSHIP_CODE                     => x_rel_rec.relationship_code,
        X_COMMENTS                              => x_rel_rec.comments,
        X_START_DATE                            => x_rel_rec.start_date,
        X_END_DATE                              => x_rel_rec.end_date,
        X_STATUS                                => x_rel_rec.status,
        X_ATTRIBUTE_CATEGORY                    => x_rel_rec.attribute_category,
        X_ATTRIBUTE1                            => x_rel_rec.attribute1,
        X_ATTRIBUTE2                            => x_rel_rec.attribute2,
        X_ATTRIBUTE3                            => x_rel_rec.attribute3,
        X_ATTRIBUTE4                            => x_rel_rec.attribute4,
        X_ATTRIBUTE5                            => x_rel_rec.attribute5,
        X_ATTRIBUTE6                            => x_rel_rec.attribute6,
        X_ATTRIBUTE7                            => x_rel_rec.attribute7,
        X_ATTRIBUTE8                            => x_rel_rec.attribute8,
        X_ATTRIBUTE9                            => x_rel_rec.attribute9,
        X_ATTRIBUTE10                           => x_rel_rec.attribute10,
        X_ATTRIBUTE11                           => x_rel_rec.attribute11,
        X_ATTRIBUTE12                           => x_rel_rec.attribute12,
        X_ATTRIBUTE13                           => x_rel_rec.attribute13,
        X_ATTRIBUTE14                           => x_rel_rec.attribute14,
        X_ATTRIBUTE15                           => x_rel_rec.attribute15,
        X_ATTRIBUTE16                           => x_rel_rec.attribute16,
        X_ATTRIBUTE17                           => x_rel_rec.attribute17,
        X_ATTRIBUTE18                           => x_rel_rec.attribute18,
        X_ATTRIBUTE19                           => x_rel_rec.attribute19,
        X_ATTRIBUTE20                           => x_rel_rec.attribute20,
        X_CONTENT_SOURCE_TYPE                   => x_rel_rec.content_source_type,
        X_RELATIONSHIP_TYPE                     => x_rel_rec.relationship_type,
        X_CREATED_BY_MODULE                     => x_rel_rec.created_by_module,
        X_APPLICATION_ID                        => x_rel_rec.application_id,
        X_ADDITIONAL_INFORMATION1               => x_rel_rec.additional_information1,
        X_ADDITIONAL_INFORMATION2               => x_rel_rec.additional_information2,
        X_ADDITIONAL_INFORMATION3               => x_rel_rec.additional_information3,
        X_ADDITIONAL_INFORMATION4               => x_rel_rec.additional_information4,
        X_ADDITIONAL_INFORMATION5               => x_rel_rec.additional_information5,
        X_ADDITIONAL_INFORMATION6               => x_rel_rec.additional_information6,
        X_ADDITIONAL_INFORMATION7               => x_rel_rec.additional_information7,
        X_ADDITIONAL_INFORMATION8               => x_rel_rec.additional_information8,
        X_ADDITIONAL_INFORMATION9               => x_rel_rec.additional_information9,
        X_ADDITIONAL_INFORMATION10               => x_rel_rec.additional_information10,
        X_ADDITIONAL_INFORMATION11               => x_rel_rec.additional_information11,
        X_ADDITIONAL_INFORMATION12               => x_rel_rec.additional_information12,
        X_ADDITIONAL_INFORMATION13               => x_rel_rec.additional_information13,
        X_ADDITIONAL_INFORMATION14               => x_rel_rec.additional_information14,
        X_ADDITIONAL_INFORMATION15               => x_rel_rec.additional_information15,
        X_ADDITIONAL_INFORMATION16               => x_rel_rec.additional_information16,
        X_ADDITIONAL_INFORMATION17               => x_rel_rec.additional_information17,
        X_ADDITIONAL_INFORMATION18               => x_rel_rec.additional_information18,
        X_ADDITIONAL_INFORMATION19               => x_rel_rec.additional_information19,
        X_ADDITIONAL_INFORMATION20               => x_rel_rec.additional_information20,
        X_ADDITIONAL_INFORMATION21               => x_rel_rec.additional_information21,
        X_ADDITIONAL_INFORMATION22               => x_rel_rec.additional_information22,
        X_ADDITIONAL_INFORMATION23               => x_rel_rec.additional_information23,
        X_ADDITIONAL_INFORMATION24               => x_rel_rec.additional_information24,
        X_ADDITIONAL_INFORMATION25               => x_rel_rec.additional_information25,
        X_ADDITIONAL_INFORMATION26               => x_rel_rec.additional_information26,
        X_ADDITIONAL_INFORMATION27               => x_rel_rec.additional_information27,
        X_ADDITIONAL_INFORMATION28               => x_rel_rec.additional_information28,
        X_ADDITIONAL_INFORMATION29               => x_rel_rec.additional_information29,
        X_ADDITIONAL_INFORMATION30               => x_rel_rec.additional_information30,
        X_DIRECTION_CODE                         => l_direction_code,
        X_PERCENTAGE_OWNERSHIP                   => x_rel_rec.percentage_ownership,
        X_ACTUAL_CONTENT_SOURCE                  => x_rel_rec.actual_content_source
    );

    -- Debug info.
    IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_message=>'HZ_PARTY_V2PUB.get_party_rec',
                                  p_prefix =>l_debug_prefix,
                                  p_msg_level=>fnd_log.level_statement);
    END IF;

    IF l_party_id IS NOT NULL
       AND
       l_party_id <> FND_API.G_MISS_NUM
    THEN
        HZ_PARTY_V2PUB.get_party_rec (
                p_party_id                         => l_party_id,
                x_party_rec                        => x_rel_rec.party_rec,
                x_return_status                    => x_return_status,
                x_msg_count                        => x_msg_count,
                x_msg_data                         => x_msg_data
            );

        IF x_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
        ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
    END IF;

    --Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data );

    -- Debug info.
    IF fnd_log.level_exception>=fnd_log.g_current_runtime_level THEN
         hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'WARNING',
                               p_msg_level=>fnd_log.level_exception);
    END IF;
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
                 hz_utility_v2pub.debug(p_message=>'get_relationhsip_rec (-)',
                                        p_prefix=>l_debug_prefix,
                                        p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- Check if API is called in debug mode. If yes, disable debug.
    --disable_debug;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;

        FND_MSG_PUB.Count_And_Get(
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data );

        -- Debug info.
        IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'ERROR',
                               p_msg_level=>fnd_log.level_error);

        END IF;
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
            hz_utility_v2pub.debug(p_message=>'get_relationsip_rec (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
        END IF;

        -- Check if API is called in debug mode. If yes, disable debug.
        --disable_debug;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        FND_MSG_PUB.Count_And_Get(
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data );

        -- Debug info.
        IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'UNEXPECTED ERROR',
                               p_msg_level=>fnd_log.level_error);

        END IF;
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
            hz_utility_v2pub.debug(p_message=>'get_relationsip_rec (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
        END IF;

        -- Check if API is called in debug mode. If yes, disable debug.
        --disable_debug;

    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_OTHERS_EXCEP' );
        FND_MESSAGE.SET_TOKEN( 'ERROR' ,SQLERRM );
        FND_MSG_PUB.ADD;

        FND_MSG_PUB.Count_And_Get(
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data );

        -- Debug info.
        IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'SQL ERROR',
                               p_msg_level=>fnd_log.level_error);

        END IF;
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
            hz_utility_v2pub.debug(p_message=>'get_relationsip_rec (-)' ,
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
        END IF;


        -- Check if API is called in debug mode. If yes, disable debug.
        --disable_debug;

END get_relationship_rec;

END HZ_RELATIONSHIP_V2PUB;

/
