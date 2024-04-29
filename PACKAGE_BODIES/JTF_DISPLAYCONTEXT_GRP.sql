--------------------------------------------------------
--  DDL for Package Body JTF_DISPLAYCONTEXT_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_DISPLAYCONTEXT_GRP" AS
/* $Header: JTFGCTXB.pls 115.12 2004/07/09 18:49:30 applrt ship $ */

-----------------------------------------------------------------
-- NOTES
--    1. Raises an exception if the api_version is not valid
--    2. If the context_id is passed in the record, the existing display
--       context is updated.
--    3. If the context_id is set to null, a new display context record
--       is inserted
--    4. If the context_id is passed for update operation, and the object
--       version number does not match , an exception is raised
---   5. If deliverable_id is passed, then the deliverable_id should have
--       the DELIVERABLE_TYPE_CODE (JTF_AMV_ITEMS_B) same as context_type
--       Valid context_types are TEMPLATE OR MEDIA
--	 6. Access name is unique for a context_type
--    7. Raises an exception if the access name is null
---------------------------------------------------------------------
PROCEDURE save_display_context(
   p_api_version           IN  NUMBER,
   p_init_msg_list    IN   VARCHAR2 := FND_API.g_false,
   p_commit                IN  VARCHAR2  := FND_API.g_false,
   x_return_status               OUT VARCHAR2,
   x_msg_count           OUT  NUMBER,
   x_msg_data            OUT  VARCHAR2,
   p_display_context_rec   IN OUT  DISPLAY_CONTEXT_REC_TYPE
)
IS
   l_api_name    CONSTANT VARCHAR2(30) := 'save_display_context';
   l_full_name   CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
   l_operation_type VARCHAR2(10) := 'INSERT';
   l_return_status  VARCHAR2(1);
   l_index		NUMBER ;
   l_context_id         NUMBER;
   l_deliverable_id      NUMBER := null;

   l_access_name 	VARCHAR2(40);

 CURSOR context_id_seq IS
   SELECT jtf_dsp_context_b_s1.NEXTVAL
     FROM DUAL;

BEGIN

   --------------------- initialize -----------------------
   SAVEPOINT save_display_context;

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

-- Check if the context type is valid
  IF jtf_dspmgrvalidation_grp.check_valid_context_type(p_display_context_rec.context_type) = false
  then
	raise FND_API.g_exc_error;
  end if;


--- Check if the context_id exists if not null
IF p_display_context_rec.context_id IS NOT NULL
THEN
---dbms_output.put_line('Context id is passed '  );

 if jtf_dspmgrvalidation_grp.check_context_exists(p_display_context_rec.context_id,
						  p_display_context_rec.context_type,
						  p_display_context_rec.Object_version_Number)
						 = false then
       raise FND_API.g_exc_error;
 end if;

l_operation_type:='UPDATE';

---dbms_output.put_line('Operation is an update '  );

END IF;

---dbms_output.put_line('Access name cannot be null' || p_display_context_rec.access_name );

--- Check if the access name of the context exists if not null
l_access_name := trim(p_display_context_rec.access_name);

IF l_access_name is not null
then


 if not jtf_dspmgrvalidation_grp.check_context_accessname(l_access_name,
		   						      p_display_context_rec.context_type,
									p_display_context_rec.context_id)
 then
      ---dbms_output.put_line('Access name already exists' );
       raise FND_API.g_exc_error;
 end if;
      ---dbms_output.put_line('Passed unique Access name ' );
else
     ---dbms_output.put_line('Access name cannot be null'  );
     RAISE jtf_dspmgrvalidation_grp.context_accname_req_exception;
end if;


--- Check if the deliverable id exists if deliverable is not null, else ignore.
IF p_display_context_rec.default_deliverable_id is not null and
   p_display_context_rec.default_deliverable_id <> FND_API.g_miss_num
