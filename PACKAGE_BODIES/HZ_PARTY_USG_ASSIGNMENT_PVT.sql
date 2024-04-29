--------------------------------------------------------
--  DDL for Package Body HZ_PARTY_USG_ASSIGNMENT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_PARTY_USG_ASSIGNMENT_PVT" AS
/*$Header: ARHPUAPB.pls 120.12 2008/06/11 06:46:36 rgokavar ship $ */

--------------------------------------
-- declaration of private global varibles
--------------------------------------

D_FUTURE_DATE                     CONSTANT DATE := TO_DATE('4712/12/31','YYYY/MM/DD');

G_SETUP_LOADED                    NUMBER(1) := 0;
G_CALLING_API                     VARCHAR2(30);

TYPE INDEX_VARCHAR100_TBL IS TABLE OF VARCHAR2(100) INDEX BY VARCHAR2(100);
TYPE INDEX_NUMBER_TBL IS TABLE OF NUMBER(15) INDEX BY VARCHAR2(30);

G_PARTY_USAGE_CODES               INDEX_VARCHAR100_TBL;
G_CREATED_BY_MODULES              INDEX_NUMBER_TBL;
G_PARTY_USAGE_RULES               INDEX_VARCHAR100_TBL;

TYPE VARCHAR100_TBL IS TABLE OF VARCHAR2(100);
TYPE NUMBER15_TBL IS TABLE OF NUMBER(15);
TYPE DATE_TBL IS TABLE OF DATE;

TYPE ASSIGNMENT_REC_TBL IS TABLE OF party_usg_assignment_rec_type;


--------------------------------------
-- declaration of private procedures and functions
--------------------------------------

PROCEDURE initialize;

PROCEDURE split (
    p_string                      IN     VARCHAR2,
    p_delimiter                   IN     VARCHAR2,
    x_table                       OUT    NOCOPY VARCHAR100_TBL
);

FUNCTION duplicates_exist (
    p_party_usg_assignment_rec    IN     party_usg_assignment_rec_type,
    x_party_usg_assignment_id     OUT    NOCOPY NUMBER
) RETURN VARCHAR2;

PROCEDURE insert_row (
    p_party_usg_assignment_rec    IN     party_usg_assignment_rec_type
);

PROCEDURE update_row (
    p_party_usg_assignment_id     IN     NUMBER,
    p_party_usg_assignment_rec    IN     party_usg_assignment_rec_type,
    p_object_version_number       IN OUT NOCOPY NUMBER,
    p_old_object_version_number   IN     NUMBER,
    p_status                      IN     VARCHAR2
);

FUNCTION violate_exclusive_rules (
    p_party_usage_code            IN     VARCHAR2,
    p_related_party_usage_code    IN     VARCHAR2
) RETURN BOOLEAN;

FUNCTION violate_coexist_rules (
    p_party_usage_code            IN     VARCHAR2,
    p_related_party_usage_code    IN     VARCHAR2
) RETURN BOOLEAN;

FUNCTION has_transition_rules (
    p_party_usage_code            IN     VARCHAR2,
    p_related_party_usage_code    IN     VARCHAR2
) RETURN BOOLEAN;

PROCEDURE populate_bot (
    p_create_update_flag          IN     VARCHAR2,
    p_party_usg_assignment_id     IN     NUMBER
);

--------------------------------------
-- private procedures and functions
--------------------------------------

/**
 * PROCEDURE populate_bot
 *
 * DESCRIPTION
 *     Populate Business Object Tracking table.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   02/24/06      Jianying Huang     o Created.
 *
 */

PROCEDURE populate_bot (
    p_create_update_flag          IN     VARCHAR2,
    p_party_usg_assignment_id     IN     NUMBER
) IS

    c_api_name                    CONSTANT VARCHAR2(30) :=
                                    'populate_bot';
    l_debug_prefix                VARCHAR2(30);

BEGIN

    l_debug_prefix := '';

    -- Debug info.
    IF fnd_log.level_procedure >= fnd_log.g_current_runtime_level THEN
      hz_utility_v2pub.debug (
        p_message                 => c_api_name||' (+)',
        p_prefix                  => l_debug_prefix,
        p_msg_level               => fnd_log.level_procedure);
    END IF;

    -- populate function for integration service
    IF hz_utility_v2pub.G_EXECUTE_API_CALLOUTS IN ('EVENTS_ENABLED', 'BO_EVENTS_ENABLED')
    THEN
      hz_populate_bot_pkg.pop_hz_party_usg_assignments(
        p_operation               => p_create_update_flag,
      P_party_usg_assignment_id   => p_party_usg_assignment_id);
    END IF;

    -- Debug info.
    IF fnd_log.level_procedure >= fnd_log.g_current_runtime_level THEN
      hz_utility_v2pub.debug (
        p_message                 => c_api_name||' (-)',
        p_prefix                  => l_debug_prefix,
        p_msg_level               => fnd_log.level_procedure);
    END IF;

END populate_bot;


/**
 * FUNCTION violate_exclusive_rules
 *
 * DESCRIPTION
 *     Check if violate exclusive rules
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   07/19/05      Jianying Huang     o Created.
 *
 */

FUNCTION violate_exclusive_rules (
    p_party_usage_code            IN     VARCHAR2,
    p_related_party_usage_code    IN     VARCHAR2
) RETURN BOOLEAN IS

    l_return                      BOOLEAN;

BEGIN

    IF (G_PARTY_USAGE_RULES.exists('EXCLUSIVE##'||p_party_usage_code||'##') OR
        G_PARTY_USAGE_RULES.exists('EXCLUSIVE##'||p_related_party_usage_code||'##'))
    THEN
      l_return := TRUE;
    ELSE
      l_return  := FALSE;
    END IF;

    RETURN l_return;

END violate_exclusive_rules;


/**
 * FUNCTION violate_coexist_rules
 *
 * DESCRIPTION
 *     Check if violate co-exist rules
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   07/19/05      Jianying Huang     o Created.
 *
 */

FUNCTION violate_coexist_rules (
    p_party_usage_code            IN     VARCHAR2,
    p_related_party_usage_code    IN     VARCHAR2
) RETURN BOOLEAN IS

    l_return                      BOOLEAN;

BEGIN

    IF (G_PARTY_USAGE_RULES.exists(
          'CANNOT_COEXIST##'||p_party_usage_code||'##'||p_related_party_usage_code) OR
        G_PARTY_USAGE_RULES.exists(
          'CANNOT_COEXIST##'||p_related_party_usage_code||'##'||p_party_usage_code))
    THEN
      l_return := TRUE;
    ELSE
      l_return  := FALSE;
    END IF;

    RETURN l_return;

END violate_coexist_rules;


/**
 * FUNCTION has_transition_rules
 *
 * DESCRIPTION
 *     Check if violate co-exist rules
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   07/19/05      Jianying Huang     o Created.
 *
 */

FUNCTION has_transition_rules (
    p_party_usage_code            IN     VARCHAR2,
    p_related_party_usage_code    IN     VARCHAR2
) RETURN BOOLEAN IS

    l_return                      BOOLEAN;

BEGIN

    IF G_PARTY_USAGE_RULES.exists(
         'TRANSITION_BI##'||
         p_party_usage_code||'##'||p_related_party_usage_code) OR
       G_PARTY_USAGE_RULES.exists(
         'TRANSITION_BI##'||
         p_related_party_usage_code||'##'||p_party_usage_code) OR
       G_PARTY_USAGE_RULES.exists(
         'TRANSITION##'||
         p_party_usage_code||'##'||p_related_party_usage_code)
    THEN
      l_return := TRUE;
    ELSE
      l_return  := FALSE;
    END IF;

    RETURN l_return;

END has_transition_rules;


/**
 * PROCEDURE validate_party_usg_assignment
 *
 * DESCRIPTION
 *     Validate usage assignment.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   05/01/05      Jianying Huang     o Created.
 *
 */

PROCEDURE validate_party_usg_assignment (
    p_create_update_flag          IN     VARCHAR2,
    p_validation_level            IN     NUMBER,
    p_party_usg_assignment_rec    IN     party_usg_assignment_rec_type,
    p_old_usg_assignment_rec      IN     party_usg_assignment_rec_type,
    x_return_status               IN OUT NOCOPY VARCHAR2
) IS

    c_api_name                    CONSTANT VARCHAR2(30) :=
                                    'validate_party_usg_assignment';
    l_debug_prefix                VARCHAR2(30);

    -- party: foreign key
    CURSOR c_party (
      p_party_id                  NUMBER
    ) IS
    SELECT party_type,
           party_name
    FROM   hz_parties
    WHERE  party_id = p_party_id
    AND    status IN ('A', 'I');

    /*
    -- relationship: foreign key
    CURSOR c_relationship (
      p_relationship_id           NUMBER
    ) IS
    SELECT null
    FROM   hz_relationships
    WHERE  relationship_id = p_relationship_id
    AND    status IN ('A', 'I')
    AND    rownum = 1;
    */

    -- assginments
    CURSOR c_assignments (
      p_party_id                  NUMBER
    ) IS
    SELECT party_usage_code
    FROM   hz_party_usg_assignments
    WHERE  party_id = p_party_id;

    db_party_type                 VARCHAR2(30);
    db_party_name                 VARCHAR2(360);
    db_party_usage_status         VARCHAR2(30);
    db_party_usage_type           VARCHAR2(30);
    db_restrict_manual_assign     VARCHAR2(30);
    db_restrict_manual_update     VARCHAR2(30);
    db_party_usage_created_by     NUMBER;
    l_created_by                  NUMBER(15);
    l_party_usage_codes_tbl       VARCHAR100_TBL;
    l_party_usage_code            VARCHAR2(30);
    l_created_by_module           VARCHAR2(150);
    i                             NUMBER;
    l_continue                    VARCHAR2(1);
    l_dummy                       VARCHAR2(30);
    l_value_tbl                   VARCHAR100_TBL;
    l_temp_party_usage_codes      INDEX_VARCHAR100_TBL;

