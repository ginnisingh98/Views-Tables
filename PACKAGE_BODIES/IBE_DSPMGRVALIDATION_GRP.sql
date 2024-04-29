--------------------------------------------------------
--  DDL for Package Body IBE_DSPMGRVALIDATION_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBE_DSPMGRVALIDATION_GRP" AS
/* $Header: IBEGDVDB.pls 120.0 2005/05/30 03:13:59 appldev noship $ */

-----------------------------------------------------------------
-- NOTES
--    1. Returns true if  the attachment id exists
--    2. Object version number is used if it is not FND_API.G_MISS_NUM
--    3. Return false, if the attachment id  does not exist,
--       IBE_DSP_ATH_NOT_EXISTS is pushed on the stack
---------------------------------------------------------------------
FUNCTION check_attachment_exists(
	p_attachment_id IN NUMBER,
	p_object_version_number IN NUMBER := FND_API.G_MISS_NUM)
RETURN BOOLEAN
IS

l_api_name CONSTANT VARCHAR2(40) := 'check_attachment_exists';

CURSOR attachment_cur( p_attachment_id IN NUMBER ) IS
    -- SELECT attachment_used_by_id
     SELECT 1
     FROM JTF_AMV_ATTACHMENTS
     WHERE attachment_id = p_attachment_id;

CURSOR attachment_version_cur( p_attachment_id IN NUMBER ,
	p_object_version_number IN NUMBER) IS
    --  SELECT attachment_used_by_id
    SELECT 1
    FROM JTF_AMV_ATTACHMENTS
     WHERE attachment_id = p_attachment_id
	AND object_version_number=p_object_version_number;

l_exists NUMBER;
l_return_status BOOLEAN := FALSE;
l_ath_not_exists_exception EXCEPTION;

BEGIN

	IF (p_attachment_id IS NULL) OR (p_object_version_number IS NULL) THEN
		RAISE l_ath_not_exists_exception;

	ELSIF p_object_version_number = FND_API.G_MISS_NUM THEN
   		OPEN attachment_cur(p_attachment_id );
   		FETCH attachment_cur INTO l_exists;
   		IF attachment_cur%NOTFOUND THEN
			CLOSE attachment_cur;
			RAISE l_ath_not_exists_exception;
		END IF;
		CLOSE attachment_cur;
		l_return_status := true;

	ELSE
		OPEN attachment_version_cur(p_attachment_id ,p_object_version_number);
		FETCH attachment_version_cur INTO l_exists;
		IF attachment_version_cur%NOTFOUND THEN
			CLOSE attachment_version_cur;
			RAISE l_ath_not_exists_exception;
		END IF;
		CLOSE attachment_version_cur;
		l_return_status := true;

	END IF;

	RETURN l_return_status;

EXCEPTION

	WHEN l_ath_not_exists_exception THEN
		IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
			FND_MESSAGE.set_name('IBE','IBE_DSP_ATH_NOT_EXISTS');
			FND_MESSAGE.set_token('ID', TO_CHAR(p_attachment_id));
			FND_MSG_PUB.ADD;
		END IF;
		RETURN l_return_status;

	WHEN OTHERS THEN
		IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
			FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
		END IF;
		RETURN l_return_status;

END check_attachment_exists;
----------------------------------------------------------------------------------------
-----------------------------------------------------------------
-- NOTES
--    1. Returns deliverable id for a attachment
--    2. If deliverable id or attachment id not exists , return null
--    3. Message IBE_DSP_ATH_NOT_EXISTS is pushed on the stack
---------------------------------------------------------------------

FUNCTION check_attachment_deliverable(p_attachment_id IN NUMBER)
RETURN NUMBER
IS
l_api_name CONSTANT VARCHAR2(40) := 'check_attachment_deliverable';

CURSOR attachment_cur( p_attachment_id IN NUMBER ) IS
	SELECT attachment_used_by_id FROM JTF_AMV_ATTACHMENTS
	WHERE attachment_id = p_attachment_id;

l_deliverable_id NUMBER;
l_ath_not_exists_exception EXCEPTION;

BEGIN

	IF p_attachment_id IS NULL THEN
		RAISE l_ath_not_exists_exception;

	ELSE
		OPEN attachment_cur(p_attachment_id );
		FETCH attachment_cur INTO l_deliverable_id;
		IF attachment_cur%NOTFOUND THEN
			CLOSE attachment_cur;
			RAISE l_ath_not_exists_exception;
		END IF;
		CLOSE attachment_cur;

	END IF;

	RETURN l_deliverable_id;

EXCEPTION

	WHEN l_ath_not_exists_exception THEN
		IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
			FND_MESSAGE.set_name('IBE','IBE_DSP_ATH_NOT_EXISTS');
			FND_MESSAGE.set_token('ID', TO_CHAR(p_attachment_id));
			FND_MSG_PUB.ADD;
		END IF;
		RETURN NULL;

	WHEN OTHERS THEN
		IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
			FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
		END IF;
		RETURN NULL;

END check_attachment_deliverable;

----------------------------------------------------------------------------------------

-----------------------------------------------------------------
-- NOTES
--    1. Returns the context type code for a given context id
--    2. If the context_id is passed does not exist, null is returned
--       , and IBE_DSP_CONTEXT_NOT_EXISTS is pushed on the
--       message stack
---------------------------------------------------------------------
FUNCTION check_context_type_code(p_context_id IN NUMBER)
RETURN VARCHAR2
IS
 l_api_name    CONSTANT VARCHAR2(40) := 'check_context_type_code';

CURSOR context_type_cur (p_context_id IN NUMBER) IS
        SELECT context_type_code FROM IBE_DSP_CONTEXT_B WHERE
        context_id = p_context_id ;

l_type_code VARCHAR2(40) := null;

BEGIN

   OPEN context_type_cur(p_context_id );
   FETCH context_type_cur INTO l_type_code;

   IF  context_type_cur%NOTFOUND
  THEN
   FND_MESSAGE.set_name('IBE','IBE_DSP_CONTEXT_NOT_EXISTS');
   FND_MESSAGE.set_token('ID', p_context_id);
   FND_MSG_PUB.ADD;
  END IF;
 CLOSE context_type_cur;

 return l_type_code;

EXCEPTION
WHEN OTHERS THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error)
      THEN
         FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
      END IF;
      return l_type_code;
END check_context_type_code;

----------------------------------------------------------------------------------------

-----------------------------------------------------------------
-- NOTES
--    1. Returns true if the context id with the context type exists
--    2. Object version number is used if it is not FND_API.G_MISS_NUM
--    3. If the context_id is passed does not exist, an exception is
--       raised , and IBE_DSP_CONTEXT_NOT_EXISTS is pushed on the
--       message stack
---------------------------------------------------------------------
FUNCTION check_context_exists(p_context_id IN NUMBER,
					p_context_type IN VARCHAR2,
				      p_object_version_number IN NUMBER := FND_API.G_MISS_NUM)
RETURN boolean
IS
 l_api_name    CONSTANT VARCHAR2(40) := 'check_context_exists';

CURSOR context_cur( p_context_id IN NUMBER ,p_context_type IN VARCHAR2 ) IS
        -- SELECT context_id
        SELECT 1
        FROM IBE_DSP_CONTEXT_B WHERE
        context_id = p_context_id and context_type_code = p_context_type;

CURSOR context_version_cur( p_context_id IN NUMBER,p_context_type IN VARCHAR2 ,
					   p_object_version_number IN NUMBER) IS
        -- SELECT context_id
        SELECT 1
        FROM IBE_DSP_CONTEXT_B WHERE
        context_id = p_context_id  and context_type_code = p_context_type
	   and object_version_number = p_object_version_number;

l_exists NUMBER;
l_return_status boolean := false;
l_context_type VARCHAR2(30);
BEGIN

