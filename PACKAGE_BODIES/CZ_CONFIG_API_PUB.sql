--------------------------------------------------------
--  DDL for Package Body CZ_CONFIG_API_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CZ_CONFIG_API_PUB" AS
/*  $Header: czcfgapb.pls 120.1.12010000.3 2009/02/13 14:49:52 asiaston ship $  */

-- model_instantiation_type
NETWORK CONSTANT VARCHAR2(1) := 'N';

-- component_instance_type
ROOT                    CONSTANT VARCHAR2(1) := 'R';
GENERIC_INSTANCE_ROOT   CONSTANT VARCHAR2(1) := 'C';
NETWORK_INSTANCE_ROOT   CONSTANT VARCHAR2(1) := 'I';

CONFIG_STATUS_COMPLETE  CONSTANT VARCHAR2(1) := '2';

BATCH_COPY_SIZE         CONSTANT INTEGER := 500;

NEW_HDR_NAME_PREFIX     CONSTANT VARCHAR2(25) := 'Copy of ';
NEW_REV_NAME_PREFIX     CONSTANT VARCHAR2(25) := 'New revision of ';

last_hdr_allocated      NUMBER := NULL;
next_hdr_to_use         NUMBER := 0;
last_item_allocated     NUMBER := NULL;
next_item_to_use        NUMBER := 0;
last_msg_seq_allocated  NUMBER := NULL;
next_msg_seq_to_use     NUMBER := 0;
id_increment            NUMBER;
DEFAULT_INCR            CONSTANT PLS_INTEGER := 20;

TYPE NUMBER_TBL_TYPE IS TABLE OF NUMBER INDEX BY VARCHAR2(15);--  Bug 6892148;

TYPE instance_rec_type IS RECORD
( instance_hdr_id  cz_config_hdrs.config_hdr_id%TYPE
 ,instance_rev_nbr cz_config_hdrs.config_rev_nbr%TYPE
 ,txn_flag         VARCHAR2(1)
);

TYPE instance_tbl_type IS TABLE of instance_rec_type INDEX BY PLS_INTEGER;

TYPE config_hdr_tbl_type IS TABLE OF cz_config_hdrs%ROWTYPE INDEX BY PLS_INTEGER;
TYPE config_item_tbl_type IS TABLE OF cz_config_items%ROWTYPE INDEX BY PLS_INTEGER;
TYPE config_input_tbl_type IS TABLE OF cz_config_inputs%ROWTYPE INDEX BY PLS_INTEGER;
TYPE config_attr_tbl_type IS TABLE OF cz_config_attributes%ROWTYPE INDEX BY PLS_INTEGER;
TYPE config_extattr_tbl_type IS TABLE OF cz_config_ext_attributes%ROWTYPE INDEX BY PLS_INTEGER;

--------------------------------------------------------------------------------
FUNCTION get_next_hdr_id RETURN NUMBER
IS
  l_config_hdr_id  NUMBER;

BEGIN
  IF ((last_hdr_allocated IS NULL) OR
      (next_hdr_to_use = last_hdr_allocated + id_increment)) THEN
    SELECT cz_config_hdrs_s.NEXTVAL
      INTO last_hdr_allocated
    FROM dual;
    next_hdr_to_use := last_hdr_allocated;
  END IF;

  l_config_hdr_id := next_hdr_to_use;
  next_hdr_to_use := next_hdr_to_use + 1;
  RETURN l_config_hdr_id;
END get_next_hdr_id;

--------------------------------------------------------------------------------
FUNCTION get_next_revision(p_config_hdr_id IN NUMBER)
    RETURN NUMBER
IS
  l_config_rev_nbr  NUMBER;

BEGIN
  SELECT MAX(CONFIG_REV_NBR) + 1  INTO l_config_rev_nbr
  FROM  CZ_CONFIG_HDRS
  WHERE  CONFIG_HDR_ID = p_config_hdr_id;

  RETURN l_config_rev_nbr;

EXCEPTION
  WHEN OTHERS THEN
    RAISE;

END get_next_revision;

--------------------------------------------------------------------------------
FUNCTION get_next_item_id RETURN NUMBER
IS
  l_config_item_id  NUMBER;
BEGIN
  IF ((last_item_allocated IS NULL) OR
      (next_item_to_use = last_item_allocated + id_increment)) THEN
    SELECT cz_config_items_s.NEXTVAL
    INTO last_item_allocated
    FROM dual;
    next_item_to_use := last_item_allocated;
  END IF;
  l_config_item_id := next_item_to_use;
  next_item_to_use := next_item_to_use + 1;
  RETURN l_config_item_id;
END get_next_item_id;

--------------------------------------------------------------------------------
FUNCTION get_next_msg_seq RETURN NUMBER
IS
  l_msg_seq  NUMBER;

BEGIN
  IF ((last_msg_seq_allocated IS NULL) OR
      (next_msg_seq_to_use = last_msg_seq_allocated + id_increment)) THEN
    SELECT cz_config_messages_s.NEXTVAL INTO last_msg_seq_allocated FROM dual;
    next_msg_seq_to_use := last_msg_seq_allocated;
  END IF;

  l_msg_seq := next_msg_seq_to_use;
  next_msg_seq_to_use := next_msg_seq_to_use + 1;
  RETURN l_msg_seq;
END get_next_msg_seq;

--------------------------------------------------------------------------------
PROCEDURE copy_config_header(p_old_config_hdr_id  IN NUMBER
                            ,p_old_config_rev_nbr IN NUMBER
                            ,p_new_config_hdr_id  IN NUMBER
                            ,p_new_config_rev_nbr IN NUMBER
                            ,p_new_name           IN VARCHAR2
                            ,p_copy_mode          IN VARCHAR2
                            )