then
    IF jtf_dspmgrvalidation_grp.check_deliverable_type_exists(p_display_context_rec.Default_deliverable_id ,
							      		  p_display_context_rec.context_type)
    then
        l_deliverable_id := p_display_context_rec.Default_deliverable_id;
    else
        raise FND_API.g_exc_error;
    END IF;
end if;


---dbms_output.put_line('PASSED DELIVERABLE_ ID TEST');

IF  l_operation_type = 'INSERT'
THEN
---dbms_output.put_line('INSERT OPERATIOn ');

---dbms_output.put_line('PASSED CONTEXT_TYPE TEST');

        OPEN context_id_seq;
        FETCH context_id_seq INTO l_context_id;
        CLOSE context_id_seq;

  ---dbms_output.put_line('Operation is an insert '  || l_context_id || '---' || FND_GLOBAL.user_id);

END IF;

IF l_operation_type = 'INSERT'
THEN
INSERT INTO JTF_DSP_CONTEXT_B (
CONTEXT_ID,
OBJECT_VERSION_NUMBER,
LAST_UPDATE_DATE,
LAST_UPDATED_BY,
CREATION_DATE,
CREATED_BY,
LAST_UPDATE_LOGIN,
ACCESS_NAME,
CONTEXT_TYPE_CODE,
ITEM_ID
)
 VALUES (
l_context_id,
1,
SYSDATE,
FND_GLOBAL.user_id,
SYSDATE,
FND_GLOBAL.user_id,
FND_GLOBAL.user_id,
p_display_context_rec.access_name,
p_display_context_rec.context_type,
l_deliverable_id);

--- Insert into the TL table
insert into JTF_DSP_CONTEXT_TL (
  CONTEXT_ID,
  LAST_UPDATE_DATE,
  LAST_UPDATED_BY,
  CREATION_DATE,
  CREATED_BY,
  LAST_UPDATE_LOGIN,
  OBJECT_VERSION_NUMBER,
  NAME,
  DESCRIPTION,
  LANGUAGE,
  SOURCE_LANG
  ) select
   l_context_id,
   sysdate,
   FND_GLOBAL.user_id,
   sysdate,
   FND_GLOBAL.user_id,
   FND_GLOBAL.user_id,
   1,
   p_display_context_rec.display_name,
   p_display_context_rec.description,
   L.LANGUAGE_CODE,
   userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
		 and not exists
		 (select NULL
		from JTF_DSP_CONTEXT_TL T
	   where T.CONTEXT_ID =l_context_id
	and T.LANGUAGE = L.LANGUAGE_CODE);
p_display_context_rec.context_id := l_context_id;
p_display_context_rec.object_version_number := 1;

ELSIF l_operation_type = 'UPDATE'
THEN

UPDATE  JTF_DSP_CONTEXT_B  SET
LAST_UPDATE_DATE = SYSDATE,
LAST_UPDATED_BY = FND_GLOBAL.user_id,
LAST_UPDATE_LOGIN= FND_GLOBAL.user_id,
ACCESS_NAME = p_display_context_rec.access_name,
CONTEXT_TYPE_CODE = p_display_context_rec.context_type,
ITEM_ID = l_deliverable_id ,
OBJECT_VERSION_NUMBER = p_display_context_rec.object_version_number + 1
WHERE
CONTEXT_ID = p_display_context_rec.context_id and
OBJECT_VERSION_NUMBER  = p_display_context_rec.object_version_number;
--- Update the TL table

update JTF_DSP_CONTEXT_TL set
    NAME = decode( p_display_context_rec.display_name,
		      FND_API.G_MISS_CHAR, NAME, p_display_context_rec.display_name),
    DESCRIPTION = decode( p_display_context_rec.description,
			 FND_API.G_MISS_CHAR, DESCRIPTION, p_display_context_rec.description),
    LAST_UPDATE_DATE = SYSDATE,
    LAST_UPDATED_BY = FND_GLOBAL.user_id,
    LAST_UPDATE_LOGIN = FND_GLOBAL.user_id,
    OBJECT_VERSION_NUMBER= p_display_context_rec.object_version_number +1 ,
    SOURCE_LANG = userenv('LANG')
 where context_id = p_display_context_rec.context_id
 and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