l_context_type := trim(p_context_type);

if p_object_version_number = FND_API.G_MISS_NUM  then
   OPEN context_cur(p_context_id ,l_context_type);
   FETCH context_cur INTO l_exists;
   IF  context_cur%NOTFOUND
   THEN
   	FND_MESSAGE.set_name('IBE','IBE_DSP_CONTEXT_NOT_EXISTS');
   	FND_MESSAGE.set_token('ID', p_context_id);
   	FND_MSG_PUB.ADD;
    ELSE
	l_return_status := true;
    END IF;
 CLOSE context_cur;
else
   OPEN context_version_cur(p_context_id ,l_context_type, p_object_version_number);
   FETCH context_version_cur INTO l_exists;
   IF  context_version_cur%NOTFOUND
   THEN
   	FND_MESSAGE.set_name('IBE','IBE_DSP_CONTEXT_NOT_EXISTS');
   	FND_MESSAGE.set_token('ID', p_context_id);
   	FND_MSG_PUB.ADD;
   ELSE
        l_return_status := true;
   END IF;
 CLOSE context_version_cur;
end if;
return l_return_status;

EXCEPTION
WHEN OTHERS THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error)
      THEN
         FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
      END IF;
      return l_return_status;
END check_context_exists;
----------------------------------------------------------------------------------------

-----------------------------------------------------------------
-- NOTES
--    1. Returns true if the context type is valid (TEMPLATE/MEDIA)
--    2. FND_LOOKUP used for context type is JTF_AMV_DELV_TYPE_CODE
--    3. If the context type passed is not valid, an exception is
--       raised , and IBE_DSP_CONTEXT_TYPE_INVALID is pushed on the
--       message stack
---------------------------------------------------------------------
FUNCTION check_valid_context_type(p_context_type in VARCHAR2)
RETURN boolean
IS
CURSOR valid_context_cur (p_context_type IN VARCHAR2) IS
	select count(*) from FND_LOOKUP_VALUES_VL WHERE
	lookup_type = 'JTF_AMV_DELV_TYPE_CODE' and
	lookup_code = p_context_type and
	enabled_flag = 'Y';

l_return_status boolean := false;
l_exists  NUMBER := 0;
l_api_name    CONSTANT VARCHAR2(40) := 'check_valid_context_type';
l_context_type VARCHAR2(30);
BEGIN
   l_context_type := trim(p_context_type);
   OPEN valid_context_cur(l_context_type);
   FETCH valid_context_cur into l_exists;

   IF valid_context_cur%NOTFOUND then
     FND_MESSAGE.set_name('IBE','IBE_DSP_CONTEXT_TYPE_INVLD');
     FND_MESSAGE.set_token('TYPE', l_context_type);
     FND_MESSAGE.set_token('ID', to_char(null));
     FND_MSG_PUB.ADD;
     l_return_status := false;
   ELSE
      l_return_status := true;
   end if;

  CLOSE valid_context_cur;
  return l_return_status;

EXCEPTION
WHEN OTHERS THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error)
      THEN
         FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
      END IF;
      return l_return_status;
END check_valid_context_type;

----------------------------------------------------------------------------------------

-----------------------------------------------------------------
-- NOTES
--    1. Returns true if the object type is valid (S/I/C)
--    2. FND_LOOKUP used for object type is
--    3. If the object type passed is not valid, an exception is
--       raised , and IBE_DSP_OBJECT_TYPE_INVALID is pushed on the
--       message stack
---------------------------------------------------------------------
FUNCTION check_valid_object_type(p_object_type_code in VARCHAR2)
RETURN boolean
IS

CURSOR valid_object_cur (p_object_type IN VARCHAR2) IS
	-- select lookup_code
        select 1
        from FND_LOOKUP_VALUES_VL WHERE
	lookup_type = 'IBE_RELATIONSHIP_RULE_OBJ_TYPE' and
	lookup_code = p_object_type and
	lookup_code <> 'N' and
	enabled_flag = 'Y';

l_return_status boolean := false;
l_exists  NUMBER := 0;
l_api_name    CONSTANT VARCHAR2(40) := 'check_valid_object_type';
l_object_type_code VARCHAR2(30);
BEGIN
l_object_type_code := trim(p_object_type_code);

/*
 if l_object_type_code = 'SECTION' or
    l_object_type_code = 'ITEM' or
    l_object_type_code = 'CATEGORY'
    then
	  return true;
	else
	  return false;
	end if;
*/

   OPEN valid_object_cur(l_object_type_code);
   FETCH valid_object_cur into l_exists;
   IF valid_object_cur%NOTFOUND then
     FND_MESSAGE.set_name('IBE','IBE_DSP_LGLCTNT_OBJTYPE_INVLD');
     FND_MESSAGE.set_token('TYPE', l_object_type_code);
     FND_MSG_PUB.ADD;
     l_return_status := false;
   ELSE
      l_return_status := true;
   end if;
   close valid_object_cur;
   return l_return_status;

EXCEPTION
WHEN OTHERS THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error)
      THEN
         FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
      END IF;
      return l_return_status;
END check_valid_object_type;
----------------------------------------------------------------------------------------

-----------------------------------------------------------------
-- NOTES
--    1. Returns false if the context accessname is not being used
--    2. If the context_id is passed, then the access name being
--       used is checked against access names other than the context
--       id passed
--    3. If the context access name is being used, then it returns false
--       and IBE_DSP_CONTEXT_ACCNAME_EXISTS  is pushed on the
--       message stack
---------------------------------------------------------------------
FUNCTION check_context_accessname(p_context_accessname IN VARCHAR2,
			          p_context_type 	 IN VARCHAR2,
				  p_context_id         IN NUMBER := FND_API.G_MISS_NUM)
RETURN boolean
IS
 l_api_name    CONSTANT VARCHAR2(40) := 'check_context_accessname';
 l_context_accessname VARCHAR2(40);
 l_context_type	    VARCHAR2(30);
CURSOR context_accessname_cur( p_context_accessname IN VARCHAR2 ,
						 p_context_type       IN VARCHAR2)
IS
        -- SELECT access_name
        SELECT 1
        FROM IBE_DSP_CONTEXT_B WHERE
        access_name = p_context_accessname ;

CURSOR context_accessname_id_cur( p_context_accessname IN VARCHAR2 ,
					 p_context_type       IN VARCHAR2,
					 p_context_id	    IN VARCHAR2)
IS
        -- SELECT access_name
        SELECT 1
        FROM IBE_DSP_CONTEXT_B WHERE
        access_name = p_context_accessname and
        context_id  <> p_context_id ;
l_exists NUMBER;
l_return_status boolean := true;

BEGIN

l_context_accessname := trim(p_context_accessname);
l_context_type       := trim(p_context_type);

if p_context_id = FND_API.G_MISS_NUM or  p_context_id is null  then
   OPEN context_accessname_cur(l_context_accessname ,l_context_type);
   FETCH context_accessname_cur INTO l_exists;
     IF  context_accessname_cur%FOUND
     THEN
      	l_return_status := FALSE;
     END IF;
 CLOSE context_accessname_cur;
else
   OPEN context_accessname_id_cur(l_context_accessname ,l_context_type,p_context_id);
   FETCH context_accessname_id_cur INTO l_exists;
      IF  context_accessname_id_cur%FOUND
      THEN
   		l_return_status := false;
      END IF;
 CLOSE context_accessname_id_cur;
end if;

if not l_return_status then
	FND_MESSAGE.set_name('IBE','IBE_DSP_CONTEXT_ACCNAME_EXISTS');
	FND_MESSAGE.set_token('ACC_NAME', l_context_accessname);
	FND_MSG_PUB.ADD;
 end if;

return l_return_status;

