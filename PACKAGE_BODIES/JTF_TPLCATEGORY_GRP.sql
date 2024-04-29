--------------------------------------------------------
--  DDL for Package Body JTF_TPLCATEGORY_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_TPLCATEGORY_GRP" AS
/* $Header: JTFGTCGB.pls 115.8 2004/07/09 18:51:14 applrt ship $ */

---- Generate primary key from sequence
CURSOR dsp_tpl_seq IS
   SELECT jtf_dsp_tpl_ctg_s1.NEXTVAL
     FROM DUAL;

---------------------------------------------------------------------
-- NOTES
--    1. Raises an exception if the api_version is not valid
--    2. Raises an exception if the category id does not exist
--    3. Raises an exception if the template_id is missing or invalid
--       The template_id should have DELIVERABLE_TYPE_CODE = TEMPLATE
--	    and APPLICABLE_TO_CODE = CATEGORY (JTF_AMV_ITEMS_B)
--	 4. If the template-category relationship already exists,
--        no error is raised
---------------------------------------------------------------------
PROCEDURE add_tpl_ctg_rec(
   p_api_version           IN  NUMBER,
   p_init_msg_list	   IN VARCHAR2 := FND_API.g_false,
   p_commit                IN  VARCHAR2  := FND_API.g_false,
   x_return_status              OUT VARCHAR2,
   p_template_id        IN NUMBER,
   p_category_id       IN  NUMBER
)
IS
l_api_name    CONSTANT VARCHAR2(30) := 'add_tpl_ctg_rec';
l_full_name   CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
l_dsp_tpl_seq_id NUMBER;
l_category_id NUMBER;
l_template_id NUMBER;
l_row_exists NUMBER;
l_type VARCHAR2(30) := 'TEMPLATE';
l_applicable_to VARCHAR2(30) := 'CATEGORY';
BEGIN

   SAVEPOINT add_tpl_ctg_rec;

---dbms_output.put_line('PASSED TO ADD_TPL_CTG_REC' || p_template_id || '---' || p_category_id);

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

 x_return_status := FND_API.g_ret_sts_success;

---dbms_output.put_line('passed api version check in add_tpl_ctg_rec');


--- Check if the deliverable id exists .
IF p_template_id  <> FND_API.g_miss_num and p_template_id is not null
then
  IF jtf_dspmgrvalidation_grp.check_deliverable_type_exists(p_template_id,l_type ,l_applicable_to)
  then
    ---dbms_output.put_line('passed template check in add_tpl_ctg_rec' || p_template_id );

   IF p_category_id <> FND_API.g_miss_num and p_category_id is not null
   THEN
     if jtf_dspmgrvalidation_grp.check_category_exists(p_category_id)
	 then
         ---dbms_output.put_line('passed category check in add_tpl_ctg_rec' || p_category_id );

         if jtf_dspmgrvalidation_grp.check_ctg_tpl_relation_exists( p_category_id,
			  				 	    p_template_id) = false then

            OPEN dsp_tpl_seq;
            FETCH dsp_tpl_seq INTO l_dsp_tpl_seq_id;
            CLOSE dsp_tpl_seq;

		INSERT INTO JTF_DSP_TPL_CTG (
		TPL_CTG_ID,
		OBJECT_VERSION_NUMBER,
		LAST_UPDATE_DATE,
		LAST_UPDATED_BY,
		CREATION_DATE,
		CREATED_BY,
		LAST_UPDATE_LOGIN,
		ITEM_ID,
		CATEGORY_ID
		)
 		VALUES (
		l_dsp_tpl_seq_id,
		1,
		SYSDATE,
		FND_GLOBAL.user_id,
		SYSDATE,
		FND_GLOBAL.user_id,
		FND_GLOBAL.user_id,
		p_template_id,
		p_category_id);

	        ---dbms_output.put_line('insert record ' || p_template_id || '0-0'|| p_category_id);

          end if; /* category - template relation not exists check */
      else
	raise FND_API.g_exc_error;
      end if; /* category exists check */
   else
       raise jtf_dspmgrvalidation_grp.category_req_exception;
   end if; /* category id is not null check */
 else
     raise FND_API.g_exc_error;
 END IF;/* deliverable exists check */