BEGIN

    l_debug_prefix := '';

    -- Debug info.
    IF fnd_log.level_procedure >= fnd_log.g_current_runtime_level THEN
      hz_utility_v2pub.debug (
        p_message                 => c_api_name||' (+)',
        p_prefix                  => l_debug_prefix,
        p_msg_level               => fnd_log.level_procedure);
    END IF;

    -- Debug info.
    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      hz_utility_v2pub.debug(
        p_prefix                => l_debug_prefix,
        p_message               => 'x_return_status = '||x_return_status,
        p_msg_level             => fnd_log.level_statement);
    END IF;

    --
    -- HIGH VALIDATION
    --
    IF p_validation_level >= G_VALID_LEVEL_HIGH THEN
      --
      -- the following validations are only needed when create
      -- a new assignment because all of involved columns
      -- are non-updateable.
      --
      IF p_create_update_flag = 'C' THEN
        --
        -- mandatory: party_id
        --
        hz_utility_v2pub.validate_mandatory (
          p_create_update_flag        => p_create_update_flag,
          p_column                    => 'party_id',
          p_column_value              => p_party_usg_assignment_rec.party_id,
          x_return_status             => x_return_status
        );

        -- Debug info.
        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          hz_utility_v2pub.debug(
            p_prefix                => l_debug_prefix,
            p_message               => 'party_id is a mandatory column. '||
                                       'x_return_status = '||x_return_status,
            p_msg_level             => fnd_log.level_statement);
        END IF;

        --
        -- mandatory: party_usage_code
        --
        hz_utility_v2pub.validate_mandatory (
          p_create_update_flag        => p_create_update_flag,
          p_column                    => 'party_usage_code',
          p_column_value              => p_party_usg_assignment_rec.party_usage_code,
          x_return_status             => x_return_status
        );

        -- Debug info.
        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          hz_utility_v2pub.debug(
            p_prefix                => l_debug_prefix,
            p_message               => 'party_usage_code is a mandatory column. '||
                                      'x_return_status = '||x_return_status,
            p_msg_level             => fnd_log.level_statement);
        END IF;

        --
        -- conditional mandatory: owner_table_name, owner_table_id
        --
        IF p_party_usg_assignment_rec.owner_table_name IS NOT NULL AND
           p_party_usg_assignment_rec.owner_table_name <> fnd_api.G_MISS_CHAR
        THEN
          hz_utility_v2pub.validate_mandatory (
            p_create_update_flag        => p_create_update_flag,
            p_column                    => 'owner_table_id',
            p_column_value              => p_party_usg_assignment_rec.owner_table_id,
            x_return_status             => x_return_status
          );
        END IF;

        IF p_party_usg_assignment_rec.owner_table_id IS NOT NULL AND
           p_party_usg_assignment_rec.owner_table_id <> fnd_api.G_MISS_NUM
        THEN
          hz_utility_v2pub.validate_mandatory (
            p_create_update_flag        => p_create_update_flag,
            p_column                    => 'owner_table_name',
            p_column_value              => p_party_usg_assignment_rec.owner_table_name,
            x_return_status             => x_return_status
          );
        END IF;

        -- Debug info.
        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          hz_utility_v2pub.debug(
            p_prefix                => l_debug_prefix,
            p_message               => 'conditional mandatory: owner_table_name, owner_table_id. '||
                                       'x_return_status = '||x_return_status,
            p_msg_level             => fnd_log.level_statement);
        END IF;

        --
        -- foreign key: owner_table_name, owner_table_id.
        --
        /*
        IF p_owner_table_name = 'HZ_RELATIONSHIPS' THEN
          OPEN c_relationship (p_owner_table_id);
          FETCH c_relationship INTO l_dummy;
          IF c_relationship%NOTFOUND THEN
            fnd_message.set_name('AR', 'HZ_API_INVALID_FK');
            fnd_message.set_token('FK', 'owner_table_id');
            fnd_message.set_token('COLUMN', 'relationship_id');
            fnd_message.set_token('TABLE', 'hz_relationships');
            fnd_msg_pub.add;
            x_return_status := fnd_api.G_RET_STS_ERROR;
          END IF;

          -- Debug info.
          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            hz_utility_v2pub.debug(
              p_prefix                => l_debug_prefix,
              p_message               => 'foreign key check when owner_table_name = HZ_RELATIONSHIPS. '||
                                         'x_return_status = '||x_return_status,
              p_msg_level             => fnd_log.level_statement);
          END IF;
        END IF;
        */

      ELSE -- p_create_update_flag = 'U'
        --
        -- non-updateable: party_id
        --
        hz_utility_v2pub.validate_nonupdateable (
          p_column                    => 'party_id',
          p_column_value              => p_party_usg_assignment_rec.party_id,
          p_old_column_value          => p_old_usg_assignment_rec.party_id,
          x_return_status             => x_return_status
        );

        -- Debug info.
        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          hz_utility_v2pub.debug(
            p_prefix                => l_debug_prefix,
            p_message               => 'party_id is a non-updateable column. '||
                                       'x_return_status = '||x_return_status,
            p_msg_level             => fnd_log.level_statement);
        END IF;

        --
        -- non-updateable: party_usage_code
        --
        hz_utility_v2pub.validate_nonupdateable (
          p_column                    => 'party_usage_code',
          p_column_value              => p_party_usg_assignment_rec.party_usage_code,
          p_old_column_value          => p_old_usg_assignment_rec.party_usage_code,
          x_return_status             => x_return_status
        );

        -- Debug info.
        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          hz_utility_v2pub.debug(
            p_prefix                => l_debug_prefix,
            p_message               => 'party_usage_code is a non-updateable column. '||
                                       'x_return_status = '||x_return_status,
            p_msg_level             => fnd_log.level_statement);
        END IF;

        --
        -- non-updateable: owner_table_name
        --
        hz_utility_v2pub.validate_nonupdateable (
          p_column                    => 'owner_table_name',
          p_column_value              => p_party_usg_assignment_rec.owner_table_name,
          p_old_column_value          => p_old_usg_assignment_rec.owner_table_name,
          x_return_status             => x_return_status
        );

        -- Debug info.
        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          hz_utility_v2pub.debug(
            p_prefix                => l_debug_prefix,
            p_message               => 'owner_table_name is a non-updateable column. '||
                                       'x_return_status = '||x_return_status,
            p_msg_level             => fnd_log.level_statement);
        END IF;

        --
        -- non-updateable: owner_table_id
        --
        hz_utility_v2pub.validate_nonupdateable (
          p_column                    => 'owner_table_id',
          p_column_value              => p_party_usg_assignment_rec.owner_table_id,
          p_old_column_value          => p_old_usg_assignment_rec.owner_table_id,
          x_return_status             => x_return_status
        );

        -- Debug info.
        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          hz_utility_v2pub.debug(
            p_prefix                => l_debug_prefix,
            p_message               => 'owner_table_id is a non-updateable column. '||
                                       'x_return_status = '||x_return_status,
            p_msg_level             => fnd_log.level_statement);
        END IF;

      END IF;   -- p_create_update_flag = 'U'

      --
      -- effective_start_date, effective_end_date
      --   end date can't be ealier then start date
      --
      IF trunc(p_party_usg_assignment_rec.effective_start_date) >
         trunc(p_party_usg_assignment_rec.effective_end_date)
      THEN
        fnd_message.set_name('AR', 'HZ_API_DATE_GREATER');
        fnd_message.set_token('DATE2', 'effective_end_date');
        fnd_message.set_token('DATE1', 'effective_start_date');
        fnd_msg_pub.add;
        x_return_status := fnd_api.G_RET_STS_ERROR;
      END IF;

      -- Debug info.
      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(
          p_prefix                => l_debug_prefix,
          p_message               => 'end date can not be earlier than start date. '||
                                     'x_return_status = '||x_return_status,
          p_msg_level             => fnd_log.level_statement);
      END IF;

      --
      -- mandatory, non-updateable, lookup : created_by_module
      --
      hz_utility_v2pub.validate_created_by_module (
        p_create_update_flag        => p_create_update_flag,
        p_created_by_module         => p_party_usg_assignment_rec.created_by_module,
        p_old_created_by_module     => p_old_usg_assignment_rec.created_by_module,
        x_return_status             => x_return_status
      );

      --
      -- quit when basic validations fail
      --
      IF x_return_status = fnd_api.G_RET_STS_ERROR THEN
        RETURN;
      END IF;

    END IF;  -- HIGH VALIDATION

    IF p_create_update_flag = 'C' THEN
      l_party_usage_code := p_party_usg_assignment_rec.party_usage_code;
      l_created_by_module := p_party_usg_assignment_rec.created_by_module;
    ELSE
      l_party_usage_code := p_old_usg_assignment_rec.party_usage_code;
    END IF;

    --
    -- MEDIUM VALIDATION
    --
    IF p_validation_level >= G_VALID_LEVEL_MEDIUM THEN
      --
      -- foreign key: party_usage_code
      --
      IF G_PARTY_USAGE_CODES.exists(l_party_usage_code) THEN
        split(G_PARTY_USAGE_CODES(l_party_usage_code), '##', l_value_tbl);
        db_party_usage_status := l_value_tbl(1);
        db_party_usage_type := l_value_tbl(2);
        db_restrict_manual_assign := l_value_tbl(3);
        db_restrict_manual_update := l_value_tbl(4);
        db_party_usage_created_by := l_value_tbl(5);

        -- Debug info.
        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          hz_utility_v2pub.debug(
            p_prefix                => l_debug_prefix,
            p_message               => 'foreign key validation for party_usage_code. '||
                                       'db_party_usage_status = '||db_party_usage_status||' '||
                                       'db_party_usage_type = '||db_party_usage_type||' '||
                                       'db_restrict_manual_assign = '||db_restrict_manual_assign||' '||
                                       'db_restrict_manual_update = '||db_restrict_manual_update,
            p_msg_level             => fnd_log.level_statement);
        END IF;
      ELSIF p_create_update_flag = 'C' THEN
        --
        -- invalid foreign key
        --
        fnd_message.set_name('AR', 'HZ_PU_INVALID_PARTY_USAGE_CODE');
        fnd_message.set_token('PARTY_USAGE_CODE', l_party_usage_code);
        fnd_msg_pub.add;
        x_return_status := fnd_api.G_RET_STS_ERROR;
      END IF;

      -- Debug info.
      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(
          p_prefix                => l_debug_prefix,
          p_message               => 'foreign key validation for party_usage_code. '||
                                     'x_return_status = '||x_return_status,
          p_msg_level             => fnd_log.level_statement);
      END IF;

      IF p_create_update_flag = 'C' THEN
        --
        -- inactive party usage code
        --
        IF db_party_usage_status <> 'A' THEN
          fnd_message.set_name('AR', 'HZ_PU_INACTIVE_PARTY_USG_CODE');
          fnd_message.set_token('PARTY_USAGE_CODE', p_party_usg_assignment_rec.party_usage_code);
          fnd_msg_pub.add;
          x_return_status := fnd_api.G_RET_STS_ERROR;
        END IF;

        -- Debug info.
        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          hz_utility_v2pub.debug(
            p_prefix                => l_debug_prefix,
            p_message               => 'inactive party_usage_code. '||
                                       'x_return_status = '||x_return_status,
            p_msg_level             => fnd_log.level_statement);
        END IF;

        --
        -- foreign key: party_id
        --
        OPEN c_party (p_party_usg_assignment_rec.party_id);
        FETCH c_party INTO db_party_type, db_party_name;
        IF (c_party%NOTFOUND) THEN
          fnd_message.set_name('AR', 'HZ_API_INVALID_FK');
          fnd_message.set_token('FK', 'party_id');
          fnd_message.set_token('COLUMN', 'party_id');
          fnd_message.set_token('TABLE', 'hz_parties');
          fnd_msg_pub.add;
          x_return_status := fnd_api.G_RET_STS_ERROR;
        END IF;
        CLOSE c_party;

        -- Debug info.
        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          hz_utility_v2pub.debug(
            p_prefix                => l_debug_prefix,
            p_message               => 'foreign key validation for party_id. '||
                                       'x_return_status = '||x_return_status||' '||
                                       'party_type = '||db_party_type,
            p_msg_level             => fnd_log.level_statement);
        END IF;

        --
        -- party type doesn't match
        --
        IF instrb(db_party_usage_type, db_party_type) = 0 THEN
          fnd_message.set_name('AR', 'HZ_PU_INVALID_PARTY_TYPE');
          fnd_message.set_token('PARTY_USAGE_CODE', p_party_usg_assignment_rec.party_usage_code);
          fnd_message.set_token('PARTY_TYPE', db_party_type);
          fnd_msg_pub.add;
          x_return_status := fnd_api.G_RET_STS_ERROR;
        END IF;

        -- Debug info.
        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          hz_utility_v2pub.debug(
            p_prefix                => l_debug_prefix,
            p_message               => 'party type doesn''t match. '||
                                       'x_return_status = '||x_return_status,
            p_msg_level             => fnd_log.level_statement);
        END IF;

        --
        -- disallow certain usages be used by public API
        --
        IF db_restrict_manual_assign = 'Y' THEN
          IF G_CREATED_BY_MODULES.exists(l_created_by_module) THEN
            l_created_by := G_CREATED_BY_MODULES(l_created_by_module);
          ELSE
            l_created_by := -99;
          END IF;

          --
          -- disallow manual assignment when created_by_module
          -- is not a seeded value and party usage is a seeded one.
          --
          --Bug 7149894: Included 121 in user id validation while validating
          --             Party Usage Assignment.
          IF l_created_by NOT IN (0, 1, 2, 120, 121) AND
             db_party_usage_created_by IN (0, 1, 2, 120, 121)
          THEN
            fnd_message.set_name('AR', 'HZ_PU_SEED_CBM_ASSIGN');
            fnd_message.set_token('PARTY_USAGE_CODE', l_party_usage_code);
            fnd_msg_pub.add;
            x_return_status := fnd_api.G_RET_STS_ERROR;
          END IF;

          -- Debug info.
          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            hz_utility_v2pub.debug(
              p_prefix                => l_debug_prefix,
              p_message               => 'created_by_module is created by . '||
                                         'l_created_by = '||l_created_by||' '||
                                         'x_return_status = '||x_return_status,
              p_msg_level             => fnd_log.level_statement);
          END IF;
        END IF;

        -- Bug 4586451
        --
        IF l_party_usage_code = 'SUPPLIER' AND
           db_party_type='ORGANIZATION' AND
           p_validation_level<>G_VALID_LEVEL_THIRD_MEDIUM
        THEN
          validate_supplier_name (
            p_party_id                => p_party_usg_assignment_rec.party_id,
            p_party_name              => db_party_name,
            x_return_status           => x_return_status);
        END IF;

      ELSE -- p_create_update_flag = 'U'
      --Bug 7149894: Included 121 in user id validation while validating
      --             Party Usage Assignment.
        IF db_restrict_manual_update = 'Y' AND
           G_CALLING_API = 'HZ_PARTY_USG_ASSIGNMENT_PUB' AND
           db_party_usage_created_by IN (0, 1, 2, 120, 121)
        THEN
          fnd_message.set_name('AR', 'HZ_PU_SEED_CBM_UPDATE');
          fnd_message.set_token('PARTY_USAGE_CODE', l_party_usage_code);
          fnd_msg_pub.add;
          x_return_status := fnd_api.G_RET_STS_ERROR;
        END IF;

        -- Debug info.
        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          hz_utility_v2pub.debug(
            p_prefix                => l_debug_prefix,
            p_message               => 'manual update is Y. calling from public API. '||
                                       'x_return_status = '||x_return_status,
            p_msg_level             => fnd_log.level_statement);
        END IF;
      END IF;

    END IF; -- MEDIUM VALIDATION

    --
    -- LOW VALIDATION
    --
    IF p_validation_level >= G_VALID_LEVEL_LOW AND
       p_create_update_flag = 'C'
    THEN
      --
      -- check party usage rules
      --
      IF G_SETUP_LOADED = 3 THEN

        OPEN c_assignments(p_party_usg_assignment_rec.party_id);
        FETCH c_assignments BULK COLLECT INTO
          l_party_usage_codes_tbl;
        CLOSE c_assignments;

        --
        -- the following check are needed only when there
        -- are some existing assignments
        --
        l_continue := 'Y';   i := 1;
        WHILE (i <= l_party_usage_codes_tbl.count AND
               l_continue = 'Y')
        LOOP
          -- Debug info.
          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            hz_utility_v2pub.debug(
              p_prefix                => l_debug_prefix,
              p_message               => 'l_party_usage_codes_tbl('||i||') = '||
                                         l_party_usage_codes_tbl(i),
              p_msg_level             => fnd_log.level_statement);
          END IF;

          IF NOT l_temp_party_usage_codes.exists(l_party_usage_codes_tbl(i)) AND
             l_party_usage_codes_tbl(i) <> l_party_usage_code
          THEN

            -- store dupliate party usage codes into a temporary pl/sql table.
            l_temp_party_usage_codes(l_party_usage_codes_tbl(i)) := 'Y';

            --
            -- check exclusive rule
            -- check co-exist rule
            --
            IF (violate_exclusive_rules(
                  l_party_usage_code, l_party_usage_codes_tbl(i)) OR
                violate_coexist_rules(
                  l_party_usage_code, l_party_usage_codes_tbl(i)))
            THEN
              fnd_message.set_name('AR', 'HZ_PU_EXCLUSIVE_RULE_FAILED');
              fnd_message.set_token('EXISTING_PARTY_USAGE_CODE', l_party_usage_codes_tbl(i));
              fnd_message.set_token('NEW_PARTY_USAGE_CODE', l_party_usage_code);
              fnd_msg_pub.add;
              x_return_status := fnd_api.G_RET_STS_ERROR;

              l_continue := 'N';
            END IF;

            -- Debug info.
            IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
              hz_utility_v2pub.debug(
                p_prefix                => l_debug_prefix,
                p_message               => 'check exclusive and co-exist rule. '||
                                           'x_return_status = '||x_return_status,
                p_msg_level             => fnd_log.level_statement);
            END IF;

          END IF;

          i := i + 1;
        END LOOP;
      END IF;

    END IF; -- LOW VALIDATION

    -- Debug info.
    IF fnd_log.level_procedure >= fnd_log.g_current_runtime_level THEN
      hz_utility_v2pub.debug (
        p_message                 => c_api_name||' (-)',
        p_prefix                  => l_debug_prefix,
        p_msg_level               => fnd_log.level_procedure);
    END IF;

