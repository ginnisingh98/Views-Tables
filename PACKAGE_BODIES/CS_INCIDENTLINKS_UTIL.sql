--------------------------------------------------------
--  DDL for Package Body CS_INCIDENTLINKS_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_INCIDENTLINKS_UTIL" AS
/* $Header: csusrlb.pls 120.1 2006/03/15 11:21:06 spusegao noship $ */

G_PKG_NAME	    CONSTANT VARCHAR2(30) := 'CS_INCIDENTLINKS_UTIL';

-- Procedure to validate if the passed in link type is valid. Link type should
-- be defined in cs_sr_link_types_vl.
-- Basic sanity validation
PROCEDURE VALIDATE_LINK_TYPE (
   P_LINK_TYPE_ID            IN           NUMBER   := NULL,
   X_RETURN_STATUS           OUT NOCOPY   VARCHAR2,
   X_MSG_COUNT               OUT NOCOPY   NUMBER,
   X_MSG_DATA                OUT NOCOPY   VARCHAR2 )
IS
   l_api_name                CONSTANT VARCHAR2(30) := 'VALIDATE_LINK_TYPE';
   l_api_name_full           CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||l_api_name;

   -- the nvl is needed coz either one of the parameters can be passed.
   cursor c1 is
   select link_type_id
   from   cs_sr_link_types_b
   where  link_type_id = p_link_type_id
   and    SYSDATE between nvl(start_date_active, SYSDATE)
		      and nvl(end_date_active  , SYSDATE);

   -- local variable to store the output of the cursor
   l_link_type_id        NUMBER(15);

BEGIN
   -- Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   open c1;
   fetch c1 into l_link_type_id;

   if ( c1%NOTFOUND ) then
      FND_MESSAGE.SET_NAME ('CS', 'CS_SR_LINK_INVALID_LINK');
      FND_MESSAGE.Set_Token('API_NAME', l_api_name_full);
      FND_MSG_PUB.Add;
      x_return_status := FND_API.G_RET_STS_ERROR;
   end if;

   close c1;

   FND_MSG_PUB.Count_And_Get(
      p_count => x_msg_count,
      p_data  => x_msg_data);

EXCEPTION
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MESSAGE.SET_NAME ('CS', 'CS_API_SR_UNKNOWN_ERROR');
      FND_MESSAGE.SET_TOKEN ('P_TEXT',l_api_name_full||'-'||SQLERRM);
      FND_MSG_PUB.ADD;
      FND_MSG_PUB.Count_And_Get(
	 p_count => x_msg_count,
	 p_data  => x_msg_data);

END VALIDATE_LINK_TYPE;

-- Procedure to validate if the passed in subject, object and link type are
-- a valid combination.
-- Rule : A link instance should have a valid subject type, object type and
--        link type combination.

PROCEDURE VALIDATE_LINK_SUB_OBJ_TYPE (
   P_SUBJECT_TYPE            IN           VARCHAR2,
   P_OBJECT_TYPE             IN           VARCHAR2,
   P_LINK_TYPE_ID            IN           NUMBER,
   X_RETURN_STATUS	     OUT NOCOPY   VARCHAR2,
   X_MSG_COUNT		     OUT NOCOPY   NUMBER,
   X_MSG_DATA		     OUT NOCOPY   VARCHAR2 )
IS
   l_api_name                CONSTANT VARCHAR2(30) := 'VALIDATE_LINK_SUB_OBJ_TYPE';
   l_api_name_full           CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||l_api_name;

   l_dummy                   NUMBER(15) := 0;
BEGIN
   -- Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   select count(*)
   into   l_dummy
   from   cs_sr_link_valid_obj
   where  subject_type = p_subject_type
   and    object_type  = p_object_type
   and    link_type_id = p_link_type_id
   and    SYSDATE between nvl(start_date_active, SYSDATE)
		      and nvl(end_date_active  , SYSDATE );

   if ( l_dummy <= 0 ) then
      -- Valid objects do not exist for the given Object, Related Object and Link
      -- type combination. Please define a valid object for this combination.
      FND_MESSAGE.Set_Name('CS', 'CS_SR_LINK_NO_VALID_OBJ');
      FND_MESSAGE.Set_Token('API_NAME', l_api_name_full);
      FND_MSG_PUB.Add;
      x_return_status := FND_API.G_RET_STS_ERROR;
   else
      -- check for the reciprocal link valid object as well; interchange the subject and
      -- object and use the reciprocal link_type_id

      l_dummy := 0;

      select count(*)
      into   l_dummy
      from   cs_sr_link_valid_obj
      where  subject_type = p_object_type
      and    object_type  = p_subject_type
      and    link_type_id = ( select reciprocal_link_type_id
			      from   cs_sr_link_types_b
			      where  link_type_id = p_link_type_id )
      and    SYSDATE between nvl(start_date_active, SYSDATE)
		         and nvl(end_date_active  , SYSDATE );

      if ( l_dummy <= 0 ) then
         -- Valid objects do not exist for the given Object, Related Object and Link
         -- type combination. Please define a valid object for this combination.
         FND_MESSAGE.Set_Name('CS', 'CS_SR_LINK_NO_VALID_OBJ');
         FND_MESSAGE.Set_Token('API_NAME', l_api_name_full);
         FND_MSG_PUB.Add;
      end if;
   end if;

   FND_MSG_PUB.Count_And_Get(
      p_count => x_msg_count,
      p_data  => x_msg_data);