else
   raise jtf_dspmgrvalidation_grp.template_req_exception;
end if; /*deliverable id is not null check */


--- Check if the caller requested to commit ,
--- If p_commit set to true, commit the transaction
IF  FND_API.to_boolean(p_commit) THEN
  COMMIT;
END IF;

x_return_status := FND_API.g_ret_sts_success;


EXCEPTION

   WHEN FND_API.g_exc_error THEN
      ROLLBACK TO add_tpl_ctg_rec;
      x_return_status := FND_API.g_ret_sts_error;


   WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO add_tpl_ctg_rec;
      x_return_status := FND_API.g_ret_sts_unexp_error ;

WHEN jtf_dspmgrvalidation_grp.category_req_exception THEN
  IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
  THEN
   x_return_status := FND_API.g_ret_sts_error;
   FND_MESSAGE.set_name('JTF','JTF_DSP_CATEGORY_REQ');
   FND_MSG_PUB.add;
  END IF;

WHEN jtf_dspmgrvalidation_grp.template_req_exception THEN
  IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
  THEN
   x_return_status := FND_API.g_ret_sts_error;
   FND_MESSAGE.set_name('JTF','JTF_DSP_TEMPLATE_REQ');
   FND_MSG_PUB.add;
  END IF;

WHEN OTHERS THEN
      ROLLBACK TO add_tpl_ctg_rec;
      x_return_status := FND_API.g_ret_sts_unexp_error ;

      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error)
                THEN
         FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
      END IF;
END add_tpl_ctg_rec;
-----------------------------------------------------------------------
-- NOTES
--    1. Raises an exception if the api_version is not valid
--    2. Raises an exception if the template_id is missing or invalid
--       The template_id should have DELIVERABLE_TYPE_CODE = TEMPLATE
--	    and APPLICABLE_TO_CODE = CATEGORY (JTF_AMV_ITEMS_B)
--	 3. Raises an exception if any invalid category is passed in
--	    p_category_id_tbl
--
---------------------------------------------------------------------
PROCEDURE add_tpl_ctg(
   p_api_version           IN  NUMBER,
   p_init_msg_list	   IN VARCHAR2 := FND_API.g_false,
   p_commit                IN  VARCHAR2  := FND_API.g_false,
   x_return_status              OUT VARCHAR2,
   x_msg_count          OUT  NUMBER,
   x_msg_data           OUT  VARCHAR2,
   p_template_id        IN NUMBER,
   p_category_id_tbl   IN  category_ID_TBL_TYPE
)
IS
   l_api_name    CONSTANT VARCHAR2(30) := 'add_tpl_ctg';
   l_full_name   CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
   l_return_status  VARCHAR2(1);
   l_deliverable_id  NUMBER;
   l_category_id     NUMBER;
   l_dsp_tpl_seq_id  NUMBER;
   l_index   	     NUMBER;
   l_row_exists      NUMBER;

l_type VARCHAR2(30) := 'TEMPLATE';
l_applicable_to VARCHAR2(30) := 'CATEGORY';

BEGIN

   --------------------- initialize -----------------------
   SAVEPOINT add_tpl_ctg;
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

IF p_template_id is not null and p_template_id <> FND_API.g_miss_num
then
   IF jtf_dspmgrvalidation_grp.check_deliverable_type_exists(p_template_id ,l_type,l_applicable_to) = false then
      raise FND_API.g_exc_error;
  END IF;/* deliverable exists check */
else
   raise jtf_dspmgrvalidation_grp.template_req_exception;
end if; /*deliverable id is not null check */


FOR l_index  IN 1..p_category_id_tbl.COUNT
LOOP
     ---dbms_output.put_line('passed add_tpl_ctg_rec' || p_category_id_tbl(l_index) ||'---' || p_template_id );
	add_tpl_ctg_rec(p_api_version,FND_API.g_false,FND_API.g_false,
		        l_return_status , p_template_id,
		        p_category_id_tbl(l_index));

	if l_return_status <> FND_API.g_ret_sts_success then
	   ---dbms_output.put_line('add_TPL_CTG_REC  returned error status **********************' ) ;
	     x_return_status := l_return_status;
	end if;