END validate_party_usg_assignment;


/**
 * PRIVATE PROCEDURE duplicates_exist
 *
 * DESCRIPTION
 *     Private procedure to check if there is any duplicates
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * MODIFICATION HISTORY
 *
 *   05/01/05      Jianying Huang     o Created.
 *
 */

FUNCTION duplicates_exist (
    p_party_usg_assignment_rec    IN     party_usg_assignment_rec_type,
    x_party_usg_assignment_id     OUT    NOCOPY NUMBER
) RETURN VARCHAR2 IS

    c_api_name                    CONSTANT VARCHAR2(30) := 'duplicates_exist';
    l_debug_prefix                VARCHAR2(30);

    -- search by owner_table_name/owner_table_id
    CURSOR c_duplicate_assignment0 (
      p_party_id                  NUMBER,
      p_party_usage_code          VARCHAR2,
      p_owner_table_name          VARCHAR2,
      p_owner_table_id            NUMBER
    ) IS
    SELECT party_usg_assignment_id
    FROM   hz_party_usg_assignments
    WHERE  owner_table_name = p_owner_table_name
    AND    owner_table_id = p_owner_table_id
    AND    party_id = p_party_id
    AND    party_usage_code = p_party_usage_code
    AND    rownum = 1;

    -- search by party id/party usage code
    CURSOR c_duplicate_assignment1 (
      p_party_id                  NUMBER,
      p_party_usage_code          VARCHAR2,
      p_effective_start_date      DATE,
      p_effective_end_date        DATE
    ) IS
    SELECT party_usg_assignment_id
    FROM   hz_party_usg_assignments
    WHERE  party_id = p_party_id
    AND    party_usage_code = p_party_usage_code
    AND    status_flag = 'A'
    AND    p_effective_start_date BETWEEN
             effective_start_date AND effective_end_date
    AND    effective_end_date >= p_effective_end_date
    AND    rownum = 1;

    l_has_duplicates              VARCHAR2(1);
    l_assignment_id               NUMBER(15);

BEGIN

    l_debug_prefix := '';

    -- Debug info.
    IF fnd_log.level_procedure >= fnd_log.g_current_runtime_level THEN
      hz_utility_v2pub.debug (
        p_message                 => c_api_name||' (+)',
        p_prefix                  => l_debug_prefix,
        p_msg_level               => fnd_log.level_procedure);
    END IF;

    l_has_duplicates := 'N';

    -- check duplicate assignment
    --
    -- check owner_table_name, owner_table_id
    --
    IF p_party_usg_assignment_rec.owner_table_name IS NOT NULL AND
       p_party_usg_assignment_rec.owner_table_name <> fnd_api.G_MISS_CHAR AND
       p_party_usg_assignment_rec.owner_table_id IS NOT NULL AND
       p_party_usg_assignment_rec.owner_table_id <> fnd_api.G_MISS_NUM
    THEN
      -- Debug info.
      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(
          p_prefix                => l_debug_prefix,
          p_message               => 'owner_table_name, owner_table_id are passed in for this usage. '||
                                     'Check duplicate assignment.',
          p_msg_level             => fnd_log.level_statement);
      END IF;

      OPEN c_duplicate_assignment0 (
        p_party_usg_assignment_rec.party_id,
        p_party_usg_assignment_rec.party_usage_code,
        p_party_usg_assignment_rec.owner_table_name,
        p_party_usg_assignment_rec.owner_table_id
      );
      FETCH c_duplicate_assignment0 INTO l_assignment_id;
      IF c_duplicate_assignment0%FOUND THEN
        -- duplicate exist. won't assign the current usage.
        l_has_duplicates := 'Y';
        x_party_usg_assignment_id := l_assignment_id;
      END IF;
      CLOSE c_duplicate_assignment0;
    --
    -- check party_id, party_usage_code, effective_start_date, effective_end_date
    --
    ELSIF p_party_usg_assignment_rec.party_id IS NOT NULL AND
       p_party_usg_assignment_rec.party_id <> fnd_api.G_MISS_NUM AND
       p_party_usg_assignment_rec.party_usage_code IS NOT NULL AND
       p_party_usg_assignment_rec.party_usage_code <> fnd_api.G_MISS_CHAR
    THEN
      -- Debug info.
      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(
          p_prefix                => l_debug_prefix,
          p_message               => 'No date tracking for this usage '||
                                     p_party_usg_assignment_rec.party_usage_code||'. '||
                                     'Check duplicate assignment.',
          p_msg_level             => fnd_log.level_statement);
      END IF;

      OPEN c_duplicate_assignment1 (
        p_party_usg_assignment_rec.party_id,
        p_party_usg_assignment_rec.party_usage_code,
        p_party_usg_assignment_rec.effective_start_date,
        p_party_usg_assignment_rec.effective_end_date
      );
      FETCH c_duplicate_assignment1 INTO l_assignment_id;
      IF c_duplicate_assignment1%FOUND THEN
        -- duplicate exist. won't assign the current usage.
        l_has_duplicates := 'Y';
        x_party_usg_assignment_id := l_assignment_id;
      END IF;
      CLOSE c_duplicate_assignment1;
    END IF;

    -- Debug info.
    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      hz_utility_v2pub.debug(
        p_prefix                => l_debug_prefix,
        p_message               => 'l_has_duplicates = '||l_has_duplicates,
        p_msg_level             => fnd_log.level_statement);
    END IF;

    -- Debug info.
    IF fnd_log.level_procedure >= fnd_log.g_current_runtime_level THEN
      hz_utility_v2pub.debug (
        p_message                 => c_api_name||' (-)',
        p_prefix                  => l_debug_prefix,
        p_msg_level               => fnd_log.level_procedure);
    END IF;

    return l_has_duplicates;

END duplicates_exist;


/**
 * PRIVATE PROCEDURE do_assign_party_usage
 *
 * DESCRIPTION
 *     Private procedure to create party usage assignment
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * MODIFICATION HISTORY
 *
 *   05/01/05      Jianying Huang     o Created.
 *
 */

PROCEDURE do_assign_party_usage (
    p_validation_level            IN     NUMBER,
    p_party_usg_assignment_rec    IN OUT NOCOPY party_usg_assignment_rec_type,
    x_return_status               IN OUT NOCOPY VARCHAR2
) IS

    c_api_name                    CONSTANT VARCHAR2(30) := 'do_assign_party_usage';
    l_debug_prefix                VARCHAR2(30);

    CURSOR c_assignments (
      p_party_id                  NUMBER
    ) IS
    SELECT party_usg_assignment_id,
           party_usage_code,
           effective_start_date
    FROM   hz_party_usg_assignments
    WHERE  party_id = p_party_id
    AND    status_flag = 'A'
    AND    trunc(sysdate) between
             effective_start_date and effective_end_date;

    l_party_usg_assignment_id_tbl NUMBER15_TBL;
    l_party_usage_code_tbl        VARCHAR100_TBL;
    l_start_date_tbl              DATE_TBL;
    l_party_usg_assignment_rec    party_usg_assignment_rec_type;
    l_object_version_number       NUMBER;
    l_continue                    VARCHAR2(1);
    i                             NUMBER;
    l_has_duplicates              VARCHAR2(1);
    l_dummy                       NUMBER(15);
    l_status                      VARCHAR2(1);


BEGIN

    l_debug_prefix := '';

    -- Debug info.
    IF fnd_log.level_procedure >= fnd_log.g_current_runtime_level THEN
      hz_utility_v2pub.debug (
        p_message                 => c_api_name||' (+)',
        p_prefix                  => l_debug_prefix,
        p_msg_level               => fnd_log.level_procedure);
    END IF;

    -- load setup data
    IF G_SETUP_LOADED = 0 THEN
      initialize;
    END IF;

    -- check dates.
    IF p_party_usg_assignment_rec.effective_start_date IS NULL OR
       p_party_usg_assignment_rec.effective_start_date = fnd_api.G_MISS_DATE
    THEN
       p_party_usg_assignment_rec.effective_start_date := trunc(sysdate);
    ELSE
       p_party_usg_assignment_rec.effective_start_date :=
         trunc(p_party_usg_assignment_rec.effective_start_date);
    END IF;

    IF p_party_usg_assignment_rec.effective_end_date IS NULL OR
       p_party_usg_assignment_rec.effective_end_date = fnd_api.G_MISS_DATE
    THEN
       p_party_usg_assignment_rec.effective_end_date := D_FUTURE_DATE;
    ELSE
       p_party_usg_assignment_rec.effective_end_date :=
         trunc(p_party_usg_assignment_rec.effective_end_date);
    END IF;

    -- Debug info.
    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      hz_utility_v2pub.debug(
        p_prefix                => l_debug_prefix,
        p_message               => 'effective_start_date = '||
                                   TO_CHAR(p_party_usg_assignment_rec.effective_start_date, 'YYYY/MM/DD')||' '||
                                   'effective_end_date = '||
                                   TO_CHAR(p_party_usg_assignment_rec.effective_end_date, 'YYYY/MM/DD'),
        p_msg_level             => fnd_log.level_statement);
    END IF;

    --
    -- Do validation
    --
    IF p_validation_level > G_VALID_LEVEL_NONE THEN
      validate_party_usg_assignment (
        p_create_update_flag        => 'C',
        p_validation_level          => p_validation_level,
        p_party_usg_assignment_rec  => p_party_usg_assignment_rec,
        p_old_usg_assignment_rec    => l_party_usg_assignment_rec,
        x_return_status             => x_return_status
      );

      IF x_return_status <> fnd_api.G_RET_STS_SUCCESS THEN
        RAISE fnd_api.G_EXC_ERROR;
      END IF;
    END IF;

    --
    -- return if there is any duplicates exist
    --
    l_has_duplicates := duplicates_exist(p_party_usg_assignment_rec, l_dummy);

    IF l_has_duplicates = 'Y' THEN
      RETURN;
    END IF;

    --
    -- handle transition rule. per talk with vinoo, we will not adjust the dates.
    -- we just inactivate existing assignments.
    --
    l_continue := 'Y';

    IF G_SETUP_LOADED >= 2 THEN

      OPEN c_assignments (p_party_usg_assignment_rec.party_id);
      FETCH c_assignments BULK COLLECT INTO
        l_party_usg_assignment_id_tbl,
        l_party_usage_code_tbl, l_start_date_tbl;
      CLOSE c_assignments;

      SAVEPOINT party_usage_transition;

      i := 1;
      WHILE i <= l_party_usg_assignment_id_tbl.count AND
            l_continue = 'Y'
      LOOP
        -- Bug 4954932: transition rule indicates that by assigning
        -- the related party usage, the existing usage will be end-dated
        IF has_transition_rules(
             l_party_usage_code_tbl(i),
             p_party_usg_assignment_rec.party_usage_code)
        THEN
          l_party_usg_assignment_rec.effective_end_date := trunc(sysdate);
          IF l_start_date_tbl(i) = trunc(sysdate) THEN
            l_status := 'I';
          ELSE
            l_status := 'A';
          END IF;

          -- don't need to compare object version number here.
          l_object_version_number := null;

          update_row (
            p_party_usg_assignment_id   => l_party_usg_assignment_id_tbl(i),
            p_party_usg_assignment_rec  => l_party_usg_assignment_rec,
            p_object_version_number     => l_object_version_number,
            p_old_object_version_number => null,
            p_status                    => l_status
          );
        -- Bug 4954932: transition rule indicates that by assigning
        -- the related party usage, the existing usage will be end-dated
        ELSIF G_PARTY_USAGE_RULES.exists(
                'TRANSITION##'||
                p_party_usg_assignment_rec.party_usage_code||'##'||
                l_party_usage_code_tbl(i))
        THEN
          l_continue := 'N';
          ROLLBACK TO party_usage_transition;
        END IF;

        i := i + 1;

      END LOOP;

    END IF;

    --
    -- create party usage assignment
    --
    IF l_continue = 'Y' THEN
      insert_row (
        p_party_usg_assignment_rec  => p_party_usg_assignment_rec
      );
    END IF;

    -- Debug info.
    IF fnd_log.level_procedure >= fnd_log.g_current_runtime_level THEN
      hz_utility_v2pub.debug (
        p_message                 => c_api_name||' (-)',
        p_prefix                  => l_debug_prefix,
        p_msg_level               => fnd_log.level_procedure);
    END IF;