END IF;

---dbms_output.put_line('Operation is successful ' );
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
      ROLLBACK TO save_display_context;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO save_display_context;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN jtf_dspmgrvalidation_grp.context_accname_req_exception THEN
   ROLLBACK TO save_display_context;
   x_return_status := FND_API.g_ret_sts_error;
   FND_MESSAGE.set_name('JTF','JTF_DSP_CONTEXT_ACCNAME_REQ');
   FND_MSG_PUB.ADD;
   FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN OTHERS THEN
      ROLLBACK TO save_display_context;
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

END save_display_context;


---------------------------------------------------------------
-- NOTES
--    1. Raise exception if the p_api_version doesn't match.
--    2. Raises exception if the context_id does not exist
--    3. The context_id passed should have context_type and the correct
--       object_version_number to be deleted.Else an exception is raised
--    4. All corresponding entries for the context_id are also deleted
--       from TL tables
--------------------------------------------------------------------
PROCEDURE delete_display_context(
   p_api_version         IN  NUMBER,
   p_init_msg_list       IN  VARCHAR2 := FND_API.g_false,
   p_commit              IN  VARCHAR2 := FND_API.g_false,
   x_return_status       OUT VARCHAR2,
   x_msg_count           OUT  NUMBER,
   x_msg_data		 OUT VARCHAR2,
   p_display_context_rec IN OUT DISPLAY_CONTEXT_REC_TYPE
)
IS
   l_api_name    CONSTANT VARCHAR2(30) := 'delete_display_context';
   l_full_name   CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
   l_index 	 NUMBER;
   l_context_id  NUMBER;
BEGIN

   --------------------- initialize -----------------------
   SAVEPOINT delete_display_context;

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

--- Check if the context_id exists
IF p_display_context_rec.context_id <> FND_API.g_miss_num
  and p_display_context_rec.context_id is  not null
THEN

--  Check if the context_id is valid
 if jtf_dspmgrvalidation_grp.check_context_exists(p_display_context_rec.context_id,
						p_display_context_rec.context_type,
						p_display_context_rec.Object_version_Number)
					= false then
       raise FND_API.g_exc_error;
 end if;

DELETE FROM JTF_DSP_CONTEXT_B WHERE
CONTEXT_ID = p_display_context_rec.context_id AND
CONTEXT_TYPE_CODE = p_display_context_rec.context_type AND
OBJECT_VERSION_NUMBER= p_display_context_rec.object_version_number;

p_display_context_rec.context_id := null;

DELETE FROM JTF_DSP_CONTEXT_TL WHERE
CONTEXT_ID = p_display_context_rec.context_id;

--- Delete all entries from jtf_dsp_obj_lgl_ctnt which use the context_id
JTF_LogicalContent_GRP.delete_context(p_display_context_rec.context_id);

JTF_DSP_SECTION_GRP.Update_Dsp_Context_To_Null(
	p_api_version,
	FND_API.g_false,
	FND_API.g_false,
	FND_API.G_VALID_LEVEL_FULL,
 	p_display_context_rec.context_id,
	x_return_status,
	x_msg_count,
	x_msg_data
     );

else
   FND_MESSAGE.set_name('JTF','JTF_DSP_CONTEXT_ID_REQ');
   FND_MSG_PUB.ADD;
   raise FND_API.g_exc_error;
END IF;


x_return_status := FND_API.G_RET_STS_SUCCESS;

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
      ROLLBACK TO delete_display_context;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO delete_display_context;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
   FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );


   WHEN OTHERS THEN
      ROLLBACK TO delete_display_context;
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


END DELETE_DISPLAY_CONTEXT;