EXCEPTION
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MESSAGE.SET_NAME ('CS', 'CS_API_SR_UNKNOWN_ERROR');
      FND_MESSAGE.SET_TOKEN ('P_TEXT',l_api_name_full||'-'||SQLERRM);
      FND_MSG_PUB.ADD;
      FND_MSG_PUB.Count_And_Get(
	 p_count => x_msg_count,
	 p_data  => x_msg_data);

END VALIDATE_LINK_SUB_OBJ_TYPE;

-- Procedure to validate if the passed in subject and object details are
-- valid definitions in their respective schemas. ie.If the subject type
-- is SR, need to validate if the 'subject_id' is a valid 'incident_id'
-- in cs_incidents_all_b table.
-- Procedure also returns back the sub and obj numbers and JTF names to be
-- used as token values for error messages in subsequent procedures.
-- If a record is not found for the given subject or object type in jtf
-- objects,(most unlikely) an error will be thrown back.
PROCEDURE VALIDATE_LINK_DETAILS (
   P_SUBJECT_ID              IN           NUMBER,
   P_SUBJECT_TYPE            IN           VARCHAR2,
   P_OBJECT_ID               IN           NUMBER,
   P_OBJECT_TYPE             IN           VARCHAR2,
   P_OBJECT_NUMBER           IN           VARCHAR2,
   X_SUBJECT_NUMBER          OUT NOCOPY   VARCHAR2,
   X_OBJECT_NUMBER           OUT NOCOPY   VARCHAR2,
   X_SUBJECT_TYPE_NAME       OUT NOCOPY   VARCHAR2,
   X_OBJECT_TYPE_NAME        OUT NOCOPY   VARCHAR2,
   X_RETURN_STATUS	     OUT NOCOPY   VARCHAR2,
   X_MSG_COUNT		     OUT NOCOPY   NUMBER,
   X_MSG_DATA		     OUT NOCOPY   VARCHAR2 )
IS
   l_api_name                CONSTANT VARCHAR2(30) := 'VALIDATE_LINK_DETAILS';
   l_api_name_full           CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||l_api_name;

   cursor get_jtf_details ( c_object_code   VARCHAR2 ) is
   select select_id, select_name, from_table, name
   from   jtf_objects_vl
   where  object_code = c_object_code;

   l_sub_select_id           varchar2(90);
   l_sub_select_name         varchar2(90);
   l_sub_from_table          varchar2(90);

   -- Defining two sets of identical variables, one to store the subject type
   -- details, and one for the object type details. This is done, so that the
   -- dynamic SQL is executed only if both the subject and object types are
   -- valid JTF Object codes.

   l_obj_select_id           varchar2(90);
   l_obj_select_name         varchar2(90);
   l_obj_from_table          varchar2(90);

   -- variable to store the token value for sub_obj_id
   l_sub_obj_id_token        varchar2(90);

   l_sql_stmnt               varchar2(4000);

   l_count                   number(15);