EXCEPTION
WHEN OTHERS THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error)
      THEN
         FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
      END IF;
      return l_return_status;
END check_context_accessname;
----------------------------------------------------------------------------------------

-----------------------------------------------------------------
-- NOTES
--    1. Returns false if there is no association for a
--       deliverable id/ category id in IBE_DSP_TPL_CTG
--    2. No message is pushed on the stack
---------------------------------------------------------------------
FUNCTION check_ctg_tpl_relation_exists(p_category_id IN NUMBER,
						   p_template_id IN NUMBER)
RETURN boolean
IS
 l_api_name    CONSTANT VARCHAR2(40) := 'check_ctg_tpl_relation_exists';

CURSOR ctg_tpl_relation_cur( p_category_id IN NUMBER,p_template_id IN NUMBER ) IS
   -- select tpl_ctg_id
  select 1
  from ibe_dsp_tpl_ctg
  where category_id = p_category_id and item_id = p_template_id;

l_exists NUMBER;
l_return_status boolean := false;

BEGIN
   OPEN ctg_tpl_relation_cur(p_category_id,p_template_id );
   FETCH ctg_tpl_relation_cur INTO l_exists;
   IF  ctg_tpl_relation_cur%FOUND
  THEN
	l_return_status := true;
  END IF;
 CLOSE ctg_tpl_relation_cur;

return l_return_status;

EXCEPTION
WHEN OTHERS THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error)
      THEN
         FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
      END IF;
      return l_return_status;
END check_ctg_tpl_relation_exists;

----------------------------------------------------------------------------------------

-----------------------------------------------------------------
-- NOTES
--    1. Returns true if  the category id does exist
--    2. Return false, if the category id does not exist,
--       IBE_DSP_CATEGORY_NOT_EXISTS is pushed on the stack
---------------------------------------------------------------------
FUNCTION check_category_exists(p_category_id IN NUMBER)
RETURN boolean
IS
 l_api_name    CONSTANT VARCHAR2(40) := 'check_category_exists';

CURSOR category_cur( p_category_id IN NUMBER ) IS
 		-- select category_id
                select 1
                from mtl_categories
                where category_id=p_category_id;

l_exists NUMBER;
l_return_status boolean := false;

BEGIN

   OPEN category_cur(p_category_id );
   FETCH category_cur INTO l_exists;
   IF  category_cur%NOTFOUND
   THEN
 	  FND_MESSAGE.set_name('IBE','IBE_DSP_CATEGORY_NOT_EXISTS');
  	  FND_MESSAGE.set_token('ID',p_category_id);
   	  FND_MSG_PUB.ADD;
  ELSE
	 l_return_status := true;
  END IF;
 CLOSE category_cur;

return l_return_status;

EXCEPTION
WHEN OTHERS THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error)
      THEN
         FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
      END IF;
      return l_return_status;
END check_category_exists;

----------------------------------------------------------------------------------------

-----------------------------------------------------------------
-- NOTES
--    1. Returns true if  the item id does exist
--    2. Return false, if the item id does not exist,
--       IBE_DSP_ITEM_NOT_EXISTS is pushed on the stack
---------------------------------------------------------------------
FUNCTION check_item_exists(p_item_id IN NUMBER)
RETURN boolean
IS
 l_api_name    CONSTANT VARCHAR2(40) := 'check_item_exists';

CURSOR item_cur( p_item_id IN NUMBER ) IS
	-- select distinct inventory_item_id
        select 1
        from mtl_system_items
		where inventory_item_id = p_item_id;

l_exists NUMBER;
l_return_status boolean := false;

BEGIN

   OPEN item_cur(p_item_id );
   FETCH item_cur INTO l_exists;
   IF  item_cur%NOTFOUND
  THEN
   FND_MESSAGE.set_name('IBE','IBE_DSP_ITEM_NOT_EXISTS');
  FND_MESSAGE.set_token('ID',p_item_id);
   FND_MSG_PUB.ADD;
  ELSE
	l_return_status := true;
  END IF;
 CLOSE item_cur;

return l_return_status;

EXCEPTION
WHEN OTHERS THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error)
      THEN
         FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
      END IF;
      return l_return_status;
END check_item_exists;

----------------------------------------------------------------------------------------

-----------------------------------------------------------------
-- NOTES
--    1. Returns true if  the section id does exist
--    2. Return false, if the section id does not exist,
--       IBE_DSP_SECTION_NOT_EXISTS is pushed on the stack
---------------------------------------------------------------------
FUNCTION check_section_exists(p_section_id IN NUMBER)
RETURN boolean
IS
 l_api_name    CONSTANT VARCHAR2(40) := 'check_section_exists';

CURSOR section_cur( p_section_id IN NUMBER ) IS
		-- select section_id
                select 1
                from ibe_dsp_sections_b where
		section_id = p_section_id;
l_exists NUMBER;
l_return_status boolean := false;

BEGIN

   OPEN section_cur(p_section_id );
   FETCH section_cur INTO l_exists;
   IF  section_cur%NOTFOUND
  THEN
   FND_MESSAGE.set_name('IBE','IBE_DSP_SECTION_NOT_EXISTS');
  FND_MESSAGE.set_token('ID',p_section_id);

   FND_MSG_PUB.ADD;
  ELSE
	l_return_status := true;
  END IF;
 CLOSE section_cur;

return l_return_status;

EXCEPTION
WHEN OTHERS THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error)
      THEN
         FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
      END IF;
---dbms_output.put_line('returning false status error');
      return l_return_status;
END check_section_exists;

-----------------------------------------------------------------
-- NOTES
--    1. Returns true if  the section id does exist
--    2. Return false, if the section id does not exist,
--       IBE_MSITE_RSECID_INVLD is pushed on the stack
---------------------------------------------------------------------
FUNCTION check_root_section_exists(p_root_section_id IN NUMBER)
RETURN boolean
IS
 l_api_name    CONSTANT VARCHAR2(40) := 'check_root_section_exists';

CURSOR section_cur( p_section_id IN NUMBER ) IS
 		-- select section_id
                select 1
                from ibe_dsp_sections_b where
		section_id = p_section_id ;
l_exists NUMBER;
l_return_status boolean := false;
BEGIN
   OPEN section_cur(p_root_section_id );
   FETCH section_cur INTO l_exists;
   IF  section_cur%NOTFOUND
   THEN
     FND_MESSAGE.set_name('IBE','IBE_MSITE_RSECID_INVLD');
     FND_MESSAGE.set_token('ID',p_root_section_id);
     FND_MSG_PUB.ADD;
  ELSE
	l_return_status := true;
  END IF;
 CLOSE section_cur;

return l_return_status;

EXCEPTION
WHEN OTHERS THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error)
      THEN
         FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
      END IF;
---dbms_output.put_line('returning false status error');
      return l_return_status;
END check_root_section_exists;


----------------------------------------------------------------------------------------

-----------------------------------------------------------------
-- NOTES
--    1. Returns true if  the object id with the right type does exist
---------------------------------------------------------------------
FUNCTION check_lgl_object_exists(p_object_type IN VARCHAR2,
                                 p_object_id IN NUMBER )
RETURN boolean
IS
 l_api_name    CONSTANT VARCHAR2(40) := 'check_lgl_object_exists';

l_exists NUMBER;
l_return_status boolean := false;
l_object_type VARCHAR2(30);
BEGIN

l_object_type := trim(p_object_type);
l_return_status := ibe_dspmgrvalidation_grp.check_valid_object_type(l_object_type);

if l_return_status = false then
   return l_return_status;
end if;

l_return_status := false;

if l_object_type = 'I'
then
   l_return_status :=  ibe_dspmgrvalidation_grp.check_item_exists(p_object_id);
elsif l_object_type = 'C'
then
   l_return_status := ibe_dspmgrvalidation_grp.check_category_exists(p_object_id);