END do_assign_party_usage;


/**
 * PRIVATE PROCEDURE do_update_usg_assignment
 *
 * DESCRIPTION
 *     Private procedure to update party usage assignment
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * MODIFICATION HISTORY
 *
 *   05/01/05      Jianying Huang     o Created.
 *
 */

PROCEDURE do_update_usg_assignment (
    p_validation_level            IN     NUMBER,
    p_usg_assignment_id_tbl       IN     NUMBER15_TBL,
    p_party_usg_assignment_rec    IN OUT NOCOPY party_usg_assignment_rec_type,
    p_old_usg_assignment_rec_tbl  IN     ASSIGNMENT_REC_TBL,
    x_return_status               IN OUT NOCOPY VARCHAR2
) IS

    c_api_name                    CONSTANT VARCHAR2(30) := 'do_update_usg_assignment';
    l_debug_prefix                VARCHAR2(30);
    l_object_version_number       NUMBER;

    CURSOR c_assignments (
      p_party_id                  NUMBER
    ) IS
    SELECT party_usg_assignment_id,
           party_usage_code,
           effective_start_date
    FROM   hz_party_usg_assignments
    WHERE  party_id = p_party_id
    AND    status_flag = 'A'
    AND    trunc(sysdate) between
             effective_start_date and effective_end_date;

    l_party_usg_assignment_id_tbl NUMBER15_TBL;
    l_party_usage_code_tbl        VARCHAR100_TBL;
    l_start_date_tbl              DATE_TBL;
    l_party_usg_assignment_rec    party_usg_assignment_rec_type;
    l_object_version_number1      NUMBER;
    l_continue                    VARCHAR2(1);
    j                             NUMBER;
    l_status                      VARCHAR2(1);

BEGIN

    l_debug_prefix := '';

    -- Debug info.
    IF fnd_log.level_procedure >= fnd_log.g_current_runtime_level THEN
      hz_utility_v2pub.debug (
        p_message                 => c_api_name||' (+)',
        p_prefix                  => l_debug_prefix,
        p_msg_level               => fnd_log.level_procedure);
    END IF;

    -- load setup data
    IF G_SETUP_LOADED = 0 THEN
      initialize;
    END IF;

    FOR i IN 1..p_usg_assignment_id_tbl.count LOOP
      l_object_version_number := null;
      l_object_version_number1 := null;

      -- check dates.
      IF p_party_usg_assignment_rec.effective_start_date IS NULL OR
         p_party_usg_assignment_rec.effective_start_date = fnd_api.G_MISS_DATE
      THEN
         p_party_usg_assignment_rec.effective_start_date :=
           p_old_usg_assignment_rec_tbl(i).effective_start_date;
      ELSE
         p_party_usg_assignment_rec.effective_start_date :=
           trunc(p_party_usg_assignment_rec.effective_start_date);
      END IF;

      IF p_party_usg_assignment_rec.effective_end_date IS NOT NULL AND
         p_party_usg_assignment_rec.effective_end_date <> fnd_api.G_MISS_DATE
      THEN
         p_party_usg_assignment_rec.effective_end_date :=
           trunc(p_party_usg_assignment_rec.effective_end_date);
      ELSIF p_party_usg_assignment_rec.effective_end_date IS NULL THEN
         p_party_usg_assignment_rec.effective_end_date :=
           p_old_usg_assignment_rec_tbl(i).effective_end_date;
      ELSE
         p_party_usg_assignment_rec.effective_end_date := D_FUTURE_DATE;
      END IF;

      -- Debug info.
      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(
          p_prefix                => l_debug_prefix,
          p_message               => 'effective_start_date = '||
                                     TO_CHAR(p_party_usg_assignment_rec.effective_start_date, 'YYYY/MM/DD')||' '||
                                     'effective_end_date = '||
                                     TO_CHAR(p_party_usg_assignment_rec.effective_end_date, 'YYYY/MM/DD'),
          p_msg_level             => fnd_log.level_statement);
      END IF;

      --
      -- Do validation
      --
      IF p_validation_level > G_VALID_LEVEL_NONE THEN
        validate_party_usg_assignment (
          p_create_update_flag        => 'U',
          p_validation_level          => p_validation_level,
          p_party_usg_assignment_rec  => p_party_usg_assignment_rec,
          p_old_usg_assignment_rec    => p_old_usg_assignment_rec_tbl(i),
          x_return_status             => x_return_status
        );

        IF x_return_status <> fnd_api.G_RET_STS_SUCCESS THEN
          RAISE fnd_api.G_EXC_ERROR;
        END IF;
      END IF;

      --
      -- handle transition rule. per talk with vinoo, we will not adjust the dates.
      -- we just inactivate existing assignments.
      --
      l_continue := 'Y';

      IF G_SETUP_LOADED >= 2 AND
         p_party_usg_assignment_rec.effective_end_date = D_FUTURE_DATE
      THEN

        OPEN c_assignments (p_party_usg_assignment_rec.party_id);
        FETCH c_assignments BULK COLLECT INTO
          l_party_usg_assignment_id_tbl,
          l_party_usage_code_tbl, l_start_date_tbl;
        CLOSE c_assignments;

        SAVEPOINT party_usage_transition;

        j := 1;
        WHILE j <= l_party_usg_assignment_id_tbl.count AND
              l_continue = 'Y'
        LOOP
          -- Bug 4954932: transition rule indicates that by assigning
          -- the related party usage, the existing usage will be end-dated
          IF has_transition_rules(
               l_party_usage_code_tbl(j),
               p_party_usg_assignment_rec.party_usage_code)
          THEN
            l_party_usg_assignment_rec.effective_end_date := trunc(sysdate);
            IF l_start_date_tbl(j) = trunc(sysdate) THEN
              l_status := 'I';
            ELSE
              l_status := 'A';
            END IF;

            -- don't need to compare object version number here.
            l_object_version_number1 := null;

            update_row (
              p_party_usg_assignment_id   => l_party_usg_assignment_id_tbl(j),
              p_party_usg_assignment_rec  => l_party_usg_assignment_rec,
              p_object_version_number     => l_object_version_number1,
              p_old_object_version_number => null,
              p_status                    => l_status
            );
          -- Bug 4954932: transition rule indicates that by assigning
          -- the related party usage, the existing usage will be end-dated
          ELSIF G_PARTY_USAGE_RULES.exists(
                  'TRANSITION##'||
                  p_party_usg_assignment_rec.party_usage_code||'##'||
                  l_party_usage_code_tbl(j))
          THEN
            l_continue := 'N';
            ROLLBACK TO party_usage_transition;
          END IF;

          j := j + 1;

        END LOOP;
      END IF;

      --
      -- update party usage assignment
      --
      IF l_continue = 'Y' THEN
        update_row (
          p_party_usg_assignment_id   => p_usg_assignment_id_tbl(i),
          p_party_usg_assignment_rec  => p_party_usg_assignment_rec,
          p_object_version_number     => l_object_version_number,
          p_old_object_version_number => null,
          p_status                    => null
        );
      END IF;
    END LOOP;

    -- Debug info.
    IF fnd_log.level_procedure >= fnd_log.g_current_runtime_level THEN
      hz_utility_v2pub.debug (
        p_message                 => c_api_name||' (-)',
        p_prefix                  => l_debug_prefix,
        p_msg_level               => fnd_log.level_procedure);
    END IF;

END do_update_usg_assignment;


/**
 * PROCEDURE initialize
 *
 * DESCRIPTION
 *     cache setup.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   05/01/05      Jianying Huang     o Created.
 *
 */

PROCEDURE initialize IS

    c_api_name                    CONSTANT VARCHAR2(30) := 'initialize';
    l_debug_prefix                VARCHAR2(30);

    -- load party usages
    CURSOR c_party_usages IS
    SELECT party_usage_code,
           party_usage_type,
           status_flag,
           restrict_manual_assign_flag,
           restrict_manual_update_flag,
           created_by
    FROM   hz_party_usages_b;

    -- load rules
    CURSOR c_exist_exclusive_rules IS
    SELECT null
    FROM   hz_party_usage_rules
    WHERE  (party_usage_rule_type = 'EXCLUSIVE' OR
            party_usage_rule_type = 'CANNOT_COEXIST')
    AND    trunc(sysdate) between
             effective_start_date AND effective_end_date
    AND    rownum = 1;

    CURSOR c_party_usage_rules IS
    SELECT party_usage_rule_type||'##'||
           party_usage_code||'##'||
           related_party_usage_code
    FROM   hz_party_usage_rules
    WHERE  trunc(sysdate) between
             effective_start_date AND effective_end_date;

    -- load created by module
    CURSOR c_created_by_module IS
    SELECT lookup_code, created_by
    FROM   fnd_lookup_values
    WHERE  lookup_type = 'HZ_CREATED_BY_MODULES'
    AND    view_application_id = 222
    AND    language = userenv('LANG')
    AND    enabled_flag = 'Y'
    AND    trunc(sysdate) BETWEEN
            trunc(nvl(start_date_active, sysdate)) AND
            trunc(nvl(end_date_active, sysdate));

    l_party_usages_tbl            VARCHAR100_TBL;
    l_party_usage_type_tbl        VARCHAR100_TBL;
    l_party_usage_status_tbl      VARCHAR100_TBL;
    l_restrict_manual_assign_tbl  VARCHAR100_TBL;
    l_restrict_manual_update_tbl  VARCHAR100_TBL;
    l_party_usage_created_by_tbl  NUMBER15_TBL;
    l_party_usage_rules_tbl       VARCHAR100_TBL;
    l_created_by_module_tbl       VARCHAR100_TBL;
    l_created_by_tbl              NUMBER15_TBL;
    l_dummy                       VARCHAR2(1);