BEGIN
   -- Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   open  get_jtf_details ( p_subject_type );
   fetch get_jtf_details into
      l_sub_select_id, l_sub_select_name, l_sub_from_table, x_subject_type_name;

   if ( get_jtf_details%notfound ) then
      -- Subject type is not valid. Please specify a valid value from JTF Objects
      -- for Subject type.
      close get_jtf_details;
      FND_MESSAGE.Set_Name('CS', 'CS_SR_LINK_NO_OBJ_JTF_TYPE');
      FND_MESSAGE.Set_Token('API_NAME', l_api_name_full);
      FND_MSG_PUB.Add;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_And_Get(
         p_count => x_msg_count,
         p_data  => x_msg_data);

      RETURN;
   elsif ( l_sub_select_name is null ) then
      close get_jtf_details;
      -- Without the select_name column filled in in jtf_objects_b, the subject number
      -- cannot be determined.
      -- MSG: Object OBJECT_CODE is not fully defined in JTF Objects.
      FND_MESSAGE.Set_Name('CS','CS_SR_LINK_NO_JTF_SEL_NAME');
      FND_MESSAGE.Set_Token('OBJECT_CODE', p_subject_type);
      FND_MESSAGE.Set_Token('API_NAME', l_api_name_full);
      FND_MSG_PUB.Add;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_And_Get(
         p_count => x_msg_count,
         p_data  => x_msg_data);

      RETURN;
   end if;  --  if ( get_jtf_details%notfound )

   close get_jtf_details;

   open get_jtf_details ( p_object_type );
   fetch get_jtf_details into
      l_obj_select_id, l_obj_select_name, l_obj_from_table, x_object_type_name;

   if ( get_jtf_details%notfound ) then
      -- Object type is not valid. Please specify a valid value from JTF Objects
      -- for Object type.
      close get_jtf_details;
      FND_MESSAGE.Set_Name('CS', 'CS_SR_LINK_NO_SUB_JTF_TYPE');
      FND_MESSAGE.Set_Token('API_NAME', l_api_name_full);
      FND_MSG_PUB.Add;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_And_Get(
         p_count => x_msg_count,
         p_data  => x_msg_data);

      RETURN;
   /* For non-validated objects, there won't be any sql
   elsif ( l_obj_select_name is null ) then
      close get_jtf_details;
      -- Without the select_name column filled in in jtf_objects_b, the object number
      -- cannot be determined.
      -- MSG: Object OBJECT_CODE is not fully defined in JTF Objects.
      FND_MESSAGE.Set_Name('CS','CS_SR_LINK_NO_JTF_SEL_NAME');
      FND_MESSAGE.Set_Token('OBJECT_CODE', p_object_type);
      FND_MESSAGE.Set_Token('API_NAME', l_api_name_full);
      FND_MSG_PUB.Add;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_And_Get(
         p_count => x_msg_count,
         p_data  => x_msg_data);

      RETURN;
   */
   end if;    -- if ( get_jtf_details%notfound )

   close get_jtf_details;

   -- validate if the subject id is a valid id in its table; don't need the check
   -- for the number column for the subject details because there is no subject
   -- number

   l_sql_stmnt := 'select max(' || l_sub_select_name || ' ) from ' || l_sub_from_table
                                || ' where ' || l_sub_select_id || ' = :p1 ' ;

   execute immediate l_sql_stmnt into x_subject_number using p_subject_id;

   if ( x_subject_number IS NULL ) then
      -- No record with primary key Subject Id exists in table || l_sub_from_table.
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MESSAGE.Set_Name('CS', 'CS_SR_LINK_INVALID_LINK_CHILD');
      FND_MESSAGE.Set_Token('API_NAME', l_api_name_full);
      FND_MESSAGE.Set_Token('SUB_OBJ_ID', nvl(to_char(p_subject_id) ,'NULL') );
      FND_MESSAGE.Set_Token('SUB_OBJ_TABLE_NAME', l_sub_from_table) ;
      FND_MSG_PUB.Add;

      FND_MSG_PUB.Count_And_Get(
         p_count => x_msg_count,
         p_data  => x_msg_data);

      RETURN;
   end if;

   -- validate if the object id is a valid id in its table; need the check for
   -- the number column as well if passed for the object details

   IF (l_obj_select_name is NOT NULL) THEN
   l_sql_stmnt := 'select max(' || l_obj_select_name || ' ) from ' || l_obj_from_table
		  || ' where ' || l_obj_select_id || ' = :p1 ' ;

   if ( p_object_number IS NOT NULL  AND
	p_object_number <> FND_API.G_MISS_CHAR ) then
      l_sql_stmnt := l_sql_stmnt || ' and ' || l_obj_select_name || ' = :p2 ';
      execute immediate l_sql_stmnt into x_object_number using p_object_id, p_object_number;
      l_sub_obj_id_token := nvl(to_char(p_object_id), 'NULL') || ' - ' ||
		            nvl(p_object_number, 'NULL');
   else
      execute immediate l_sql_stmnt into x_object_number using p_object_id;
      l_sub_obj_id_token := nvl(to_char(p_object_id), 'NULL');
   end if;    -- if ( p_object_number IS NOT NULL

   if ( x_object_number IS NULL ) then
      -- No record with primary key Object Id exists in table || l_obj_from_table.
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MESSAGE.Set_Name('CS', 'CS_SR_LINK_INVALID_LINK_CHILD');
      FND_MESSAGE.Set_Token('SUB_OBJ_ID', l_sub_obj_id_token );
      FND_MESSAGE.Set_Token('SUB_OBJ_TABLE_NAME', l_obj_from_table);
      FND_MESSAGE.Set_Token('API_NAME', l_api_name_full);
      FND_MSG_PUB.Add;

      FND_MSG_PUB.Count_And_Get(
         p_count => x_msg_count,
         p_data  => x_msg_data);

      RETURN;
   end if; -- for x_object_number is null
   ELSE
     x_object_number := p_object_number;
   END IF; -- p_obj_select_name is not null

EXCEPTION
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MESSAGE.SET_NAME ('CS', 'CS_API_SR_UNKNOWN_ERROR');
      FND_MESSAGE.SET_TOKEN ('P_TEXT',l_api_name_full||'-'||SQLERRM);
      FND_MSG_PUB.ADD;
      FND_MSG_PUB.Count_And_Get(
	 p_count => x_msg_count,
	 p_data  => x_msg_data);

END VALIDATE_LINK_DETAILS;

-- Procedure to validate the uniqueness of the link being created.
-- Rule : Two linked objects cannot have more than one link pair between them.
-- Note : Object number is an IN parameter, as sometimes the object_id may be
--        null.
PROCEDURE VALIDATE_LINK_UNIQUENESS (
   P_SUBJECT_ID              IN           NUMBER,
   P_SUBJECT_TYPE            IN           VARCHAR2,
   P_OBJECT_ID               IN           NUMBER,
   P_OBJECT_TYPE             IN           VARCHAR2,
   P_OBJECT_NUMBER           IN           VARCHAR2,
   X_RETURN_STATUS	     OUT NOCOPY   VARCHAR2,
   X_MSG_COUNT		     OUT NOCOPY   NUMBER,
   X_MSG_DATA		     OUT NOCOPY   VARCHAR2 )
IS
   l_api_name                CONSTANT VARCHAR2(30) := 'VALIDATE_LINK_UNIQUENESS';
   l_api_name_full           CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||l_api_name;

   l_dummy                   NUMBER(15) := 0;

BEGIN
   -- Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Perform check for link object uniquenes (only on active links and not the end dated
   -- ones.
   -- Rule : Two linked objects cannot have more than one link pair between them.

   select count(*)
   into   l_dummy
   from   cs_incident_links
   where  subject_id   = p_subject_id
   and    subject_type = p_subject_type
   and    object_id    = p_object_id
   and    object_type  = p_object_type
   and    SYSDATE between nvl(start_date_active   , SYSDATE)
		      and nvl(end_date_active - 1 , SYSDATE);

   if ( l_dummy > 0 ) then
      -- Duplicate link. Link already exists for given object and related object.
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MESSAGE.Set_Name('CS', 'CS_SR_LINK_DUP_LINK');
      FND_MESSAGE.Set_Token('API_NAME', l_api_name_full);
      FND_MSG_PUB.Add;
   end if;

   FND_MSG_PUB.Count_And_Get(
      p_count => x_msg_count,
      p_data  => x_msg_data);

EXCEPTION
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MESSAGE.SET_NAME ('CS', 'CS_API_SR_UNKNOWN_ERROR');
      FND_MESSAGE.SET_TOKEN ('P_TEXT',l_api_name_full||'-'||SQLERRM);
      FND_MSG_PUB.ADD;
      FND_MSG_PUB.Count_And_Get(
	 p_count => x_msg_count,
	 p_data  => x_msg_data);

END VALIDATE_LINK_UNIQUENESS;


-- Procedure to validate if the creation of the link will result in a circular
-- dependency.
-- Rule : Prevent creation of circular dependency regardless of link type.
PROCEDURE VALIDATE_LINK_CIRCULARS (
   P_SUBJECT_ID              IN           NUMBER,
   P_SUBJECT_TYPE            IN           VARCHAR2,
   P_OBJECT_ID               IN           NUMBER,
   P_OBJECT_TYPE             IN           VARCHAR2,
   P_LINK_TYPE_ID            IN           NUMBER,
   P_SUBJECT_NUMBER          IN           VARCHAR2,
   P_OBJECT_NUMBER           IN           VARCHAR2,
   P_SUBJECT_TYPE_NAME       IN           VARCHAR2,
   P_OBJECT_TYPE_NAME        IN           VARCHAR2,
   P_OPERATION_MODE          IN           VARCHAR2,
   X_RETURN_STATUS	     OUT NOCOPY   VARCHAR2,
   X_MSG_COUNT		     OUT NOCOPY   NUMBER,
   X_MSG_DATA		     OUT NOCOPY   VARCHAR2 )
IS
   l_api_name                CONSTANT VARCHAR2(30) := 'VALIDATE_LINK_CIRCULARS';
   l_api_name_full           CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||l_api_name;

   l_dummy                   NUMBER(15) := 0;

   -- Local variable to store values to be use to set message tokens
   l_link_type_name         VARCHAR2(240); -- link name from p_link_type_id

   -- Change is that we now Check for circulars only within the current link type.
   -- add link_type_id as a parameter.

   cursor c1 is
   select object_id
   from   cs_incident_links
   start  with (     subject_id   = p_object_id
                 and subject_type = p_object_type
 		 and link_type_id = p_link_type_id
		 and SYSDATE between nvl(start_date_active, SYSDATE)
				 and nvl(end_date_active,   SYSDATE) )
   connect by  prior object_id          = subject_id
   and         prior object_type        = subject_type
   and         prior link_type_id       = link_type_id
   and         SYSDATE between nvl(start_date_active, SYSDATE)
			   and nvl(end_date_active,   SYSDATE);

   c1rec                        C1%ROWTYPE;

BEGIN
   -- Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Perform check for circular dependency
   -- Rule : Prevent creation of circular dependency
   -- Pseudocode:
   -- 1. Walk the tree starting with the given subject_id; fetch the object_id as nodes
   -- 2. If the passed in object_id, p_object_id is found as a node on the tree, then the
   --    creation of the link will result in a circular link. Stop and return back an
   --    error.
   -- 3. If the passed in object_id, p_object_id, is not found as a node on the tree, then
   --    the creation of the link will **not** result in a circular. Return success.

   open c1;
   loop
      fetch c1 into c1rec;
      exit when c1%NOTFOUND;

      if ( c1rec.object_id = p_subject_id ) then
         -- Creation of link will result in a circular dependency.
	 -- You cannot create a LINK_TYPE link to OBJECT_TYPE - OBJECT_NUM because it will
	 -- result in a circular.

	 -- get the link name to set the message token. Using max to avoid no-data-found
	 -- exception; should never result in a no data found exception though.
	 select max(name)
	 into   l_link_type_name
	 from   cs_sr_link_types_vl
	 where  link_type_id = p_link_type_id;

	 if ( p_operation_mode = 'CREATE' ) then
            FND_MESSAGE.Set_Name('CS', 'CS_SR_LINK_CIRCULAR_LINK');
	    FND_MESSAGE.Set_Token('LINK_TYPE'  , l_link_type_name );
	    FND_MESSAGE.Set_Token('OBJECT_TYPE', p_object_type_name);
	    FND_MESSAGE.Set_Token('OBJECT_NUM' , p_object_number);
            FND_MESSAGE.Set_Token('API_NAME'   , l_api_name_full);
         else
            FND_MESSAGE.Set_Name('CS', 'CS_SR_LINK_CIRCULAR_LINK_UPD');
	    FND_MESSAGE.Set_Token('LINK_TYPE'  , l_link_type_name );
	    FND_MESSAGE.Set_Token('OBJECT_TYPE', p_object_type_name);
	    FND_MESSAGE.Set_Token('OBJECT_NUM' , p_object_number);
	    FND_MESSAGE.Set_Token('API_NAME'   , l_api_name_full);
         end if;

         FND_MSG_PUB.Add;
         x_return_status := FND_API.G_RET_STS_ERROR;
	 exit;
      end if;
   end loop;

   close c1;

   FND_MSG_PUB.Count_And_Get(
      p_count => x_msg_count,
      p_data  => x_msg_data);


EXCEPTION
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MESSAGE.SET_NAME ('CS', 'CS_API_SR_UNKNOWN_ERROR');
      FND_MESSAGE.SET_TOKEN ('P_TEXT',l_api_name_full||'-'||SQLERRM);
      FND_MSG_PUB.ADD;
      FND_MSG_PUB.Count_And_Get(
	 p_count => x_msg_count,
	 p_data  => x_msg_data);

END VALIDATE_LINK_CIRCULARS;

-- Procedure to validate that a duplicate link can have exactly only one
-- original. For eg. if SR1 is duplicate of SR2, SR1 cannot be a duplicate
-- of SR3 as well. Rather SR3 should be created as a duplicate of SR2.
-- Rule : A duplicate object must have exactly 1 original.
PROCEDURE VALIDATE_LINK_DUPLICATES (
   P_SUBJECT_ID              IN           NUMBER,
   P_SUBJECT_TYPE            IN           VARCHAR2,
   P_OBJECT_ID               IN           NUMBER,
   P_OBJECT_TYPE             IN           VARCHAR2,
   P_LINK_TYPE_ID            IN           NUMBER,
   P_SUBJECT_NUMBER          IN           VARCHAR2,
   P_OBJECT_NUMBER           IN           VARCHAR2,
   P_SUBJECT_TYPE_NAME       IN           VARCHAR2,
   P_OBJECT_TYPE_NAME        IN           VARCHAR2,
   X_RETURN_STATUS	     OUT NOCOPY   VARCHAR2,
   X_MSG_COUNT		     OUT NOCOPY   NUMBER,
   X_MSG_DATA		     OUT NOCOPY   VARCHAR2 )
IS
   l_api_name                CONSTANT VARCHAR2(30) := 'VALIDATE_LINK_DUPLICATES';
   l_api_name_full           CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||l_api_name;

   l_dummy                   NUMBER(15) := 0;

   -- Local variable to store values to be use to set message tokens
   l_object_type_name           VARCHAR2(240);
   l_new_link_type_name         VARCHAR2(240); -- link name from p_link_type_id
   l_existing_link_type_name    VARCHAR2(240); -- link name for c2rec.link_type_id

   -- This cursor is used to implement Rule 1. ie. A link cannot be created to a
   -- business object 'A', if 'A' is already a 'Duplicate Of' another business
   -- object.
   -- Cursor is called twice, once for the new Subject and once for the new object.
   -- The reason being, the message token should be set to either the new subject or
   -- the new object, depending on which one has the existing dup of link.
   cursor c1 (c_sub_obj_id      NUMBER,
	      c_sub_obj_type    VARCHAR2 ) is
   select object_type, object_number
   from   cs_incident_links
   where  subject_id   = c_sub_obj_id
   and    subject_type = c_sub_obj_type
   and    link_type_id = 3     -- Duplicate Of
   and    SYSDATE between nvl(start_date_active, SYSDATE)
		      and nvl(end_date_active - 1,   SYSDATE);

   c1rec     c1%rowtype;

   -- This cursor is used to implement Rule 2. ie. A business object 'A' cannot be made
   -- a 'Duplicate Of' another business object, if 'A' already has either a Causal link
   -- or another Orig. For/Dup link link associated to it.
   -- If the link 'SR1 Dup Of SR2' is attempted to be created, then SR1 should not have
   -- existing Causal, Orig or Dup links.
   -- In this case the new subject_id and type are passed to the cursor.
   -- If the link 'SR1 Org For SR2' is attempted to be created, then SR2 should not have
   -- existing Causal, Orig or Dup links.
   -- In this case the new object_id and type are passed to the cursor.
   cursor c2 (c_sub_obj_id      NUMBER,
	      c_sub_obj_type    VARCHAR2 ) is
   select link_type_id
   from   cs_incident_links
   where  subject_id    = c_sub_obj_id
   and    subject_type  = c_sub_obj_type
   and    link_type_id in (1, 2, 3, 4) --causals and Orig/Dup link type ids.
   and    SYSDATE between nvl(start_date_active, SYSDATE)
		      and nvl(end_date_active - 1,   SYSDATE);

   c2rec     c2%rowtype;

   -- cursor to get the link name for p_link_type_id and c2rec.link_type_id
   cursor get_link_name ( c_link_type_id     NUMBER) is
   select name
   from   cs_sr_link_types_vl
   where  link_type_id = c_link_type_id;

BEGIN
   -- Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   open c1 ( c_sub_obj_id    => p_subject_id,
	     c_sub_obj_type  => p_subject_type);
   fetch c1 into c1rec;
   close c1;

   if ( c1rec.object_type IS NOT NULL ) then
      -- The  subject of this link is  already a duplicate . Any other link cannot be created.
      -- MSG: You cannot add new relationships to duplicate SUB_OBJ_TYPE - SUB_OBJ_NUM. Please
      --      add any new relationships to the original REL_OBJ_TYPE - REL_OBJ_NUM.
      -- API validation error (API_NAME)

      -- get the related object name to set the message token. Using max to avoid
      -- no-data-found exception; should never result in a no data found exception
      -- though.
      select name
      into   l_object_type_name
      from   jtf_objects_vl
      where  object_code = c1rec.object_type;

      FND_MESSAGE.Set_Name('CS', 'CS_SR_LINK_ORIGINAL_EXISTS');
      FND_MESSAGE.Set_Token('SUB_OBJ_TYPE' , p_subject_type_name);
      FND_MESSAGE.Set_Token('SUB_OBJ_NUM'  , p_subject_number);
      FND_MESSAGE.Set_Token('REL_OBJ_TYPE' , l_object_type_name);
      FND_MESSAGE.Set_Token('REL_OBJ_NUM'  , c1rec.object_number);
      FND_MESSAGE.Set_Token('API_NAME', l_api_name_full);
      FND_MSG_PUB.Add;
      x_return_status := FND_API.G_RET_STS_ERROR;
   else
      open c1 ( c_sub_obj_id    => p_object_id,
	        c_sub_obj_type  => p_object_type );
      fetch c1 into c1rec;
      close c1;

      if ( c1rec.object_type IS NOT NULL ) then
         -- This object of this link is already a duplicate. Any other link cannot be created.
         -- MSG: You cannot add new relationships to duplicate SUB_OBJ_TYPE - SUB_OBJ_NUM. Please
         --      add any new relationships to the original REL_OBJ_TYPE - REL_OBJ_NUM.
         -- API validation error (API_NAME)

         -- get the related object name to set the message token. Using max to avoid
         -- no-data-found exception; should never result in a no data found exception
         -- though.
         select name
         into   l_object_type_name
         from   jtf_objects_vl
         where  object_code = c1rec.object_type;

         FND_MESSAGE.Set_Name('CS', 'CS_SR_LINK_ORIGINAL_EXISTS');
         FND_MESSAGE.Set_Token('SUB_OBJ_TYPE' , p_object_type_name);
         FND_MESSAGE.Set_Token('SUB_OBJ_NUM'  , p_object_number);
         FND_MESSAGE.Set_Token('REL_OBJ_TYPE' , l_object_type_name);
         FND_MESSAGE.Set_Token('REL_OBJ_NUM'  , c1rec.object_number);
         FND_MESSAGE.Set_Token('API_NAME', l_api_name_full);
         FND_MSG_PUB.Add;
         x_return_status := FND_API.G_RET_STS_ERROR;
      end if;
   end if;

   if ( x_return_status = FND_API.G_RET_STS_SUCCESS ) then
      if p_link_type_id = 3 then           -- Creating a 'Duplicate Of' link
         open c2 ( c_sub_obj_id    => p_subject_id,
	           c_sub_obj_type  => p_subject_type );
         fetch c2 into c2rec;
         close c2;

         if ( c2rec.link_type_id IS NOT NULL ) then
            -- This subject of this link has existing causal, orig or dup links already.
	    -- MSG: You cannot create a LINK_TYPE link to SUB_OBJ_TYPE - SUB_OBJ_NUM
	    --      because it has an existing EXISTING_LINK_TYPE link.
	    -- API validation error (API_NAME)

	    -- get the link name to set the message token. Using max to avoid no-data-found
	    -- exception; should never result in a no data found exception though.
	    select max(name)
	    into   l_new_link_type_name
	    from   cs_sr_link_types_vl
	    where  link_type_id = p_link_type_id;

	    select max(name)
	    into   l_existing_link_type_name
	    from   cs_sr_link_types_vl
	    where  link_type_id = c2rec.link_type_id;

            FND_MESSAGE.Set_Name('CS', 'CS_SR_LINK_DUP_ORG_NOT_ALLOW');
            FND_MESSAGE.Set_Token('LINK_TYPE'  , l_new_link_type_name);
            FND_MESSAGE.Set_Token('SUB_OBJ_TYPE', p_subject_type_name);
            FND_MESSAGE.Set_Token('SUB_OBJ_NUM' , p_subject_number);
            FND_MESSAGE.Set_Token('EXISTING_LINK_TYPE', l_existing_link_type_name);
            FND_MESSAGE.Set_Token('API_NAME', l_api_name_full);
            FND_MSG_PUB.Add;
            x_return_status := FND_API.G_RET_STS_ERROR;
         end if;
      elsif p_link_type_id = 4 then -- Creating a 'Original For' link
         open c2 ( c_sub_obj_id    => p_object_id,
	           c_sub_obj_type  => p_object_type );
         fetch c2 into c2rec;
         close c2;

         if ( c2rec.link_type_id IS NOT NULL ) then
            -- The object of this Link has existing causal, orig or dup links already.
	    -- MSG: You cannot create a LINK_TYPE link to SUB_OBJ_TYPE - SUB_OBJ_NUM
	    --      because it has an existing EXISTING_LINK_TYPE link.
	    -- API validation error (API_NAME)

	    -- get the link name to set the message token. Using max to avoid no-data-found
	    -- exception; should never result in a no data found exception though.
	    select max(name)
	    into   l_new_link_type_name
	    from   cs_sr_link_types_vl
	    where  link_type_id = p_link_type_id;

	    select max(name)
	    into   l_existing_link_type_name
	    from   cs_sr_link_types_vl
	    where  link_type_id = c2rec.link_type_id;

            FND_MESSAGE.Set_Name('CS', 'CS_SR_LINK_DUP_ORG_NOT_ALLOW');
            FND_MESSAGE.Set_Token('LINK_TYPE'          , l_new_link_type_name);
            FND_MESSAGE.Set_Token('SUB_OBJ_TYPE'       , p_object_type_name);
            FND_MESSAGE.Set_Token('SUB_OBJ_NUM'        , p_object_number);
            FND_MESSAGE.Set_Token('EXISTING_LINK_TYPE' , l_existing_link_type_name );
            FND_MESSAGE.Set_Token('API_NAME', l_api_name_full);
            FND_MSG_PUB.Add;
            x_return_status := FND_API.G_RET_STS_ERROR;
         end if;
      end if;    -- if p_link_type_id = 3 then
   end if;    -- if ( x_return_status = FND_API.G_RET_STS_SUCCESS ) then

   FND_MSG_PUB.Count_And_Get(
      p_count => x_msg_count,
      p_data  => x_msg_data);

EXCEPTION
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MESSAGE.SET_NAME ('CS', 'CS_API_SR_UNKNOWN_ERROR');
      FND_MESSAGE.SET_TOKEN ('P_TEXT',l_api_name_full||'-'||SQLERRM);
      FND_MSG_PUB.ADD;
      FND_MSG_PUB.Count_And_Get(
	 p_count => x_msg_count,
	 p_data  => x_msg_data);

END VALIDATE_LINK_DUPLICATES;

-- Validation procedure to implement Service Security introduced in R11.5.10
-- Procedure to validate if the responsibilty creating / updating the link has
-- access to the subject and/or object if they are service requests.
PROCEDURE VALIDATE_SR_SEC_ACCESS (
   P_INCIDENT_ID       IN           NUMBER,
   X_RETURN_STATUS     OUT NOCOPY   VARCHAR2,
   X_MSG_COUNT         OUT NOCOPY   NUMBER,
   X_MSG_DATA          OUT NOCOPY   VARCHAR2 )
IS
   l_api_name          CONSTANT VARCHAR2(30) := 'VALIDATE_SR_SEC_ACCESS';
   l_api_name_full     CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||l_api_name;

   l_dummy                   NUMBER(15) := 0;

   -- Cursor to get the responsibility name to be displayed in the error
   -- message
   cursor get_resp_name is
   select responsibility_name
   from   fnd_responsibility_vl
   where  responsibility_id = sys_context('FND', 'RESP_ID')
   and    application_id    = sys_context('FND', 'RESP_APPL_ID');

   l_resp_name          VARCHAR2(240);

   -- Cursor to get the incident number of the sr to be displayed in the error
   -- message
   cursor get_sr_number is
   select incident_number
   from   cs_incidents_all_b
   where  incident_id = p_incident_id;

   l_sr_number          VARCHAR2(90);

BEGIN
   -- Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   select count(*)
   into   l_dummy
   from   cs_incidents_b_sec
   where  incident_id = p_incident_id;

   if ( l_dummy <= 0 ) then
      -- new message for 11.5.10
      -- Responsibility RESP_NAME does not have access to service
      -- request SR_NUMBER.
      --
      -- cursor to get the responsibility name for the message
      open  get_resp_name;
      fetch get_resp_name into l_resp_name;
      close get_resp_name;

      -- cursor to get the sr number for the message
      open  get_sr_number;
      fetch get_sr_number into l_sr_number;
      close get_sr_number;

      x_return_status := FND_API.G_RET_STS_ERROR;
      fnd_message.set_name ('CS', 'CS_SR_NO_ACCESS');
      fnd_message.set_token('RESP_NAME', l_resp_name );
      fnd_message.set_token('SR_NUMBER', l_sr_number );
      fnd_message.set_token('API_NAME', l_api_name_full);
      fnd_msg_pub.add;
   end if;

   FND_MSG_PUB.Count_And_Get(
      p_count => x_msg_count,
      p_data  => x_msg_data);

EXCEPTION
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MESSAGE.SET_NAME ('CS', 'CS_API_SR_UNKNOWN_ERROR');
      FND_MESSAGE.SET_TOKEN ('P_TEXT',l_api_name_full||'-'||SQLERRM);
      FND_MSG_PUB.ADD;
      FND_MSG_PUB.Count_And_Get(
	 p_count => x_msg_count,
	 p_data  => x_msg_data);

END VALIDATE_SR_SEC_ACCESS;


END CS_INCIDENTLINKS_UTIL;

/
