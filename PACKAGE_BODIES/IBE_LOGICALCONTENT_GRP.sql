--------------------------------------------------------
--  DDL for Package Body IBE_LOGICALCONTENT_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBE_LOGICALCONTENT_GRP" AS
  /* $Header: IBEGLCTB.pls 120.1 2005/12/28 13:26:46 savarghe noship $ */

  -- HISTORY
  --   12/12/02           SCHAK         Modified for NOCOPY (Bug # 2691704) Changes.
  -- *********************************************************************************

--- Generate primary key for the table
CURSOR obj_lgl_ctnt_id_seq IS
  SELECT ibe_dsp_obj_lgl_ctnt_s1.NEXTVAL
    FROM DUAL;


PROCEDURE delete_logical_content(
  p_api_version         IN  NUMBER,
  p_init_msg_list       IN  VARCHAR2 := FND_API.g_false,
  p_commit              IN  VARCHAR2 := FND_API.g_false,
  x_return_status       OUT NOCOPY VARCHAR2,
  x_msg_count           OUT NOCOPY  NUMBER,
  x_msg_data            OUT NOCOPY  VARCHAR2,
  p_object_type		IN  VARCHAR2,
  p_lgl_ctnt_rec	IN OBJ_LGL_CTNT_REC_TYPE )
IS
  l_api_name    CONSTANT VARCHAR2(30) := 'delete_logical_content';
  l_full_name   CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
  l_return_status  VARCHAR2(1);
  l_index          NUMBER;
  l_context_id     NUMBER;
  l_exists 	   NUMBER;
BEGIN
  --------------------- initialize -----------------------+
  SAVEPOINT delete_logical_content;

  IF NOT FND_API.compatible_api_call(
    g_api_version,
    p_api_version,
    l_api_name,
    g_pkg_name )
  THEN
    RAISE FND_API.g_exc_unexpected_error;
  END IF;

  IF FND_API.to_boolean(p_init_msg_list)
  THEN
    FND_MSG_PUB.initialize;
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF p_lgl_ctnt_rec.obj_lgl_ctnt_id IS NOT NULL
  THEN
    --- Check if the object logical content exists
    IF ibe_dspmgrvalidation_grp.check_lgl_ctnt_id_exists(
      p_lgl_ctnt_rec.obj_lgl_ctnt_id,
      p_lgl_ctnt_rec.object_version_number) = false
    THEN
      RAISE FND_API.g_exc_error;
    END IF;

    DELETE FROM ibe_dsp_obj_lgl_ctnt
      WHERE obj_lgl_ctnt_id       = p_lgl_ctnt_rec.obj_lgl_ctnt_id
      AND   object_version_number = p_lgl_ctnt_rec.object_version_number;
  ELSE
    RAISE ibe_dspmgrvalidation_grp.lglctnt_id_req_exception;
  END IF;

  --- Check if the caller requested to commit ,
  --- If p_commit set to true, commit the transaction

  IF  FND_API.to_boolean(p_commit)
  THEN
    COMMIT;
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  FND_MSG_PUB.count_and_get(
    p_encoded => FND_API.g_false,
    p_count   => x_msg_count,
    p_data    => x_msg_data );
EXCEPTION
   WHEN FND_API.g_exc_error THEN
     ROLLBACK TO delete_logical_content;
     x_return_status := FND_API.g_ret_sts_error;
     FND_MSG_PUB.count_and_get(
       p_encoded => FND_API.g_false,
       p_count   => x_msg_count,
       p_data    => x_msg_data );

   WHEN FND_API.g_exc_unexpected_error THEN
     ROLLBACK TO delete_logical_content;
     x_return_status := FND_API.g_ret_sts_error ;
     FND_MSG_PUB.count_and_get(
       p_encoded => FND_API.g_false,
       p_count   => x_msg_count,
       p_data    => x_msg_data );

   WHEN ibe_dspmgrvalidation_grp.lglctnt_id_req_exception THEN
     ROLLBACK TO delete_logical_content;
     x_return_status := FND_API.g_ret_sts_error;
     FND_MESSAGE.set_name('IBE','IBE_DSP_LGLCTNT_ID_REQ');
     FND_MSG_PUB.ADD;
     FND_MSG_PUB.count_and_get(
       p_encoded => FND_API.g_false,
       p_count   => x_msg_count,
       p_data    => x_msg_data );

   WHEN OTHERS THEN
     ROLLBACK TO delete_logical_content;
     x_return_status := FND_API.g_ret_sts_unexp_error ;
     IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error)
     THEN
       FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
     END IF;
     FND_MSG_PUB.count_and_get(
       p_encoded => FND_API.g_false,
       p_count   => x_msg_count,
       p_data    => x_msg_data);