IS
BEGIN
  INSERT INTO CZ_CONFIG_HDRS
        (CONFIG_HDR_ID
        ,NAME
        ,CONFIG_REV_NBR
        ,COMPONENT_ID
        ,PERSISTENT_COMPONENT_ID
        ,DESC_TEXT
        ,UI_DEF_ID
        ,OPPORTUNITY_HDR_ID
        ,CONFIG_STATUS
        ,CONFIG_DATE_CREATED
        ,CONFIG_NOTE
        ,USER_ID_CREATED
        ,USER_ID_FOR_WHOM_CREATED
        ,NUMBER_QUOTES_USED_IN
        ,USER_NUM01
        ,USER_NUM02
        ,USER_NUM03
        ,USER_NUM04
        ,USER_STR01
        ,USER_STR02
        ,USER_STR03
        ,USER_STR04
        ,DELETED_FLAG
        ,SECURITY_MASK
        ,CHECKOUT_USER
        ,LAST_UPDATE_LOGIN
        ,MODEL_IDENTIFIER
        ,EFFECTIVE_DATE
        ,EFFECTIVE_USAGE_ID
        ,CONFIG_MODEL_LOOKUP_DATE
        ,CONFIG_DELTA_SPEC
        ,MODEL_INSTANTIATION_TYPE
        ,COMPONENT_INSTANCE_TYPE
        ,BASELINE_REV_NBR
        ,HAS_FAILURES
        ,MODEL_POST_MIGR_CHG_FLAG
        ,TO_BE_DELETED_FLAG
        ,AUTO_COMPLETION_FLAG
        ,CONFIG_ENGINE_TYPE
        )
    SELECT
         p_new_config_hdr_id  -- new or old value
        ,SUBSTR(DECODE(p_new_name, NULL, DECODE(NAME,NULL,NAME,DECODE(p_copy_mode,CZ_API_PUB.G_NEW_HEADER_COPY_MODE,
             NEW_HDR_NAME_PREFIX || NAME, NEW_REV_NAME_PREFIX || NAME)), p_new_name), 1, 240)
        ,p_new_config_rev_nbr -- new value
        ,COMPONENT_ID
        ,PERSISTENT_COMPONENT_ID
        ,DESC_TEXT
        ,UI_DEF_ID
        ,OPPORTUNITY_HDR_ID
        ,CONFIG_STATUS
        ,CONFIG_DATE_CREATED
        ,CONFIG_NOTE
        ,USER_ID_CREATED
        ,USER_ID_FOR_WHOM_CREATED
        ,NUMBER_QUOTES_USED_IN
        ,USER_NUM01
        ,USER_NUM02
        ,USER_NUM03
        ,USER_NUM04
        ,USER_STR01
        ,USER_STR02
        ,USER_STR03
        ,USER_STR04
        ,DELETED_FLAG
        ,SECURITY_MASK
        ,CHECKOUT_USER
        ,LAST_UPDATE_LOGIN
        ,MODEL_IDENTIFIER
        ,EFFECTIVE_DATE
        ,EFFECTIVE_USAGE_ID
        ,CONFIG_MODEL_LOOKUP_DATE
        ,CONFIG_DELTA_SPEC
        ,MODEL_INSTANTIATION_TYPE
        ,COMPONENT_INSTANCE_TYPE
        ,BASELINE_REV_NBR
        ,HAS_FAILURES
        ,MODEL_POST_MIGR_CHG_FLAG
        ,TO_BE_DELETED_FLAG
        ,AUTO_COMPLETION_FLAG
        ,CONFIG_ENGINE_TYPE
    FROM CZ_CONFIG_HDRS
    WHERE CONFIG_HDR_ID = p_old_config_hdr_id
      AND CONFIG_REV_NBR = p_old_config_rev_nbr;

EXCEPTION
  WHEN OTHERS THEN
    RAISE;

END copy_config_header;

--------------------------------------------------------------------------------
-- Copies all instance header records associated with the input session header
-- Returns an instance header lookup map: key, old instance header id; value,
-- record of new instance header id and revision as well as a flag indicating
-- if transaction needs to be written for network instance
PROCEDURE copy_instance_headers(p_session_hdr_id   IN NUMBER
                               ,p_session_rev_nbr  IN NUMBER
                               ,p_copy_mode        IN VARCHAR2
                               ,x_instance_hdr_map OUT NOCOPY instance_tbl_type
                               )
IS
  l_instance_hdr_id   NUMBER;
  l_instance_hdr_tbl  config_hdr_tbl_type;

BEGIN
  SELECT * BULK COLLECT INTO l_instance_hdr_tbl
  FROM cz_config_hdrs
  WHERE deleted_flag = '0' AND (config_hdr_id, config_rev_nbr) IN
       (SELECT instance_hdr_id, instance_rev_nbr
        FROM cz_config_items
        WHERE config_hdr_id = p_session_hdr_id AND config_rev_nbr = p_session_rev_nbr
        AND component_instance_type IN (GENERIC_INSTANCE_ROOT, NETWORK_INSTANCE_ROOT)
        AND deleted_flag = '0');

  IF l_instance_hdr_tbl.COUNT = 0 THEN RETURN; END IF;

  -- generic: all depends on copy mode
  -- network: depends on copy mode and baseline rev
  --   new rev: copy all fields except config_rev_nbr (new rev)
  --   new config: copy mode and baseline rev
  --     1. baseline_rev_nbr is not null: copy all fields except config_rev_nbr (new rev)
  --     2. baseline_rev_nbr is null: copy all fields except config_hdr_id and config_rev_nbr (new hdr)
  FOR i IN l_instance_hdr_tbl.FIRST .. l_instance_hdr_tbl.LAST LOOP
    l_instance_hdr_id := l_instance_hdr_tbl(i).config_hdr_id;

    IF (p_copy_mode = CZ_API_PUB.G_NEW_REVISION_COPY_MODE OR
        l_instance_hdr_tbl(i).component_instance_type = NETWORK_INSTANCE_ROOT AND
        l_instance_hdr_tbl(i).baseline_rev_nbr IS NOT NULL) THEN
      l_instance_hdr_tbl(i).config_rev_nbr := get_next_revision(l_instance_hdr_id);
    ELSE
      l_instance_hdr_tbl(i).config_hdr_id  := get_next_hdr_id;
      l_instance_hdr_tbl(i).config_rev_nbr := 1;
    END IF;

    IF l_instance_hdr_tbl(i).name IS NOT NULL THEN
      IF l_instance_hdr_tbl(i).config_rev_nbr = 1 THEN
        l_instance_hdr_tbl(i).name := SUBSTR(NEW_HDR_NAME_PREFIX||l_instance_hdr_tbl(i).name,1,240);
      ELSE
        l_instance_hdr_tbl(i).name := SUBSTR(NEW_REV_NAME_PREFIX||l_instance_hdr_tbl(i).name,1,240);
      END IF;
    END IF;

    x_instance_hdr_map(l_instance_hdr_id).instance_hdr_id  := l_instance_hdr_tbl(i).config_hdr_id;
    x_instance_hdr_map(l_instance_hdr_id).instance_rev_nbr := l_instance_hdr_tbl(i).config_rev_nbr;
    IF l_instance_hdr_tbl(i).component_instance_type = NETWORK_INSTANCE_ROOT AND
       p_copy_mode = CZ_API_PUB.G_NEW_HEADER_COPY_MODE AND l_instance_hdr_tbl(i).baseline_rev_nbr IS NULL THEN
      -- transaction writing needed for this instance
      x_instance_hdr_map(l_instance_hdr_id).txn_flag := '1';
    END IF;
  END LOOP;

  FORALL i IN 1..l_instance_hdr_tbl.COUNT
    INSERT INTO cz_config_hdrs VALUES l_instance_hdr_tbl(i);

EXCEPTION
  WHEN OTHERS THEN
    RAISE;

END copy_instance_headers;

--------------------------------------------------------------------------------
-- copy config containing no instance
PROCEDURE copy_config_item(p_old_config_hdr_id   IN  NUMBER,
                           p_old_config_rev_nbr  IN  NUMBER,
                           p_new_config_hdr_id   IN  NUMBER,
                           p_new_config_rev_nbr  IN  NUMBER)
IS