END LOOP;

--- Check if the caller requested to commit ,
--- If p_commit set to true, commit the transaction
IF  FND_API.to_boolean(p_commit) THEN
  COMMIT;
END IF;

      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

EXCEPTION

   WHEN FND_API.g_exc_error THEN
      ROLLBACK TO add_tpl_ctg;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );


 WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO add_tpl_ctg;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

WHEN jtf_dspmgrvalidation_grp.template_req_exception THEN
  IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
  THEN
   x_return_status := FND_API.g_ret_sts_error;
   FND_MESSAGE.set_name('JTF','JTF_DSP_TEMPLATE_REQ');
   FND_MSG_PUB.add;
  END IF;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

 WHEN OTHERS THEN
      ROLLBACK TO add_tpl_ctg;
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

END add_tpl_ctg;


-----------------------------------------------------------------------
-- NOTES
--    1. Raise exception if the p_api_version doesn't match.
--    2. Deletes the association of the template to the category
--	 3. Deletes the category to template association in JTF_OBJ_LGL_CTNT
--       for all display contexts
--------------------------------------------------------------------
PROCEDURE delete_tpl_ctg_relation(
   p_api_version         IN  NUMBER,
   p_init_msg_list	   IN VARCHAR2 := FND_API.g_false,
   p_commit              IN  VARCHAR2 := FND_API.g_false,
   x_return_status              OUT VARCHAR2,
   x_msg_count          OUT  NUMBER,
   x_msg_data           OUT  VARCHAR2,
   p_tpl_ctg_id_tbl     IN  tpl_ctg_id_TBL_TYPE
)
IS
   l_api_name    CONSTANT VARCHAR2(30) := 'delete_tpl_ctg_relation';
   l_full_name   CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
   l_category_id  number ;
   l_deliverable_id number;
   l_index   	     NUMBER;

   CURSOR category_cur(p_tpl_ctg_id IN NUMBER)  IS
	       SELECT category_id ,ITEM_ID from jtf_dsp_tpl_ctg where
		 tpl_ctg_id = p_tpl_ctg_id;

BEGIN

   --------------------- initialize -----------------------
   SAVEPOINT delete_tpl_ctg_relation;
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

FOR l_index  IN 1..p_tpl_ctg_id_tbl.COUNT
LOOP
BEGIN
   SAVEPOINT delete_ctg_relation;
--- Check if the context_id exists
IF p_tpl_ctg_id_tbl(l_index) <> FND_API.g_miss_num and
   p_tpl_ctg_id_tbl(l_index) is not null
THEN

--- Delete all the entries matching category id and deliverable id
  OPEN category_cur(p_tpl_ctg_id_tbl(l_index) );
  FETCH category_cur into l_category_id,l_deliverable_id;
  CLOSE category_cur;


  DELETE FROM JTF_DSP_TPL_CTG WHERE
  			TPL_CTG_ID  = p_tpl_ctg_id_tbl(l_index);


  JTF_LogicalContent_grp.delete_category_dlv( l_category_id,
								      l_deliverable_id);


END IF;

EXCEPTION
   WHEN OTHERS THEN
      ROLLBACK TO delete_ctg_relation;
      x_return_status := FND_API.g_ret_sts_error;
END;
END LOOP;

--- Check if the caller requested to commit ,
--- If p_commit set to true, commit the transaction
        IF  FND_API.to_boolean(p_commit) THEN
             COMMIT;
        END IF;

      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

EXCEPTION

   WHEN FND_API.g_exc_error THEN
      ROLLBACK TO delete_tpl_ctg_relation;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO delete_tpl_ctg_relation;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );


   WHEN OTHERS THEN
      ROLLBACK TO delete_tpl_ctg_relation;
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


END delete_tpl_ctg_relation;