END delete_logical_content;

PROCEDURE save_logical_content(
  p_api_version         IN  NUMBER,
  p_init_msg_list       IN  VARCHAR2 := FND_API.g_false,
  p_commit              IN  VARCHAR2 := FND_API.g_false,
  x_return_status       OUT NOCOPY VARCHAR2,
  x_msg_count           OUT NOCOPY  NUMBER,
  x_msg_data            OUT NOCOPY  VARCHAR2,
  p_object_type		IN  VARCHAR2,
  p_lgl_ctnt_rec	IN OBJ_LGL_CTNT_REC_TYPE
                              )
IS
  l_api_name    CONSTANT VARCHAR2(30) := 'save_logical_content';
  l_full_name   CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
  l_return_status     VARCHAR2(1);
  l_index	      NUMBER ;
  l_context_id        NUMBER;
  l_deliverable_id    NUMBER := null;
  l_exists	      NUMBER := null;
  l_context_type      VARCHAR2(100);
  l_obj_lgl_ctnt_id   NUMBER;
  l_object_type       VARCHAR2(40);
  l_applicable_to     VARCHAR2(40);
BEGIN
  --------------------- initialize -----------------------+
  SAVEPOINT save_logical_content;

  IF NOT FND_API.compatible_api_call(
    g_api_version,
    p_api_version,
    l_api_name,
    g_pkg_name )
  THEN
    RAISE FND_API.g_exc_unexpected_error;
  END IF;

  IF FND_API.to_boolean(p_init_msg_list)
  THEN
    FND_MSG_PUB.initialize;
  END IF;

  --- Initialize API return status to success
  x_return_status := FND_API.g_ret_sts_success;

  --- check for existence of the object id
  l_object_type := trim(p_object_type);

  IF l_object_type = 'I' AND
    p_lgl_ctnt_rec.obj_lgl_ctnt_id IS NULL AND
    p_lgl_ctnt_rec.deliverable_id IS NULL
  THEN
    IF FND_API.to_boolean(p_commit)
    THEN
      COMMIT;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    FND_MSG_PUB.count_and_get(
      p_encoded => FND_API.g_false,
      p_count   => x_msg_count,
      p_data    => x_msg_data );

    RETURN;
  END IF;

  IF ibe_dspmgrvalidation_grp.check_lgl_object_exists(
    p_object_type,p_lgl_ctnt_rec.object_id) = false
  THEN
    RAISE FND_API.g_exc_error;
  END IF;

  --- check if the context exists
  IF p_lgl_ctnt_rec.context_id IS NOT NULL OR
     p_lgl_ctnt_rec.context_id <> FND_API.g_miss_num
  THEN
    l_context_type := ibe_dspmgrvalidation_grp.check_context_type_code(
                                              p_lgl_ctnt_rec.context_id);

    IF l_context_type IS NULL
    THEN
      RAISE FND_API.g_exc_error;
    END IF;
  ELSE
    RAISE ibe_dspmgrvalidation_grp.context_req_exception;
  END IF;

  --- check if the deliverable exists
  --- if the deliverable is passed, make sure the type is the same as
  --- context type
  -- Do not add error message to the message stack
  -- IF l_context_type = 'TEMPLATE' AND
  --   p_object_type = 'S'
  -- THEN
  --   FND_MESSAGE.set_name('IBE','IBE_DSP_LGLCTNT_SCT_INVLD');
  --   FND_MSG_PUB.ADD;
  -- END IF;

  IF (p_lgl_ctnt_rec.deliverable_id IS NOT NULL)
    AND (l_context_type = 'MEDIA')
  THEN
    IF(l_object_type = 'I')
    THEN
      l_applicable_to := 'CATEGORY';
    ELSIF (l_object_type = 'C')
    THEN
      l_applicable_to := 'CATEGORY';
    ELSIF (l_object_type = 'S')
    THEN
      l_applicable_to := 'SECTION';
    END IF;

    IF ibe_dspmgrvalidation_grp.check_deliverable_type_exists(
      p_lgl_ctnt_rec.deliverable_id,
      l_context_type,
      l_applicable_to) = false
    THEN
      RAISE FND_API.g_exc_error;
    END IF;

  END IF;

  IF l_object_type = 'I' AND
    p_lgl_ctnt_rec.obj_lgl_ctnt_id IS NOT NULL AND
    p_lgl_ctnt_rec.deliverable_id = null
  THEN
    --- Check if the object logical content id exists
    IF ibe_dspmgrvalidation_grp.check_lgl_ctnt_id_exists(
      p_lgl_ctnt_rec.obj_lgl_ctnt_id,
      p_lgl_ctnt_rec.object_version_number) = false
    THEN
      RAISE FND_API.g_exc_error;
    END IF;

    DELETE FROM IBE_DSP_OBJ_LGL_ctnt
      WHERE obj_lgl_ctnt_id       = p_lgl_ctnt_rec.obj_lgl_ctnt_id
      AND   object_version_number = p_lgl_ctnt_rec.object_version_number
      AND   object_type           = l_object_type;
  ELSE
    IF  p_lgl_ctnt_rec.obj_lgl_ctnt_id IS NULL
    THEN
      OPEN obj_lgl_ctnt_id_seq;
      FETCH obj_lgl_ctnt_id_seq INTO l_obj_lgl_ctnt_id;
      CLOSE obj_lgl_ctnt_id_seq;

      INSERT INTO IBE_DSP_OBJ_LGL_CTNT (
        OBJ_LGL_CTNT_ID,
        OBJECT_VERSION_NUMBER,
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY,
        CREATION_DATE,
        CREATED_BY,
        LAST_UPDATE_LOGIN,
        OBJECT_ID,
        OBJECT_TYPE,
        CONTEXT_ID,
        ITEM_ID )
      VALUES (
        l_obj_lgl_ctnt_id,
        1,
        SYSDATE,
        FND_GLOBAL.user_id,
        SYSDATE,
        FND_GLOBAL.user_id,
        FND_GLOBAL.user_id,
        p_lgl_ctnt_rec.object_id,
        l_object_type,
        p_lgl_ctnt_rec.context_id,
        p_lgl_ctnt_rec.deliverable_id);
    ELSE
      --- Check if the object logical content id exists
      IF ibe_dspmgrvalidation_grp.check_lgl_ctnt_id_exists(
         p_lgl_ctnt_rec.obj_lgl_ctnt_id,
         p_lgl_ctnt_rec.object_version_number) = false
      THEN
        RAISE FND_API.g_exc_error;
      END IF;

      UPDATE IBE_DSP_OBJ_LGL_CTNT
      SET    LAST_UPDATE_DATE  = SYSDATE,
             LAST_UPDATED_BY   = FND_GLOBAL.user_id,
             LAST_UPDATE_LOGIN = FND_GLOBAL.user_id,
             OBJECT_ID         = p_lgl_ctnt_rec.object_id,
             OBJECT_TYPE       = l_object_type,
             CONTEXT_id        = p_lgl_ctnt_rec.context_id,
             ITEM_id           = p_lgl_ctnt_rec.deliverable_id ,
             OBJECT_VERSION_NUMBER = p_lgl_ctnt_rec.object_version_number + 1
      WHERE OBJ_LGL_CTNT_id        = p_lgl_ctnt_rec.obj_lgl_ctnt_id
      AND   OBJECT_VERSION_NUMBER  = p_lgl_ctnt_rec.object_version_number;
    END IF;
  END IF;
  --- Check if the caller requested to commit ,
  --- If p_commit set to true, commit the transaction

  IF  FND_API.to_boolean(p_commit)
  THEN
    COMMIT;
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  FND_MSG_PUB.count_and_get(
    p_encoded => FND_API.g_false,
    p_count   => x_msg_count,
    p_data    => x_msg_data );