elsif l_object_type = 'S'
then
   l_return_status := ibe_dspmgrvalidation_grp.check_section_exists(p_object_id);
end if;

return l_return_status;

EXCEPTION
WHEN OTHERS THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error)
      THEN
         FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
      END IF;
      return l_return_status;
END check_lgl_object_exists;


----------------------------------------------------------------------------------------
-----------------------------------------------------------------
-- NOTES
--    1. Returns true if  the deliverable with type matches
--       valid types are TEMPLATE/MEDIA
---   2. applicable to ,is used if passed
--    3. If not found ,returns false and message IBE_DSP_DLV_TYPE_NOT_EXISTS
--       is pushed onto the stack
--    4. Modified for bug 2454428 to include 'GENERIC'
--    5. Modified by YAXU on 12/19/2002, do not check the applicable_to for 'MEDIA'
---------------------------------------------------------------------
FUNCTION check_deliverable_type_exists(
	p_deliverable_id IN NUMBER,
	p_item_type IN VARCHAR2,
	p_applicable_to IN VARCHAR2 := FND_API.g_miss_char)
RETURN BOOLEAN
IS
l_api_name    CONSTANT VARCHAR2(40) := 'check_deliverable_type_exists';
l_exists NUMBER;
l_item_type VARCHAR2(40);
CURSOR deliverable_type_cur( p_deliverable_id IN NUMBER,
	p_item_type IN VARCHAR2 ) IS
  		-- SELECT item_id
                SELECT 1
                FROM JTF_AMV_ITEMS_B
			WHERE item_id = p_deliverable_id and
		      deliverable_type_code = p_item_type ;

CURSOR deliverable_type_app_cur( p_deliverable_id IN NUMBER,
	p_item_type IN VARCHAR2, p_applicable_to IN VARCHAR2 ) IS
 		-- SELECT item_id
                    SELECT 1
                    FROM JTF_AMV_ITEMS_B
			WHERE item_id = p_deliverable_id and
		      deliverable_type_code = p_item_type and
			 (applicable_to_code    = p_applicable_to OR
			  applicable_to_code    = 'GENERIC');

l_return_status BOOLEAN := false;

BEGIN

 l_item_type := trim(p_item_type);

  --Modified by YAXU on 12/19/2002, do not check the applicable_to for 'MEDIA'
   if p_applicable_to is null or p_applicable_to = FND_API.g_miss_char or p_item_type = 'MEDIA'
   then
	OPEN deliverable_type_cur(p_deliverable_id,l_item_type);
	FETCH deliverable_type_cur INTO l_exists;
	IF  deliverable_type_cur%FOUND THEN
		l_return_status := true;
      end if;
	CLOSE deliverable_type_cur;
   else
	OPEN deliverable_type_app_cur(p_deliverable_id,l_item_type,p_applicable_to);
	FETCH deliverable_type_app_cur INTO l_exists;
	IF  deliverable_type_app_cur%FOUND THEN
		l_return_status := true;
      end if;

	CLOSE deliverable_type_app_cur;
   end if;

   if l_return_status = false then
		FND_MESSAGE.set_name('IBE','IBE_DSP_DLV_TYPE_NOT_EXISTS');
		FND_MESSAGE.set_token('ID', p_deliverable_id);
 		FND_MESSAGE.set_token('TYPE', p_item_type);
		FND_MSG_PUB.add;
   end if;

	return l_return_status;

EXCEPTION

	WHEN OTHERS THEN
     	IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
         		FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
      	END IF;
      	return l_return_status;

END check_deliverable_type_exists;

----------------------------------------------------------------------------------------
-----------------------------------------------------------------
-- NOTES
--    1. Returns true if  the deliverable  id  exists
--    2. If object version number is passed, then the deliverable id
--	   with object version number is checked for existence
--    3. If deliverable id  in both cases if not found
--       message IBE_DSP_DLV_NOT_EXISTS is pushed on the stack
---------------------------------------------------------------------

FUNCTION check_deliverable_exists(
	p_deliverable_id IN NUMBER,
     p_object_version_number IN NUMBER := FND_API.G_MISS_NUM)
RETURN boolean
IS
l_api_name CONSTANT VARCHAR2(40) := 'check_deliverable_exists';

CURSOR deliverable_cur( p_deliverable_id IN NUMBER ) IS
     -- SELECT item_id
     SELECT 1
     FROM JTF_AMV_ITEMS_B
     WHERE item_id = p_deliverable_id;

CURSOR deliverable_version_cur( p_deliverable_id IN NUMBER,
	p_object_version_number IN NUMBER ) IS
     -- SELECT item_id
     SELECT 1
     FROM JTF_AMV_ITEMS_B
     WHERE item_id = p_deliverable_id and
	object_version_number = p_object_version_number;

l_exists NUMBER;
l_return_status boolean := false;
l_dlv_not_exists_exception EXCEPTION;

BEGIN

	IF  (p_deliverable_id IS NULL) OR (p_object_version_number IS NULL) THEN
		RAISE l_dlv_not_exists_exception;

	ELSIF p_object_version_number = FND_API.G_MISS_NUM  then
   		OPEN deliverable_cur(p_deliverable_id );
   		FETCH deliverable_cur INTO l_exists;
   		IF  deliverable_cur%NOTFOUND THEN
			CLOSE deliverable_cur;
			RAISE l_dlv_not_exists_exception;
		END IF;
 		CLOSE deliverable_cur;
        	l_return_status := true;

	ELSE
   		OPEN deliverable_version_cur(p_deliverable_id,
			p_object_version_number);
   		FETCH deliverable_version_cur INTO l_exists;
   		IF  deliverable_version_cur%NOTFOUND THEN
			CLOSE deliverable_version_cur;
			RAISE l_dlv_not_exists_exception;
		END IF;
		CLOSE deliverable_version_cur;
   		l_return_status := true;

	END IF;

	return l_return_status;

EXCEPTION

	WHEN l_dlv_not_exists_exception THEN
		IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
			FND_MESSAGE.set_name('IBE','IBE_DSP_DLV_NOT_EXISTS');
			FND_MESSAGE.set_token('ID', TO_CHAR(p_deliverable_id));
			FND_MSG_PUB.add;
		END IF;
		RETURN l_return_status;

	WHEN OTHERS THEN
		IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
         		FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
      	END IF;
      	return l_return_status;

END check_deliverable_exists;

----------------------------------------------------------------------------------------
-----------------------------------------------------------------
-- NOTES
--    1. Returns true if  the logical content  id  exists
--    2. If object version number is passed, then the logical content id
--	   with object version number is checked for existence
--    3. If logical content id in both cases is not found
--       message IBE_DSP_LGL_CTNT_ID_NOT_EXISTS is pushed on the stack
---------------------------------------------------------------------

FUNCTION check_lgl_ctnt_id_exists(p_lgl_ctnt_id IN NUMBER,
                                 p_object_version_number IN NUMBER := FND_API.G_MISS_NUM)
RETURN boolean
IS
 l_api_name    CONSTANT VARCHAR2(40) := 'check_lgl_ctnt_id_exists';

CURSOR lgl_ctnt_cur( p_lgl_ctnt_id IN NUMBER ) IS
  	 	-- SELECT obj_lgl_ctnt_id
                SELECT 1
                FROM IBE_DSP_OBJ_LGL_CTNT
	        WHERE obj_lgl_ctnt_id = p_lgl_ctnt_id;

CURSOR lgl_ctnt_version_cur( p_lgl_ctnt_id IN NUMBER,
				 p_object_version_number IN NUMBER ) IS
  	-- select obj_lgl_ctnt_id
        select 1
        FROM IBE_DSP_OBJ_LGL_CTNT
        WHERE obj_lgl_ctnt_id = p_lgl_ctnt_id and
	      object_version_number = p_object_version_number;

