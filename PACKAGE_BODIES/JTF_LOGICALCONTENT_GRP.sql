--------------------------------------------------------
--  DDL for Package Body JTF_LOGICALCONTENT_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_LOGICALCONTENT_GRP" AS
/* $Header: JTFGLCTB.pls 115.10 2004/07/09 18:49:55 applrt ship $ */


--- Generate primary key for the table
 CURSOR obj_lgl_ctnt_id_seq IS
   SELECT jtf_dsp_obj_lgl_ctnt_s1.NEXTVAL
     FROM DUAL;


PROCEDURE delete_logical_content(
   p_api_version         IN  NUMBER,
   p_init_msg_list       IN  VARCHAR2 := FND_API.g_false,
   p_commit              IN  VARCHAR2 := FND_API.g_false,
   x_return_status       OUT VARCHAR2,
   x_msg_count           OUT  NUMBER,
   x_msg_data            OUT  VARCHAR2,
  p_object_type		IN  VARCHAR2,
  p_lgl_ctnt_rec	IN OBJ_LGL_CTNT_REC_TYPE
 )
IS
   l_api_name    CONSTANT VARCHAR2(30) := 'delete_logical_content';
   l_full_name   CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
   l_return_status  VARCHAR2(1);
   l_index       NUMBER;
   l_context_id  NUMBER;
   l_exists 	 NUMBER;
BEGIN

   --------------------- initialize -----------------------
   SAVEPOINT delete_logical_content;

--dbms_output.put_line('delete_logical_content: checking the object existence');

   IF NOT FND_API.compatible_api_call(
         g_api_version,
         p_api_version,
         l_api_name,
         g_pkg_name
   ) THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;

   IF FND_API.to_boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  if p_lgl_ctnt_rec.obj_lgl_ctnt_id is not null
  then
   --- Check if the object logical content exists

 if jtf_dspmgrvalidation_grp.check_lgl_ctnt_id_exists(p_lgl_ctnt_rec.obj_lgl_ctnt_id,
						      p_lgl_ctnt_rec.object_version_number) = false then
       raise FND_API.g_exc_error;
 end if;

--dbms_output.put_line('delete_logical_content: passed the object existence');

  delete from jtf_dsp_obj_lgl_ctnt where
	 obj_lgl_ctnt_id = p_lgl_ctnt_rec.obj_lgl_ctnt_id and
	 object_version_number = p_lgl_ctnt_rec.object_version_number;
  else
 	raise jtf_dspmgrvalidation_grp.lglctnt_id_req_exception;
  end if;

--- Check if the caller requested to commit ,
--- If p_commit set to true, commit the transaction

IF  FND_API.to_boolean(p_commit) THEN
  COMMIT;
END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

EXCEPTION

   WHEN FND_API.g_exc_error THEN
      ROLLBACK TO delete_logical_content;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO delete_logical_content;
      x_return_status := FND_API.g_ret_sts_error ;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );


WHEN jtf_dspmgrvalidation_grp.lglctnt_id_req_exception THEN
   ROLLBACK TO delete_logical_content;
   x_return_status := FND_API.g_ret_sts_error;
   FND_MESSAGE.set_name('JTF','JTF_DSP_LGLCTNT_ID_REQ');
   FND_MSG_PUB.ADD;
   FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

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
            p_data    => x_msg_data
      );

END delete_logical_content;


PROCEDURE save_logical_content(
   p_api_version         IN  NUMBER,
   p_init_msg_list       IN  VARCHAR2 := FND_API.g_false,
   p_commit              IN  VARCHAR2 := FND_API.g_false,
   x_return_status       OUT VARCHAR2,
   x_msg_count           OUT  NUMBER,
   x_msg_data            OUT  VARCHAR2,
  p_object_type		IN  VARCHAR2,
  p_lgl_ctnt_rec	IN OBJ_LGL_CTNT_REC_TYPE
 )
IS
   l_api_name    CONSTANT VARCHAR2(30) := 'save_logical_content';
   l_full_name   CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
   l_return_status  VARCHAR2(1);
   l_index		NUMBER ;
   l_context_id         NUMBER;
   l_deliverable_id      NUMBER := null;
   l_exists			NUMBER := null;
   l_context_type		varchar2(100);
   l_obj_lgl_ctnt_id   NUMBER;
   l_object_type       VARCHAR2(40);
   l_applicable_to     VARCHAR2(40);

BEGIN

   --------------------- initialize -----------------------
   SAVEPOINT save_logical_content;

   IF NOT FND_API.compatible_api_call(
         g_api_version,
         p_api_version,
         l_api_name,
         g_pkg_name
   ) THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;


  --dbms_output.put_line('save_logical_content: checking the object existence');

   IF FND_API.to_boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;