EXCEPTION
   WHEN FND_API.g_exc_error THEN
     ROLLBACK TO save_logical_content;
     x_return_status := FND_API.g_ret_sts_error;
     FND_MSG_PUB.count_and_get(
       p_encoded => FND_API.g_false,
       p_count   => x_msg_count,
       p_data    => x_msg_data );

   WHEN DUP_VAL_ON_INDEX THEN
     ROLLBACK TO save_logical_content;
     x_return_status := FND_API.g_ret_sts_error ;
     FND_MESSAGE.set_name('IBE','IBE_DSP_LGLCTNT_ROW_EXISTS');
     FND_MESSAGE.set_token('ID', p_lgl_ctnt_rec.object_id);
     FND_MESSAGE.set_token('TYPE', p_object_type);
     FND_MESSAGE.set_token('CTX_ID', p_lgl_ctnt_rec.context_id);
     FND_MSG_PUB.ADD;
     FND_MSG_PUB.count_and_get(
       p_encoded => FND_API.g_false,
       p_count   => x_msg_count,
       p_data    => x_msg_data );

   WHEN FND_API.g_exc_unexpected_error THEN
     ROLLBACK TO save_logical_content;
     x_return_status := FND_API.g_ret_sts_error ;
     FND_MSG_PUB.count_and_get(
       p_encoded => FND_API.g_false,
       p_count   => x_msg_count,
       p_data    => x_msg_data );

   WHEN ibe_dspmgrvalidation_grp.context_req_exception THEN
     ROLLBACK TO save_logical_content;
     x_return_status := FND_API.g_ret_sts_unexp_error ;
     IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error)
     THEN
       FND_MESSAGE.set_name('IBE','IBE_DSP_CONTEXT_REQ');
       FND_MSG_PUB.ADD;
     END IF;
     FND_MSG_PUB.count_and_get(
       p_encoded => FND_API.g_false,
       p_count   => x_msg_count,
       p_data    => x_msg_data );

   WHEN OTHERS THEN
     ROLLBACK TO save_logical_content;
     x_return_status := FND_API.g_ret_sts_unexp_error ;
     IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error)
     THEN
       FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
     END IF;
     FND_MSG_PUB.count_and_get(
       p_encoded => FND_API.g_false,
       p_count   => x_msg_count,
       p_data    => x_msg_data );