BEGIN

    l_debug_prefix := '';

    -- Debug info.
    IF fnd_log.level_procedure >= fnd_log.g_current_runtime_level THEN
      hz_utility_v2pub.debug (
        p_message                 => c_api_name||' (+)',
        p_prefix                  => l_debug_prefix,
        p_msg_level               => fnd_log.level_procedure);
    END IF;

    G_PARTY_USAGE_CODES.delete;
    G_CREATED_BY_MODULES.delete;
    G_PARTY_USAGE_RULES.delete;

    --
    -- load set up data
    --

    -- load party usages
    OPEN c_party_usages;
    FETCH c_party_usages BULK COLLECT INTO
      l_party_usages_tbl, l_party_usage_type_tbl,
      l_party_usage_status_tbl, l_restrict_manual_assign_tbl,
      l_restrict_manual_update_tbl, l_party_usage_created_by_tbl;
    CLOSE c_party_usages;

    FOR i IN 1..l_party_usages_tbl.count LOOP
      G_PARTY_USAGE_CODES(l_party_usages_tbl(i)) :=
        l_party_usage_status_tbl(i)||'##'||
        l_party_usage_type_tbl(i)||'##'||
        l_restrict_manual_assign_tbl(i)||'##'||
        l_restrict_manual_update_tbl(i)||'##'||
        l_party_usage_created_by_tbl(i);
    END LOOP;

    -- load created by module
    OPEN c_created_by_module;
    FETCH c_created_by_module BULK COLLECT INTO
      l_created_by_module_tbl, l_created_by_tbl;
    CLOSE c_created_by_module;

    FOR i IN 1..l_created_by_module_tbl.count LOOP
      G_CREATED_BY_MODULES(l_created_by_module_tbl(i)) := l_created_by_tbl(i);
    END LOOP;

    G_SETUP_LOADED := 1;

    -- load party usage rule
    OPEN c_party_usage_rules;
    FETCH c_party_usage_rules BULK COLLECT INTO l_party_usage_rules_tbl;
    CLOSE c_party_usage_rules;

    IF l_party_usage_rules_tbl.count > 0 THEN
      FOR i IN 1..l_party_usage_rules_tbl.count LOOP
        G_PARTY_USAGE_RULES(l_party_usage_rules_tbl(i)) := 'Y';
      END LOOP;

      --
      -- have rules defined
      --
      G_SETUP_LOADED := 2;

      -- check if there is any exclusive or co-exist rule
      OPEN c_exist_exclusive_rules;
      FETCH c_exist_exclusive_rules INTO l_dummy;
      IF c_exist_exclusive_rules%FOUND THEN
        G_SETUP_LOADED := 3;
      END IF;
      CLOSE c_exist_exclusive_rules;

    END IF;

    -- Debug info.
    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      hz_utility_v2pub.debug(
        p_prefix                => l_debug_prefix,
        p_message               => 'G_SETUP_LOADED = '||G_SETUP_LOADED,
        p_msg_level             => fnd_log.level_statement);
    END IF;

    -- Debug info.
    IF fnd_log.level_procedure >= fnd_log.g_current_runtime_level THEN
      hz_utility_v2pub.debug (
        p_message                 => c_api_name||' (-)',
        p_prefix                  => l_debug_prefix,
        p_msg_level               => fnd_log.level_procedure);
    END IF;

END initialize;


/**
 * PROCEDURE insert_row
 *
 * DESCRIPTION
 *     Insert a new assignment.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   05/01/05      Jianying Huang     o Created.
 *
 */

PROCEDURE insert_row (
    p_party_usg_assignment_rec    IN     party_usg_assignment_rec_type
) IS

    c_api_name                    CONSTANT VARCHAR2(30) := 'insert_row';
    l_debug_prefix                VARCHAR2(30);
    l_party_usg_assignment_id     NUMBER(15);

BEGIN

    l_debug_prefix := '';

    -- Debug info.
    IF fnd_log.level_procedure >= fnd_log.g_current_runtime_level THEN
      hz_utility_v2pub.debug (
        p_message                 => c_api_name||' (+)',
        p_prefix                  => l_debug_prefix,
        p_msg_level               => fnd_log.level_procedure);
    END IF;

    HZ_PARTY_USG_ASSIGNMENTS_PKG.insert_row (
      x_party_id                  => p_party_usg_assignment_rec.party_id,
      x_party_usage_code          => p_party_usg_assignment_rec.party_usage_code,
      x_effective_start_date      => p_party_usg_assignment_rec.effective_start_date,
      x_effective_end_date        => p_party_usg_assignment_rec.effective_end_date,
      x_status_flag               => 'A',
      x_comments                  => p_party_usg_assignment_rec.comments,
      x_owner_table_name          => p_party_usg_assignment_rec.owner_table_name,
      x_owner_table_id            => p_party_usg_assignment_rec.owner_table_id,
      x_attribute_category        => p_party_usg_assignment_rec.attribute_category,
      x_attribute1                => p_party_usg_assignment_rec.attribute1,
      x_attribute2                => p_party_usg_assignment_rec.attribute2,
      x_attribute3                => p_party_usg_assignment_rec.attribute3,
      x_attribute4                => p_party_usg_assignment_rec.attribute4,
      x_attribute5                => p_party_usg_assignment_rec.attribute5,
      x_attribute6                => p_party_usg_assignment_rec.attribute6,
      x_attribute7                => p_party_usg_assignment_rec.attribute7,
      x_attribute8                => p_party_usg_assignment_rec.attribute8,
      x_attribute9                => p_party_usg_assignment_rec.attribute9,
      x_attribute10               => p_party_usg_assignment_rec.attribute10,
      x_attribute11               => p_party_usg_assignment_rec.attribute11,
      x_attribute12               => p_party_usg_assignment_rec.attribute12,
      x_attribute13               => p_party_usg_assignment_rec.attribute13,
      x_attribute14               => p_party_usg_assignment_rec.attribute14,
      x_attribute15               => p_party_usg_assignment_rec.attribute15,
      x_attribute16               => p_party_usg_assignment_rec.attribute16,
      x_attribute17               => p_party_usg_assignment_rec.attribute17,
      x_attribute18               => p_party_usg_assignment_rec.attribute18,
      x_attribute19               => p_party_usg_assignment_rec.attribute19,
      x_attribute20               => p_party_usg_assignment_rec.attribute20,
      x_object_version_number     => 1,
      x_created_by_module         => p_party_usg_assignment_rec.created_by_module,
      x_application_id            => fnd_global.resp_appl_id,
      x_party_usg_assignment_id   => l_party_usg_assignment_id
    );

    -- populate business object tracking table
    populate_bot(
      p_create_update_flag        => 'I',
      p_party_usg_assignment_id   => l_party_usg_assignment_id);

    -- Debug info.
    IF fnd_log.level_procedure >= fnd_log.g_current_runtime_level THEN
      hz_utility_v2pub.debug (
        p_message                 => c_api_name||' (-)',
        p_prefix                  => l_debug_prefix,
        p_msg_level               => fnd_log.level_procedure);
    END IF;

END insert_row;


/**
 * PROCEDURE update_row
 *
 * DESCRIPTION
 *     Update a new assignment.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   05/01/05      Jianying Huang     o Created.
 *
 */

PROCEDURE update_row (
    p_party_usg_assignment_id     IN     NUMBER,
    p_party_usg_assignment_rec    IN     party_usg_assignment_rec_type,
    p_object_version_number       IN OUT NOCOPY NUMBER,
    p_old_object_version_number   IN     NUMBER,
    p_status                      IN     VARCHAR2
) IS

    c_api_name                    CONSTANT VARCHAR2(30) := 'update_row';
    l_debug_prefix                VARCHAR2(30);

    CURSOR c_assignment (
      p_party_usg_assignment_id   NUMBER
    ) IS
    SELECT object_version_number
    FROM   hz_party_usg_assignments
    WHERE  party_usg_assignment_id = p_party_usg_assignment_id
    FOR UPDATE NOWAIT;

    l_object_version_number       NUMBER;

BEGIN

    l_debug_prefix := '';

    -- Debug info.
    IF fnd_log.level_procedure >= fnd_log.g_current_runtime_level THEN
      hz_utility_v2pub.debug (
        p_message                 => c_api_name||' (+)',
        p_prefix                  => l_debug_prefix,
        p_msg_level               => fnd_log.level_procedure);
    END IF;

    OPEN c_assignment(p_party_usg_assignment_id);
    FETCH c_assignment INTO l_object_version_number;
    CLOSE c_assignment;

    IF p_object_version_number IS NOT NULL THEN
      IF p_old_object_version_number IS NOT NULL THEN
        l_object_version_number := p_old_object_version_number;
      END IF;

      IF p_object_version_number <> l_object_version_number THEN
        fnd_message.set_name('AR', 'HZ_API_RECORD_CHANGED');
        fnd_message.set_token('TABLE', 'hz_party_usg_assignments');
        fnd_msg_pub.add;
        RAISE fnd_api.g_exc_error;
      END IF;
    END IF;

    p_object_version_number := l_object_version_number + 1;

    HZ_PARTY_USG_ASSIGNMENTS_PKG.update_row (
      x_party_usg_assignment_id   => p_party_usg_assignment_id,
      x_party_id                  => null,
      x_party_usage_code          => null,
      x_effective_start_date      => p_party_usg_assignment_rec.effective_start_date,
      x_effective_end_date        => p_party_usg_assignment_rec.effective_end_date,
      x_status_flag               => p_status,
      x_comments                  => p_party_usg_assignment_rec.comments,
      x_owner_table_name          => null,
      x_owner_table_id            => null,
      x_attribute_category        => p_party_usg_assignment_rec.attribute_category,
      x_attribute1                => p_party_usg_assignment_rec.attribute1,
      x_attribute2                => p_party_usg_assignment_rec.attribute2,
      x_attribute3                => p_party_usg_assignment_rec.attribute3,
      x_attribute4                => p_party_usg_assignment_rec.attribute4,
      x_attribute5                => p_party_usg_assignment_rec.attribute5,
      x_attribute6                => p_party_usg_assignment_rec.attribute6,
      x_attribute7                => p_party_usg_assignment_rec.attribute7,
      x_attribute8                => p_party_usg_assignment_rec.attribute8,
      x_attribute9                => p_party_usg_assignment_rec.attribute9,
      x_attribute10               => p_party_usg_assignment_rec.attribute10,
      x_attribute11               => p_party_usg_assignment_rec.attribute11,
      x_attribute12               => p_party_usg_assignment_rec.attribute12,
      x_attribute13               => p_party_usg_assignment_rec.attribute13,
      x_attribute14               => p_party_usg_assignment_rec.attribute14,
      x_attribute15               => p_party_usg_assignment_rec.attribute15,
      x_attribute16               => p_party_usg_assignment_rec.attribute16,
      x_attribute17               => p_party_usg_assignment_rec.attribute17,
      x_attribute18               => p_party_usg_assignment_rec.attribute18,
      x_attribute19               => p_party_usg_assignment_rec.attribute19,
      x_attribute20               => p_party_usg_assignment_rec.attribute20,
      x_object_version_number     => p_object_version_number
    );

    -- populate business object tracking table
    populate_bot(
      p_create_update_flag        => 'U',
      p_party_usg_assignment_id   => p_party_usg_assignment_id);

    -- Debug info.
    IF fnd_log.level_procedure >= fnd_log.g_current_runtime_level THEN
      hz_utility_v2pub.debug (
        p_message                 => c_api_name||' (-)',
        p_prefix                  => l_debug_prefix,
        p_msg_level               => fnd_log.level_procedure);
    END IF;

END update_row;


/**
 * PROCEDURE split
 *
 * DESCRIPTION
 *     Split a string via delimiter.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   05/01/05      Jianying Huang     o Created.
 *
 */

PROCEDURE split (
    p_string                      IN     VARCHAR2,
    p_delimiter                   IN     VARCHAR2,
    x_table                       OUT    NOCOPY VARCHAR100_TBL
) IS

    l_length                      NUMBER;
    l_dlength                     NUMBER;
    l_start                       NUMBER;
    l_counter                     NUMBER;
    l_index                       NUMBER;

BEGIN

    x_table := VARCHAR100_TBL();
    l_length := lengthb(p_string);
    l_dlength := lengthb(p_delimiter);

    l_start := 1;   l_counter := 1;   l_index := 1;
    WHILE (l_start <= l_length AND l_index > 0)
    LOOP
      l_index := instrb(p_string, p_delimiter, l_start);
      IF l_index <> 0 THEN
        x_table.extend(1);
        x_table(l_counter) := substr(p_string, l_start, l_index - l_start);
        l_start := l_index + l_dlength;
        l_counter := l_counter + 1;
      END IF;
    END LOOP;

    IF l_start <= l_length THEN
      x_table.extend(1);
      x_table(l_counter) := substrb(p_string, l_start);
    END IF;

END split;


--------------------------------------
-- public procedures and functions
--------------------------------------

/**
 * PROCEDURE assign_party_usage
 *
 * DESCRIPTION
 *     Creates party usage assignment.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list            Initialize message stack if it is set to
 *                                fnd_api.G_TRUE. Default is fnd_api.G_FALSE.
 *     p_validation_level         Validation level. Default is full validation.
 *     p_party_usg_assignment_rec Party usage assignment record.
 *   IN/OUT:
 *   OUT:
 *     x_return_status            Return status after the call. The status can
 *                                be fnd_api.G_RET_STS_SUCCESS (success),
 *                                fnd_api.G_RET_STS_ERROR (error),
 *                                fnd_api.G_RET_STS_UNEXP_ERROR (unexpected error).
 *     x_msg_count                Number of messages in message stack.
 *     x_msg_data                 Message text if x_msg_count is 1.
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   05/01/05      Jianying Huang     o Created.
 *
 */

PROCEDURE assign_party_usage (
    p_init_msg_list               IN     VARCHAR2,
    p_validation_level            IN     NUMBER,
    p_party_usg_assignment_rec    IN     party_usg_assignment_rec_type,
    x_return_status               OUT    NOCOPY VARCHAR2,
    x_msg_count                   OUT    NOCOPY NUMBER,
    x_msg_data                    OUT    NOCOPY VARCHAR2
) IS

    c_api_name                    CONSTANT VARCHAR2(30) := 'assign_party_usage';
    l_debug_prefix                VARCHAR2(30);
    l_validation_level            NUMBER(3);
    l_party_usg_assignment_rec    party_usg_assignment_rec_type;