--- Initialize API return status to success
x_return_status := FND_API.g_ret_sts_success;

--- check for existence of the object id

l_object_type := trim(p_object_type);

--dbms_output.put_line('type passed is ' || l_object_type );
--dbms_output.put_line('lgltype passed is ' || p_lgl_ctnt_rec.obj_lgl_ctnt_id );
--dbms_output.put_line('dtype passed is ' || p_lgl_ctnt_rec.deliverable_id );
if l_object_type = 'I' and
   p_lgl_ctnt_rec.obj_lgl_ctnt_id is null and
   p_lgl_ctnt_rec.deliverable_id is null
then
	IF  FND_API.to_boolean(p_commit) THEN
  		COMMIT;
	END IF;

  	x_return_status := FND_API.G_RET_STS_SUCCESS;

      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

--dbms_output.put_line('type passed is item');
      return;
end if;


--dbms_output.put_line('save_logical_content: checking the object existence and id ');

if jtf_dspmgrvalidation_grp.check_lgl_object_exists(p_object_type,p_lgl_ctnt_rec.object_id) = false  then
    raise FND_API.g_exc_error;
 end if;

--dbms_output.put_line('save_logical_content: passed the object existence');
--- check if the context exists

if p_lgl_ctnt_rec.context_id is not null or p_lgl_ctnt_rec.context_id <> FND_API.g_miss_num
then

l_context_type := jtf_dspmgrvalidation_grp.check_context_type_code(p_lgl_ctnt_rec.context_id);

--dbms_output.put_line('save_logical_content: passed the context_type validation');

if l_context_type is NULL then
       raise FND_API.g_exc_error;
 end if;

else
	raise jtf_dspmgrvalidation_grp.context_req_exception;
end if;

--- check if the deliverable exists
--- if the deliverable is passed, make sure the type is the same as
--- context type

if l_context_type = 'TEMPLATE' and p_object_type = 'S' then

   FND_MESSAGE.set_name('JTF','JTF_DSP_LGLCTNT_SCT_INVLD');
   FND_MSG_PUB.ADD;
end if;

if p_lgl_ctnt_rec.deliverable_id is not null
then

    if(l_object_type = 'I') then
	 l_applicable_to := 'CATEGORY';
    elsif (l_object_type = 'C') then
	 l_applicable_to := 'CATEGORY';
    elsif (l_object_type = 'S') then
 	 l_applicable_to := 'SECTION';
    end if;

     --dbms_output.put_line('save_logical_content: checking for deliverable type_exists ');

    if jtf_dspmgrvalidation_grp.check_deliverable_type_exists(p_lgl_ctnt_rec.deliverable_id, l_context_type,
  	   								         l_applicable_to) = false
    then
            raise FND_API.g_exc_error;
    end if;
     --dbms_output.put_line('save_logical_content: passed checking for deliverable type_exists ');

  if l_context_type = 'TEMPLATE'
  then

    if(l_object_type ='I' ) then
--- Make sure that the deliverable id is associated to atleast one of the categories the item
--- belongs to , otherwise raise an exception

  if jtf_dspmgrvalidation_grp.check_item_deliverable(p_lgl_ctnt_rec.object_id,p_lgl_ctnt_rec.deliverable_id) = false
  then
       raise FND_API.g_exc_error;
   end if;
elsif(l_object_type = 'C') then
--- Make sure that the deliverable id is associated to  the category
--- , otherwise raise an exception

  if jtf_dspmgrvalidation_grp.check_category_deliverable(p_lgl_ctnt_rec.object_id,p_lgl_ctnt_rec.deliverable_id) = false
  then
       raise FND_API.g_exc_error;
  end if;

 end if;
end if;
-----dbms_output.put_line('save_logical_content: passed the deliverable existence');
end if;


if l_object_type = 'I' and p_lgl_ctnt_rec.obj_lgl_ctnt_id is not null and
  p_lgl_ctnt_rec.deliverable_id = null
 then
--- Check if the object logical content id exists

 if jtf_dspmgrvalidation_grp.check_lgl_ctnt_id_exists(p_lgl_ctnt_rec.obj_lgl_ctnt_id,
						      p_lgl_ctnt_rec.object_version_number) = false then
       raise FND_API.g_exc_error;
 end if;
	delete from JTF_DSP_OBJ_LGL_CTNT where
		obj_lgl_ctnt_id = p_lgl_ctnt_rec.obj_lgl_ctnt_id and
                object_version_number = p_lgl_ctnt_rec.object_version_number and
		object_type = l_object_type;
else

IF  p_lgl_ctnt_rec.obj_lgl_ctnt_id is null
THEN
        OPEN obj_lgl_ctnt_id_seq;
        FETCH obj_lgl_ctnt_id_seq INTO l_obj_lgl_ctnt_id;
        CLOSE obj_lgl_ctnt_id_seq;