END save_logical_content;

PROCEDURE save_delete_lgl_ctnt(
  p_api_version         IN  NUMBER,
  p_init_msg_list       IN  VARCHAR2 := FND_API.g_false,
  p_commit              IN  VARCHAR2 := FND_API.g_false,
  x_return_status       OUT NOCOPY VARCHAR2,
  x_msg_count           OUT NOCOPY NUMBER,
  x_msg_data            OUT NOCOPY VARCHAR2,
  p_object_type_code	IN  VARCHAR2,
  p_lgl_ctnt_tbl	IN  OBJ_LGL_CTNT_TBL_TYPE )
IS
  l_api_name    CONSTANT VARCHAR2(30) := 'save_delete_itm_lgl_ctnt';
  l_full_name   CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
  l_return_status       VARCHAR2(1);
  l_index		NUMBER ;
  l_context_id          NUMBER;
  l_deliverable_id      NUMBER := null;
  l_msg_count           NUMBER;
  l_msg_data            VARCHAR2(80);
  l_object_type_code    VARCHAR2(1) := null;
BEGIN
  --------------------- initialize -----------------------+
  SAVEPOINT save_delete_itm_lgl_ctnt;

  IF NOT FND_API.compatible_api_call(
    g_api_version,
    p_api_version,
    l_api_name,
    g_pkg_name )
  THEN
    RAISE FND_API.g_exc_unexpected_error;
  END IF;

  IF FND_API.to_boolean(p_init_msg_list)
  THEN
    FND_MSG_PUB.initialize;
  END IF;

  --- Initialize API return status to success
  x_return_status := FND_API.g_ret_sts_success;

  IF ibe_dspmgrvalidation_grp.check_valid_object_type(
    p_object_type_code) = false
  THEN
    RAISE FND_API.g_exc_error;
  END IF;

  FOR l_index  IN 1..p_lgl_ctnt_tbl.COUNT
  LOOP
    IF p_lgl_ctnt_tbl(l_index).obj_lgl_ctnt_delete = FND_API.g_true
    THEN
      delete_logical_content(
        p_api_version,
        FND_API.g_false,
        FND_API.g_false,
        l_return_status,
        l_msg_count,
        l_msg_data,
        p_object_type_code,
        p_lgl_ctnt_tbl(l_index));

    ELSIF p_lgl_ctnt_tbl(l_index).obj_lgl_ctnt_delete = FND_API.g_false
    THEN
      save_logical_content(
        p_api_version,
        FND_API.g_false,
        p_commit,
        l_return_status,
        l_msg_count,
        l_msg_data,
        p_object_type_code,
        p_lgl_ctnt_tbl(l_index));
    END IF;

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS
    THEN
      x_return_status := l_return_status;
    END IF;
  END LOOP;

  FND_MSG_PUB.count_and_get(
    p_encoded => FND_API.g_false,
    p_count   => x_msg_count,
    p_data    => x_msg_data );