l_exists NUMBER;
l_return_status boolean := false;

BEGIN
if p_object_version_number = FND_API.G_MISS_NUM  then
   OPEN lgl_ctnt_cur(p_lgl_ctnt_id );
   FETCH lgl_ctnt_cur INTO l_exists;
   IF  lgl_ctnt_cur%NOTFOUND
  THEN
   FND_MESSAGE.set_name('IBE','IBE_DSP_LGLCTNT_ID_NOT_EXISTS');
  FND_MESSAGE.set_token('ID',p_lgl_ctnt_id);
   FND_MSG_PUB.ADD;
  ELSE
        l_return_status := true;
  END IF;
 CLOSE lgl_ctnt_cur;
else
   OPEN lgl_ctnt_version_cur(p_lgl_ctnt_id ,p_object_version_number);
   FETCH lgl_ctnt_version_cur INTO l_exists;
   IF  lgl_ctnt_version_cur%NOTFOUND
  THEN
   FND_MESSAGE.set_name('IBE','IBE_DSP_LGLCTNT_ID_NOT_EXISTS');
   FND_MESSAGE.set_token('ID',p_lgl_ctnt_id);
   FND_MSG_PUB.ADD;
  ELSE
        l_return_status := true;
  END IF;
 CLOSE lgl_ctnt_version_cur;

end if;
return l_return_status;

EXCEPTION
WHEN OTHERS THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error)
      THEN
         FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
      END IF;
      return l_return_status;
END check_lgl_ctnt_id_exists;

----------------------------------------------------------------------------------------
-----------------------------------------------------------------
-- NOTES
--    1. Returns true if  the filename associated with the attachment
--	   is not null and unique
--    2. If file name is null or missing message IBE_DSP_ATH_FILENAME_REQ
--        is pushed on the stack
--	3. If file name already exists , message IBE_DSP_ATH_FILENAME_EXISTS
--       is pushed on the stack
---------------------------------------------------------------------

FUNCTION check_attachment_filename(
	p_attachment_id IN NUMBER,
	p_file_name IN varchar2)
RETURN BOOLEAN
IS
l_api_name CONSTANT VARCHAR2(40) := 'check_attachment_filename';
l_return_status BOOLEAN := FALSE;
l_exists NUMBER;

CURSOR filename_cur( p_file_name IN VARCHAR2 ) IS
	-- SELECT file_name
        SELECT 1
        FROM JTF_AMV_ATTACHMENTS
	WHERE file_name = p_file_name;

CURSOR attachment_filename_cur(p_attachment_id IN NUMBER,
	p_file_name IN VARCHAR2) IS
	-- SELECT file_name
        SELECT 1
        FROM JTF_AMV_ATTACHMENTS
	WHERE file_name = p_file_name and attachment_id <> p_attachment_id;

l_dup_file_exception EXCEPTION;

BEGIN

	IF TRIM(p_file_name) IS NULL THEN
		IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
			FND_MESSAGE.set_name('IBE', 'IBE_DSP_ATH_FILENAME_REQ');
			FND_MSG_PUB.add;
		END IF;

	ELSE
		IF p_attachment_id IS NOT NULL THEN
			OPEN attachment_filename_cur(p_attachment_id, p_file_name);
			FETCH attachment_filename_cur INTO l_exists;
			IF attachment_filename_cur%FOUND THEN
				CLOSE attachment_filename_cur;
				RAISE l_dup_file_exception;
			END IF;
			CLOSE attachment_filename_cur;
		ELSE
			OPEN filename_cur(p_file_name);
			FETCH filename_cur INTO l_exists;
			IF filename_cur%FOUND THEN
				CLOSE filename_cur;
				RAISE l_dup_file_exception;
			END IF;
			CLOSE filename_cur;
		END IF;

		l_return_status := TRUE;

	END IF;

	RETURN l_return_status;

EXCEPTION

	WHEN l_dup_file_exception THEN
		IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
			FND_MESSAGE.set_name('IBE','IBE_DSP_ATH_FILENAME_EXISTS');
			FND_MESSAGE.set_token('FILE_NAME', p_file_name);
			FND_MSG_PUB.ADD;
		END IF;
		RETURN l_return_status;

	WHEN OTHERS THEN
		IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
			FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
		END IF;
		RETURN l_return_status;

END check_attachment_filename;

----------------------------------------------------------------------------------------
-----------------------------------------------------------------
-- NOTES
--    1. Returns true if  the minisite exists
--    2. If not, message IBE_MSITE_NOT_EXISTS is pushed on the stack
---------------------------------------------------------------------

FUNCTION check_msite_exists(
	p_msite_id IN NUMBER,
     p_object_version_number IN NUMBER := FND_API.G_MISS_NUM)
RETURN boolean
IS
l_api_name CONSTANT VARCHAR2(40) := 'check_msite_exists';
l_return_status boolean := false;
l_exists NUMBER;

CURSOR msite_cur( p_msite_id IN NUMBER ) IS
	-- SELECT msite_id
        SELECT 1
        FROM IBE_MSITES_B where msite_id = p_msite_id and site_type = 'I';
-- and
--        end_date_active is null);
---      sysdate between start_date_active and nvl(end_date_active,sysdate));

CURSOR msite_version_cur( p_msite_id IN NUMBER,
	p_object_version_number IN NUMBER ) IS
	-- SELECT msite_id
        SELECT 1
        FROM IBE_MSITES_B
	WHERE msite_id = p_msite_id
	and object_version_number = p_object_version_number and site_type = 'I';
-- AND
--        end_date_active is null);
----      sysdate between start_date_active and nvl(end_date_active,sysdate));


l_msite_not_exists_exception EXCEPTION;

BEGIN

	if (p_msite_id IS NULL) OR (p_object_version_number IS NULL) THEN
		RAISE l_msite_not_exists_exception;

	elsif p_object_version_number = FND_API.G_MISS_NUM  then
 		OPEN msite_cur(p_msite_id );
		FETCH msite_cur INTO l_exists;
		IF  msite_cur%NOTFOUND THEN
			CLOSE msite_cur;
			RAISE l_msite_not_exists_exception;
  		END IF;
		close msite_cur;
		l_return_status := true;

	else
		OPEN msite_version_cur(p_msite_id ,p_object_version_number);
		FETCH msite_version_cur INTO l_exists;
		IF  msite_version_cur%NOTFOUND THEN
			CLOSE msite_version_cur;
			RAISE l_msite_not_exists_exception;
		END IF;
		CLOSE msite_version_cur;
		l_return_status := true;

	END IF;

	return l_return_status;

EXCEPTION

	WHEN l_msite_not_exists_exception THEN
		IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
			FND_MESSAGE.set_name('IBE', 'IBE_MSITE_NOT_EXISTS');
			FND_MESSAGE.set_token('ID', TO_CHAR(p_msite_id));
			FND_MSG_PUB.add;
		END IF;
		RETURN l_return_status;

	WHEN OTHERS THEN
		IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
         		FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
      	END IF;
		return l_return_status;

END check_msite_exists;

----------------------------------------------------------------------------------------
-----------------------------------------------------------------
-- NOTES
--    1. Returns true if  lgl_phys_map_id (IBE_DSP_LGL_PHYS_MAP) exists
--    2. If not , message IBE_DSP_PHYSMAP_NOT_EXISTS is pushed on the stack
---------------------------------------------------------------------
FUNCTION check_physicalmap_exists(p_lgl_phys_map_id IN NUMBER)
RETURN boolean
IS
l_api_name CONSTANT VARCHAR2(40) := 'check_physicalmap_exists';
l_return_status boolean := false;
l_exists NUMBER;