BEGIN
  INSERT INTO CZ_CONFIG_ITEMS
                (LAST_UPDATE_LOGIN,
                 CONFIG_HDR_ID,
                 CONFIG_REV_NBR,
                 CONFIG_ITEM_ID,
                 PARENT_CONFIG_ITEM_ID,
                 PS_NODE_ID,
                 ITEM_VAL,
                 ITEM_NUM_VAL,
                 INSTANCE_NBR,
                 ROOT_BOM_CONFIG_ITEM_ID,
                 SEQUENCE_NBR,
                 VALUE_TYPE_CODE,
                 DELETED_FLAG,
                 SECURITY_MASK,
                 CHECKOUT_USER,
                 NODE_IDENTIFIER,
                 INVENTORY_ITEM_ID,
                 ORGANIZATION_ID,
                 COMPONENT_SEQUENCE_ID,
                 UOM_CODE,
                 BOM_SORT_ORDER,
                 QUOTEABLE_FLAG,
                 BOM_ITEM_TYPE,
                 TARGET_CONFIG_ITEM_ID,
                 INSTANCE_CONFIG_ITEM_ID,
                 NAME,
                 ATO_CONFIG_ITEM_ID
                ,INSTANCE_HDR_ID
                ,INSTANCE_REV_NBR
                ,LINE_TYPE
                ,COMPONENT_INSTANCE_TYPE
                ,TARGET_HDR_ID
                ,TARGET_REV_NBR
                ,CONFIG_DELTA
                ,LOCATION_ID
                ,LOCATION_TYPE_CODE
                ,IB_TRACKABLE
                ,EXT_ACTIVATED_FLAG
                ,DISCONTINUED_FLAG
                ,ORIG_SYS_REF
                ,ITEM_SRC_APPL_ID
                ,PS_NODE_NAME
                ,TANGIBLE_ITEM_FLAG
                ,RETURNED_FLAG
                ,VALUE_SOURCE
                ,ORDERABLE_FLAG
                )
  SELECT
                LAST_UPDATE_LOGIN,
                p_new_config_hdr_id,
                p_new_config_rev_nbr,
                CONFIG_ITEM_ID,
                PARENT_CONFIG_ITEM_ID,
                PS_NODE_ID,
                ITEM_VAL,
                ITEM_NUM_VAL,
                INSTANCE_NBR,
                ROOT_BOM_CONFIG_ITEM_ID,
                SEQUENCE_NBR,
                VALUE_TYPE_CODE,
                DELETED_FLAG,
                SECURITY_MASK,
                CHECKOUT_USER,
                NODE_IDENTIFIER,
                INVENTORY_ITEM_ID,
                ORGANIZATION_ID,
                COMPONENT_SEQUENCE_ID,
                UOM_CODE,
                BOM_SORT_ORDER,
                QUOTEABLE_FLAG,
                BOM_ITEM_TYPE,
                TARGET_CONFIG_ITEM_ID,
                INSTANCE_CONFIG_ITEM_ID,
                NAME,
                ATO_CONFIG_ITEM_ID
               ,p_new_config_hdr_id    -- instance_hdr_id
               ,p_new_config_rev_nbr   -- instance_rev_nbr
               ,LINE_TYPE
               ,COMPONENT_INSTANCE_TYPE
               ,DECODE(TARGET_HDR_ID, NULL, NULL, p_new_config_hdr_id)
               ,DECODE(TARGET_REV_NBR, NULL, NULL, p_new_config_rev_nbr)
               ,CONFIG_DELTA
               ,LOCATION_ID
               ,LOCATION_TYPE_CODE
               ,IB_TRACKABLE
               ,EXT_ACTIVATED_FLAG
               ,DISCONTINUED_FLAG
               ,ORIG_SYS_REF
               ,ITEM_SRC_APPL_ID
               ,PS_NODE_NAME
               ,TANGIBLE_ITEM_FLAG
               ,RETURNED_FLAG
               ,VALUE_SOURCE
               ,ORDERABLE_FLAG
    FROM CZ_CONFIG_ITEMS
    WHERE CONFIG_HDR_ID = p_old_config_hdr_id
      AND CONFIG_REV_NBR = p_old_config_rev_nbr AND deleted_flag = '0';

EXCEPTION
  WHEN OTHERS THEN
    RAISE;
END;

--------------------------------------------------------------------------------
PROCEDURE copy_config_item(p_old_config_hdr_id   IN  NUMBER
                          ,p_old_config_rev_nbr  IN  NUMBER
                          ,p_new_config_hdr_id   IN  NUMBER
                          ,p_new_config_rev_nbr  IN  NUMBER
                          ,p_copy_mode           IN  VARCHAR2
                          ,p_network_config      IN  BOOLEAN
                          ,p_instance_hdr_map    IN  instance_tbl_type
                          ,x_item_id_map         OUT NOCOPY number_tbl_type
                          )
IS
  l_config_item_id           NUMBER;
  l_parent_config_item_id    NUMBER;
  l_ato_config_item_id       NUMBER;
  l_instance_config_item_id  NUMBER;
  l_target_config_item_id    NUMBER;
  l_instance_hdr_id          NUMBER;
  l_instance_rev_nbr         NUMBER;
  l_target_hdr_id            NUMBER;
  l_target_rev_nbr           NUMBER;
  l_index                    PLS_INTEGER;
  l_config_item_tbl          config_item_tbl_type;

  CURSOR item_cursor IS  SELECT * FROM cz_config_items
                         WHERE config_hdr_id = p_old_config_hdr_id
                         AND config_rev_nbr = p_old_config_rev_nbr
                         AND deleted_flag = '0';