-----------------------------------------------------------------------
-- NOTES
--    1. Raises an exception if the api_version is not valid
--    2. Raises an exception if the category_id is missing or invalid
--	3. Raises an exception if any invalid template_id is passed in
--	    p_template_id_tbl
--    4. Creates a category to templates relationship (JTF_DSP_TPL_CTG)
---------------------------------------------------------------------
PROCEDURE add_ctg_tpl(
   p_api_version           IN  NUMBER,
   p_init_msg_list	   IN VARCHAR2 := FND_API.g_false,
   p_commit                IN  VARCHAR2  := FND_API.g_false,
   x_return_status              OUT VARCHAR2,
   x_msg_count          OUT  NUMBER,
   x_msg_data           OUT  VARCHAR2,
   p_category_id                   IN NUMBER,
   p_template_id_tbl       IN  template_ID_TBL_TYPE
)
IS

   l_api_name    CONSTANT VARCHAR2(30) := 'add_ctg_tpl';
   l_full_name   CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
   l_return_status  VARCHAR2(1);
   l_category_id  number ;
   l_deliverable_id number;
l_dsp_tpl_seq_id   number;
   l_index   	     NUMBER;
   l_row_exists      NUMBER;
BEGIN

   --------------------- initialize -----------------------
   SAVEPOINT add_ctg_tpl;

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


 x_return_status := FND_API.g_ret_sts_success;

IF p_category_id <> FND_API.g_miss_num or
   p_category_id is not null
THEN
if jtf_dspmgrvalidation_grp.check_category_exists(p_category_id) = false then
   ---dbms_output.put_line('passed category check in add_tpl_ctg_rec' || p_category_id );
   raise FND_API.g_exc_error;
end if; /* category exists check */
else
   raise jtf_dspmgrvalidation_grp.category_req_exception;
end if; /* category id is not null check */

--- Add all the entries
FOR l_index  IN 1..p_template_id_tbl.COUNT
LOOP

	add_tpl_ctg_rec(p_api_version,FND_API.g_false,FND_API.g_false,
		        l_return_status , p_template_id_tbl(l_index),
		        p_category_id);

	if l_return_status <> FND_API.g_ret_sts_success THEN
	   ---dbms_output.put_line('add_TPL_CTG_REC  returned error status **********************' ) ;
	     x_return_status := l_return_status;
	end if;
END LOOP;

--- Check if the caller requested to commit ,
--- If p_commit set to true, commit the transaction
        IF  FND_API.to_boolean(p_commit) THEN
             COMMIT;
        END IF;

      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

EXCEPTION

   WHEN FND_API.g_exc_error THEN
      ROLLBACK TO add_ctg_tpl;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO add_ctg_tpl;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

WHEN jtf_dspmgrvalidation_grp.category_req_exception THEN
      ROLLBACK TO add_ctg_tpl;
  IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
  THEN
   x_return_status := FND_API.g_ret_sts_error;
   FND_MESSAGE.set_name('JTF','JTF_DSP_CATEGORY_REQ');
   FND_MSG_PUB.add;
  END IF;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN OTHERS THEN
      ROLLBACK TO add_ctg_tpl;
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


END ADD_CTG_TPL;


-----------------------------------------------------------------------
-- NOTES
--    1. Deletes all the category-template_id association for the
--	   template_id passed
--  Note : This method should not be called from the application
---------------------------------------------------------------------
PROCEDURE delete_deliverable(
   p_template_id      IN  NUMBER
)
IS
BEGIN
   --------------------- initialize -----------------------
   SAVEPOINT delete_deliverable;

--- Delete the deliverable from the table
  delete from jtf_dsp_tpl_ctg where
  item_id = p_template_id;


EXCEPTION

   WHEN OTHERS THEN
      ROLLBACK TO delete_deliverable;

END delete_deliverable;


-----------------------------------------------------------------------
-- NOTES
--    1. Deletes all the category-template_id association for the
--	   category id passed
--  Note : This method should not be called from the application
---------------------------------------------------------------------
PROCEDURE delete_category(
   p_category_id      IN  NUMBER
)
IS
BEGIN
   --------------------- initialize -----------------------
   SAVEPOINT delete_category;

--- Delete the deliverable from the table
  delete from jtf_dsp_tpl_ctg where
  category_id = p_category_id;

EXCEPTION

   WHEN OTHERS THEN
      ROLLBACK TO delete_category;

END delete_category;


END JTF_TplCategory_GRP;

/