---------------------------------------------------------------
-- NOTES
--    1. Raise exception if the p_api_version doesn't match.
--    2. If context_delete is FND_API.g_true, then operation is
--       delete and delete_display_context is called with appropriate
--       parameters
--    3. If the context_id is passed in the record, the existing display
--       context is updated.
--    4. If the context_id is set to null, a new display context record
--       is inserted  and context_delete is FND_API.g_false
--    5. If the operation is an insert/update, save_display_context with
--	   appropriate parameters is called
--    6. Raises exception if the context_id does not exist for an update
--	    operation
--    7. If the context_id is passed for update operation, and the object
--       version number does not match , the update operation fails and
--	   an exception is raised
--    8. All corresponding entries for the context_id are also inserted
--	    updated,deleted from TL tables depending on the operation (2,3)
--------------------------------------------------------------------
PROCEDURE save_delete_display_context(
   p_api_version         IN  NUMBER,
   p_init_msg_list       IN   VARCHAR2 := FND_API.g_false,
   p_commit              IN  VARCHAR2  := FND_API.g_false,
   x_return_status       OUT VARCHAR2,
   x_msg_count           OUT  NUMBER,
   x_msg_data            OUT  VARCHAR2,
   p_display_context_tbl IN OUT DISPLAY_CONTEXT_TBL_TYPE
) IS
   l_api_name    CONSTANT VARCHAR2(30) := 'save_delete_display_context';
   l_full_name   CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
   l_return_status  VARCHAR2(1);
   l_index 	 NUMBER;
   l_context_id  NUMBER;
   l_msg_count NUMBER;
   l_msg_data VARCHAR2(80);

BEGIN
   --------------------- initialize -----------------------
   SAVEPOINT save_delete_display_context;

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

FOR l_index  IN 1..p_display_context_tbl.COUNT
LOOP
---
   IF p_display_context_tbl(l_index).context_delete = FND_API.g_true
   then
	delete_display_context(
           p_api_version,
	     FND_API.g_false,
           FND_API.g_false,
           l_return_status,
           l_msg_count,
	     l_msg_data,
           p_display_context_tbl(l_index));

        ---dbms_output.put_line('Return from delete_display_context:' || l_return_status);


   ELSIF p_display_context_tbl(l_index).context_delete = FND_API.g_false
	then
	  save_display_context(
           p_api_version,
	     FND_API.g_false,
           FND_API.g_false,
           l_return_status,
           l_msg_count,
	   l_msg_data,
           p_display_context_tbl(l_index));
        ---dbms_output.put_line('Return from save_display_context:' || l_return_status);
    END IF;

     if l_return_status <> FND_API.G_RET_STS_SUCCESS
	  then
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

   WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO save_delete_display_context;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );


   WHEN OTHERS THEN
      ROLLBACK TO save_delete_display_context;
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
END save_delete_display_context;


---------------------------------------------------------------
-- NOTES
--    1. Raise exception if there is a database error
--    2. Sets the item_id in JTF_DSP_CONTEXT_B to null for
--	   the deliverable id passed
--    3. No api level exceptions are raised
--------------------------------------------------------------------
PROCEDURE delete_deliverable(
   p_deliverable_id      IN  NUMBER
)
IS
BEGIN

   SAVEPOINT delete_deliverable;

   if p_deliverable_id <> FND_API.g_miss_num or p_deliverable_id is  not null
   then
   -- Set the deliverable id to null for any display context
    update JTF_DSP_CONTEXT_B set item_id = null where
    item_id = p_deliverable_id;
   end if;


EXCEPTION
   WHEN OTHERS THEN
      ROLLBACK TO delete_deliverable;

END delete_deliverable;

/* ------ Begin Insert_row ------------- */