BEGIN
  -- config containing no instance: plain copy
  IF (p_instance_hdr_map.COUNT = 0) THEN
    copy_config_item(p_old_config_hdr_id
                    ,p_old_config_rev_nbr
                    ,p_new_config_hdr_id
                    ,p_new_config_rev_nbr
                    );

  ELSE
    -- For network config, if copy mode is new_config and transaction needs to be written
    -- for an instance, new instance config will be created and all config_item_ids of
    -- the new instance items will be regenerated.
    IF (p_network_config AND p_copy_mode = CZ_API_PUB.G_NEW_HEADER_COPY_MODE) THEN
      l_index := p_instance_hdr_map.FIRST;
      WHILE (l_index IS NOT NULL) LOOP
        IF p_instance_hdr_map(l_index).txn_flag = '1' THEN
          FOR id_rec IN (SELECT config_item_id FROM cz_config_items
                         WHERE config_hdr_id = p_old_config_hdr_id
                         AND config_rev_nbr = p_old_config_rev_nbr
                         AND deleted_flag = '0' AND instance_hdr_id = l_index)
          LOOP
            x_item_id_map(id_rec.config_item_id) := get_next_item_id;
          END LOOP;
        END IF;
        l_index := p_instance_hdr_map.NEXT(l_index);
      END LOOP;
    END IF;  -- generating new item ids

    OPEN item_cursor;
    LOOP
      l_config_item_tbl.DELETE;
      FETCH item_cursor BULK COLLECT INTO l_config_item_tbl LIMIT BATCH_COPY_SIZE;
      EXIT WHEN item_cursor%NOTFOUND AND l_config_item_tbl.COUNT = 0;

      FOR i IN l_config_item_tbl.FIRST .. l_config_item_tbl.LAST LOOP
        IF (x_item_id_map.FIRST IS NOT NULL) THEN
          l_config_item_id          := l_config_item_tbl(i).config_item_id;
          l_parent_config_item_id   := l_config_item_tbl(i).parent_config_item_id;
          l_ato_config_item_id      := l_config_item_tbl(i).ato_config_item_id;
          l_instance_config_item_id := l_config_item_tbl(i).instance_config_item_id;
          l_target_config_item_id   := l_config_item_tbl(i).target_config_item_id;

          IF (x_item_id_map.EXISTS(l_config_item_id)) THEN
            l_config_item_id := x_item_id_map(l_config_item_id);
          END IF;

          IF (l_parent_config_item_id IS NOT NULL AND
              x_item_id_map.EXISTS(l_parent_config_item_id)) THEN
            l_parent_config_item_id := x_item_id_map(l_parent_config_item_id);
          END IF;

          IF (l_ato_config_item_id IS NOT NULL AND
              x_item_id_map.EXISTS(l_ato_config_item_id)) THEN
            l_ato_config_item_id := x_item_id_map(l_ato_config_item_id);
          END IF;

          IF (l_instance_config_item_id IS NOT NULL AND
              x_item_id_map.EXISTS(l_instance_config_item_id)) THEN
            l_instance_config_item_id := x_item_id_map(l_instance_config_item_id);
          END IF;

          IF (l_target_config_item_id IS NOT NULL AND
              x_item_id_map.EXISTS(l_target_config_item_id)) THEN
            l_target_config_item_id := x_item_id_map(l_target_config_item_id);
          END IF;

          l_config_item_tbl(i).config_item_id := l_config_item_id;
          l_config_item_tbl(i).parent_config_item_id := l_parent_config_item_id;
          l_config_item_tbl(i).ato_config_item_id := l_ato_config_item_id;
          l_config_item_tbl(i).instance_config_item_id := l_instance_config_item_id;
          l_config_item_tbl(i).target_config_item_id := l_target_config_item_id;
        END IF;

        IF (p_instance_hdr_map.EXISTS(l_config_item_tbl(i).instance_hdr_id)) THEN
          l_instance_hdr_id  := p_instance_hdr_map(l_config_item_tbl(i).instance_hdr_id).instance_hdr_id;
          l_instance_rev_nbr := p_instance_hdr_map(l_config_item_tbl(i).instance_hdr_id).instance_rev_nbr;
        ELSE
          l_instance_hdr_id  := p_new_config_hdr_id;
          l_instance_rev_nbr := p_new_config_rev_nbr;
        END IF;
        l_config_item_tbl(i).instance_hdr_id  := l_instance_hdr_id;
        l_config_item_tbl(i).instance_rev_nbr := l_instance_rev_nbr;

        -- Target hdr could be out of the session config scope, e.g., a connector in an
        -- active instance could target a node in a passive instance (bug 2533239 fix)
        IF l_config_item_tbl(i).target_hdr_id IS NOT NULL THEN
          l_target_hdr_id  := l_config_item_tbl(i).target_hdr_id;
          l_target_rev_nbr := l_config_item_tbl(i).target_rev_nbr;
          IF p_instance_hdr_map.EXISTS(l_config_item_tbl(i).target_hdr_id) THEN
            l_target_rev_nbr := p_instance_hdr_map(l_target_hdr_id).instance_rev_nbr;
            l_target_hdr_id  := p_instance_hdr_map(l_target_hdr_id).instance_hdr_id;
          ELSIF l_target_hdr_id = p_old_config_hdr_id AND l_target_rev_nbr = p_old_config_rev_nbr THEN
            l_target_hdr_id  := p_new_config_hdr_id;
            l_target_rev_nbr := p_new_config_rev_nbr;
          END IF;

          l_config_item_tbl(i).target_hdr_id  := l_target_hdr_id;
          l_config_item_tbl(i).target_rev_nbr := l_target_rev_nbr;
        END IF;

        l_config_item_tbl(i).config_hdr_id  := p_new_config_hdr_id;
        l_config_item_tbl(i).config_rev_nbr := p_new_config_rev_nbr;
      END LOOP;

      FORALL i IN 1..l_config_item_tbl.COUNT
        INSERT INTO cz_config_items VALUES l_config_item_tbl(i);

    END LOOP;

    CLOSE item_cursor;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF item_cursor%ISOPEN THEN CLOSE item_cursor; END IF;
    RAISE;
END copy_config_item;

--------------------------------------------------------------------------------
PROCEDURE copy_config_input(p_old_config_hdr_id   IN NUMBER
                           ,p_old_config_rev_nbr  IN NUMBER
                           ,p_new_config_hdr_id   IN NUMBER
                           ,p_new_config_rev_nbr  IN NUMBER
                           ,p_instance_hdr_map    IN instance_tbl_type
                           )
IS

  l_config_input_tbl        config_input_tbl_type;

  CURSOR input_cursor IS SELECT *
                         FROM cz_config_inputs
                         WHERE config_hdr_id = p_old_config_hdr_id
                         AND config_rev_nbr = p_old_config_rev_nbr
                         AND deleted_flag = '0';

BEGIN

  IF ( p_instance_hdr_map.COUNT = 0 ) THEN

     INSERT INTO CZ_CONFIG_INPUTS
                    (LAST_UPDATE_LOGIN,
                     CONFIG_HDR_ID,
                     CONFIG_REV_NBR,
                     CONFIG_INPUT_ID,
                     INPUT_SEQ,
                     PARENT_INPUT_ID,
                     PS_NODE_ID,
                     INPUT_VAL,
                     INPUT_NUM_VAL,
                     INSTANCE_NBR,
                     INPUT_TYPE_CODE,
                     DELETED_FLAG,
                     SECURITY_MASK,
                     CHECKOUT_USER,
                     NODE_IDENTIFIER,
                     INSTANCE_ACTION_TYPE,
                     CONFIG_ITEM_ID,
                     TARGET_CONFIG_ITEM_ID,
                     TARGET_CONFIG_INPUT_ID,
                     FLOAT_TYPE,
                     INPUT_SOURCE)
     SELECT
                     LAST_UPDATE_LOGIN,
                     p_new_config_hdr_id,
                     p_new_config_rev_nbr,
                     CONFIG_INPUT_ID,
                     INPUT_SEQ,
                     PARENT_INPUT_ID,
                     PS_NODE_ID,
                     INPUT_VAL,
                     INPUT_NUM_VAL,
                     INSTANCE_NBR,
                     INPUT_TYPE_CODE,
                     DELETED_FLAG,
                     SECURITY_MASK,
                     CHECKOUT_USER,
                     NODE_IDENTIFIER,
                     INSTANCE_ACTION_TYPE,
                     CONFIG_ITEM_ID,
                     TARGET_CONFIG_ITEM_ID,
                     TARGET_CONFIG_INPUT_ID,
                     FLOAT_TYPE,
                     INPUT_SOURCE
         FROM CZ_CONFIG_INPUTS
         WHERE CONFIG_HDR_ID = p_old_config_hdr_id
          AND CONFIG_REV_NBR = p_old_config_rev_nbr
          AND deleted_flag = '0';

  ELSE

    --Bug #8198519. There are instance headers, need to resolve containment_instance_hdr_id values
    --when they are specified.
    --All validations are done by DIO.

    OPEN input_cursor;
    LOOP

      l_config_input_tbl.DELETE;

      FETCH input_cursor BULK COLLECT INTO l_config_input_tbl LIMIT BATCH_COPY_SIZE;
      EXIT WHEN input_cursor%NOTFOUND AND l_config_input_tbl.COUNT = 0;

      FOR i IN l_config_input_tbl.FIRST .. l_config_input_tbl.LAST LOOP

        l_config_input_tbl(i).config_hdr_id  := p_new_config_hdr_id;
        l_config_input_tbl(i).config_rev_nbr := p_new_config_rev_nbr;

        IF ( l_config_input_tbl(i).containment_instance_hdr_id IS NOT NULL ) THEN
           l_config_input_tbl(i).containment_instance_hdr_id := p_instance_hdr_map(l_config_input_tbl(i).containment_instance_hdr_id).instance_hdr_id;
        END IF;
      END LOOP;

      FORALL i IN 1..l_config_input_tbl.COUNT
        INSERT INTO cz_config_inputs VALUES l_config_input_tbl(i);

    END LOOP;

    CLOSE input_cursor;

  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF input_cursor%ISOPEN THEN CLOSE input_cursor; END IF;
    RAISE;