INSERT INTO JTF_DSP_OBJ_LGL_CTNT (
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
ITEM_ID
)
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

 if jtf_dspmgrvalidation_grp.check_lgl_ctnt_id_exists(p_lgl_ctnt_rec.obj_lgl_ctnt_id,
						      p_lgl_ctnt_rec.object_version_number) = false then
       raise FND_API.g_exc_error;
 end if;

UPDATE  JTF_DSP_OBJ_LGL_CTNT  SET
LAST_UPDATE_DATE = SYSDATE,
LAST_UPDATED_BY = FND_GLOBAL.user_id,
LAST_UPDATE_LOGIN= FND_GLOBAL.user_id,
OBJECT_ID = p_lgl_ctnt_rec.object_id,
OBJECT_TYPE = l_object_type,
CONTEXT_ID = p_lgl_ctnt_rec.context_id,
ITEM_ID = p_lgl_ctnt_rec.deliverable_id ,
OBJECT_VERSION_NUMBER = p_lgl_ctnt_rec.object_version_number + 1
WHERE
OBJ_LGL_CTNT_ID = p_lgl_ctnt_rec.obj_lgl_ctnt_id and
OBJECT_VERSION_NUMBER  = p_lgl_ctnt_rec.object_version_number;
END IF;

END IF;
--- Check if the caller requested to commit ,
--- If p_commit set to true, commit the transaction

IF  FND_API.to_boolean(p_commit) THEN
  COMMIT;
END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

EXCEPTION

   WHEN FND_API.g_exc_error THEN
      ROLLBACK TO save_logical_content;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN DUP_VAL_ON_INDEX THEN
      ROLLBACK TO save_logical_content;
      x_return_status := FND_API.g_ret_sts_error ;
      FND_MESSAGE.set_name('JTF','JTF_DSP_LGLCTNT_ROW_EXISTS');
      FND_MESSAGE.set_token('ID', p_lgl_ctnt_rec.object_id);
      FND_MESSAGE.set_token('TYPE', p_object_type);
      FND_MESSAGE.set_token('CTX_ID', p_lgl_ctnt_rec.context_id);
      FND_MSG_PUB.ADD;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
   WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO save_logical_content;
      x_return_status := FND_API.g_ret_sts_error ;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
WHEN jtf_dspmgrvalidation_grp.context_req_exception THEN
     ROLLBACK TO save_logical_content;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error)
      THEN
	  FND_MESSAGE.set_name('JTF','JTF_DSP_CONTEXT_REQ');
          FND_MSG_PUB.ADD;
        END IF;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

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
            p_data    => x_msg_data
      );

END save_logical_content;


PROCEDURE save_delete_lgl_ctnt(
   p_api_version         IN  NUMBER,
   p_init_msg_list       IN  VARCHAR2 := FND_API.g_false,
   p_commit              IN  VARCHAR2 := FND_API.g_false,
   x_return_status       OUT VARCHAR2,
   x_msg_count           OUT  NUMBER,
   x_msg_data            OUT  VARCHAR2,
   p_object_type_code	 IN   VARCHAR2,
  p_lgl_ctnt_tbl	      IN OBJ_LGL_CTNT_TBL_TYPE
 )
IS

   l_api_name    CONSTANT VARCHAR2(30) := 'save_delete_itm_lgl_ctnt';
   l_full_name   CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
   l_return_status  VARCHAR2(1);
   l_index		NUMBER ;
   l_context_id         NUMBER;
   l_deliverable_id      NUMBER := null;
   l_msg_count NUMBER;
   l_msg_data VARCHAR2(80);
   l_object_type_code  VARCHAR2(1) := null;
BEGIN

   --------------------- initialize -----------------------
   SAVEPOINT save_delete_itm_lgl_ctnt;

   IF NOT FND_API.compatible_api_call(
         g_api_version,
         p_api_version,
         l_api_name,
         g_pkg_name
   ) THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;


   IF FND_API.to_boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;


--- Initialize API return status to success
x_return_status := FND_API.g_ret_sts_success;


--dbms_output.put_line('PASSED THE VERSION NUMBER TEST:' || p_object_type_code || ':' || length(p_object_type_code));

if jtf_dspmgrvalidation_grp.check_valid_object_type(p_object_type_code) = false then
       raise FND_API.g_exc_error;
end if;


--dbms_output.put_line('PASSED THE TYPE  TEST');


FOR l_index  IN 1..p_lgl_ctnt_tbl.COUNT
LOOP
---
   IF p_lgl_ctnt_tbl(l_index).obj_lgl_ctnt_delete = FND_API.g_true
   then