BEGIN

    -- standard start of API savepoint
    SAVEPOINT assign_party_usage;

    l_debug_prefix := '';

    -- Debug info.
    IF fnd_log.level_procedure >= fnd_log.g_current_runtime_level THEN
      hz_utility_v2pub.debug (
        p_message                 => c_api_name||' (+)',
        p_prefix                  => l_debug_prefix,
        p_msg_level               => fnd_log.level_procedure
      );
    END IF;

    -- initialize message list if p_init_msg_list is set to TRUE.
    IF p_init_msg_list IS NOT NULL AND
       fnd_api.To_Boolean(p_init_msg_list)
    THEN
      fnd_msg_pub.initialize;
    END IF;

    -- initialize validation level
    IF p_validation_level IS NULL THEN
      l_validation_level := G_VALID_LEVEL_FULL;
    ELSE
      l_validation_level := p_validation_level;
    END IF;

    -- initialize API return status to success.
    x_return_status := fnd_api.G_RET_STS_SUCCESS;

    -- call to business logic.
    l_party_usg_assignment_rec := p_party_usg_assignment_rec;

    do_assign_party_usage (
      p_validation_level           => l_validation_level,
      p_party_usg_assignment_rec   => l_party_usg_assignment_rec,
      x_return_status              => x_return_status
    );

    -- standard call to get message count and if count is 1, get message info.
    fnd_msg_pub.Count_And_Get (
      p_encoded                   => fnd_api.G_FALSE,
      p_count                     => x_msg_count,
      p_data                      => x_msg_data);

    -- Debug info.
    IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
      hz_utility_v2pub.debug_return_messages (
        p_msg_count               => x_msg_count,
        p_msg_data                => x_msg_data,
        p_msg_type                => 'WARNING',
        p_msg_level               => fnd_log.level_exception
      );
    END IF;

    IF fnd_log.level_procedure >= fnd_log.g_current_runtime_level THEN
      hz_utility_v2pub.debug (
        p_message                 => c_api_name||' (-)',
        p_prefix                  => l_debug_prefix,
        p_msg_level               => fnd_log.level_procedure
      );
    END IF;

EXCEPTION
    WHEN fnd_api.G_EXC_ERROR THEN
      ROLLBACK TO assign_party_usage;
      x_return_status := fnd_api.G_RET_STS_ERROR;

      fnd_msg_pub.Count_And_Get (
        p_encoded                 => fnd_api.G_FALSE,
        p_count                   => x_msg_count,
        p_data                    => x_msg_data
      );

      -- Debug info.
      IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages (
          p_msg_count             => x_msg_count,
          p_msg_data              => x_msg_data,
          p_msg_type              => 'ERROR',
          p_msg_level             => fnd_log.level_error
        );
      END IF;

      IF fnd_log.level_procedure >= fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug (
          p_message               => c_api_name||' (-)',
          p_prefix                => l_debug_prefix,
          p_msg_level             => fnd_log.level_procedure
        );
      END IF;

    WHEN fnd_api.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO assign_party_usage;
      x_return_status := fnd_api.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.Count_And_Get (
        p_encoded                 => fnd_api.G_FALSE,
        p_count                   => x_msg_count,
        p_data                    => x_msg_data
      );

      -- Debug info.
      IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages (
          p_msg_count             => x_msg_count,
          p_msg_data              => x_msg_data,
          p_msg_type              => 'UNEXPECTED ERROR',
          p_msg_level             => fnd_log.level_error
        );
      END IF;

      IF fnd_log.level_procedure >= fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug (
          p_message               => c_api_name||' (-)',
          p_prefix                => l_debug_prefix,
          p_msg_level             => fnd_log.level_procedure
        );
      END IF;

    WHEN OTHERS THEN
      ROLLBACK TO assign_party_usage;
      x_return_status := fnd_api.G_RET_STS_UNEXP_ERROR;

      fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
      fnd_message.set_token('ERROR' ,SQLERRM);
      fnd_msg_pub.add;

      fnd_msg_pub.Count_And_Get (
        p_encoded                 => fnd_api.G_FALSE,
        p_count                   => x_msg_count,
        p_data                    => x_msg_data
      );

      -- Debug info.
      IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages (
          p_msg_count             => x_msg_count,
          p_msg_data              => x_msg_data,
          p_msg_type              => 'SQL ERROR',
          p_msg_level             => fnd_log.level_error
        );
      END IF;

      IF fnd_log.level_procedure >= fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug (
          p_message               => c_api_name||' (-)',
          p_prefix                => l_debug_prefix,
          p_msg_level             => fnd_log.level_procedure
        );
      END IF;

END assign_party_usage;


/**
 * PROCEDURE get_usg_assignment
 *
 * DESCRIPTION
 *     Get party usage assignment.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list            Initialize message stack if it is set to
 *                                fnd_api.G_TRUE. Default is fnd_api.G_FALSE.
 *     p_party_usg_assignment_id  Party usage assignment Id.
 *     p_party_usg_assignment_rec Party usage assignment record.
 *   IN/OUT:
 *   OUT:
 *     x_usg_assignment_id_tbl    Table of party usage assignment Id.
 *     x_usg_assignment_rec_tbl   Table of party usage assignment record.
 *     x_return_status            Return status after the call. The status can
 *                                be fnd_api.G_RET_STS_SUCCESS (success),
 *                                fnd_api.G_RET_STS_ERROR (error),
 *                                fnd_api.G_RET_STS_UNEXP_ERROR (unexpected error).
 *     x_msg_count                Number of messages in message stack.
 *     x_msg_data                 Message text if x_msg_count is 1.
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   05/01/05      Jianying Huang     o Created.
 *
 */

PROCEDURE get_usg_assignment (
    p_init_msg_list               IN     VARCHAR2 DEFAULT NULL,
    p_party_usg_assignment_id     IN     NUMBER,
    p_party_usg_assignment_rec    IN     party_usg_assignment_rec_type,
    x_usg_assignment_id_tbl       OUT    NOCOPY NUMBER15_TBL,
    x_usg_assignment_rec_tbl      OUT    NOCOPY ASSIGNMENT_REC_TBL,
    x_return_status               OUT    NOCOPY VARCHAR2,
    x_msg_count                   OUT    NOCOPY NUMBER,
    x_msg_data                    OUT    NOCOPY VARCHAR2
) IS

    c_api_name                    CONSTANT VARCHAR2(30) := 'get_usg_assignment';
    l_debug_prefix                VARCHAR2(30);

    TYPE assignment_cursor_type IS REF CURSOR RETURN hz_party_usg_assignments%ROWTYPE;
    c_assignment                  assignment_cursor_type;
    assignment_row                hz_party_usg_assignments%ROWTYPE;
    l_counter                     NUMBER;
    l_search_by                   VARCHAR2(30);

BEGIN

    l_debug_prefix := '';

    -- Debug info.
    IF fnd_log.level_procedure >= fnd_log.g_current_runtime_level THEN
      hz_utility_v2pub.debug (
        p_message                 => c_api_name||' (+)',
        p_prefix                  => l_debug_prefix,
        p_msg_level               => fnd_log.level_procedure
      );
    END IF;

    -- initialize message list if p_init_msg_list is set to TRUE.
    IF p_init_msg_list IS NOT NULL AND
       fnd_api.to_Boolean(p_init_msg_list)
    THEN
      fnd_msg_pub.initialize;
    END IF;

    -- initialize API return status to success.
    x_return_status := fnd_api.G_RET_STS_SUCCESS;

    x_usg_assignment_id_tbl := NUMBER15_TBL();
    x_usg_assignment_rec_tbl := ASSIGNMENT_REC_TBL();

    -- check assignment id
    --
    IF p_party_usg_assignment_id IS NOT NULL AND
       p_party_usg_assignment_id <> fnd_api.G_MISS_NUM
    THEN
      l_search_by := 'ASSIGNMENT_ID';
      OPEN c_assignment FOR
        SELECT *
        FROM   hz_party_usg_assignments
        WHERE  party_usg_assignment_id = p_party_usg_assignment_id;
    --
    -- check party_id, party_usage_code
    --
    ELSIF p_party_usg_assignment_rec.party_usage_code IS NOT NULL AND
       p_party_usg_assignment_rec.party_usage_code <> fnd_api.G_MISS_CHAR AND
       p_party_usg_assignment_rec.party_id IS NOT NULL AND
       p_party_usg_assignment_rec.party_id <> fnd_api.G_MISS_NUM
    THEN
      l_search_by := 'USAGE_CODE';
      OPEN c_assignment FOR
        SELECT *
        FROM   hz_party_usg_assignments
        WHERE  party_id = p_party_usg_assignment_rec.party_id
        AND    party_usage_code = p_party_usg_assignment_rec.party_usage_code
        AND    status_flag = 'A'
        AND    effective_end_date > trunc(sysdate);
    --
    -- check owner_table_name, owner_table_id
    --
    ELSIF p_party_usg_assignment_rec.owner_table_name IS NOT NULL AND
          p_party_usg_assignment_rec.owner_table_name <> fnd_api.G_MISS_CHAR AND
          p_party_usg_assignment_rec.owner_table_id IS NOT NULL AND
          p_party_usg_assignment_rec.owner_table_id <> fnd_api.G_MISS_NUM
    THEN
      l_search_by := 'OWNER_TABLE_NAME';
      OPEN c_assignment FOR
        SELECT *
        FROM   hz_party_usg_assignments
        WHERE  owner_table_name = p_party_usg_assignment_rec.owner_table_name
        AND    owner_table_id = p_party_usg_assignment_rec.owner_table_id;
     -- need required parameters
    --
    ELSE
      fnd_message.set_name('AR', 'HZ_PU_MISSING_COLUMN');
      fnd_msg_pub.add;
      RAISE fnd_api.G_EXC_ERROR;
    END IF;

    l_counter := 0;
    LOOP
      FETCH c_assignment INTO assignment_row;
      EXIT WHEN c_assignment%NOTFOUND;

      l_counter := l_counter + 1;
      IF l_counter > 1 AND
         l_search_by IN ('USAGE_CODE', 'ASSIGNMENT_ID')
      THEN
        EXIT;
      END IF;

      x_usg_assignment_id_tbl.extend(1);
      x_usg_assignment_rec_tbl.extend(1);

      x_usg_assignment_id_tbl(l_counter) := assignment_row.party_usg_assignment_id;
      x_usg_assignment_rec_tbl(l_counter).party_id := assignment_row.party_id;
      x_usg_assignment_rec_tbl(l_counter).party_usage_code := assignment_row.party_usage_code;
      x_usg_assignment_rec_tbl(l_counter).effective_start_date := assignment_row.effective_start_date;
      x_usg_assignment_rec_tbl(l_counter).effective_end_date := assignment_row.effective_end_date;
      x_usg_assignment_rec_tbl(l_counter).comments := assignment_row.comments;
      x_usg_assignment_rec_tbl(l_counter).owner_table_name := assignment_row.owner_table_name;
      x_usg_assignment_rec_tbl(l_counter).owner_table_id := assignment_row.owner_table_id;
      x_usg_assignment_rec_tbl(l_counter).created_by_module := assignment_row.created_by_module;
      x_usg_assignment_rec_tbl(l_counter).attribute_category := assignment_row.attribute_category;
      x_usg_assignment_rec_tbl(l_counter).attribute1 := assignment_row.attribute1;
      x_usg_assignment_rec_tbl(l_counter).attribute2 := assignment_row.attribute2;
      x_usg_assignment_rec_tbl(l_counter).attribute3 := assignment_row.attribute3;
      x_usg_assignment_rec_tbl(l_counter).attribute4 := assignment_row.attribute4;
      x_usg_assignment_rec_tbl(l_counter).attribute5 := assignment_row.attribute5;
      x_usg_assignment_rec_tbl(l_counter).attribute6 := assignment_row.attribute6;
      x_usg_assignment_rec_tbl(l_counter).attribute7 := assignment_row.attribute7;
      x_usg_assignment_rec_tbl(l_counter).attribute8 := assignment_row.attribute8;
      x_usg_assignment_rec_tbl(l_counter).attribute9 := assignment_row.attribute9;
      x_usg_assignment_rec_tbl(l_counter).attribute10 := assignment_row.attribute10;
      x_usg_assignment_rec_tbl(l_counter).attribute11 := assignment_row.attribute11;
      x_usg_assignment_rec_tbl(l_counter).attribute12 := assignment_row.attribute12;
      x_usg_assignment_rec_tbl(l_counter).attribute13 := assignment_row.attribute13;
      x_usg_assignment_rec_tbl(l_counter).attribute14 := assignment_row.attribute14;
      x_usg_assignment_rec_tbl(l_counter).attribute15 := assignment_row.attribute15;
      x_usg_assignment_rec_tbl(l_counter).attribute16 := assignment_row.attribute16;
      x_usg_assignment_rec_tbl(l_counter).attribute17 := assignment_row.attribute17;
      x_usg_assignment_rec_tbl(l_counter).attribute18 := assignment_row.attribute18;
      x_usg_assignment_rec_tbl(l_counter).attribute19 := assignment_row.attribute19;
      x_usg_assignment_rec_tbl(l_counter).attribute20 := assignment_row.attribute20;

    END LOOP;
    CLOSE c_assignment;

    --
    -- more than one assignment exist
    --
    IF l_counter > 1 AND
       l_search_by IN ('USAGE_CODE', 'ASSIGNMENT_ID')
    THEN
      fnd_message.set_name('AR', 'HZ_PU_MULTIPLE_ASSIGNMENT');
      fnd_msg_pub.add;
      RAISE fnd_api.G_EXC_ERROR;
    --
    -- no assignment exist
    --
    ELSIF l_counter = 0 THEN
      fnd_message.set_name('AR', 'HZ_PU_INVALID_ASSIGNMENT');
      fnd_msg_pub.add;
      RAISE fnd_api.G_EXC_ERROR;
    END IF;

    -- standard call to get message count and if count is 1, get message info.
    fnd_msg_pub.Count_And_Get (
      p_encoded                   => fnd_api.G_FALSE,
      p_count                     => x_msg_count,
      p_data                      => x_msg_data);

    -- Debug info.
    IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
      hz_utility_v2pub.debug_return_messages (
        p_msg_count               => x_msg_count,
        p_msg_data                => x_msg_data,
        p_msg_type                => 'WARNING',
        p_msg_level               => fnd_log.level_exception
      );
    END IF;

    IF fnd_log.level_procedure >= fnd_log.g_current_runtime_level THEN
      hz_utility_v2pub.debug (
        p_message                 => c_api_name||' (-)',
        p_prefix                  => l_debug_prefix,
        p_msg_level               => fnd_log.level_procedure
      );
    END IF;