END copy_config_input;

--------------------------------------------------------------------------------
PROCEDURE copy_config_input(p_old_config_hdr_id   IN NUMBER
                           ,p_old_config_rev_nbr  IN NUMBER
                           ,p_new_config_hdr_id   IN NUMBER
                           ,p_new_config_rev_nbr  IN NUMBER
                           ,p_item_id_map         IN number_tbl_type
                           ,p_instance_hdr_map    IN instance_tbl_type
                           )
IS
  l_config_input_tbl        config_input_tbl_type;

  CURSOR input_cursor IS SELECT *
                         FROM cz_config_inputs
                         WHERE config_hdr_id = p_old_config_hdr_id
                         AND config_rev_nbr = p_old_config_rev_nbr
                         AND deleted_flag = '0';

BEGIN
  IF (p_item_id_map.COUNT = 0) THEN
    copy_config_input(p_old_config_hdr_id
                     ,p_old_config_rev_nbr
                     ,p_new_config_hdr_id
                     ,p_new_config_rev_nbr
                     ,p_instance_hdr_map
                     );
  ELSE
    OPEN input_cursor;
    LOOP
      l_config_input_tbl.DELETE;
      FETCH input_cursor BULK COLLECT INTO l_config_input_tbl LIMIT BATCH_COPY_SIZE;
      EXIT WHEN input_cursor%NOTFOUND AND l_config_input_tbl.COUNT = 0;

      FOR i IN l_config_input_tbl.FIRST .. l_config_input_tbl.LAST LOOP
        IF p_item_id_map.EXISTS(l_config_input_tbl(i).config_input_id) THEN
          l_config_input_tbl(i).config_input_id := p_item_id_map(l_config_input_tbl(i).config_input_id);
          l_config_input_tbl(i).config_item_id  := l_config_input_tbl(i).config_input_id;
        END IF;

        IF l_config_input_tbl(i).parent_input_id IS NOT NULL AND
           p_item_id_map.EXISTS(l_config_input_tbl(i).parent_input_id) THEN
          l_config_input_tbl(i).parent_input_id := p_item_id_map(l_config_input_tbl(i).parent_input_id);
        END IF;

        IF l_config_input_tbl(i).target_config_input_id IS NOT NULL AND
           p_item_id_map.EXISTS(l_config_input_tbl(i).target_config_input_id) THEN
          l_config_input_tbl(i).target_config_input_id := p_item_id_map(l_config_input_tbl(i).target_config_input_id);
          l_config_input_tbl(i).target_config_item_id := l_config_input_tbl(i).target_config_input_id;
        END IF;

        l_config_input_tbl(i).config_hdr_id  := p_new_config_hdr_id;
        l_config_input_tbl(i).config_rev_nbr := p_new_config_rev_nbr;

        --Bug #8198519. Resolve containment_instance_hdr_id values. All validations are done by DIO.

        IF l_config_input_tbl(i).containment_instance_hdr_id IS NOT NULL THEN
           l_config_input_tbl(i).containment_instance_hdr_id := p_instance_hdr_map(l_config_input_tbl(i).containment_instance_hdr_id).instance_hdr_id;
        END IF;
      END LOOP;

      FORALL i IN 1..l_config_input_tbl.COUNT
        INSERT INTO cz_config_inputs VALUES l_config_input_tbl(i);

    END LOOP;

    CLOSE input_cursor;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF input_cursor%ISOPEN THEN CLOSE input_cursor; END IF;
    RAISE;
END copy_config_input;

--------------------------------------------------------------------------------
PROCEDURE copy_config_attributes(p_old_config_hdr_id  IN  NUMBER,
                                 p_old_config_rev_nbr IN  NUMBER,
                                 p_new_config_hdr_id  IN  NUMBER,
                                 p_new_config_rev_nbr IN  NUMBER,
                                 p_item_id_map        IN number_tbl_type)
IS
  l_config_attr_tbl config_attr_tbl_type;

  CURSOR attr_cursor IS SELECT *
                        FROM cz_config_attributes
                        WHERE config_hdr_id = p_old_config_hdr_id
                        AND config_rev_nbr = p_old_config_rev_nbr
                        AND deleted_flag = '0';

BEGIN
  IF p_item_id_map.COUNT = 0 THEN
    INSERT INTO CZ_CONFIG_ATTRIBUTES
                (CONFIG_HDR_ID,
                 CONFIG_REV_NBR,
                 CONFIG_ITEM_ID,
                 ATTRIBUTE_CATEGORY,
                 ATTRIBUTE1,
                 ATTRIBUTE2,
                 ATTRIBUTE3,
                 ATTRIBUTE4,
                 ATTRIBUTE5,
                 ATTRIBUTE6,
                 ATTRIBUTE7,
                 ATTRIBUTE8,
                 ATTRIBUTE9,
                 ATTRIBUTE10,
                 ATTRIBUTE11,
                 ATTRIBUTE12,
                 ATTRIBUTE13,
                 ATTRIBUTE14,
                 ATTRIBUTE15,
                 ATTRIBUTE16,
                 ATTRIBUTE17,
                 ATTRIBUTE18,
                 ATTRIBUTE19,
                 ATTRIBUTE20,
                 ATTRIBUTE21,
                 ATTRIBUTE22,
                 ATTRIBUTE23,
                 ATTRIBUTE24,
                 ATTRIBUTE25,
                 ATTRIBUTE26,
                 ATTRIBUTE27,
                 ATTRIBUTE28,
                 ATTRIBUTE29,
                 ATTRIBUTE30,
                 LAST_UPDATE_LOGIN )
    SELECT
                 p_new_config_hdr_id,
                 p_new_config_rev_nbr,
                 CONFIG_ITEM_ID,
                 ATTRIBUTE_CATEGORY,
                 ATTRIBUTE1,
                 ATTRIBUTE2,
                 ATTRIBUTE3,
                 ATTRIBUTE4,
                 ATTRIBUTE5,
                 ATTRIBUTE6,
                 ATTRIBUTE7,
                 ATTRIBUTE8,
                 ATTRIBUTE9,
                 ATTRIBUTE10,
                 ATTRIBUTE11,
                 ATTRIBUTE12,
                 ATTRIBUTE13,
                 ATTRIBUTE14,
                 ATTRIBUTE15,
                 ATTRIBUTE16,
                 ATTRIBUTE17,
                 ATTRIBUTE18,
                 ATTRIBUTE19,
                 ATTRIBUTE20,
                 ATTRIBUTE21,
                 ATTRIBUTE22,
                 ATTRIBUTE23,
                 ATTRIBUTE24,
                 ATTRIBUTE25,
                 ATTRIBUTE26,
                 ATTRIBUTE27,
                 ATTRIBUTE28,
                 ATTRIBUTE29,
                 ATTRIBUTE30,
                 LAST_UPDATE_LOGIN
    FROM CZ_CONFIG_ATTRIBUTES
    WHERE CONFIG_HDR_ID=p_old_config_hdr_id AND CONFIG_REV_NBR=p_old_config_rev_nbr
    AND deleted_flag = '0';

  ELSE
    OPEN attr_cursor;
    LOOP
      l_config_attr_tbl.DELETE;
      FETCH attr_cursor BULK COLLECT INTO l_config_attr_tbl LIMIT BATCH_COPY_SIZE;
      EXIT WHEN attr_cursor%NOTFOUND AND l_config_attr_tbl.COUNT = 0;

      FOR i IN l_config_attr_tbl.FIRST .. l_config_attr_tbl.LAST LOOP
        IF (p_item_id_map.EXISTS(l_config_attr_tbl(i).config_item_id)) THEN
          l_config_attr_tbl(i).config_item_id := p_item_id_map(l_config_attr_tbl(i).config_item_id);
        END IF;

        l_config_attr_tbl(i).config_hdr_id  := p_new_config_hdr_id;
        l_config_attr_tbl(i).config_rev_nbr := p_new_config_rev_nbr;
      END LOOP;

      FORALL i IN l_config_attr_tbl.FIRST .. l_config_attr_tbl.LAST
        INSERT INTO CZ_CONFIG_ATTRIBUTES VALUES l_config_attr_tbl(i);
    END LOOP;

    CLOSE attr_cursor;
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF attr_cursor%ISOPEN THEN CLOSE attr_cursor; END IF;
    RAISE;