CURSOR lgl_phys_map_cur( p_lgl_phys_map_id IN NUMBER ) IS
	-- SELECT lgl_phys_map_id
        SELECT 1
        FROM IBE_DSP_LGL_PHYS_MAP
	where lgl_phys_map_id = p_lgl_phys_map_id;

l_map_not_exists_exception EXCEPTION;

BEGIN

	IF p_lgl_phys_map_id IS NULL THEN
		RAISE l_map_not_exists_exception;

	ELSE
		OPEN lgl_phys_map_cur(p_lgl_phys_map_id );
		FETCH lgl_phys_map_cur INTO l_exists;
		IF  lgl_phys_map_cur%NOTFOUND THEN
			CLOSE lgl_phys_map_cur;
			RAISE l_map_not_exists_exception;
		END IF;
		CLOSE lgl_phys_map_cur;
		l_return_status := true;

	END IF;

	return l_return_status;

EXCEPTION

	WHEN l_map_not_exists_exception THEN
		IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
			FND_MESSAGE.set_name('IBE', 'IBE_DSP_PHYSMAP_NOT_EXISTS');
			FND_MESSAGE.set_token('ID', TO_CHAR(p_lgl_phys_map_id));
			FND_MSG_PUB.add;
		END IF;
		RETURN l_return_status;

	WHEN OTHERS THEN
      	IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
         		FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
      	END IF;
      	return l_return_status;

END check_physicalmap_exists;

----------------------------------------------------------------------------------------
-----------------------------------------------------------------
-- NOTES
--    1. Returns true if  the deliverable with accessname exists and
--	   is not null and unique
--    2. If access name is null, message IBE_DSP_DLV_ACCNAME_REQ
--        is pushed on the stack
--	3. If access name already exists , message IBE_DSP_DLV_ACCNAME_EXISTS
--       is pushed on the stack
---------------------------------------------------------------------

FUNCTION check_deliverable_accessname(
	p_deliverable_id IN NUMBER,
	p_access_name IN varchar2)
RETURN BOOLEAN
IS
l_api_name  CONSTANT VARCHAR2(40) := 'check_deliverable_accessname';
l_return_status boolean := false;
l_exists NUMBER;

CURSOR accessname_cur(p_access_name IN VARCHAR2 ) IS
   	 -- SELECT access_name
         SELECT 1
         FROM JTF_AMV_ITEMS_B
	 WHERE access_name = p_access_name;

CURSOR deliverable_accessname_cur(p_item_id IN NUMBER,
	p_access_name IN VARCHAR2 ) IS
	-- SELECT access_name
        SELECT 1
        FROM JTF_AMV_ITEMS_B
	WHERE access_name = p_access_name AND item_id <> p_item_id;

l_dup_access_exception EXCEPTION;

BEGIN

	IF TRIM(p_access_name) IS NULL THEN
		IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
			FND_MESSAGE.set_name('IBE', 'IBE_DSP_DLV_ACCNAME_REQ');
			FND_MSG_PUB.add;
		END IF;

	ELSE
		IF p_deliverable_id IS NOT NULL THEN
			-- update
 			OPEN deliverable_accessname_cur(p_deliverable_id, p_access_name);
   			FETCH deliverable_accessname_cur INTO l_exists;
   			IF deliverable_accessname_cur%FOUND THEN
				CLOSE deliverable_accessname_cur;
				RAISE l_dup_access_exception;
			END IF;
			CLOSE deliverable_accessname_cur;
		ELSE
			OPEN accessname_cur(p_access_name);
			FETCH accessname_cur INTO l_exists;
			IF accessname_cur%FOUND THEN
				CLOSE accessname_cur;
				RAISE l_dup_access_exception;
			END IF;
			CLOSE accessname_cur;
		END IF;

		l_return_status := TRUE;

	END IF;

	RETURN l_return_status;

EXCEPTION

	WHEN l_dup_access_exception THEN
		IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
			FND_MESSAGE.set_name('IBE', 'IBE_DSP_DLV_ACCNAME_EXISTS');
			FND_MESSAGE.set_token('ACC_NAME', p_access_name);
			FND_MSG_PUB.add;
		END IF;
		RETURN l_return_status;

	WHEN OTHERS THEN
		IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
			FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
      	END IF;
		RETURN l_return_status;

END check_deliverable_accessname;


----------------------------------------------------------------------------------------
-----------------------------------------------------------------
-- NOTES
--    1. Returns true if  the language is supported by the minisite
--    2. If not,  message IBE_MSITE_LANG_NOT_SUPPORTED
--        is pushed on the stack
---------------------------------------------------------------------

FUNCTION check_language_supported(
	p_msite_id IN NUMBER,
	p_language_code in varchar2 )
RETURN boolean
IS
l_api_name CONSTANT VARCHAR2(40) := 'check_language_supported';
l_return_status boolean := false;
l_exists NUMBER;

CURSOR msite_lang_cur( p_msite_id IN NUMBER, p_language_code IN VARCHAR2 ) IS
	-- SELECT b.language_code
        SELECT 1 FROM
	IBE_MSITES_B A, IBE_MSITE_LANGUAGES B where
	A.msite_id = p_msite_id and
	B.msite_id = A.msite_id and
	A.site_type = 'I' and
	B.language_code = p_language_code ;

l_lang_not_supp_exception EXCEPTION;

BEGIN

	IF (p_msite_id IS NULL) OR (p_language_code IS NULL) THEN
		RAISE l_lang_not_supp_exception;
	ELSE
		OPEN msite_lang_cur(p_msite_id,p_language_code );
		FETCH msite_lang_cur INTO l_exists;
		IF msite_lang_cur%NOTFOUND THEN
			CLOSE msite_lang_cur;
			RAISE l_lang_not_supp_exception;
		END IF;
		CLOSE msite_lang_cur;
		l_return_status := true;
	END IF;

	return l_return_status;

EXCEPTION

	WHEN l_lang_not_supp_exception THEN
		IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
			FND_MESSAGE.set_name('IBE', 'IBE_MSITE_LANG_NOT_SUPP' );
			FND_MESSAGE.set_token('ID', TO_CHAR(p_msite_id));
			FND_MESSAGE.set_token('LANG', p_language_code);
			FND_MSG_PUB.add;
		END IF;
		return l_return_status;

	WHEN OTHERS THEN
		IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
         		FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
      	END IF;
      	return l_return_status;

END check_language_supported;

FUNCTION check_item_deliverable(p_item_id IN NUMBER,
					  p_deliverable_id IN NUMBER)
RETURN boolean
IS
l_api_name CONSTANT VARCHAR2(40) := 'check_item_deliverable';

CURSOR item_dlv_cur(p_item_id in NUMBER,
				p_deliverable_id IN NUMBER ) IS
		-- SELECT A.ITEM_ID
                 SELECT 1
                      from IBE_DSP_TPL_CTG A, MTL_ITEM_CATEGORIES B where
				B.INVENTORY_ITEM_ID = p_item_id and
			      B.CATEGORY_ID = A.CATEGORY_ID AND
				A.ITEM_ID= p_deliverable_id ;

l_return_status boolean := false;
l_exists NUMBER := 0;
BEGIN

return true;
/*
if p_deliverable_id is not null and  p_item_id is not null  then

  open item_dlv_cur(p_item_id,p_deliverable_id);
  FETCH item_dlv_cur INTO l_exists;
  IF item_dlv_cur%FOUND THEN
	l_return_status := true;
  END IF;

  CLOSE item_dlv_cur;

  if l_return_status = false then
   	FND_MESSAGE.set_name('IBE', 'IBE_DSP_ITEM_DLV_INVLD');
	FND_MESSAGE.set_token('ITEM_ID', p_item_id);
	FND_MESSAGE.set_token('ID', p_deliverable_id);
	FND_MSG_PUB.add;
   END IF;
else
   	FND_MESSAGE.set_name('IBE', 'IBE_DSP_ITEM_DLV_REQ');
	FND_MSG_PUB.add;
END IF;


   return l_return_status;

EXCEPTION
WHEN OTHERS THEN
   IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
    		FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
   END IF;
   return false;
*/
end check_item_deliverable;