EXCEPTION
    WHEN fnd_api.G_EXC_ERROR THEN
      x_return_status := fnd_api.G_RET_STS_ERROR;

      fnd_msg_pub.Count_And_Get (
        p_encoded                 => fnd_api.G_FALSE,
        p_count                   => x_msg_count,
        p_data                    => x_msg_data
      );

      -- Debug info.
      IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages (
          p_msg_count             => x_msg_count,
          p_msg_data              => x_msg_data,
          p_msg_type              => 'ERROR',
          p_msg_level             => fnd_log.level_error
        );
      END IF;

      IF fnd_log.level_procedure >= fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug (
          p_message               => c_api_name||' (-)',
          p_prefix                => l_debug_prefix,
          p_msg_level             => fnd_log.level_procedure
        );
      END IF;

    WHEN fnd_api.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := fnd_api.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.Count_And_Get (
        p_encoded                 => fnd_api.G_FALSE,
        p_count                   => x_msg_count,
        p_data                    => x_msg_data
      );

      -- Debug info.
      IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages (
          p_msg_count             => x_msg_count,
          p_msg_data              => x_msg_data,
          p_msg_type              => 'UNEXPECTED ERROR',
          p_msg_level             => fnd_log.level_error
        );
      END IF;

      IF fnd_log.level_procedure >= fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug (
          p_message               => c_api_name||' (-)',
          p_prefix                => l_debug_prefix,
          p_msg_level             => fnd_log.level_procedure
        );
      END IF;

    WHEN OTHERS THEN
      x_return_status := fnd_api.G_RET_STS_UNEXP_ERROR;

      fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
      fnd_message.set_token('ERROR' ,SQLERRM);
      fnd_msg_pub.add;

      fnd_msg_pub.Count_And_Get (
        p_encoded                 => fnd_api.G_FALSE,
        p_count                   => x_msg_count,
        p_data                    => x_msg_data
      );

      -- Debug info.
      IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages (
          p_msg_count             => x_msg_count,
          p_msg_data              => x_msg_data,
          p_msg_type              => 'SQL ERROR',
          p_msg_level             => fnd_log.level_error
        );
      END IF;

      IF fnd_log.level_procedure >= fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug (
          p_message               => c_api_name||' (-)',
          p_prefix                => l_debug_prefix,
          p_msg_level             => fnd_log.level_procedure
        );
      END IF;

END get_usg_assignment;


/**
 * PROCEDURE update_usg_assignment
 *
 * DESCRIPTION
 *     Update party usage assignment.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list            Initialize message stack if it is set to
 *                                fnd_api.G_TRUE. Default is fnd_api.G_FALSE.
 *     p_validation_level         Validation level. Default is full validation.
 *     p_party_usg_assignment_id  Party usage assignment Id.
 *     p_party_usg_assignment_rec Party usage assignment record.
 *   IN/OUT:
 *   OUT:
 *     x_return_status            Return status after the call. The status can
 *                                be fnd_api.G_RET_STS_SUCCESS (success),
 *                                fnd_api.G_RET_STS_ERROR (error),
 *                                fnd_api.G_RET_STS_UNEXP_ERROR (unexpected error).
 *     x_msg_count                Number of messages in message stack.
 *     x_msg_data                 Message text if x_msg_count is 1.
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   05/01/05      Jianying Huang     o Created.
 *
 */

PROCEDURE update_usg_assignment (
    p_init_msg_list               IN     VARCHAR2,
    p_validation_level            IN     NUMBER,
    p_party_usg_assignment_id     IN     NUMBER,
    p_party_usg_assignment_rec    IN     party_usg_assignment_rec_type,
    x_return_status               OUT    NOCOPY VARCHAR2,
    x_msg_count                   OUT    NOCOPY NUMBER,
    x_msg_data                    OUT    NOCOPY VARCHAR2
) IS

    c_api_name                    CONSTANT VARCHAR2(30) := 'update_usg_assignment';
    l_debug_prefix                VARCHAR2(30);
    l_validation_level            NUMBER(3);
    l_party_usg_assignment_rec    party_usg_assignment_rec_type;
    l_usg_assignment_id_tbl       NUMBER15_TBL;
    l_usg_assignment_rec_tbl      ASSIGNMENT_REC_TBL;

BEGIN

    -- standard start of API savepoint
    SAVEPOINT update_usg_assignment;

    l_debug_prefix := '';

    -- Debug info.
    IF fnd_log.level_procedure >= fnd_log.g_current_runtime_level THEN
      hz_utility_v2pub.debug (
        p_message                 => c_api_name||' (+)',
        p_prefix                  => l_debug_prefix,
        p_msg_level               => fnd_log.level_procedure
      );
    END IF;

    -- initialize message list if p_init_msg_list is set to TRUE.
    IF p_init_msg_list IS NOT NULL AND
       fnd_api.to_Boolean(p_init_msg_list)
    THEN
      fnd_msg_pub.initialize;
    END IF;

    -- initialize validation level
    IF p_validation_level IS NULL THEN
      l_validation_level := G_VALID_LEVEL_FULL;
    ELSE
      l_validation_level := p_validation_level;
    END IF;

    -- initialize API return status to success.
    x_return_status := fnd_api.G_RET_STS_SUCCESS;

    -- get old assignment.
    get_usg_assignment(
      p_party_usg_assignment_id      => p_party_usg_assignment_id,
      p_party_usg_assignment_rec     => p_party_usg_assignment_rec,
      x_usg_assignment_id_tbl        => l_usg_assignment_id_tbl,
      x_usg_assignment_rec_tbl       => l_usg_assignment_rec_tbl,
      x_return_status                => x_return_status,
      x_msg_count                    => x_msg_count,
      x_msg_data                     => x_msg_data
    );

    IF x_return_status <> fnd_api.G_RET_STS_SUCCESS THEN
      RAISE fnd_api.G_EXC_ERROR;
    END IF;

    -- call to business logic.
    l_party_usg_assignment_rec := p_party_usg_assignment_rec;

    do_update_usg_assignment (
      p_validation_level           => l_validation_level,
      p_usg_assignment_id_tbl      => l_usg_assignment_id_tbl,
      p_party_usg_assignment_rec   => l_party_usg_assignment_rec,
      p_old_usg_assignment_rec_tbl => l_usg_assignment_rec_tbl,
      x_return_status              => x_return_status
    );

    -- standard call to get message count and if count is 1, get message info.
    fnd_msg_pub.Count_And_Get (
      p_encoded                   => fnd_api.G_FALSE,
      p_count                     => x_msg_count,
      p_data                      => x_msg_data);

    -- Debug info.
    IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
      hz_utility_v2pub.debug_return_messages (
        p_msg_count               => x_msg_count,
        p_msg_data                => x_msg_data,
        p_msg_type                => 'WARNING',
        p_msg_level               => fnd_log.level_exception
      );
    END IF;

    IF fnd_log.level_procedure >= fnd_log.g_current_runtime_level THEN
      hz_utility_v2pub.debug (
        p_message                 => c_api_name||' (-)',
        p_prefix                  => l_debug_prefix,
        p_msg_level               => fnd_log.level_procedure
      );
    END IF;

EXCEPTION
    WHEN fnd_api.G_EXC_ERROR THEN
      ROLLBACK TO update_usg_assignment;
      x_return_status := fnd_api.G_RET_STS_ERROR;

      fnd_msg_pub.Count_And_Get (
        p_encoded                 => fnd_api.G_FALSE,
        p_count                   => x_msg_count,
        p_data                    => x_msg_data
      );

      -- Debug info.
      IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages (
          p_msg_count             => x_msg_count,
          p_msg_data              => x_msg_data,
          p_msg_type              => 'ERROR',
          p_msg_level             => fnd_log.level_error
        );
      END IF;

      IF fnd_log.level_procedure >= fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug (
          p_message               => c_api_name||' (-)',
          p_prefix                => l_debug_prefix,
          p_msg_level             => fnd_log.level_procedure
        );
      END IF;

    WHEN fnd_api.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO update_usg_assignment;
      x_return_status := fnd_api.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.Count_And_Get (
        p_encoded                 => fnd_api.G_FALSE,
        p_count                   => x_msg_count,
        p_data                    => x_msg_data
      );

      -- Debug info.
      IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages (
          p_msg_count             => x_msg_count,
          p_msg_data              => x_msg_data,
          p_msg_type              => 'UNEXPECTED ERROR',
          p_msg_level             => fnd_log.level_error
        );
      END IF;

      IF fnd_log.level_procedure >= fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug (
          p_message               => c_api_name||' (-)',
          p_prefix                => l_debug_prefix,
          p_msg_level             => fnd_log.level_procedure
        );
      END IF;

    WHEN OTHERS THEN
      ROLLBACK TO update_usg_assignment;
      x_return_status := fnd_api.G_RET_STS_UNEXP_ERROR;

      fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
      fnd_message.set_token('ERROR' ,SQLERRM);
      fnd_msg_pub.add;

      fnd_msg_pub.Count_And_Get (
        p_encoded                 => fnd_api.G_FALSE,
        p_count                   => x_msg_count,
        p_data                    => x_msg_data
      );

      -- Debug info.
      IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages (
          p_msg_count             => x_msg_count,
          p_msg_data              => x_msg_data,
          p_msg_type              => 'SQL ERROR',
          p_msg_level             => fnd_log.level_error
        );
      END IF;

      IF fnd_log.level_procedure >= fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug (
          p_message               => c_api_name||' (-)',
          p_prefix                => l_debug_prefix,
          p_msg_level             => fnd_log.level_procedure
        );
      END IF;

END update_usg_assignment;


/**
 * PROCEDURE inactivate_usg_assignment
 *
 * DESCRIPTION
 *     Inactivates party usage assignment.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list            Initialize message stack if it is set to
 *                                fnd_api.G_TRUE. Default is fnd_api.G_FALSE.
 *     p_validation_level         Validation level. Default is full validation.
 *     p_party_id                 Party Id
 *     p_party_usage_code         Party usage code
 *   IN/OUT:
 *   OUT:
 *     x_return_status            Return status after the call. The status can
 *                                be fnd_api.G_RET_STS_SUCCESS (success),
 *                                fnd_api.G_RET_STS_ERROR (error),
 *                                fnd_api.G_RET_STS_UNEXP_ERROR (unexpected error).
 *     x_msg_count                Number of messages in message stack.
 *     x_msg_data                 Message text if x_msg_count is 1.
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   05/01/05      Jianying Huang     o Created.
 *
 */

PROCEDURE inactivate_usg_assignment (
    p_init_msg_list               IN     VARCHAR2,
    p_validation_level            IN     NUMBER,
    p_party_usg_assignment_id     IN     NUMBER,
    p_party_id                    IN     NUMBER,
    p_party_usage_code            IN     VARCHAR2,
    x_return_status               OUT    NOCOPY VARCHAR2,
    x_msg_count                   OUT    NOCOPY NUMBER,
    x_msg_data                    OUT    NOCOPY VARCHAR2
) IS

    c_api_name                    CONSTANT VARCHAR2(30) := 'inactivate_usg_assignment';
    l_debug_prefix                VARCHAR2(30);
    l_party_usg_assignment_rec    party_usg_assignment_rec_type;
    l_success                     VARCHAR2(1);