END copy_config_attributes;

--------------------------------------------------------------------------------
PROCEDURE copy_config_ext_attributes(p_old_sess_config_hdr_id  IN NUMBER
                                    ,p_old_sess_config_rev_nbr IN NUMBER
                                    ,p_instance_hdr_map IN instance_tbl_type
                                    ,p_item_id_map      IN number_tbl_type
                                    )
IS
  l_ext_attr_tbl    config_extattr_tbl_type;

  CURSOR attr_cursor IS
      SELECT *
      FROM cz_config_ext_attributes
      WHERE deleted_flag = '0' AND (config_hdr_id, config_rev_nbr) IN
        (SELECT instance_hdr_id, instance_rev_nbr
         FROM cz_config_items
         WHERE config_hdr_id = p_old_sess_config_hdr_id
         AND config_rev_nbr = p_old_sess_config_rev_nbr
         AND component_instance_type = NETWORK_INSTANCE_ROOT
         AND deleted_flag = '0');

BEGIN
  OPEN attr_cursor;
  LOOP
    l_ext_attr_tbl.DELETE;
    FETCH attr_cursor BULK COLLECT INTO l_ext_attr_tbl LIMIT BATCH_COPY_SIZE;
    EXIT WHEN attr_cursor%NOTFOUND AND l_ext_attr_tbl.COUNT = 0;

    FOR i IN l_ext_attr_tbl.FIRST .. l_ext_attr_tbl.LAST LOOP
      IF (p_item_id_map.EXISTS(l_ext_attr_tbl(i).config_item_id)) THEN
        l_ext_attr_tbl(i).config_item_id := p_item_id_map(l_ext_attr_tbl(i).config_item_id);
      END IF;

      l_ext_attr_tbl(i).config_rev_nbr := p_instance_hdr_map(l_ext_attr_tbl(i).config_hdr_id).instance_rev_nbr;
      l_ext_attr_tbl(i).config_hdr_id  := p_instance_hdr_map(l_ext_attr_tbl(i).config_hdr_id).instance_hdr_id;
    END LOOP;

    FORALL i IN l_ext_attr_tbl.FIRST .. l_ext_attr_tbl.LAST
      INSERT INTO CZ_CONFIG_EXT_ATTRIBUTES VALUES l_ext_attr_tbl(i);
  END LOOP;

  CLOSE attr_cursor;

EXCEPTION
  WHEN OTHERS THEN
    CLOSE attr_cursor;
    RAISE;

END copy_config_ext_attributes;

--------------------------------------------------------------------------------
PROCEDURE copy_config_messages(p_old_config_hdr_id   IN NUMBER
                              ,p_old_config_rev_nbr  IN NUMBER
                              ,p_new_config_hdr_id   IN NUMBER
                              ,p_new_config_rev_nbr  IN NUMBER
                              ,p_instance_hdr_map    IN instance_tbl_type
                              ,p_item_id_map         IN number_tbl_type)
IS
  l_instance_hdr_id   NUMBER;
  l_instance_rev_nbr  NUMBER;
  l_config_item_id    NUMBER;
  l_message_seq       NUMBER;

BEGIN
  FOR msg_rec IN (SELECT * FROM cz_config_messages
                  WHERE config_hdr_id = p_old_config_hdr_id
                    AND config_rev_nbr = p_old_config_rev_nbr
                    AND deleted_flag = '0'
                  ORDER BY MESSAGE_SEQ)
  LOOP
    l_instance_hdr_id  := msg_rec.instance_hdr_id;
    l_instance_rev_nbr := msg_rec.instance_rev_nbr;
    l_config_item_id   := msg_rec.config_item_id;

    IF (l_instance_hdr_id IS NOT NULL) THEN
      IF (p_instance_hdr_map.EXISTS(l_instance_hdr_id)) THEN
        l_instance_rev_nbr := p_instance_hdr_map(l_instance_hdr_id).instance_rev_nbr;
        l_instance_hdr_id  := p_instance_hdr_map(l_instance_hdr_id).instance_hdr_id;
      ELSE
        l_instance_hdr_id := p_new_config_hdr_id;
        l_instance_rev_nbr := p_new_config_rev_nbr;
      END IF;
    END IF;

    IF (l_config_item_id IS NOT NULL AND p_item_id_map.EXISTS(l_config_item_id)) THEN
      l_config_item_id := p_item_id_map(l_config_item_id);
    END IF;

    l_message_seq := get_next_msg_seq;

    INSERT INTO CZ_CONFIG_MESSAGES
            (MESSAGE_SEQ,
             CONFIG_HDR_ID,
             CONFIG_REV_NBR,
             CONSTRAINT_TYPE,
             MESSAGE,
             OVERRIDE,
             RULE_ID,
             PS_NODE_ID,
             LAST_UPDATE_LOGIN,
             SECURITY_MASK,
             CHECKOUT_USER,
             DELETED_FLAG,
             EFF_FROM,
             EFF_TO,
             EFF_MASK
            ,config_item_id
            ,instance_hdr_id
            ,instance_rev_nbr
           )
        VALUES
            (l_message_seq,
             p_new_config_hdr_id,
             p_new_config_rev_nbr,
             msg_rec.CONSTRAINT_TYPE,
             msg_rec.MESSAGE,
             msg_rec.OVERRIDE,
             msg_rec.RULE_ID,
             msg_rec.PS_NODE_ID,
             msg_rec.LAST_UPDATE_LOGIN,
             msg_rec.SECURITY_MASK,
             msg_rec.CHECKOUT_USER,
             msg_rec.DELETED_FLAG,
             msg_rec.EFF_FROM,
             msg_rec.EFF_TO,
             msg_rec.EFF_MASK
            ,l_config_item_id
            ,l_instance_hdr_id
            ,l_instance_rev_nbr
            );
  END LOOP;

EXCEPTION
  WHEN OTHERS THEN
    RAISE;

END copy_config_messages;