--dbms_output.put_line('CALLING DELETE_LOGICAL_CONTENT');
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
	then

--dbms_output.put_line('CALLING SAVE_LOGICAL_CONTENT');
	  save_logical_content(
           p_api_version,
	     FND_API.g_false,
           FND_API.g_false,
           l_return_status,
           l_msg_count,
 	     l_msg_data,
	    p_object_type_code,
           p_lgl_ctnt_tbl(l_index));
   END IF;

--dbms_output.put_line('CALLED LOGICAL_CONTENT' || l_return_status );

  if l_return_status <> FND_API.G_RET_STS_SUCCESS
  then
		--dbms_output.put_line('retirn status from save' || l_return_status);
		x_return_status := l_return_status;
  end if;

--dbms_output.put_line('processing ' || p_lgl_ctnt_tbl(l_index).deliverable_id);
END LOOP;


      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

EXCEPTION

   WHEN FND_API.g_exc_error THEN
      ROLLBACK TO save_delete_itm_lgl_ctnt;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO save_delete_itm_lgl_ctnt;
      x_return_status := FND_API.g_ret_sts_error ;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );


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
            p_data    => x_msg_data
      );

END save_delete_lgl_ctnt;

PROCEDURE delete_section(
   p_section_id          IN   NUMBER
 )
IS
   l_api_name    CONSTANT VARCHAR2(30) := 'delete_section';
begin

SAVEPOINT delete_section;

if jtf_dspmgrvalidation_grp.check_section_exists(p_section_id) = false then
       raise FND_API.g_exc_error;
end if;

 DELETE FROM JTF_DSP_OBJ_LGL_CTNT where
 OBJECT_TYPE = 'S' and
 OBJECT_ID = p_section_id;

EXCEPTION
   WHEN OTHERS THEN
      ROLLBACK TO delete_section;

END delete_section;

PROCEDURE delete_deliverable(
   p_deliverable_id          IN   NUMBER
 )
IS
   l_api_name    CONSTANT VARCHAR2(30) := 'delete_deliverable';
BEGIN
SAVEPOINT delete_deliverable;

if p_deliverable_id is not null
then

 UPDATE  JTF_DSP_OBJ_LGL_CTNT SET
 ITEM_ID = null where
 ITEM_ID = p_deliverable_id ;

end if;

EXCEPTION
   WHEN OTHERS THEN
      ROLLBACK TO delete_deliverable;
END delete_deliverable;


PROCEDURE delete_category(
   p_category_id          IN   NUMBER
 )
IS
   l_api_name    CONSTANT VARCHAR2(30) := 'delete_category';
BEGIN
-- SAVEPOINT delete_category;

if p_category_id is not null
then
 DELETE FROM JTF_DSP_OBJ_LGL_CTNT where
 OBJECT_TYPE = 'C' and
 OBJECT_ID = p_category_id;
end if;

-- EXCEPTION
--    WHEN OTHERS THEN
--       ROLLBACK TO delete_category;
END delete_category;

PROCEDURE delete_item(
   p_item_id          IN   NUMBER
 )
IS
   l_api_name    CONSTANT VARCHAR2(30) := 'delete_item';
BEGIN
-- SAVEPOINT delete_item;

if p_item_id is not null
then
 DELETE FROM JTF_DSP_OBJ_LGL_CTNT where
 OBJECT_TYPE = 'I' and
 OBJECT_ID = p_item_id;
end if;

-- EXCEPTION
--    WHEN OTHERS THEN
--       ROLLBACK TO delete_item;
END delete_item;


PROCEDURE delete_context(
   p_context_id          IN   NUMBER
 )
IS
   l_api_name    CONSTANT VARCHAR2(30) := 'delete_context';
BEGIN
SAVEPOINT delete_context;

if p_context_id is not null
then

delete JTF_DSP_OBJ_LGL_CTNT
where context_id = p_context_id;
end if;

EXCEPTION
   WHEN OTHERS THEN
      ROLLBACK TO delete_context;
END delete_context;

PROCEDURE delete_category_dlv(
   p_category_id          IN   NUMBER,
   p_deliverable_id	    IN   NUMBER
 )
IS
   l_api_name    CONSTANT VARCHAR2(30) := 'delete_category_dlv';
BEGIN
SAVEPOINT delete_category_dlv;

if p_category_id  is not null  and
   p_deliverable_id is not null
then

UPDATE  JTF_DSP_OBJ_LGL_CTNT
set item_id = null
where object_type  = 'C' and
	    object_id = p_category_id and
	    ITEM_ID   = p_deliverable_id;
end if;

EXCEPTION

   WHEN OTHERS THEN
      ROLLBACK TO delete_category_dlv;

END delete_category_dlv;

END JTF_LogicalContent_GRP;


/