-----------------------------------------------------------------
-- NOTES
--    1. Returns true if category has the deliverable association
--    2. If not,  message IBE_DSP_CATEGORY_DLV_INVALID
--        is pushed on the stack
---------------------------------------------------------------------
FUNCTION check_category_deliverable(p_category_id IN NUMBER,
					      p_deliverable_id IN NUMBER)
RETURN boolean
IS
l_api_name CONSTANT VARCHAR2(40) := 'check_category_deliverable';

CURSOR category_dlv_cur(p_category_id in NUMBER,
				p_deliverable_id IN NUMBER ) IS
		-- SELECT ITEM_ID
                 SELECT 1
                 from IBE_DSP_TPL_CTG where category_id = p_category_id and
									  ITEM_ID= p_deliverable_id ;

l_return_status boolean := false;
l_exists NUMBER := 0;
BEGIN

if p_deliverable_id is not null and  p_category_id is not null  then

  open category_dlv_cur(p_category_id,p_deliverable_id);
  FETCH category_dlv_cur INTO l_exists;
  IF category_dlv_cur%NOTFOUND THEN
	CLOSE category_dlv_cur;
   	FND_MESSAGE.set_name('IBE', 'IBE_DSP_CATEGORY_DLV_INVLD');
	FND_MESSAGE.set_token('CATEGORY_ID', p_category_id);
	FND_MESSAGE.set_token('ID', p_deliverable_id);
	FND_MSG_PUB.add;
	l_return_status := false;
  else
	 CLOSE category_dlv_cur;
	 l_return_status := true;
  END IF;
else
   	FND_MESSAGE.set_name('IBE', 'IBE_DSP_CATEGORY_DLV_REQ');
	FND_MSG_PUB.add;
END IF;

return l_return_status;

EXCEPTION
WHEN OTHERS THEN
   IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
    		FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
   END IF;
   return false;

end check_category_deliverable;

-----------------------------------------------------------------
-- NOTES
--    1. Returns true if  the minisite exists
--    2. If not, message IBE_MSITE_NOT_EXISTS is pushed on the stack
---------------------------------------------------------------------

FUNCTION check_master_msite_exists
RETURN NUMBER
IS
l_api_name CONSTANT VARCHAR2(40) := 'check_master_msite_exists';
l_msite_id NUMBER := null;

CURSOR msite_cur IS
	SELECT msite_id  FROM IBE_MSITES_B where master_msite_flag='Y' and site_type = 'I';

BEGIN

		OPEN msite_cur;
		FETCH msite_cur INTO l_msite_id;
		close msite_cur;

	if l_msite_id is null then
		FND_MESSAGE.set_name('IBE', 'IBE_MSITE_MASTER_NOT_EXISTS');
		FND_MSG_PUB.add;
	END IF;

	return l_msite_id;

EXCEPTION

	WHEN OTHERS THEN
		IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
         		FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
      	END IF;
		return l_msite_id;

END check_master_msite_exists;

FUNCTION check_attachment_exists(p_file_name IN VARCHAR2)
RETURN NUMBER
IS
l_api_name CONSTANT VARCHAR2(40) := 'check_attachment_exists';

CURSOR attachment_cur(p_file_name IN VARCHAR2) IS
     SELECT attachment_id FROM JTF_AMV_ATTACHMENTS
     WHERE file_name = p_file_name;

l_attachment_id NUMBER := NULL;

BEGIN

     IF TRIM(p_file_name) IS NOT NULL THEN
          OPEN attachment_cur(TRIM(p_file_name));
          FETCH attachment_cur INTO l_attachment_id;
          CLOSE attachment_cur;
     END IF;

     RETURN l_attachment_id;

EXCEPTION

     WHEN OTHERS THEN
          IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
               FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
          END IF;
          RETURN NULL;

END check_attachment_exists;

-- Added by G. Zhang 05/23/01 10:57AM
FUNCTION check_attachment_exists(
	p_deliverable_id IN NUMBER,
	p_file_id IN NUMBER,
 	p_file_name IN VARCHAR2)
RETURN NUMBER
IS
l_api_name CONSTANT VARCHAR2(40) := 'check_attachment_exists';

/*bug 2665027
CURSOR attachment_cur(p_deliverable_id IN NUMBER,p_file_id IN NUMBER,p_file_name IN VARCHAR2) IS
     SELECT attachment_id FROM JTF_AMV_ATTACHMENTS
     WHERE file_name = p_file_name AND
     	   file_id = p_file_id AND
     	   attachment_used_by_id = p_deliverable_id;

CURSOR attachment_cur2(p_deliverable_id IN NUMBER,p_file_name IN VARCHAR2) IS
     SELECT attachment_id FROM JTF_AMV_ATTACHMENTS
     WHERE file_name = p_file_name AND
     	   file_id is null AND
     	   attachment_used_by_id = p_deliverable_id;
*/
--bug 2665027
CURSOR attachment_cur(p_deliverable_id IN NUMBER,p_file_id IN NUMBER,p_file_name IN VARCHAR2) IS
     SELECT jta.attachment_id
	FROM   JTF_AMV_ATTACHMENTS jta,
		  JTF_AMV_ITEMS_B jtai,
		  IBE_DSP_LGL_PHYS_MAP idlpm
     WHERE  jta.file_name = p_file_name AND
     	  jta.file_id = p_file_id AND
		  jta.attachment_id = idlpm.attachment_id AND
		  idlpm.item_id = jtai.item_id AND
		  rownum=1;

CURSOR attachment_cur2(p_deliverable_id IN NUMBER,p_file_name IN VARCHAR2) IS
     SELECT jta.attachment_id
	FROM   JTF_AMV_ATTACHMENTS jta,
		  JTF_AMV_ITEMS_B jtai,
		  IBE_DSP_LGL_PHYS_MAP idlpm
     WHERE  jta.file_name = p_file_name AND
     	  jta.file_id is null AND
            jta.attachment_id = idlpm.attachment_id AND
		  idlpm.item_id = jtai.item_id AND
		  rownum = 1;

l_attachment_id NUMBER := NULL;

BEGIN

     IF TRIM(p_file_name) IS NOT NULL THEN
     	IF p_file_id is null THEN
          OPEN attachment_cur2(p_deliverable_id,TRIM(p_file_name));
          FETCH attachment_cur2 INTO l_attachment_id;
          CLOSE attachment_cur2;
        ELSE
          OPEN attachment_cur(p_deliverable_id,p_file_id,TRIM(p_file_name));
          FETCH attachment_cur INTO l_attachment_id;
          CLOSE attachment_cur;
        END IF;
     END IF;

     RETURN l_attachment_id;

EXCEPTION

     WHEN OTHERS THEN
          IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
               FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
          END IF;
          RETURN NULL;

END check_attachment_exists;

FUNCTION check_attachment_deliverable(
     p_attachment_id IN NUMBER,
     p_deliverable_id IN NUMBER)
RETURN BOOLEAN
IS

l_api_name CONSTANT VARCHAR2(40) := 'check_attachment_deliverable';

CURSOR attachment_cur(p_attachment_id IN NUMBER,
     p_deliverable_id IN NUMBER) IS
       -- SELECT attachment_used_by_id
     SELECT 1
     FROM JTF_AMV_ATTACHMENTS
     WHERE attachment_id = p_attachment_id
     AND attachment_used_by_id = p_deliverable_id;

l_exists NUMBER;
l_return_status BOOLEAN := FALSE;