--------------------------------------------------------------------------------
PROCEDURE copy_configuration(p_api_version          IN  NUMBER
                            ,p_config_hdr_id        IN  NUMBER
                            ,p_config_rev_nbr       IN  NUMBER
                            ,p_copy_mode            IN  VARCHAR2
                            ,x_config_hdr_id        OUT NOCOPY  NUMBER
                            ,x_config_rev_nbr       OUT NOCOPY  NUMBER
                            ,x_orig_item_id_tbl     OUT NOCOPY  CZ_API_PUB.number_tbl_type
                            ,x_new_item_id_tbl      OUT NOCOPY  CZ_API_PUB.number_tbl_type
                            ,x_return_status        OUT NOCOPY  VARCHAR2
                            ,x_msg_count            OUT NOCOPY  NUMBER
                            ,x_msg_data             OUT NOCOPY  VARCHAR2
                            ,p_handle_deleted_flag  IN  VARCHAR2 := NULL
                            ,p_new_name             IN  VARCHAR2 := NULL
                            )
IS
  l_api_version  CONSTANT NUMBER := 1.0;
  l_api_name     CONSTANT VARCHAR2(30) := 'copy_configuration';

  l_model_instantiation_type  cz_config_hdrs.model_instantiation_type%TYPE;
  l_component_instance_type   cz_config_hdrs.component_instance_type%TYPE;
  l_deleted_flag              cz_config_hdrs.DELETED_FLAG%TYPE;

  -- lookup map of new instance hdr recs (id, rev), keyed by old instance_hdr_id
  l_instance_hdr_map   instance_tbl_type;

   -- config_item_id lookup map: key, old config_item_id; value, new config_item_id
  l_item_id_map     number_tbl_type;

  l_new_config_hdr_id   NUMBER;
  l_new_config_rev_nbr  NUMBER;

  l_index           NUMBER;
  l_run_id          NUMBER;
  l_instance_count  NUMBER;
  l_new_item_count  NUMBER;

BEGIN
  SAVEPOINT start_transaction;

  -- standard call to check for call compatibility
  IF (NOT FND_API.compatible_api_call(l_api_version
                                     ,p_api_version
                                     ,l_api_name
                                     ,G_PKG_NAME
                                     )) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  IF ((p_copy_mode IS NULL) OR (p_copy_mode <> CZ_API_PUB.G_NEW_HEADER_COPY_MODE AND
                                p_copy_mode <> CZ_API_PUB.G_NEW_REVISION_COPY_MODE)) THEN
    FND_MESSAGE.SET_NAME('CZ', 'CZ_NET_API_INVALID_TREE_MODE');
    FND_MESSAGE.SET_TOKEN('MODE', p_copy_mode);
    FND_MESSAGE.SET_TOKEN('PROC', l_api_name);
    FND_MSG_PUB.ADD;
    fnd_msg_pub.count_and_get(p_count => x_msg_count,
                              p_data  => x_msg_data);
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  BEGIN
    SELECT model_instantiation_type, component_instance_type, deleted_flag
      INTO l_model_instantiation_type, l_component_instance_type, l_deleted_flag
    FROM   cz_config_hdrs
    WHERE  config_hdr_id  = p_config_hdr_id
      AND  config_rev_nbr = p_config_rev_nbr;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      fnd_message.set_name('CZ', 'CZ_CFG_COPY_NO_CONFIG');
      fnd_msg_pub.add;
      RAISE FND_API.G_EXC_ERROR;
  END;

  IF( l_deleted_flag = '1') THEN
    IF (p_handle_deleted_flag IS NULL) THEN
      fnd_message.set_name('CZ', 'CZ_CFG_COPY_DELETED_CONFIG');
      fnd_msg_pub.add;
      RAISE FND_API.G_EXC_ERROR;
    ELSIF (p_handle_deleted_flag = '0') THEN
      UPDATE CZ_CONFIG_HDRS SET DELETED_FLAG = '0'
      WHERE CONFIG_HDR_ID = p_config_hdr_id
        AND CONFIG_REV_NBR = p_config_rev_nbr;
    END IF;
  END IF;

  -- input config must be session config
  -- i.e., component_instance_type must be 'R'
  IF (l_component_instance_type <> ROOT) THEN
    fnd_message.set_name('CZ', 'CZ_CFG_COPY_HDR_TYPE');
    fnd_message.set_token('id', p_config_hdr_id);
    fnd_message.set_token('revision', p_config_rev_nbr);
    fnd_message.set_token('type', l_component_instance_type);
    fnd_msg_pub.add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  IF (p_copy_mode = CZ_API_PUB.G_NEW_REVISION_COPY_MODE) THEN
    l_new_config_hdr_id  := p_config_hdr_id;
    l_new_config_rev_nbr := get_next_revision(p_config_hdr_id);
  ELSE
    l_new_config_hdr_id  := get_next_hdr_id;
    l_new_config_rev_nbr := 1;
  END IF;

  copy_config_header(p_config_hdr_id
                    ,p_config_rev_nbr
                    ,l_new_config_hdr_id
                    ,l_new_config_rev_nbr
                    ,p_new_name
                    ,p_copy_mode
                    );

  copy_instance_headers(p_config_hdr_id
                       ,p_config_rev_nbr
                       ,p_copy_mode
                       ,l_instance_hdr_map
                       );

  copy_config_item(p_config_hdr_id
                  ,p_config_rev_nbr
                  ,l_new_config_hdr_id
                  ,l_new_config_rev_nbr
                  ,p_copy_mode
                  ,(l_model_instantiation_type = NETWORK)
                  ,l_instance_hdr_map
                  ,l_item_id_map
                  );

  copy_config_input(p_config_hdr_id
                   ,p_config_rev_nbr
                   ,l_new_config_hdr_id
                   ,l_new_config_rev_nbr
                   ,l_item_id_map
                   ,l_instance_hdr_map
                   );


  copy_config_attributes(p_config_hdr_id
                        ,p_config_rev_nbr
                        ,l_new_config_hdr_id
                        ,l_new_config_rev_nbr
                        ,l_item_id_map
                        );

  l_instance_count := l_instance_hdr_map.COUNT;
  IF (l_model_instantiation_type = NETWORK AND l_instance_count > 0) THEN
    copy_config_ext_attributes(p_config_hdr_id
                              ,p_config_rev_nbr
                              ,l_instance_hdr_map
                              ,l_item_id_map
                              );
  END IF;

  copy_config_messages(p_config_hdr_id
                      ,p_config_rev_nbr
                      ,l_new_config_hdr_id
                      ,l_new_config_rev_nbr
                      ,l_instance_hdr_map
                      ,l_item_id_map
                      );

  -- copy ib data if necessary
  IF (l_model_instantiation_type = NETWORK AND l_instance_count > 0) THEN
    cz_ib_transactions.clone_ib_data(l_new_config_hdr_id
                                    ,l_new_config_rev_nbr
                                    ,l_run_id
                                    );
    IF (l_run_id <> 0) THEN
      fnd_message.set_name('CZ', 'CZ_CFG_COPY_IB');
      fnd_message.set_token('id', l_new_config_hdr_id);
      fnd_message.set_token('revision', l_new_config_rev_nbr);
      fnd_msg_pub.add;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
  END IF;

  x_config_hdr_id  := l_new_config_hdr_id;
  x_config_rev_nbr := l_new_config_rev_nbr;

  x_orig_item_id_tbl := CZ_API_PUB.NUMBER_TBL_TYPE();
  x_new_item_id_tbl  := CZ_API_PUB.NUMBER_TBL_TYPE();
  l_new_item_count := l_item_id_map.COUNT;
  IF (l_new_item_count > 0) THEN
    x_orig_item_id_tbl.EXTEND(l_new_item_count);
    x_new_item_id_tbl.EXTEND(l_new_item_count);
    l_index := l_item_id_map.FIRST;
    WHILE (l_index IS NOT NULL) LOOP
      x_orig_item_id_tbl(l_new_item_count) := l_index;
      x_new_item_id_tbl(l_new_item_count) := l_item_id_map(l_index);
      l_new_item_count := l_new_item_count - 1;
      l_index := l_item_id_map.NEXT(l_index);
    END LOOP;
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;
  fnd_msg_pub.count_and_get(p_count => x_msg_count,
                            p_data  => x_msg_data);

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    fnd_msg_pub.count_and_get(p_count => x_msg_count,
                              p_data  => x_msg_data);
    ROLLBACK TO start_transaction;

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    fnd_msg_pub.count_and_get(p_count => x_msg_count,
                              p_data  => x_msg_data);
    ROLLBACK TO start_transaction;

  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF fnd_msg_pub.check_msg_Level(fnd_msg_pub.G_MSG_LVL_UNEXP_ERROR) THEN
      fnd_msg_pub.add_exc_msg(G_PKG_NAME, l_api_name);
    END IF;

    fnd_msg_pub.count_and_get(p_count => x_msg_count,
                              p_data  => x_msg_data);
    ROLLBACK TO start_transaction;