EXCEPTION
   WHEN FND_API.g_exc_error THEN
     ROLLBACK TO save_delete_itm_lgl_ctnt;
     x_return_status := FND_API.g_ret_sts_error;
     FND_MSG_PUB.count_and_get(
       p_encoded => FND_API.g_false,
       p_count   => x_msg_count,
       p_data    => x_msg_data );

   WHEN FND_API.g_exc_unexpected_error THEN
     ROLLBACK TO save_delete_itm_lgl_ctnt;
     x_return_status := FND_API.g_ret_sts_error ;
     FND_MSG_PUB.count_and_get(
       p_encoded => FND_API.g_false,
       p_count   => x_msg_count,
       p_data    => x_msg_data );

   WHEN OTHERS THEN
     ROLLBACK TO save_delete_itm_lgl_ctnt;
     x_return_status := FND_API.g_ret_sts_unexp_error ;
     IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error)
     THEN
       FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
     END IF;
     FND_MSG_PUB.count_and_get(
       p_encoded => FND_API.g_false,
       p_count   => x_msg_count,
       p_data    => x_msg_data );
END save_delete_lgl_ctnt;

PROCEDURE delete_section(p_section_id IN  NUMBER )
IS
  l_api_name    CONSTANT VARCHAR2(30) := 'delete_section';
BEGIN
  SAVEPOINT delete_section;

  IF ibe_dspmgrvalidation_grp.check_section_exists(
     p_section_id) = false
  THEN
    RAISE FND_API.g_exc_error;
  END IF;

  DELETE FROM IBE_DSP_OBJ_LGL_ctnt
    WHERE OBJECT_TYPE = 'S'
    AND   OBJECT_ID = p_section_id;
EXCEPTION
   WHEN OTHERS THEN
     ROLLBACK TO delete_section;
END delete_section;

PROCEDURE delete_deliverable(p_deliverable_id IN NUMBER)
IS
  l_api_name    CONSTANT VARCHAR2(30) := 'delete_deliverable';
BEGIN
  SAVEPOINT delete_deliverable;

  IF p_deliverable_id IS NOT NULL
  THEN
    UPDATE  IBE_DSP_OBJ_LGL_CTNT SET
      ITEM_ID = null where
      ITEM_ID = p_deliverable_id ;
  END IF;
EXCEPTION
   WHEN OTHERS THEN
     ROLLBACK TO delete_deliverable;
END delete_deliverable;

PROCEDURE delete_category(p_category_id IN NUMBER)
IS
  l_api_name    CONSTANT VARCHAR2(30) := 'delete_category';
BEGIN
  -- SAVEPOINT delete_category;
  IF p_category_id IS NOT NULL
  THEN
    DELETE FROM IBE_DSP_OBJ_LGL_ctnt
      WHERE OBJECT_TYPE = 'C'
      AND   OBJECT_ID = p_category_id;
  END IF;
END delete_category;

PROCEDURE delete_item(p_item_id IN NUMBER )
IS
  l_api_name    CONSTANT VARCHAR2(30) := 'delete_item';
BEGIN
  -- SAVEPOINT delete_item;
  IF p_item_id IS NOT NULL
  THEN
    DELETE FROM IBE_DSP_OBJ_LGL_ctnt
      WHERE OBJECT_TYPE = 'I'
      AND   OBJECT_id   = p_item_id;
  END IF;
END delete_item;

PROCEDURE delete_context(p_context_id IN NUMBER )
IS
  l_api_name    CONSTANT VARCHAR2(30) := 'delete_context';
BEGIN
  SAVEPOINT delete_context;

  IF p_context_id IS NOT NULL
  THEN
    DELETE IBE_DSP_OBJ_LGL_CTNT
      WHERE context_id = p_context_id;
  END IF;
EXCEPTION
   WHEN OTHERS THEN
     ROLLBACK TO delete_context;
END delete_context;

PROCEDURE delete_category_dlv(
          p_category_id       IN   NUMBER,
          p_deliverable_id    IN   NUMBER )
IS
  l_api_name    CONSTANT VARCHAR2(30) := 'delete_category_dlv';
BEGIN
  SAVEPOINT delete_category_dlv;

  IF p_category_id  IS NOT NULL  AND
    p_deliverable_id IS NOT NULL
  THEN
    UPDATE  IBE_DSP_OBJ_LGL_CTNT
       SET  item_id = NULL
      WHERE object_type  = 'C'
      AND   object_id    = p_category_id
      AND   item_id      = p_deliverable_id;
  END IF;
EXCEPTION
   WHEN OTHERS THEN
     ROLLBACK TO delete_category_dlv;
END delete_category_dlv;
END IBE_LogicalContent_GRP;

/