BEGIN

     IF (p_attachment_id IS NOT NULL)
          AND (p_attachment_id <> FND_API.G_MISS_NUM)
          AND (p_deliverable_id IS NOT NULL)
          AND (p_deliverable_id <> FND_API.G_MISS_NUM) THEN
          OPEN attachment_cur(p_attachment_id, p_deliverable_id);

          FETCH attachment_cur INTO l_exists;
          IF attachment_cur%FOUND THEN
               l_return_status := TRUE;
          END IF;
          CLOSE attachment_cur;
     END IF;

     IF NOT l_return_status THEN
          IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
               FND_MESSAGE.set_name('IBE','IBE_DSP_DLV_ATH_INVLD');
               FND_MESSAGE.set_token('ID', TO_CHAR(p_deliverable_id));
               FND_MESSAGE.set_token('ATH_ID', TO_CHAR(p_attachment_id));
               FND_MSG_PUB.ADD;
          END IF;
     END IF;

     RETURN l_return_status;

EXCEPTION

     WHEN OTHERS THEN
          IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
               FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
          END IF;
          RETURN l_return_status;

END check_attachment_deliverable;

FUNCTION check_default_attachment(p_attachment_id IN NUMBER)
RETURN BOOLEAN IS

l_api_name CONSTANT VARCHAR2(40) := 'check_default_attachment';

CURSOR physmap_cur(p_attachment_id IN NUMBER) IS
       -- SELECT attachment_id
     SELECT 1
     FROM IBE_DSP_LGL_PHYS_MAP
     WHERE attachment_id = p_attachment_id
     AND default_site = 'Y'
     AND default_language = 'Y';

l_exists NUMBER;
l_return_status BOOLEAN := FALSE;

BEGIN

     IF p_attachment_id IS NOT NULL THEN
          OPEN physmap_cur(p_attachment_id);
          FETCH physmap_cur INTO l_exists;
          IF physmap_cur%FOUND THEN
               l_return_status := TRUE;
          END IF;
          CLOSE physmap_cur;
     END IF;

     RETURN l_return_status;

EXCEPTION

     WHEN OTHERS THEN
          IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
               FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
          END IF;
          RETURN FALSE;

END check_default_attachment;

---------------------------------------------------------------------
-- NOTES
-- 1. Returns TRUE if the access_name for a mini site is Unique.
-- 2. If Access Name already exists, message IBE_MSITE_DUP_ACCNAME is
--      pushed on stack.
---------------------------------------------------------------------
FUNCTION Check_Msite_Accessname(p_access_name IN VARCHAR2)
RETURN BOOLEAN
AS
 Cursor C_Exists(p_access_name Varchar2) Is
   Select 'x'
   From   ibe_msites_b
   Where  access_name = p_access_name  and site_type = 'I';
 l_exists Varchar2(1);
 l_status Boolean := TRUE;
Begin
  Open C_Exists(p_access_name);
  Fetch C_Exists INTO l_exists;
  If C_Exists%FOUND Then
   l_status := FALSE ;
   IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MESSAGE.set_name('IBE','IBE_MSITE_DUP_ACCNAME');
      FND_MESSAGE.set_token('ACCNAME',p_access_name);
      FND_MSG_PUB.ADD;
   END IF;
  Else
   l_status := TRUE ;
  End If;
  Close C_Exists ;
  Return l_status;

End Check_Msite_Accessname ;

FUNCTION check_lookup_exists(
  p_lookup_type        IN VARCHAR2,
  p_lookup_code        IN VARCHAR2
) Return VARCHAR2 AS
  l_count NUMBER;

  Cursor c_check_lookup(c_lookup_type VARCHAR2, c_lookup_code VARCHAR2) IS
    select COUNT(*) FROM FND_LOOKUP_VALUES WHERE lookup_type = c_lookup_type
    And lookup_code = c_lookup_code And enabled_flag = 'Y';

BEGIN

  open c_check_lookup(p_lookup_type, p_lookup_code);
  fetch c_check_lookup into l_count;
  CLOSE c_check_lookup;

  IF l_count = 0 THEN
    RETURN FND_API.g_false;
   ELSE
    RETURN FND_API.g_true;
  END IF;
END check_lookup_exists;

FUNCTION Check_Media_Object(p_operation IN VARCHAR2,
					  p_access_name IN VARCHAR2,
					  p_deliverable_type_code IN VARCHAR2,
					  p_applicable_to_code IN VARCHAR2)
RETURN NUMBER
IS
BEGIN
  IF (p_operation = 'CREATE') THEN
    IF (p_access_name is NULL)
	 OR (p_access_name = FND_API.G_MISS_CHAR) THEN
      -- Access name cannot be null
      RETURN -1;
    END IF;
    IF (p_deliverable_type_code is NULL)
	 OR (p_deliverable_type_code = FND_API.G_MISS_CHAR) THEN
      -- Deliverable type code cannot be null
      RETURN -2;
    ELSE
      -- Check content type code for OCM integration
      NULL;
    END IF;
    IF (p_applicable_to_code is NULL)
	 OR (p_applicable_to_code = FND_API.G_MISS_CHAR) THEN
      -- Applicable to code cannot be null
      RETURN -3;
    ELSE
      -- Check the lookup code
      IF check_lookup_exists(p_lookup_type  => 'JTF_AMV_APPLI_TO_CODE',
	     p_lookup_code  => p_applicable_to_code)
	     = FND_API.G_FALSE THEN
	   IF p_deliverable_type_code = 'TEMPLATE' THEN
	     IF check_lookup_exists(p_lookup_type  => 'IBE_M_TEMPLATE_APPLI_TO',
	         p_lookup_code  => p_applicable_to_code)
		    = FND_API.G_FALSE THEN
		  RETURN -5;
          END IF;
	   ELSIF p_deliverable_type_code = 'MEDIA' THEN
	     IF check_lookup_exists(p_lookup_type  => 'IBE_M_MEDIA_OBJECT_APPLI_TO',
	         p_lookup_code  => p_applicable_to_code)
		    = FND_API.G_FALSE THEN
		  RETURN -6;
	     END IF;
	   END IF;
      END IF;
    END IF;
  ELSIF (p_operation = 'UPDATE') THEN
    IF (p_access_name is NULL) THEN
      -- Access name cannot be null
      RETURN -1;
    END IF;
    IF (p_deliverable_type_code is NULL) THEN
      -- Deliverable type code cannot be null
      RETURN -2;
    ELSE
      -- Check content type code for OCM integration
      NULL;
    END IF;
    IF (p_applicable_to_code is NULL) THEN
      -- Applicable to code cannot be null
      RETURN -3;
    ELSE
      IF (p_applicable_to_code <> FND_API.G_MISS_CHAR) THEN
        -- Check the lookup code
        IF check_lookup_exists(p_lookup_type  => 'JTF_AMV_APPLI_TO_CODE',
	       p_lookup_code  => p_applicable_to_code)
	       = FND_API.G_FALSE THEN
	     IF p_deliverable_type_code = 'TEMPLATE' THEN
	       IF check_lookup_exists(p_lookup_type  => 'IBE_M_TEMPLATE_APPLI_TO',
		      p_lookup_code  => p_applicable_to_code)
		      = FND_API.G_FALSE THEN
		    RETURN -5;
            END IF;
	     ELSIF p_deliverable_type_code = 'MEDIA' THEN
	       IF check_lookup_exists(p_lookup_type  => 'IBE_M_MEDIA_OBJECT_APPLI_TO',
		      p_lookup_code  => p_applicable_to_code)
		      = FND_API.G_FALSE THEN
		    RETURN -6;
	       END IF;
	     END IF;
        END IF;
      END IF; -- FND_API.G_MISS_CHAR checking
    END IF;
  END IF;
  RETURN 0;
END Check_Media_Object;

END IBE_DSPMGRVALIDATION_GRP;

/