END copy_configuration;

--------------------------------------------------------------------------------
PROCEDURE copy_configuration_auto
             (p_api_version          IN  NUMBER
             ,p_config_hdr_id        IN  NUMBER
             ,p_config_rev_nbr       IN  NUMBER
             ,p_copy_mode            IN  VARCHAR2
             ,x_config_hdr_id        OUT NOCOPY  NUMBER
             ,x_config_rev_nbr       OUT NOCOPY  NUMBER
             ,x_orig_item_id_tbl     OUT NOCOPY  CZ_API_PUB.number_tbl_type
             ,x_new_item_id_tbl      OUT NOCOPY  CZ_API_PUB.number_tbl_type
             ,x_return_status        OUT NOCOPY  VARCHAR2
             ,x_msg_count            OUT NOCOPY  NUMBER
             ,x_msg_data             OUT NOCOPY  VARCHAR2
             ,p_handle_deleted_flag  IN  VARCHAR2 := NULL
             ,p_new_name             IN  VARCHAR2 := NULL
      	)
IS
  PRAGMA AUTONOMOUS_TRANSACTION;
  l_api_version  CONSTANT NUMBER := 1.0;
  l_api_name     CONSTANT VARCHAR2(30) := 'copy_configuration_auto';

BEGIN
  copy_configuration(p_api_version
                    ,p_config_hdr_id
                    ,p_config_rev_nbr
                    ,p_copy_mode
                    ,x_config_hdr_id
                    ,x_config_rev_nbr
                    ,x_orig_item_id_tbl
                    ,x_new_item_id_tbl
                    ,x_return_status
                    ,x_msg_count
                    ,x_msg_data
                    ,p_handle_deleted_flag
                    ,p_new_name
                    );
  COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF fnd_msg_pub.check_msg_Level(fnd_msg_pub.G_MSG_LVL_UNEXP_ERROR) THEN
      fnd_msg_pub.add_exc_msg(G_PKG_NAME, l_api_name);
    END IF;
    fnd_msg_pub.count_and_get(p_count => x_msg_count,
                              p_data  => x_msg_data);
    ROLLBACK;
END copy_configuration_auto;

--------------------------------------------------------------------------------
PROCEDURE verify_configuration(p_api_version        IN  NUMBER
                              ,p_config_hdr_id      IN  NUMBER
                              ,p_config_rev_nbr     IN  NUMBER
                              ,x_exists_flag        OUT NOCOPY  VARCHAR2
                              ,x_valid_flag         OUT NOCOPY  VARCHAR2
                              ,x_complete_flag      OUT NOCOPY  VARCHAR2
                              ,x_return_status      OUT NOCOPY  VARCHAR2
                              ,x_msg_count          OUT NOCOPY  NUMBER
                              ,x_msg_data           OUT NOCOPY  VARCHAR2
                              )
IS
  l_api_version  CONSTANT NUMBER := 1.0;
  l_api_name     CONSTANT VARCHAR2(30) := 'verify_configuration';

  l_component_instance_type   cz_config_hdrs.component_instance_type%TYPE;
  l_config_status             cz_config_hdrs.config_status%TYPE;
  l_dummy  INTEGER;

BEGIN
  IF (NOT FND_API.compatible_api_call(l_api_version
                                     ,p_api_version
                                     ,l_api_name
                                     ,G_PKG_NAME
                                     )) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  BEGIN
    SELECT component_instance_type, config_status
     INTO  l_component_instance_type, l_config_status
    FROM cz_config_hdrs
    WHERE config_hdr_id = p_config_hdr_id
     AND  config_rev_nbr = p_config_rev_nbr
     AND  deleted_flag = '0';

    -- input config must be a session config
    IF (l_component_instance_type <> ROOT) THEN
      fnd_message.set_name('CZ', 'CZ_CFG_VERIFY_HDR_TYPE');
      fnd_message.set_token('id', p_config_hdr_id);
      fnd_message.set_token('revision', p_config_rev_nbr);
      fnd_message.set_token('type', l_component_instance_type);
      fnd_msg_pub.add;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    x_exists_flag := FND_API.G_TRUE;
    x_complete_flag := FND_API.G_TRUE;
    IF (l_config_status <> CONFIG_STATUS_COMPLETE) THEN
      x_complete_flag := FND_API.G_FALSE;
    END IF;

    BEGIN
      SELECT 1 INTO l_dummy
      FROM cz_config_messages
      WHERE config_hdr_id = p_config_hdr_id
       AND  config_rev_nbr = p_config_rev_nbr
       AND  deleted_flag = '0'
       AND ROWNUM < 2;

      x_valid_flag := FND_API.G_FALSE;

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        x_valid_flag := FND_API.G_TRUE;
    END;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      x_exists_flag := FND_API.G_FALSE;

  END;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;

    fnd_msg_pub.count_and_get(p_count => x_msg_count,
                              p_data  => x_msg_data);

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    fnd_msg_pub.count_and_get(p_count => x_msg_count,
                              p_data  => x_msg_data);

  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF fnd_msg_pub.check_msg_Level(fnd_msg_pub.G_MSG_LVL_UNEXP_ERROR) THEN
      fnd_msg_pub.add_exc_msg(G_PKG_NAME, l_api_name);
    END IF;

    fnd_msg_pub.count_and_get(p_count => x_msg_count,
                              p_data  => x_msg_data);
END verify_configuration;

--------------------------------------------------------------------------------
BEGIN
    SELECT NVL(cz_utils.conv_num(value),DEFAULT_INCR) INTO id_increment
    FROM CZ_DB_SETTINGS
    WHERE section_name='SCHEMA' AND setting_id='OracleSequenceIncr';

END CZ_CONFIG_API_PUB;

/