procedure INSERT_ROW (
  X_ROWID 			in out 	VARCHAR2,
  X_CONTEXT_ID 			in 	NUMBER,
  X_SECURITY_GROUP_ID 		in 	NUMBER,
  X_OBJECT_VERSION_NUMBER 	in 	NUMBER,
  X_ACCESS_NAME 		in 	VARCHAR2,
  X_CONTEXT_TYPE_CODE 		in 	VARCHAR2,
  X_ITEM_ID 			in 	NUMBER,
  X_NAME 			in 	VARCHAR2,
  X_DESCRIPTION 		in 	VARCHAR2,
  X_CREATION_DATE 		in 	DATE,
  X_CREATED_BY 			in 	NUMBER,
  X_LAST_UPDATE_DATE 		in 	DATE,
  X_LAST_UPDATED_BY 		in 	NUMBER,
  X_LAST_UPDATE_LOGIN 		in 	NUMBER) IS

 cursor C is select ROWID from JTF_DSP_CONTEXT_B
    where CONTEXT_ID = X_CONTEXT_ID
    ;
begin
  insert into JTF_DSP_CONTEXT_B (
    SECURITY_GROUP_ID,
    CONTEXT_ID,
    OBJECT_VERSION_NUMBER,
    ACCESS_NAME,
    CONTEXT_TYPE_CODE,
    ITEM_ID,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_SECURITY_GROUP_ID,
    X_CONTEXT_ID,
    X_OBJECT_VERSION_NUMBER,
    X_ACCESS_NAME,
    X_CONTEXT_TYPE_CODE,
    X_ITEM_ID,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into JTF_DSP_CONTEXT_TL (
    SECURITY_GROUP_ID,
    CONTEXT_ID,
    OBJECT_VERSION_NUMBER,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    NAME,
    DESCRIPTION,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_SECURITY_GROUP_ID,
    X_CONTEXT_ID,
    X_OBJECT_VERSION_NUMBER,
    X_CREATED_BY,
    X_CREATION_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATE_LOGIN,
    X_NAME,
    X_DESCRIPTION,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from JTF_DSP_CONTEXT_TL T
    where T.CONTEXT_ID = X_CONTEXT_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);

  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

end INSERT_ROW;

/* ---- End INSERT_ROW Procedure ----- */

/* ---- Start LOCK_ROW Procedue ------ */

procedure LOCK_ROW (
  X_CONTEXT_ID 			in 	NUMBER,
  X_SECURITY_GROUP_ID 		in 	NUMBER,
  X_OBJECT_VERSION_NUMBER 	in 	NUMBER,
  X_ACCESS_NAME 		in 	VARCHAR2,
  X_CONTEXT_TYPE_CODE 		in 	VARCHAR2,
  X_ITEM_ID 			in 	NUMBER,
  X_NAME 			in 	VARCHAR2,
  X_DESCRIPTION 		in 	VARCHAR2
) IS

  cursor c is select
      SECURITY_GROUP_ID,
      OBJECT_VERSION_NUMBER,
      ACCESS_NAME,
      CONTEXT_TYPE_CODE,
      ITEM_ID
    from JTF_DSP_CONTEXT_B
    where CONTEXT_ID = X_CONTEXT_ID
    for update of CONTEXT_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      NAME,
      DESCRIPTION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from JTF_DSP_CONTEXT_TL
    where CONTEXT_ID = X_CONTEXT_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of CONTEXT_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    ((recinfo.SECURITY_GROUP_ID = X_SECURITY_GROUP_ID)
           OR ((recinfo.SECURITY_GROUP_ID is null) AND (X_SECURITY_GROUP_ID is null)))
      AND (recinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER)
      AND (recinfo.ACCESS_NAME = X_ACCESS_NAME)
      AND (recinfo.CONTEXT_TYPE_CODE = X_CONTEXT_TYPE_CODE)
      AND ((recinfo.ITEM_ID = X_ITEM_ID)
           OR ((recinfo.ITEM_ID is null) AND (X_ITEM_ID is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    ((tlinfo.NAME = X_NAME)
               OR ((tlinfo.NAME is null) AND (X_NAME is null)))
          AND ((tlinfo.DESCRIPTION = X_DESCRIPTION)
               OR ((tlinfo.DESCRIPTION is null) AND (X_DESCRIPTION is null)))
      ) then
        null;
      else
        fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
        app_exception.raise_exception;
      end if;
    end if;
  end loop;
  return;
end LOCK_ROW;

/* ------- End LOCK_ROW Procedure ---------- */

/* ------- start UPDATE_ROW Procedure ------- */

procedure UPDATE_ROW (
  X_CONTEXT_ID 			in 	NUMBER,
  X_SECURITY_GROUP_ID 		in 	NUMBER,
  X_OBJECT_VERSION_NUMBER 	in 	NUMBER,
  X_ACCESS_NAME 		in 	VARCHAR2,
  X_CONTEXT_TYPE_CODE 		in 	VARCHAR2,
  X_ITEM_ID 			in 	NUMBER,
  X_NAME 			in 	VARCHAR2,
  X_DESCRIPTION 		in 	VARCHAR2,
  X_LAST_UPDATE_DATE 		in 	DATE,
  X_LAST_UPDATED_BY 		in 	NUMBER,
  X_LAST_UPDATE_LOGIN 		in 	NUMBER
) IS

begin
  update JTF_DSP_CONTEXT_B set
    SECURITY_GROUP_ID = X_SECURITY_GROUP_ID,
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
    ACCESS_NAME = X_ACCESS_NAME,
    CONTEXT_TYPE_CODE = X_CONTEXT_TYPE_CODE,
    ITEM_ID = X_ITEM_ID,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where CONTEXT_ID = X_CONTEXT_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update JTF_DSP_CONTEXT_TL set
    NAME = X_NAME,
    DESCRIPTION = X_DESCRIPTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where CONTEXT_ID = X_CONTEXT_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

/* ---- End UPDATE_ROW Procedure ---------- */

/* ---- Start DELETE_ROW Procedure --------- */

procedure DELETE_ROW (
  X_CONTEXT_ID 		in 	NUMBER
) is
begin
  delete from JTF_DSP_CONTEXT_TL
  where CONTEXT_ID = X_CONTEXT_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from JTF_DSP_CONTEXT_B
  where CONTEXT_ID = X_CONTEXT_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

/* --- End DELETE_ROW Procedure ---- */

/* -- Start TRANSLATE_ROW Procedure ---- */

procedure TRANSLATE_ROW (
  X_CONTEXT_ID          in      NUMBER,
  X_OWNER               in      VARCHAR2,
  X_NAME          	in      VARCHAR2,
  X_DESCRIPTION   	in      VARCHAR2 ) is

begin

update jtf_dsp_context_tl
set language = USERENV('LANG'),
    source_lang = USERENV('LANG'),
    name = X_NAME,
    description = X_DESCRIPTION,
    last_updated_by = decode(X_OWNER,'SEED',1,0),
    last_update_date = sysdate,
    last_update_login=0
Where userenv('LANG') in (language,source_lang)
and context_id = X_CONTEXT_ID;

end TRANSLATE_ROW;

/* ---- End TRANSLATE_ROW Procedure ---- */

/* ----- Start LOAD_ROW Procedure ------- */

procedure LOAD_ROW (
  X_CONTEXT_ID 			in 	NUMBER,
  X_SECURITY_GROUP_ID 		in 	NUMBER,
  X_OWNER			in	VARCHAR2,
  X_OBJECT_VERSION_NUMBER 	in 	NUMBER,
  X_ACCESS_NAME 		in 	VARCHAR2,
  X_CONTEXT_TYPE_CODE 		in 	VARCHAR2,
  X_ITEM_ID 			in 	NUMBER,
  X_NAME 			in 	VARCHAR2,
  X_DESCRIPTION 		in 	VARCHAR2) IS

Owner_id 	NUMBER := 0;
Row_Id		VARCHAR2(64);

Begin

	If X_OWNER = 'SEED' Then
		Owner_id := 1;
	End If;

	UPDATE_ROW (
  		X_CONTEXT_ID 		=>  X_CONTEXT_ID,
  		X_SECURITY_GROUP_ID 	=>  X_SECURITY_GROUP_ID,
		X_OBJECT_VERSION_NUMBER =>  X_OBJECT_VERSION_NUMBER,
  		X_ACCESS_NAME 		=>  X_ACCESS_NAME,
 		X_CONTEXT_TYPE_CODE 	=>  X_CONTEXT_TYPE_CODE,
  		X_ITEM_ID 		=>  X_ITEM_ID,
  		X_NAME 			=>  X_NAME,
  		X_DESCRIPTION 		=>  X_DESCRIPTION,
  		X_LAST_UPDATE_DATE 	=>  sysdate,
  		X_LAST_UPDATED_BY 	=>  Owner_id,
  		X_LAST_UPDATE_LOGIN 	=>  0);
Exception
	When NO_DATA_FOUND Then

		INSERT_ROW(
			X_ROWID 			=> Row_id,
  			X_CONTEXT_ID 			=> X_CONTEXT_ID,
  			X_SECURITY_GROUP_ID 		=> X_SECURITY_GROUP_ID,
  			X_OBJECT_VERSION_NUMBER 	=> X_OBJECT_VERSION_NUMBER,
  			X_ACCESS_NAME 			=> X_ACCESS_NAME,
  			X_CONTEXT_TYPE_CODE 		=> X_CONTEXT_TYPE_CODE,
  			X_ITEM_ID 			=> X_ITEM_ID,
  			X_NAME 				=> X_NAME,
 			X_DESCRIPTION 			=> X_DESCRIPTION,
  			X_CREATION_DATE 		=> sysdate,
  			X_CREATED_BY 			=> Owner_id,
  			X_LAST_UPDATE_DATE 		=> sysdate,
  			X_LAST_UPDATED_BY 		=> Owner_id,
  			X_LAST_UPDATE_LOGIN 		=> 0);
End LOAD_ROW;

/* ----- End LOAD_ROW_PROCEDURE ----- */

procedure ADD_LANGUAGE
is
begin
  delete from JTF_DSP_CONTEXT_TL T
  where not exists
    (select NULL
    from JTF_DSP_CONTEXT_B B
    where B.CONTEXT_ID = T.CONTEXT_ID
    );

  update JTF_DSP_CONTEXT_TL T set (
      NAME,
      DESCRIPTION
    ) = (select
      B.NAME,
      B.DESCRIPTION
    from JTF_DSP_CONTEXT_TL B
    where B.CONTEXT_ID = T.CONTEXT_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.CONTEXT_ID,
      T.LANGUAGE
  ) in (select
      SUBT.CONTEXT_ID,
      SUBT.LANGUAGE
    from JTF_DSP_CONTEXT_TL SUBB, JTF_DSP_CONTEXT_TL SUBT
    where SUBB.CONTEXT_ID = SUBT.CONTEXT_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.NAME <> SUBT.NAME
      or (SUBB.NAME is null and SUBT.NAME is not null)
      or (SUBB.NAME is not null and SUBT.NAME is null)
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));

  insert into JTF_DSP_CONTEXT_TL (
    CONTEXT_ID,
    OBJECT_VERSION_NUMBER,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    NAME,
    DESCRIPTION,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.CONTEXT_ID,
    B.OBJECT_VERSION_NUMBER,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    B.NAME,
    B.DESCRIPTION,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from JTF_DSP_CONTEXT_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from JTF_DSP_CONTEXT_TL T
    where T.CONTEXT_ID = B.CONTEXT_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);

end ADD_LANGUAGE;


END JTF_DisplayContext_GRP;


/