BEGIN

    l_debug_prefix := '';

    -- Debug info.
    IF fnd_log.level_procedure >= fnd_log.g_current_runtime_level THEN
      hz_utility_v2pub.debug (
        p_message                 => c_api_name||' (+)',
        p_prefix                  => l_debug_prefix,
        p_msg_level               => fnd_log.level_procedure
      );
    END IF;

    l_party_usg_assignment_rec.party_id := p_party_id;
    l_party_usg_assignment_rec.party_usage_code := p_party_usage_code;
    l_party_usg_assignment_rec.effective_end_date := trunc(sysdate);

    update_usg_assignment (
      p_init_msg_list             => p_init_msg_list,
      p_validation_level          => p_validation_level,
      p_party_usg_assignment_id   => p_party_usg_assignment_id,
      p_party_usg_assignment_rec  => l_party_usg_assignment_rec,
      x_return_status             => x_return_status,
      x_msg_count                 => x_msg_count,
      x_msg_data                  => x_msg_data
    );

    -- replace error message
    IF x_return_status <> fnd_api.G_RET_STS_SUCCESS THEN
      fnd_message.set_name('AR', 'HZ_PU_WRONG_API');
      fnd_msg_pub.Set_Search_Name('AR', 'HZ_PU_MULTIPLE_ASSIGNMENT');
      l_success := fnd_msg_pub.Change_Msg;

      IF l_success = 'T' THEN
        -- standard call to get message count and if count is 1, get message info.
        fnd_msg_pub.Count_And_Get (
          p_encoded                   => fnd_api.G_FALSE,
          p_count                     => x_msg_count,
          p_data                      => x_msg_data);
      END IF;
    END IF;

    IF fnd_log.level_procedure >= fnd_log.g_current_runtime_level THEN
      hz_utility_v2pub.debug (
        p_message                 => c_api_name||' (-)',
        p_prefix                  => l_debug_prefix,
        p_msg_level               => fnd_log.level_procedure
      );
    END IF;

END inactivate_usg_assignment;


/**
 * PROCEDURE refresh
 *
 * DESCRIPTION
 *     Refresh the cached setup. Need to be called when the party usage setup
 *     is changed via admin UI.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   05/01/05      Jianying Huang     o Created.
 *
 */

PROCEDURE refresh IS

BEGIN

    G_SETUP_LOADED := 0;

END refresh;


/**
 * PROCEDURE set_calling_api
 *
 * DESCRIPTION
 *     Set calling api. Internal use only.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   05/01/05      Jianying Huang     o Created.
 *
 */

PROCEDURE set_calling_api (
    p_calling_api                 IN     VARCHAR2
) IS

BEGIN

    G_CALLING_API := p_calling_api;

END set_calling_api;


/**
 * FUNCTION allow_party_merge
 *
 * DESCRIPTION
 *     Created for party merge. Check party usage
 *     rules to determine if merge is allowed.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   07/19/05      Jianying Huang     o Created.
 *
 */

FUNCTION allow_party_merge (
    p_init_msg_list               IN     VARCHAR2,
    p_from_party_id               IN     NUMBER,
    p_to_party_id                 IN     NUMBER,
    x_msg_count                   OUT    NOCOPY NUMBER,
    x_msg_data                    OUT    NOCOPY VARCHAR2
) RETURN VARCHAR2 IS

    c_api_name                    CONSTANT VARCHAR2(30) := 'allow_party_merge';
    l_debug_prefix                VARCHAR2(30);
    l_allow_party_merge           VARCHAR2(1);

    CURSOR c_assignments (
      p_party_id                  NUMBER
    ) IS
    SELECT UNIQUE party_usage_code
    FROM   hz_party_usg_assignments
    WHERE  party_id = p_party_id;

    l_from_party_usage_codes_tbl  VARCHAR100_TBL;
    l_to_party_usage_codes_tbl    VARCHAR100_TBL;
    l_continue_i                  VARCHAR2(1);
    l_continue_j                  VARCHAR2(1);
    i                             NUMBER;
    j                             NUMBER;

BEGIN

    l_debug_prefix := '';
    l_allow_party_merge := 'Y';

    -- Debug info.
    IF fnd_log.level_procedure >= fnd_log.g_current_runtime_level THEN
      hz_utility_v2pub.debug (
        p_message                 => c_api_name||' (+)',
        p_prefix                  => l_debug_prefix,
        p_msg_level               => fnd_log.level_procedure
      );
    END IF;

    -- initialize message list if p_init_msg_list is set to TRUE.
    IF p_init_msg_list IS NOT NULL AND
       fnd_api.to_Boolean(p_init_msg_list)
    THEN
      fnd_msg_pub.initialize;
    END IF;

    -- load setup data
    IF G_SETUP_LOADED = 0 THEN
      initialize;
    END IF;

    --
    -- check party usage rules
    --
    IF G_SETUP_LOADED = 3 THEN
      OPEN c_assignments(p_from_party_id);
      FETCH c_assignments BULK COLLECT INTO
        l_from_party_usage_codes_tbl;
      CLOSE c_assignments;

      IF l_from_party_usage_codes_tbl.count > 0 THEN
        OPEN c_assignments(p_to_party_id);
        FETCH c_assignments BULK COLLECT INTO
          l_to_party_usage_codes_tbl;
        CLOSE c_assignments;

        IF l_to_party_usage_codes_tbl.count > 0 THEN
          --
          -- the following check are needed only when there
          -- are some existing assignments
          --
          l_continue_i := 'Y';   i := 1;
          WHILE (i <= l_from_party_usage_codes_tbl.count AND
                 l_continue_i = 'Y')
          LOOP
            -- Debug info.
            IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
              hz_utility_v2pub.debug(
                p_prefix                => l_debug_prefix,
                p_message               => 'l_from_party_usage_codes_tbl('||i||') = '||
                                           l_from_party_usage_codes_tbl(i),
                p_msg_level             => fnd_log.level_statement);
            END IF;

            l_continue_j := 'Y';   j := 1;
            WHILE (j <= l_to_party_usage_codes_tbl.count AND
                   l_continue_j = 'Y')
            LOOP
              -- Debug info.
              IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                hz_utility_v2pub.debug(
                  p_prefix                => l_debug_prefix,
                  p_message               => 'l_to_party_usage_codes_tbl('||j||') = '||
                                           l_to_party_usage_codes_tbl(j),
                  p_msg_level             => fnd_log.level_statement);
              END IF;

              --
              -- check exclusive rule
              -- check co-exist rule
              --
              IF (violate_exclusive_rules(
                    l_from_party_usage_codes_tbl(i),
                    l_to_party_usage_codes_tbl(j)) OR
                  violate_coexist_rules(
                    l_from_party_usage_codes_tbl(i),
                    l_to_party_usage_codes_tbl(j)))
              THEN
                fnd_message.set_name('AR', 'HZ_PU_EXCLUSIVE_RULE_FAILED');
                fnd_message.set_token('EXISTING_PARTY_USAGE_CODE', l_from_party_usage_codes_tbl(i));
                fnd_message.set_token('NEW_PARTY_USAGE_CODE', l_to_party_usage_codes_tbl(j));
                fnd_msg_pub.add;

                l_continue_j := 'N';   l_continue_i := 'N';
                l_allow_party_merge := 'N';
              ELSE
                j := j + 1;
              END IF;

            END LOOP;

            i := i + 1;

          END LOOP;
        END IF;  -- to party has assignments
      END IF;  -- from party has assignments
    END IF;   -- has rules defined.

    -- standard call to get message count and if count is 1, get message info.
    fnd_msg_pub.Count_And_Get (
      p_encoded                   => fnd_api.G_FALSE,
      p_count                     => x_msg_count,
      p_data                      => x_msg_data);

    -- Debug info.
    IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
      hz_utility_v2pub.debug_return_messages (
        p_msg_count               => x_msg_count,
        p_msg_data                => x_msg_data,
        p_msg_type                => 'ERROR',
        p_msg_level               => fnd_log.level_exception
      );
    END IF;

    IF fnd_log.level_procedure >= fnd_log.g_current_runtime_level THEN
      hz_utility_v2pub.debug (
        p_message                 => c_api_name||' (-)',
        p_prefix                  => l_debug_prefix,
        p_msg_level               => fnd_log.level_procedure
      );
    END IF;

    RETURN l_allow_party_merge;

END allow_party_merge;


/**
 * FUNCTION find_duplicates
 *
 * DESCRIPTION
 *     Created for party merge. Find duplicate assignment.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   07/19/05      Jianying Huang     o Created.
 *
 */

PROCEDURE find_duplicates (
    p_from_assignment_id          IN     NUMBER,
    p_to_party_id                 IN     NUMBER,
    x_to_assignment_id            OUT    NOCOPY NUMBER
) IS

    c_api_name                    CONSTANT VARCHAR2(30) := 'find_duplicates';
    l_debug_prefix                VARCHAR2(30);
    l_party_usg_assignment_rec    party_usg_assignment_rec_type;
    l_usg_assignment_id_tbl       NUMBER15_TBL;
    l_usg_assignment_rec_tbl      ASSIGNMENT_REC_TBL;
    l_has_duplicates              VARCHAR2(1);
    x_return_status               VARCHAR2(1);
    x_msg_count                   NUMBER;
    x_msg_data                    VARCHAR2(2000);

BEGIN
    -- Debug info.
    IF fnd_log.level_procedure >= fnd_log.g_current_runtime_level THEN
      hz_utility_v2pub.debug (
        p_message                 => c_api_name||' (+)',
        p_prefix                  => l_debug_prefix,
        p_msg_level               => fnd_log.level_procedure
      );
    END IF;

    -- get old assignment.
    get_usg_assignment(
      p_party_usg_assignment_id      => p_from_assignment_id,
      p_party_usg_assignment_rec     => l_party_usg_assignment_rec,
      x_usg_assignment_id_tbl        => l_usg_assignment_id_tbl,
      x_usg_assignment_rec_tbl       => l_usg_assignment_rec_tbl,
      x_return_status                => x_return_status,
      x_msg_count                    => x_msg_count,
      x_msg_data                     => x_msg_data
    );

    IF l_usg_assignment_rec_tbl.count = 1 THEN
      l_party_usg_assignment_rec := l_usg_assignment_rec_tbl(1);
      l_party_usg_assignment_rec.party_id := p_to_party_id;

      l_has_duplicates := duplicates_exist(l_party_usg_assignment_rec, x_to_assignment_id);
    END IF;

    -- Debug info.
    IF fnd_log.level_procedure >= fnd_log.g_current_runtime_level THEN
      hz_utility_v2pub.debug (
        p_message                 => c_api_name||' (-)',
        p_prefix                  => l_debug_prefix,
        p_msg_level               => fnd_log.level_procedure
      );
    END IF;

END find_duplicates;


/**
 * PROCEDURE validate_supplier_name
 *
 * DESCRIPTION
 *     Validate supplier name.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *     IN:
 *       p_party_id              party id
 *       p_party_name            party name
 *       x_return_status         return status
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 */

PROCEDURE validate_supplier_name (
    p_party_id                    IN     NUMBER,
    p_party_name                  IN     VARCHAR2,
    x_return_status               IN OUT NOCOPY VARCHAR2
) IS

    c_supplier_code               CONSTANT VARCHAR2(30) := 'SUPPLIER';

    CURSOR c_party (
      p_party_id                  NUMBER,
      p_party_name                VARCHAR2
    ) IS
    SELECT null
    FROM   hz_parties p
    WHERE  p.party_name = p_party_name
    AND    p.party_type = 'ORGANIZATION'
    AND    p.party_id <> p_party_id
    AND    p.status IN ('A', 'I')
    AND    EXISTS (
             SELECT null
             FROM   hz_party_usg_assignments pu
             WHERE  pu.party_usage_code = c_supplier_code
             AND    pu.party_id = p.party_id
             AND    ROWNUM = 1)
    AND    ROWNUM = 1;

    l_dummy                       VARCHAR2(1);

BEGIN

    -- check uniqueness across supplier parties
    OPEN c_party(p_party_id, p_party_name);
    FETCH c_party INTO l_dummy;
    IF c_party%FOUND THEN
      fnd_message.set_name('AR', 'HZ_NONUNIQUE_SUPPLIER_NAME');
      fnd_msg_pub.add;
      x_return_status := fnd_api.g_ret_sts_error;
    END IF;
    CLOSE c_party;

    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      hz_utility_v2pub.debug(
        p_prefix                   => '',
        p_message                  => 'after validate supplier name uniqueness ... ' ||
                                      'x_return_status = ' || x_return_status,
        p_msg_level                => fnd_log.level_statement);
    END IF;

END validate_supplier_name;


END HZ_PARTY_USG_ASSIGNMENT_PVT;

/
