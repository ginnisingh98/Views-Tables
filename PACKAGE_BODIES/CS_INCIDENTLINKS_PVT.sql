--------------------------------------------------------
--  DDL for Package Body CS_INCIDENTLINKS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_INCIDENTLINKS_PVT" AS
/* $Header: csvsrlb.pls 120.4 2006/06/08 00:05:57 klou noship $ */

G_PKG_NAME	    CONSTANT VARCHAR2(30) := 'CS_INCIDENTLINKS_PVT';

-- The following variable will denote if a create link or an update link operation is being
-- performed.
-- Based on this the operation_mode of the validate_circular link proc. will be set and
-- passed. The validate circular proc. sets different error messages based on what operation
-- is being performed.
-- This will be set to 'UPDATE' at the beginning of the update proc. and re-set to 'CREATE'
-- after the call to the validate circular proc. Since this is being used primarily for the
-- circular message, resetting it after the call to the validate circular is fine. If more
-- use of this variable is needed, more logic will be needed in re-setting the value to
-- 'CREATE'
G_OPERATION_MODE             VARCHAR2(30) := 'CREATE';

-- Existing procedure. Existing calls to this API can remain, but is recommended to
-- invoke the new overloaded procedure that accepts a record structure.

-- The four parameters that are obsoleted for 1159 l_from_incident_id,
-- l_to_incident_id, l_from_incident_number and  l_to_incident_number are accepted
-- as IN parameter in this procedure for backward compatability. It is not passed
-- to the overloade procedure.
PROCEDURE CREATE_INCIDENTLINK (
   P_API_VERSION		IN     NUMBER,
   P_INIT_MSG_LIST     	        IN     VARCHAR2,
   P_COMMIT     		IN     VARCHAR2,
   P_VALIDATION_LEVEL  	        IN     NUMBER,
   P_RESP_APPL_ID		IN     NUMBER,    -- not used
   P_RESP_ID		        IN     NUMBER,    -- not used
   P_USER_ID		        IN     NUMBER,    -- not used
   P_LOGIN_ID		        IN     NUMBER,
   P_ORG_ID		        IN     NUMBER,    -- not used
   P_LINK_ID                    IN     NUMBER,    -- new for 1159
   P_SUBJECT_ID                 IN     NUMBER,    -- new for 1159
   P_SUBJECT_TYPE               IN     VARCHAR2,  -- new for 1159
   P_OBJECT_ID                  IN     NUMBER,    -- new for 1159
   P_OBJECT_NUMBER              IN     VARCHAR2,  -- new for 1159
   P_OBJECT_TYPE                IN     VARCHAR2,  -- new for 1159
   P_LINK_TYPE_ID		IN     NUMBER,    -- new for 1159
   P_LINK_TYPE		        IN     VARCHAR2,  -- existed prior to 1159. This is made
						  -- non mandatory in the spec in 1159.
   P_REQUEST_ID                 IN     NUMBER,    -- new for 1159
   P_PROGRAM_APPLICATION_ID     IN     NUMBER,    -- new for 1159
   P_PROGRAM_ID                 IN     NUMBER,    -- new for 1159
   P_PROGRAM_UPDATE_DATE        IN     DATE,      -- new for 1159
   P_FROM_INCIDENT_ID	        IN     NUMBER,    -- obsoleted for 1159
   P_TO_INCIDENT_ID	        IN     NUMBER,    -- obsoleted for 1159
   P_LINK_SEGMENT1		IN     VARCHAR2,
   P_LINK_SEGMENT2		IN     VARCHAR2,
   P_LINK_SEGMENT3		IN     VARCHAR2,
   P_LINK_SEGMENT4		IN     VARCHAR2,
   P_LINK_SEGMENT5		IN     VARCHAR2,
   P_LINK_SEGMENT6		IN     VARCHAR2,
   P_LINK_SEGMENT7		IN     VARCHAR2,
   P_LINK_SEGMENT8		IN     VARCHAR2,
   P_LINK_SEGMENT9		IN     VARCHAR2,
   P_LINK_SEGMENT10	        IN     VARCHAR2,
   P_LINK_SEGMENT11	        IN     VARCHAR2,  -- new for 1159
   P_LINK_SEGMENT12	        IN     VARCHAR2,  -- new for 1159
   P_LINK_SEGMENT13	        IN     VARCHAR2,  -- new for 1159
   P_LINK_SEGMENT14	        IN     VARCHAR2,  -- new for 1159
   P_LINK_SEGMENT15	        IN     VARCHAR2,  -- new for 1159
   P_LINK_CONTEXT		IN     VARCHAR2,
   X_RETURN_STATUS	        OUT NOCOPY   VARCHAR2,
   X_MSG_COUNT		        OUT NOCOPY   NUMBER,
   X_MSG_DATA		        OUT NOCOPY   VARCHAR2,
   X_OBJECT_VERSION_NUMBER      OUT NOCOPY   NUMBER, -- new for 1159
   X_RECIPROCAL_LINK_ID         OUT NOCOPY   NUMBER, -- new for 1159
   X_LINK_ID			OUT NOCOPY   NUMBER )
IS
   l_api_name                  CONSTANT VARCHAR2(30) := 'CREATE_INCIDENTLINK';
   l_api_name_full             CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||l_api_name;

   -- The following is the newly created (for 1159) record structure that will be
   -- populated and passed to the overloaded create procedure.
   l_link_rec                   CS_INCIDENT_LINK_REC_TYPE;


BEGIN

   -- Populate the record structure before calling the overloaded procedure.
   l_link_rec.LINK_ID                := p_link_id;       -- new for 1159
   l_link_rec.SUBJECT_ID             := p_subject_id;    -- new for 1159
   l_link_rec.SUBJECT_TYPE           := p_subject_type;  -- new for 1159
   l_link_rec.OBJECT_ID              := p_object_id;     -- new for 1159
   l_link_rec.OBJECT_NUMBER          := p_object_number; -- new for 1159
   l_link_rec.OBJECT_TYPE            := p_object_type;   -- new for 1159
   l_link_rec.LINK_TYPE_ID           := p_link_type_id;  -- new for 1159
   l_link_rec.LINK_TYPE		     := p_link_type;     -- no change
   l_link_rec.REQUEST_ID             := p_request_id;    -- new for 1159
   l_link_rec.PROGRAM_APPLICATION_ID := p_program_application_id; -- new for 1159
   l_link_rec.PROGRAM_ID             := p_program_id;    -- new for 1159
   l_link_rec.PROGRAM_UPDATE_DATE    := p_program_update_date;    -- new for 1159
   l_link_rec.LINK_SEGMENT1	     := p_link_segment1;
   l_link_rec.LINK_SEGMENT2	     := p_link_segment2;
   l_link_rec.LINK_SEGMENT3	     := p_link_segment3;
   l_link_rec.LINK_SEGMENT4	     := p_link_segment4;
   l_link_rec.LINK_SEGMENT5	     := p_link_segment5;
   l_link_rec.LINK_SEGMENT6	     := p_link_segment6;
   l_link_rec.LINK_SEGMENT7	     := p_link_segment7;
   l_link_rec.LINK_SEGMENT8	     := p_link_segment8;
   l_link_rec.LINK_SEGMENT9	     := p_link_segment9;
   l_link_rec.LINK_SEGMENT10	     := p_link_segment10;
   l_link_rec.LINK_SEGMENT11	     := p_link_segment11; -- new for 1159
   l_link_rec.LINK_SEGMENT12	     := p_link_segment12; -- new for 1159
   l_link_rec.LINK_SEGMENT13	     := p_link_segment13; -- new for 1159
   l_link_rec.LINK_SEGMENT14	     := p_link_segment14; -- new for 1159
   l_link_rec.LINK_SEGMENT15	     := p_link_segment15; -- new for 1159
   l_link_rec.LINK_CONTEXT           := p_link_context;

   CREATE_INCIDENTLINK (
      P_API_VERSION		=> p_api_version,
      P_INIT_MSG_LIST     	=> p_init_msg_list,
      P_COMMIT     		=> p_commit,
      P_VALIDATION_LEVEL  	=> p_validation_level,
      P_RESP_APPL_ID		=> p_resp_appl_id, -- not used
      P_RESP_ID		        => p_resp_id,      -- not used
      P_USER_ID		        => p_user_id,      -- not used
      P_LOGIN_ID		=> p_login_id,
      P_ORG_ID		        => p_org_id,       -- not used
      P_LINK_REC                => L_LINK_REC,
      X_RETURN_STATUS	        => x_return_status,
      X_MSG_COUNT		=> x_msg_count,
      X_MSG_DATA		=> x_msg_data,
      X_OBJECT_VERSION_NUMBER   => x_object_version_number,
      X_RECIPROCAL_LINK_ID      => x_reciprocal_link_id,
      X_LINK_ID			=> x_link_id );

EXCEPTION
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MESSAGE.SET_NAME ('CS', 'CS_API_SR_UNKNOWN_ERROR');
      FND_MESSAGE.SET_TOKEN ('P_TEXT',l_api_name_full||'-'||SQLERRM);
      FND_MSG_PUB.ADD;
      FND_MSG_PUB.Count_And_Get(
	 p_count => x_msg_count,
	 p_data  => x_msg_data);

END CREATE_INCIDENTLINK;

-- Overloaded procedure (new for 1159) that accepts a record structure.
-- Invoking programs can use either one of the procedures.

--Seeded link types and their ids.
--ID NAME
---- -------------
--1  ROOT CAUSE OF
--2  CAUSED BY
--3  DUPLICATE OF
--4  ORIGINAL FOR
--5  REFERENCE FOR
--6  REFERS TO

PROCEDURE CREATE_INCIDENTLINK (
   P_API_VERSION		IN     NUMBER,
   P_INIT_MSG_LIST     	        IN     VARCHAR2,
   P_COMMIT     		IN     VARCHAR2,
   P_VALIDATION_LEVEL  	        IN     NUMBER,
   P_RESP_APPL_ID		IN     NUMBER, -- not used
   P_RESP_ID		        IN     NUMBER, -- not used
   P_USER_ID		        IN     NUMBER, -- not used
   P_LOGIN_ID		        IN     NUMBER,
   P_ORG_ID		        IN     NUMBER, -- not used
   P_LINK_REC                   IN     CS_INCIDENT_LINK_REC_TYPE,
   X_RETURN_STATUS	        OUT NOCOPY   VARCHAR2,
   X_MSG_COUNT		        OUT NOCOPY   NUMBER,
   X_MSG_DATA		        OUT NOCOPY   VARCHAR2,
   X_OBJECT_VERSION_NUMBER      OUT NOCOPY   NUMBER,
   X_RECIPROCAL_LINK_ID         OUT NOCOPY   NUMBER,
   X_LINK_ID			OUT NOCOPY   NUMBER )
IS
   l_api_name                  CONSTANT VARCHAR2(30) := 'CREATE_INCIDENTLINK_1';
   l_api_name_full             CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||l_api_name;

   -- Changed due to bugs 2972584 and 2972611
   -- Commented out because this procedure should be allowed to be called with both the versions 1.2 and 2,0
   -- l_api_version               CONSTANT NUMBER := 2.0;

   -- Variable to be used for version compatibility call, introduced for bugs 2972584 and 2972611
   l_invoked_version       NUMBER;

   l_test	               CHAR(1);

   -- Local variable to store the id of the link to be created. If passed in and is already
   -- used, then return error, else use it. If not passed, get the id from the sequence
   l_link_id                   NUMBER(15);
   l_count                     NUMBER(15);

   -- The l_reciprocal_link_type_id will be used as the link_type_id while creating the
   -- reciprocal link.
   l_reciprocal_link_type_id   NUMBER(15);

   l_select_id                 VARCHAR2(30);
   l_select_name               VARCHAR2(240);
   l_from_table                VARCHAR2(240);

   -- Local variables to be used to get the subject and object number from procedure
   -- validate_link_details
   lx_subject_number           VARCHAR2(90);
   lx_object_number            VARCHAR2(90);
   lx_subject_type_name        VARCHAR2(90);
   lx_object_type_name         VARCHAR2(90);

   -- local variables for the Business events OUT parameters; Using local variables for
   -- the standard out params, return_status, msg_count and msg_data because, if the
   -- BES API return back a failure status, it means only that the BES raise event has
   -- failed, and has nothing to do with the creation of the link.

   -- Link Rec. to store the reciprocal link details to be passed to the BES wrapper to
   -- raise the event for the creation of the reciprocal link
   l_link_rec                  CS_INCIDENT_LINK_REC_TYPE;
   lx_wf_process_id            NUMBER; -- not used in links BES, but in calls to BES from
				       -- the SR API, this is used to stamp the WF process
				       -- id in the SR Header table.
   lx_return_status            VARCHAR2(3);
   lx_msg_count                NUMBER;
   lx_msg_data                 VARCHAR2(4000);

   -- For bugs 2972584 and 2972611
   -- Variables needed to store the values of the old columns
   l_from_incident_id      number;
   l_from_incident_number  varchar2(70);
   l_link_type             varchar2(30);
   l_to_incident_id        number;
   l_to_incident_number    varchar2(70);

   -- For bugs 2972584 and 2972611
   -- Record type variable to store the ext link details.
   l_links_ext_rec		CS_INCIDENTLINKS_PVT.CS_INCIDENT_LINK_EXT_REC_TYPE;

   -- For bugs 2972584 and 2972611
   -- Record type variable to store the values that will be inserted into the cs_incident_links table
   l_link_int_rec		CS_INCIDENT_LINK_REC_TYPE;

   --Added for call to SR Child Audit API after creation of incident link --anmukher --09/12/03
   lx_audit_id			NUMBER;

BEGIN
   -- Standard start of API savepoint
   SAVEPOINT Create_IncidentLink_PVT;

   -- Initialize message list if p_init_msg_list is set to TRUE
   IF FND_API.To_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.Initialize;
   END IF;

   -- Allow this API to be called with both version numbers, 1.2 and 2.0,
   -- introduced for bugs 2972584 and 2972611
   IF p_api_version = 1.2 THEN
   	  l_invoked_version := 1.2;
   ELSIF p_api_version = 2.0 THEN
      l_invoked_version := 2.0;
   END IF;

   -- Standard call to check for call compatibility
   IF NOT FND_API.Compatible_API_Call(l_invoked_version, p_api_version,
						l_api_name, G_PKG_NAME) THEN
      FND_MSG_PUB.Count_And_Get(
	 p_count => x_msg_count,
	 p_data  => x_msg_data );

      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- ----------------------------------------------------------------------
   -- Apply parameter validations and business-rule validation to all passed
   -- parameters if validation level is set.
   -- ----------------------------------------------------------------------
   -- Check if the passed in link id is already used.
   if ( p_link_rec.link_id <> FND_API.G_MISS_NUM and
        p_link_rec.link_id IS NOT NULL ) then

      select count(*)
      into   l_count
      from   cs_incident_links
      where  link_id = p_link_rec.link_id;

      if ( l_count > 0 ) then
         -- link_id is already used. return error.
         x_return_status := FND_API.G_RET_STS_ERROR;
         CS_SERVICEREQUEST_UTIL.Add_Invalid_Argument_Msg(
            p_token_an    => l_api_name_full,
            p_token_v     => p_link_rec.link_id,
            p_token_p     => 'link_id' );

         RAISE FND_API.G_EXC_ERROR;
      else
         l_link_id := p_link_rec.link_id;
      end if;
   else
      select cs_incident_links_s.nextval
      into   l_link_id
      from   dual;
   end if;

   IF (p_validation_level > FND_API.G_VALID_LEVEL_NONE) THEN
      --
      -- Validate the user and login id's
      --
      CS_ServiceRequest_UTIL.Validate_Who_Info (
         p_api_name             => l_api_name_full,
         p_parameter_name_usr   => 'p_user_id',
         p_parameter_name_login => 'p_login_id',
         p_user_id              => p_user_id,
         p_login_id             => p_login_id,
         x_return_status        => x_return_status );

      IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
         FND_MSG_PUB.Count_And_Get(
	    p_count => x_msg_count,
	    p_data  => x_msg_data );
         RAISE FND_API.G_EXC_ERROR;
      END IF;

      -- Sanity validation
      -- Check if the link type passed is valid
      CS_INCIDENTLINKS_UTIL.VALIDATE_LINK_TYPE (
         P_LINK_TYPE_ID            => p_link_rec.link_type_id,
         X_RETURN_STATUS           => x_return_status,
         X_MSG_COUNT               => x_msg_count,
         X_MSG_DATA                => x_msg_data );

      if ( x_return_status <> FND_API.G_RET_STS_SUCCESS ) then
	 -- Specified link type is not valid.
	 RAISE FND_API.G_EXC_ERROR;
      end if;

      -- Business validations.
      -- Perform check for valid objects
      -- Rule : A link instance should have a valid subject type, object type and link
      --        type combination.
      CS_INCIDENTLINKS_UTIL.VALIDATE_LINK_SUB_OBJ_TYPE (
         P_SUBJECT_TYPE            => p_link_rec.subject_type,
         P_OBJECT_TYPE             => p_link_rec.object_type,
         P_LINK_TYPE_ID            => p_link_rec.link_type_id,
         X_RETURN_STATUS           => x_return_status,
         X_MSG_COUNT               => x_msg_count,
         X_MSG_DATA                => x_msg_data ) ;

      if ( x_return_status <> FND_API.G_RET_STS_SUCCESS ) then
	 -- Valid objects do not exist for the given Object, Related Object and Link
	 -- type combination. Please define a valid object for this combination.
	 RAISE FND_API.G_EXC_ERROR;
      end if;

      /**********************************
      -- Check if parameters passed are valid
      -- 1. Check if subject and object types are valid in JTF Objects
      -- 2. Check if subject and object ids are valid in their schemas
      -- 3. Check if object number is valid in its schema
      -- 4. Return back the sub and obj number, and the sub and obj
      --    type names for error messaging in circular checks
      ***********************************/

      -- Check if subject and object are the same.
      IF ((p_link_rec.subject_id = p_link_rec.object_id) AND
          (p_link_rec.subject_type = p_link_rec.object_type)) THEN

          FND_MESSAGE.Set_Name('CS', 'CS_SR_SAME_SUBJECT_OBJECT');
          FND_MESSAGE.Set_Token('API_NAME', l_api_name_full);
          FND_MSG_PUB.Add;

          FND_MSG_PUB.Count_And_Get(
            p_count => x_msg_count,
            p_data  => x_msg_data);

          RAISE  FND_API.G_EXC_ERROR;
      END IF;


      CS_INCIDENTLINKS_UTIL.VALIDATE_LINK_DETAILS (
           P_SUBJECT_ID              => p_link_rec.subject_id,
           P_SUBJECT_TYPE            => p_link_rec.subject_type,
           P_OBJECT_ID               => p_link_rec.object_id,
           P_OBJECT_TYPE             => p_link_rec.object_type,
           P_OBJECT_NUMBER           => p_link_rec.object_number,
           X_SUBJECT_NUMBER          => lx_subject_number,
           X_OBJECT_NUMBER           => lx_object_number,
           X_SUBJECT_TYPE_NAME       => lx_subject_type_name,
           X_OBJECT_TYPE_NAME        => lx_object_type_name,
           X_RETURN_STATUS           => x_return_status,
           X_MSG_COUNT               => x_msg_count,
           X_MSG_DATA                => x_msg_data );

        if ( x_return_status <> FND_API.G_RET_STS_SUCCESS ) then
	   -- Link details are invalid.
          RAISE FND_API.G_EXC_ERROR;
        end if; -- if ( x_return_status <> FND_API.G_RET_STS_SUCCESS )


      -- For bugs 2972584 and 2972611
      -- Perform the following validation only if the invoked version is 2.0 (not 1.2)
      IF (l_invoked_version >= 2.0) THEN

	 -- Service security implementation for Create link
         -- Included check for Service Security introduced in R11.5.10.
         -- The validation is to make sure that the responsibility creating
         -- the link, has access to the subject and/or object if they are
         -- service requests
         if ( p_link_rec.subject_type = 'SR' ) then
	    cs_incidentlinks_util.validate_sr_sec_access (
	       p_incident_id        => p_link_rec.subject_id,
	       x_return_status      => x_return_status,
               x_msg_count          => x_msg_count,
               x_msg_data           => x_msg_data );

            if ( x_return_status <> FND_API.G_RET_STS_SUCCESS ) then
               -- Responsibility RESP_NAME does not have access to service
               -- request SR_NUMBER.
               RAISE FND_API.G_EXC_ERROR;
            end if;
         end if;

         if ( p_link_rec.object_type = 'SR' ) then
            cs_incidentlinks_util.validate_sr_sec_access (
               p_incident_id        => p_link_rec.object_id,
               x_return_status      => x_return_status,
               x_msg_count          => x_msg_count,
               x_msg_data           => x_msg_data );
            if ( x_return_status <> FND_API.G_RET_STS_SUCCESS ) then
               -- Responsibility RESP_NAME does not have access to service
               -- request SR_NUMBER.
               RAISE FND_API.G_EXC_ERROR;
            end if;
         end if;

	 -- END OF SECURITY ACCESS CHECK FOR R11.5.10

    	-- Perform check for link object uniquenes
        -- Rule : Two linked objects cannot have more than one link pair between them.
        CS_INCIDENTLINKS_UTIL.VALIDATE_LINK_UNIQUENESS (
          P_SUBJECT_ID              => p_link_rec.subject_id,
          P_SUBJECT_TYPE            => p_link_rec.subject_type,
          P_OBJECT_ID               => p_link_rec.object_id,
          P_OBJECT_TYPE             => p_link_rec.object_type,
          P_OBJECT_NUMBER           => p_link_rec.object_number,
          X_RETURN_STATUS           => x_return_status,
          X_MSG_COUNT               => x_msg_count,
          X_MSG_DATA                => x_msg_data );

        if ( x_return_status <> FND_API.G_RET_STS_SUCCESS ) then
    	  -- Duplicate link. Link already exists for given object and related object.
	      RAISE FND_API.G_EXC_ERROR;
        end if; -- if ( x_return_status <> FND_API.G_RET_STS_SUCCESS )

      END IF; -- if (l_invoked_version >= 2.0)


      -- For bugs 2972584 and 2972611
      -- Perform the following validation only if the invoked version is >= 2.0
      IF (l_invoked_version >= 2.0) THEN

        -- Perform check for 'Duplicate Of' link types.
        -- Rule: 1> A link cannot be created to a business object 'A', if 'A' is already
        --          a 'Duplicate Of' another business object.
        -- MSG: You cannot add new relationships to duplicate SUB_OBJ_TYPE_NAME - SUB_OBJ_NUM.
        --      Please add any new relationsihps to the original SUB_OBJ_TYPE_NAME - SUB_OBJ_NUM
        --       2> A business object 'A' cannot be made a 'Duplicate Of' another business
        --          object, if 'A' already has a CAUSAL link associated to it.
        -- MSG:
        CS_INCIDENTLINKS_UTIL.VALIDATE_LINK_DUPLICATES (
           P_SUBJECT_ID              => p_link_rec.subject_id,
           P_SUBJECT_TYPE            => p_link_rec.subject_type,
           P_OBJECT_ID               => p_link_rec.object_id,
           P_OBJECT_TYPE             => p_link_rec.object_type,
           P_LINK_TYPE_ID            => p_link_rec.link_type_id,
           P_SUBJECT_NUMBER          => lx_subject_number,
           P_OBJECT_NUMBER           => lx_object_number,
           P_SUBJECT_TYPE_NAME       => lx_subject_type_name,
           P_OBJECT_TYPE_NAME        => lx_object_type_name,
           X_RETURN_STATUS           => x_return_status,
           X_MSG_COUNT               => x_msg_count,
           X_MSG_DATA                => x_msg_data );

         if ( x_return_status <> FND_API.G_RET_STS_SUCCESS ) then
           -- This subject is already a duplicate of another related object. A
           -- duplicate object must have exactly one original.
           RAISE FND_API.G_EXC_ERROR;
         end if;

      END IF; -- if (l_invoked_version >= 2.0)

   END IF;  -- (p_validation_level > FND_API.G_VALID_LEVEL_NONE)


   -- if the validation level is none, then the procedure validate_link_details would not
   -- have got executed. In this case, the subject_number and the names of the subject and
   -- object types need to be derived. Use the same variables that are used for the out
   -- parameters in the call to validate_link_details.
   -- The value of the object_number is assumed to be passed coz the validation level is
   -- none. Store this value into the variable lx_object_number to be passed to the
   -- circular proc for message token.

   if ( p_validation_level = FND_API.G_VALID_LEVEL_NONE ) then
      -- subject type is some valid type in JTF Object. Derive the number from
      -- the details got from JTF_OBJECTS_VL. Using the VL so as to select the
      -- name of the subject type for the message tokens
      select select_id,   select_name  , from_table,   name
      into   l_select_id, l_select_name, l_from_table, lx_subject_type_name
      from   jtf_objects_vl
      where  object_code = p_link_rec.subject_type;

      -- use max to avoid the 'no data found' exception.
      EXECUTE IMMEDIATE 'select max(' || l_select_name ||
			') from '  || l_from_table||
			' where ' || l_select_id || ' = :p1'
			INTO lx_subject_number USING p_link_rec.subject_id;

      -- issue another select to jtf_objects_vl to get the object name.(check if
      -- use of cursor will help for the two select to jtf_objects_vl
      select max(name)
      into   lx_object_type_name
      from   jtf_objects_vl
      where  object_code = p_link_rec.object_type;

      -- store the passed in object_number into lx_object_number for circular message
      lx_object_number := p_link_rec.object_number;
   end if;     -- if ( p_validation_level = FND_API.G_VALID_LEVEL_NONE )


   -- For bugs 2972584 and 2972611
   -- Perform the following validation only if the invoked version is >= 2.0
   IF (l_invoked_version >= 2.0) THEN

     -- Perform check for circular dependency. The circular dependency check is always performed
     -- irrespective of the validation level. The global variable g_circulare_check_done is checked
     -- to verify that the circular check is not already done, in case the link is created due to
     -- an update. (update end dates a link and creates a new link)
     -- Rule : Prevent creation of circular dependency regardless of link type.

     if ( p_link_rec.link_type_id in (1,2) ) then
        CS_INCIDENTLINKS_UTIL.VALIDATE_LINK_CIRCULARS (
           P_SUBJECT_ID              => p_link_rec.subject_id,
           P_SUBJECT_TYPE            => p_link_rec.subject_type,
           P_OBJECT_ID               => p_link_rec.object_id,
           P_OBJECT_TYPE             => p_link_rec.object_type,
           P_LINK_TYPE_ID            => p_link_rec.link_type_id,
           P_SUBJECT_NUMBER          => lx_subject_number,
           P_OBJECT_NUMBER           => lx_object_number,
           P_SUBJECT_TYPE_NAME       => lx_subject_type_name,
           P_OBJECT_TYPE_NAME        => lx_object_type_name,
           P_OPERATION_MODE          => G_OPERATION_MODE,
           X_RETURN_STATUS           => x_return_status,
           X_MSG_COUNT               => x_msg_count,
           X_MSG_DATA                => x_msg_data );


        if ( x_return_status <> FND_API.G_RET_STS_SUCCESS ) then
           -- Creation of link will result in a circular dependency.
           RAISE FND_API.G_EXC_ERROR;
        end if;
     end if;  -- if ( p_link_rec.link_type_id in (1,2) ) then

   END IF; -- if (l_invoked_version >= 2.0)


   -- Reset the operation mode to create, since the circular check is done. Read comments
   -- about the use of this global variable at the beginning of the pkg.
   G_OPERATION_MODE := 'CREATE';

   -- If control comes to this point, either, validations were not performed, or all
   -- the validations were satisfied.

   -- Need to get the subject number to be used as the object number when creating the
   -- reciprocal link. Since there is'nt a parameter for subject number, this is needed
   -- If the subject_type is 'SR' then directly get the SR number, else derieve
   -- the value using the info in JTF Objets.

   -- Ready to create the link
   -- The following 4 columns are obsoleted for 1159; from_incident_id, to_incident_id,
   -- from_incident_number and  to_incident_number
   -- The reciprocal link id is NULL for the first link.

   -- For bugs 2972584 and 2972611
   -- Populate 	the old column values if the link is an internal link and a 11.5.8 link type can be determined
   	If (p_link_rec.subject_type = 'SR' and p_link_rec.object_type = 'SR') then
   		If  (l_invoked_version >= 2.0) then
			select decode(p_link_rec.link_type_id,
			6,'REF',
			4,'DUP',
			1, 'PARENT',
			2, 'CHILD',
			NULL)
			into l_link_type
			from dual;
			if (l_link_type is not null) then
				l_from_incident_id	:= p_link_rec.subject_id;
				l_from_incident_number	:= lx_subject_number;
				l_to_incident_id	:= p_link_rec.object_Id;
				l_to_incident_number	:= lx_object_number;
			end if;  -- if (l_link_type is not null)
		else
			l_from_incident_id	:= p_link_rec.from_incident_id;
			l_from_incident_number	:= p_link_rec.from_incident_number;
			l_to_incident_id	:= p_link_rec.to_incident_id;
			l_to_incident_number	:= p_link_rec.to_incident_number;
			l_link_type 		:= p_link_rec.link_type;
		end if;  -- If  (l_invoked_version >= 2.0)
	end if;  -- If (p_link_rec.subject_type = 'SR' and p_link_rec.object_type = 'SR')

   -- For bugs 2972584 and 2972611
   -- Populate the columns initialized to NULL in the record type, based on the value passed
   -- For columns initialized to FND_API.G_MISS_CHAR, if FND_API.G_MISS_CHAR is passed, then store NULL in database

   If p_link_rec.link_segment1 = FND_API.G_MISS_CHAR Then
     l_link_int_rec.link_segment1	:= NULL;
   Else
     l_link_int_rec.link_segment1      	:= p_link_rec.link_segment1;
   End If;

   If p_link_rec.link_segment2 = FND_API.G_MISS_CHAR Then
     l_link_int_rec.link_segment2	:= NULL;
   Else
     l_link_int_rec.link_segment2      	:= p_link_rec.link_segment2;
   End If;

   If p_link_rec.link_segment3 = FND_API.G_MISS_CHAR Then
     l_link_int_rec.link_segment3	:= NULL;
   Else
     l_link_int_rec.link_segment3      	:= p_link_rec.link_segment3;
   End If;

   If p_link_rec.link_segment4 = FND_API.G_MISS_CHAR Then
     l_link_int_rec.link_segment4	:= NULL;
   Else
     l_link_int_rec.link_segment4      	:= p_link_rec.link_segment4;
   End If;

   If p_link_rec.link_segment5 = FND_API.G_MISS_CHAR Then
     l_link_int_rec.link_segment5	:= NULL;
   Else
     l_link_int_rec.link_segment5      	:= p_link_rec.link_segment5;
   End If;

   If p_link_rec.link_segment6 = FND_API.G_MISS_CHAR Then
     l_link_int_rec.link_segment6	:= NULL;
   Else
     l_link_int_rec.link_segment6      	:= p_link_rec.link_segment6;
   End If;

   If p_link_rec.link_segment7 = FND_API.G_MISS_CHAR Then
     l_link_int_rec.link_segment7	:= NULL;
   Else
     l_link_int_rec.link_segment7      	:= p_link_rec.link_segment7;
   End If;

   If p_link_rec.link_segment8 = FND_API.G_MISS_CHAR Then
     l_link_int_rec.link_segment8	:= NULL;
   Else
     l_link_int_rec.link_segment8      	:= p_link_rec.link_segment8;
   End If;

   If p_link_rec.link_segment9 = FND_API.G_MISS_CHAR Then
     l_link_int_rec.link_segment9	:= NULL;
   Else
     l_link_int_rec.link_segment9      	:= p_link_rec.link_segment9;
   End If;

   If p_link_rec.link_segment10 = FND_API.G_MISS_CHAR Then
     l_link_int_rec.link_segment10	:= NULL;
   Else
     l_link_int_rec.link_segment10      	:= p_link_rec.link_segment10;
   End If;

   If p_link_rec.link_segment11 = FND_API.G_MISS_CHAR Then
     l_link_int_rec.link_segment11	:= NULL;
   Else
     l_link_int_rec.link_segment11      	:= p_link_rec.link_segment11;
   End If;

   If p_link_rec.link_segment12 = FND_API.G_MISS_CHAR Then
     l_link_int_rec.link_segment12	:= NULL;
   Else
     l_link_int_rec.link_segment12      	:= p_link_rec.link_segment12;
   End If;

   If p_link_rec.link_segment13 = FND_API.G_MISS_CHAR Then
     l_link_int_rec.link_segment13	:= NULL;
   Else
     l_link_int_rec.link_segment13      	:= p_link_rec.link_segment13;
   End If;

   If p_link_rec.link_segment14 = FND_API.G_MISS_CHAR Then
     l_link_int_rec.link_segment14	:= NULL;
   Else
     l_link_int_rec.link_segment14      	:= p_link_rec.link_segment14;
   End If;

   If p_link_rec.link_segment15 = FND_API.G_MISS_CHAR Then
     l_link_int_rec.link_segment15	:= NULL;
   Else
     l_link_int_rec.link_segment15      	:= p_link_rec.link_segment15;
   End If;

   If p_link_rec.link_context = FND_API.G_MISS_CHAR Then
     l_link_int_rec.link_context	:= NULL;
   Else
     l_link_int_rec.link_context     	:= p_link_rec.link_context;
   End If;


   -- Create the main link
   INSERT INTO CS_INCIDENT_LINKS (
      link_id,                           subject_id,                   subject_type,
      object_id,                         object_type,                  object_number,
      link_type_id,                      reciprocal_link_id,           request_id,
      program_application_id,            program_id,                   program_update_date,
      last_update_date,                  last_updated_by,              last_update_login,
      creation_date,                     created_by,                   attribute1,
      attribute2,                        attribute3,                   attribute4,
      attribute5,                        attribute6,                   attribute7,
      attribute8,                        attribute9,                   attribute10,
      attribute11,                       attribute12,                  attribute13,
      attribute14,                       attribute15,                  context,
      object_version_number,             from_incident_id,             from_incident_number,
      link_type,                         to_incident_id,               to_incident_number)
   VALUES (
      l_link_id,                         p_link_rec.subject_id,        p_link_rec.subject_type,
      p_link_rec.object_id,              p_link_rec.object_type,       lx_object_number,
      p_link_rec.link_type_id,           NULL,                         p_link_rec.request_id,
      p_link_rec.program_application_id, p_link_rec.program_id,        p_link_rec.program_update_date,
      SYSDATE,                           p_user_id,                    p_login_id,
      SYSDATE,                           p_user_id,                    l_link_int_rec.link_segment1,
      l_link_int_rec.link_segment2,      l_link_int_rec.link_segment3, l_link_int_rec.link_segment4,
      l_link_int_rec.link_segment5,      l_link_int_rec.link_segment6, l_link_int_rec.link_segment7,
      l_link_int_rec.link_segment8,      l_link_int_rec.link_segment9, l_link_int_rec.link_segment10,
      l_link_int_rec.link_segment11,     l_link_int_rec.link_segment12, l_link_int_rec.link_segment13,
      l_link_int_rec.link_segment14,     l_link_int_rec.link_segment15, l_link_int_rec.link_context,
      1,                                 l_from_incident_id,           l_from_incident_number,
      l_link_type,                       l_to_incident_id,             l_to_incident_number)
   RETURNING link_id,object_version_number into x_link_id,x_object_version_number ;

   --Added call to SR Child Audit API for auditing creation of SR Link --anmukher --09/12/03
   CS_SR_CHILD_AUDIT_PKG.CS_SR_AUDIT_CHILD
  (P_incident_id           => p_link_rec.subject_id,
   P_updated_entity_code   => 'SR_LINK',
   p_updated_entity_id     => x_link_id,
   p_entity_update_date    => sysdate,
   p_entity_activity_code  => 'C' ,
   x_audit_id              => lx_audit_id,
   x_return_status         => lx_return_status,
   x_msg_count             => lx_msg_count ,
   x_msg_data              => lx_msg_data );

   IF (lx_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Fetch the reciprocal link type id; this select will have to be a success because the
   -- link_type_id should be valid for control to come to this point. If for some reason it
   -- is not, the when others exception will be raised.
   select reciprocal_link_type_id
   into   l_reciprocal_link_type_id
   from   cs_sr_link_types_b
   where  link_type_id = p_link_rec.link_type_id;

   -- For bugs 2972584 and 2972611
   -- Reset the old columns to NULL
   l_from_incident_id		:= NULL;
   l_from_incident_number	:= NULL;
   l_to_incident_id		:= NULL;
   l_to_incident_number		:= NULL;

   -- For bugs 2972584 and 2972611
   -- Populate 	the old column values if the reciprocal link is an internal link and a 11.5.8 link type can be determined
	If ( l_link_type  IS   NOT   NULL   AND
       (p_link_rec.subject_type = 'SR' and p_link_rec.object_type = 'SR') ) then
		--If  (l_invoked_version >= 2.0) then
			select decode(l_reciprocal_link_type_id,
			6,'REF',
			4,'DUP',
			1, 'PARENT',
			2, 'CHILD',
			NULL)
			into l_link_type
			from dual;

			if (l_link_type is not null) then  -- swap the subject and object info. of the main link
				l_from_incident_id	:= p_link_rec.object_id;
				l_from_incident_number	:= lx_object_number;
				l_to_incident_id	:= p_link_rec.subject_Id;
				l_to_incident_number	:= lx_subject_number;
			end if;  -- if (l_link_type is not null)

		--end if;  -- If  (l_invoked_version >= 2.0)
	end if;  --If ( l_link_type  IS   NOT   NULL   AND


   -- Create the reciprocal link.
   -- The reciprocal link is always created.
   -- While creating the reciprocal, interchange the subject and object details.
   -- NOTE: (i) The object_number uses a local variable since the subject number
   --           is not a parameter and (ii) the reciprocal link id is the link
   --           id of the first link created.(iii) the link_type_id is the reciprocal
   --           link_type_id of the main link link_type_id
   --

   INSERT INTO CS_INCIDENT_LINKS (
      link_id,                     subject_id,            subject_type,
      object_id,                   object_type,           object_number,
      link_type_id,                reciprocal_link_id,    request_id,
      program_application_id,      program_id,            program_update_date,
      last_update_date,            last_updated_by,       last_update_login,
      creation_date,               created_by,            attribute1,
      attribute2,                  attribute3,            attribute4,
      attribute5,                  attribute6,            attribute7,
      attribute8,                  attribute9,            attribute10,
      attribute11,                 attribute12,           attribute13,
      attribute14,                 attribute15,           context,
      object_version_number,       from_incident_id,      from_incident_number,
      link_type,                   to_incident_id,        to_incident_number )
   VALUES (
      cs_incident_links_s.nextval, 	  p_link_rec.object_id,           p_link_rec.object_type,
      p_link_rec.subject_id,       	  p_link_rec.subject_type,        lx_subject_number,
      l_reciprocal_link_type_id,   	  X_LINK_ID,                      p_link_rec.request_id,
      p_link_rec.program_application_id,  p_link_rec.program_id,   	  p_link_rec.program_update_date,
      SYSDATE,                            p_user_id,                      p_login_id,
      SYSDATE,                            p_user_id,                      l_link_int_rec.link_segment1,
      l_link_int_rec.link_segment2,       l_link_int_rec.link_segment3,   l_link_int_rec.link_segment4,
      l_link_int_rec.link_segment5,       l_link_int_rec.link_segment6,   l_link_int_rec.link_segment7,
      l_link_int_rec.link_segment8,       l_link_int_rec.link_segment9,   l_link_int_rec.link_segment10,
      l_link_int_rec.link_segment11,      l_link_int_rec.link_segment12,  l_link_int_rec.link_segment13,
      l_link_int_rec.link_segment14,      l_link_int_rec.link_segment15,  l_link_int_rec.link_context,
      1,                                  l_from_incident_id,             l_from_incident_number,
      l_link_type,                        l_to_incident_id,               l_to_incident_number)
   RETURNING link_id into x_reciprocal_link_id ;

   -- update the main link's reciprocal link id with the link id of the reciprocal rec. just
   -- created.
   update cs_incident_links
   set    reciprocal_link_id = x_reciprocal_link_id
   where  link_id            = l_link_id;

   --Added call to SR Child Audit API for auditing creation of SR Link --anmukher --09/12/03
   -- Create audit record only if object entity is a service request
   IF (p_link_rec.object_type = 'SR') THEN
   CS_SR_CHILD_AUDIT_PKG.CS_SR_AUDIT_CHILD
  (P_incident_id           => p_link_rec.object_id,
   P_updated_entity_code   => 'SR_LINK',
   p_updated_entity_id     => x_reciprocal_link_id,
   p_entity_update_date    => sysdate,
   p_entity_activity_code  => 'C' ,
   x_audit_id              => lx_audit_id,
   x_return_status         => lx_return_status,
   x_msg_count             => lx_msg_count ,
   x_msg_data              => lx_msg_data );

   IF (lx_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
   END IF;

   -- For bugs 2972584 and 2972611
   -- Create the external link record if the link that has been passed is an external link

    IF p_link_rec.subject_type <> 'SR' OR p_link_rec.object_type <> 'SR' THEN

   -- Populate the record type for the external link with the available values
   -- Depending on whether the forward or reciprocal link has the subject type as 'SR', assign the values accordingly
        IF (p_link_rec.subject_type = 'SR' AND p_link_rec.object_type <> 'SR') THEN
		l_links_ext_rec.from_incident_id	:= p_link_rec.subject_id;
		l_links_ext_rec.to_object_id		:= p_link_rec.object_id;
		l_links_ext_rec.to_object_number	:= lx_object_number;
		l_links_ext_rec.to_object_type	:= p_link_rec.object_type;
	ELSIF ( p_link_rec.object_type = 'SR' AND p_link_rec.subject_type <> 'SR')  THEN
		l_links_ext_rec.from_incident_id	:= p_link_rec.object_id;
		l_links_ext_rec.to_object_id		:= p_link_rec.subject_id;
		l_links_ext_rec.to_object_number	:= lx_subject_number;
		l_links_ext_rec.to_object_type	:= p_link_rec.subject_type;
	END IF;
		l_links_ext_rec.last_update_date	:= SYSDATE;
		l_links_ext_rec.last_updated_by		:= p_user_id;
		l_links_ext_rec.last_update_login	:= p_login_id;
		l_links_ext_rec.creation_date		:= SYSDATE;
		l_links_ext_rec.created_by		:= p_user_id;

		If p_link_rec.link_segment1 = FND_API.G_MISS_CHAR Then
     			l_links_ext_rec.attribute1	:= NULL;
   		Else
     			l_links_ext_rec.attribute1      := p_link_rec.link_segment1;
   		End If;

   		If p_link_rec.link_segment2 = FND_API.G_MISS_CHAR Then
     			l_links_ext_rec.attribute2	:= NULL;
   		Else
     			l_links_ext_rec.attribute2      := p_link_rec.link_segment2;
   		End If;

   		If p_link_rec.link_segment3 = FND_API.G_MISS_CHAR Then
     			l_links_ext_rec.attribute3	:= NULL;
   		Else
     			l_links_ext_rec.attribute3      := p_link_rec.link_segment3;
   		End If;

   		If p_link_rec.link_segment4 = FND_API.G_MISS_CHAR Then
     			l_links_ext_rec.attribute4	:= NULL;
   		Else
     			l_links_ext_rec.attribute4      := p_link_rec.link_segment4;
   		End If;

   		If p_link_rec.link_segment5 = FND_API.G_MISS_CHAR Then
     			l_links_ext_rec.attribute5	:= NULL;
   		Else
     			l_links_ext_rec.attribute5      := p_link_rec.link_segment5;
   		End If;

   		If p_link_rec.link_segment6 = FND_API.G_MISS_CHAR Then
     			l_links_ext_rec.attribute6	:= NULL;
   		Else
     			l_links_ext_rec.attribute6      := p_link_rec.link_segment6;
   		End If;

   		If p_link_rec.link_segment7 = FND_API.G_MISS_CHAR Then
     			l_links_ext_rec.attribute7	:= NULL;
   		Else
     			l_links_ext_rec.attribute7      := p_link_rec.link_segment7;
   		End If;

   		If p_link_rec.link_segment8 = FND_API.G_MISS_CHAR Then
     			l_links_ext_rec.attribute8	:= NULL;
   		Else
     			l_links_ext_rec.attribute8      := p_link_rec.link_segment8;
   		End If;

   		If p_link_rec.link_segment9 = FND_API.G_MISS_CHAR Then
     			l_links_ext_rec.attribute9	:= NULL;
   		Else
     			l_links_ext_rec.attribute9      := p_link_rec.link_segment9;
   		End If;

   		If p_link_rec.link_segment10 = FND_API.G_MISS_CHAR Then
     			l_links_ext_rec.attribute10	:= NULL;
   		Else
     			l_links_ext_rec.attribute10     := p_link_rec.link_segment10;
   		End If;

		If p_link_rec.link_context = FND_API.G_MISS_CHAR Then
     			l_links_ext_rec.context		:= NULL;
   		Else
     			l_links_ext_rec.context         := p_link_rec.link_context;
   		End If;

	  BEGIN
		SELECT	link_Id
	        INTO	l_link_id
		FROM	cs_incident_links_ext
	        WHERE	from_incident_id	= l_links_ext_rec.from_incident_id
		AND	(to_object_id		= l_links_ext_rec.to_object_id OR
		        to_object_number	= l_links_ext_rec.to_object_number)
		AND 	to_object_type		= l_links_ext_rec.to_object_type;

	  EXCEPTION
		WHEN NO_DATA_FOUND THEN
	                INSERT INTO cs_incident_links_ext (
			link_id,
	    		from_incident_id,
     			to_object_id,
    			to_object_number,
			to_object_type,
			last_update_date,
        		last_updated_by,
    			last_update_login,
			creation_date,
			created_by,
    			attribute1,
			attribute2,
			attribute3,
    			attribute4,
			attribute5,
			attribute6,
    			attribute7,
			attribute8,
			attribute9,
    			attribute10,
			context,
			object_version_number)
		      VALUES (
			cs_incident_links_ext_s.NEXTVAL,
			l_links_ext_rec.from_incident_id,
		    	l_links_ext_rec.to_object_id,
	                l_links_ext_rec.to_object_number,
			l_links_ext_rec.to_object_type,
        		l_links_ext_rec.last_update_date,
			l_links_ext_rec.last_updated_by,
			l_links_ext_rec.last_update_login,
			l_links_ext_rec.creation_date,
			l_links_ext_rec.created_by,
	    		l_links_ext_rec.attribute1,
			l_links_ext_rec.attribute2,
			l_links_ext_rec.attribute3,
    			l_links_ext_rec.attribute4,
			l_links_ext_rec.attribute5,
			l_links_ext_rec.attribute6,
	    		l_links_ext_rec.attribute7,
			l_links_ext_rec.attribute8,
			l_links_ext_rec.attribute9,
    			l_links_ext_rec.attribute10,
			l_links_ext_rec.context,
			l_links_ext_rec.object_version_number);

	  END;  -- end for begin block
    END IF;  -- If p_link_rec.subject_type <> 'SR' OR p_link_rec.object_type



      -- Recreating a savepoint, coz if the BES fails with an unhandled exception, then the
      -- when others in this proc. tries to rollback to the create savepoint. Since the
      -- commit has happened, the context of the savepoint is lost. By re-creating it here,
      -- there is no loss, and will avoid the ORA-1086 error.
--      SAVEPOINT Create_IncidentLink_PVT;
--      This save point is not needed as even if the raising of business event fails we are not erroring out
--      Moved the commit at the bottom.

   	  -- For bugs 2972584 and 2972611
   	  -- Raise the following business events only if the invoked version is >= 2.0
	   IF (l_invoked_version >= 2.0) THEN

	      -- *************
	      -- Raise BES event that link is created. (Only after commit???)
	      -- *************
	      CS_WF_EVENT_PKG.RAISE_SERVICEREQUEST_EVENT(
	        p_api_version           => 1.0,
	        p_init_msg_list         => FND_API.G_TRUE,
	        p_commit                => p_commit,
		    p_validation_level      => FND_API.G_VALID_LEVEL_FULL,
	        p_event_code            => 'RELATIONSHIP_CREATE_FOR_SR',
	        p_incident_number       => lx_subject_number,
	        p_user_id               => p_user_id,
	        p_resp_id               => p_resp_id,
	        p_resp_appl_id          => p_resp_appl_id,
	        p_link_rec              => p_link_rec,
	        p_wf_process_id         => NULL,  -- using default value
	        p_owner_id		 => NULL,  -- using default value
	        p_wf_manual_launch	 => 'N' ,  -- using default value
	        x_wf_process_id         => lx_wf_process_id,
	        x_return_status         => lx_return_status,
	        x_msg_count             => lx_msg_count,
	        x_msg_data              => lx_msg_data );

	      if ( lx_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
		 -- do nothing in this API. The BES wrapper API will have to trap this
		 -- situation and send a notification to the SR owner that the BES has
		 -- not been raised. If the BES API return back a failure status, it
		 -- means only that the BES raise event has failed, and has nothing to
		 -- do with the creation of the link.
		 null;
	      end if;

	      -- populate the reciprocal link rec. type to pass to the BES wrapper to raise the
	      -- event that the reciprocal is created.
	      -- interchange the subject and object information.
	      l_link_rec.LINK_ID                := x_reciprocal_link_id;
	      l_link_rec.SUBJECT_ID             := p_link_rec.object_id;
	      l_link_rec.SUBJECT_TYPE           := p_link_rec.object_type;
	      l_link_rec.OBJECT_ID              := p_link_rec.subject_id;
	      l_link_rec.OBJECT_NUMBER          := lx_subject_number;
	      l_link_rec.OBJECT_TYPE            := p_link_rec.subject_type;
	      l_link_rec.LINK_TYPE_ID           := l_reciprocal_link_type_id;
	      l_link_rec.LINK_TYPE		:= p_link_rec.link_type;
	      l_link_rec.REQUEST_ID             := p_link_rec.request_id;
	      l_link_rec.PROGRAM_APPLICATION_ID := p_link_rec.program_application_id;
	      l_link_rec.PROGRAM_ID             := p_link_rec.program_id;
	      l_link_rec.PROGRAM_UPDATE_DATE    := p_link_rec.program_update_date;
	      l_link_rec.LINK_SEGMENT1	        := p_link_rec.link_segment1;
	      l_link_rec.LINK_SEGMENT2	        := p_link_rec.link_segment2;
	      l_link_rec.LINK_SEGMENT3	        := p_link_rec.link_segment3;
	      l_link_rec.LINK_SEGMENT4	        := p_link_rec.link_segment4;
	      l_link_rec.LINK_SEGMENT5	        := p_link_rec.link_segment5;
	      l_link_rec.LINK_SEGMENT6	        := p_link_rec.link_segment6;
	      l_link_rec.LINK_SEGMENT7	        := p_link_rec.link_segment7;
	      l_link_rec.LINK_SEGMENT8	        := p_link_rec.link_segment8;
	      l_link_rec.LINK_SEGMENT9	        := p_link_rec.link_segment9;
	      l_link_rec.LINK_SEGMENT10	        := p_link_rec.link_segment10;
	      l_link_rec.LINK_SEGMENT11	        := p_link_rec.link_segment11;
	      l_link_rec.LINK_SEGMENT12	        := p_link_rec.link_segment12;
	      l_link_rec.LINK_SEGMENT13	        := p_link_rec.link_segment13;
	      l_link_rec.LINK_SEGMENT14	        := p_link_rec.link_segment14;
	      l_link_rec.LINK_SEGMENT15	        := p_link_rec.link_segment15;
	      l_link_rec.LINK_CONTEXT           := p_link_rec.link_context;

	      -- *************
	      -- Raise BES event that the reciprocal link is created.
	      -- *************
	      CS_WF_EVENT_PKG.RAISE_SERVICEREQUEST_EVENT(
		 p_api_version           => 1.0,
		 p_init_msg_list         => FND_API.G_TRUE,
		 p_commit                => p_commit,
		 p_validation_level      => FND_API.G_VALID_LEVEL_FULL,
	         p_event_code            => 'RELATIONSHIP_CREATE_FOR_SR',
	         p_incident_number       => lx_object_number, --the main link's Object, which
							      --is the reciprocal's subject
	         p_user_id               => p_user_id,
	         p_resp_id               => p_resp_id,
	         p_resp_appl_id          => p_resp_appl_id,
	         p_link_rec              => L_LINK_REC,
	         p_wf_process_id         => NULL,  -- using default value
	         p_owner_id		 => NULL,  -- using default value
	         p_wf_manual_launch	 => 'N' ,  -- using default value
	         x_wf_process_id         => lx_wf_process_id,
	         x_return_status         => lx_return_status,
	         x_msg_count             => lx_msg_count,
	         x_msg_data              => lx_msg_data );

	      if ( lx_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
		 -- do nothing in this API. The BES wrapper API will have to trap this
		 -- situation and send a notification to the SR owner that the BES has
		 -- not been raised. If the BES API return back a failure status, it
		 -- means only that the BES raise event has failed, and has nothing to
		 -- do with the creation of the link.
		 null;
	      end if;

	   END IF; -- if (l_invoked_version >= 2.0)
    -- END IF; -- if FND_API.To_Boolean(p_commit)

   -- Standard check of p_commit
   IF FND_API.To_Boolean(p_commit) THEN
      COMMIT WORK;
   END IF ;
            -- Moved the IF - END IF of the p_commit here since the business events were not raised
            -- if the p_commit parameter is FALSE. This issue is faced by HTML service since the
            -- API is called with p_commit= false -- spusegao 12/15/2003

   -- Standard call to get message count and if count is 1, get message info
   FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data  => x_msg_data);

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO create_incidentlink_pvt;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data  => x_msg_data);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO create_incidentlink_pvt;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data  => x_msg_data);

   WHEN OTHERS THEN
      ROLLBACK TO create_incidentlink_pvt;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MESSAGE.SET_NAME ('CS', 'CS_API_SR_UNKNOWN_ERROR');
      FND_MESSAGE.SET_TOKEN ('P_TEXT',l_api_name_full||'-'||SQLERRM);
      FND_MSG_PUB.ADD;
      FND_MSG_PUB.Count_And_Get(
	 p_count => x_msg_count,
	 p_data  => x_msg_data);

END CREATE_INCIDENTLINK;

--
-- Existing procedure. This procedure calls the new overloaded procedure with the
-- record structure.
-- The two parameters that are obsoleted for 1159 , p_from_incident_id and
-- p_to_incident_id are accepted as IN parameter in this procedure for backward
-- compatability. It is not passed to the overloaded procedure.
-- NOTE : Even though the following three columns are accepted as IN params. via the
--        record type, it will not be used in the procedure or modified in the
--        update statement: created_by, creation_date, reciprocal_link_id
--
PROCEDURE UPDATE_INCIDENTLINK (
   P_API_VERSION		IN     NUMBER,
   P_INIT_MSG_LIST	        IN     VARCHAR2,
   P_COMMIT			IN     VARCHAR2,
   P_VALIDATION_LEVEL           IN     NUMBER,
   P_RESP_APPL_ID		IN     NUMBER,    -- not used
   P_RESP_ID			IN     NUMBER,    -- not used
   P_USER_ID			IN     NUMBER,
   P_LOGIN_ID		        IN     NUMBER,
   P_ORG_ID			IN     NUMBER,    -- not used
   P_LINK_ID			IN     NUMBER,    -- no change
   P_OBJECT_VERSION_NUMBER      IN     NUMBER,    -- new for 1159
   P_OBJECT_ID                  IN     NUMBER,    -- new for 1159
   P_OBJECT_NUMBER              IN     VARCHAR2,  -- new for 1159
   P_OBJECT_TYPE                IN     VARCHAR2,  -- new for 1159
   P_LINK_TYPE_ID		IN     NUMBER,    -- new for 1159
   P_LINK_TYPE		        IN     VARCHAR2,  -- no change
   P_REQUEST_ID                 IN     NUMBER,    -- new for 1159
   P_PROGRAM_APPLICATION_ID     IN     NUMBER,    -- new for 1159
   P_PROGRAM_ID                 IN     NUMBER,    -- new for 1159
   P_PROGRAM_UPDATE_DATE        IN     DATE,      -- new for 1159
   P_FROM_INCIDENT_ID	        IN     NUMBER,    -- obsoleted for 1159
   P_TO_INCIDENT_ID	        IN     NUMBER,    -- obsoleted for 1159
   P_LINK_SEGMENT1	        IN     VARCHAR2,
   P_LINK_SEGMENT2	        IN     VARCHAR2,
   P_LINK_SEGMENT3	        IN     VARCHAR2,
   P_LINK_SEGMENT4	        IN     VARCHAR2,
   P_LINK_SEGMENT5	        IN     VARCHAR2,
   P_LINK_SEGMENT6	        IN     VARCHAR2,
   P_LINK_SEGMENT7	        IN     VARCHAR2,
   P_LINK_SEGMENT8	        IN     VARCHAR2,
   P_LINK_SEGMENT9	        IN     VARCHAR2,
   P_LINK_SEGMENT10	        IN     VARCHAR2,
   P_LINK_SEGMENT11	        IN     VARCHAR2,  -- new for 1159
   P_LINK_SEGMENT12	        IN     VARCHAR2,  -- new for 1159
   P_LINK_SEGMENT13	        IN     VARCHAR2,  -- new for 1159
   P_LINK_SEGMENT14	        IN     VARCHAR2,  -- new for 1159
   P_LINK_SEGMENT15	        IN     VARCHAR2,  -- new for 1159
   P_LINK_CONTEXT		IN     VARCHAR2,
   X_RETURN_STATUS	        OUT NOCOPY   VARCHAR2,
   X_OBJECT_VERSION_NUMBER      OUT NOCOPY   NUMBER,  -- new for 1159
   X_MSG_COUNT		        OUT NOCOPY   NUMBER,
   X_MSG_DATA		        OUT NOCOPY   VARCHAR2 )
IS

   l_api_name                  CONSTANT VARCHAR2(30) := 'UPDATE_INCIDENTLINK';
   l_api_name_full             CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||l_api_name;
   l_api_version               CONSTANT NUMBER := 2.0;

   -- The following is the newly created (for 1159) record structure that will be
   -- populated and passed to the overloaded update procedure.
   l_link_rec                   CS_INCIDENT_LINK_REC_TYPE;

BEGIN
   l_link_rec.OBJECT_ID               := p_object_id;               -- new for 1159
   l_link_rec.OBJECT_NUMBER           := p_object_number;           -- new for 1159
   l_link_rec.OBJECT_TYPE             := p_object_type;             -- new for 1159
   l_link_rec.LINK_TYPE_ID            := p_link_type_id;            -- new for 1159
   l_link_rec.LINK_TYPE               := p_link_type;               -- no change
   l_link_rec.REQUEST_ID              := p_request_id;              -- new for 1159
   l_link_rec.PROGRAM_APPLICATION_ID  := p_program_application_id;  -- new for 1159
   l_link_rec.PROGRAM_ID              := p_program_id;              -- new for 1159
   l_link_rec.PROGRAM_UPDATE_DATE     := p_program_update_date;     -- new for 1159
   l_link_rec.LINK_SEGMENT1           := p_link_segment1;
   l_link_rec.LINK_SEGMENT2           := p_link_segment2;
   l_link_rec.LINK_SEGMENT3           := p_link_segment3;
   l_link_rec.LINK_SEGMENT4           := p_link_segment4;
   l_link_rec.LINK_SEGMENT5           := p_link_segment5;
   l_link_rec.LINK_SEGMENT6           := p_link_segment6;
   l_link_rec.LINK_SEGMENT7           := p_link_segment7;
   l_link_rec.LINK_SEGMENT8           := p_link_segment8;
   l_link_rec.LINK_SEGMENT9           := p_link_segment9;
   l_link_rec.LINK_SEGMENT10          := p_link_segment10;
   l_link_rec.LINK_SEGMENT11          := p_link_segment11;         -- new for 1159
   l_link_rec.LINK_SEGMENT12          := p_link_segment12;         -- new for 1159
   l_link_rec.LINK_SEGMENT13          := p_link_segment13;         -- new for 1159
   l_link_rec.LINK_SEGMENT14          := p_link_segment14;         -- new for 1159
   l_link_rec.LINK_SEGMENT15          := p_link_segment15;         -- new for 1159
   l_link_rec.LINK_CONTEXT            := p_link_context;

   UPDATE_INCIDENTLINK (
      P_API_VERSION		=> p_api_version,
      P_INIT_MSG_LIST	        => p_init_msg_list,
      P_COMMIT			=> p_commit,
      P_VALIDATION_LEVEL        => p_validation_level,
      P_RESP_APPL_ID		=> p_resp_appl_id,           -- not used
      P_RESP_ID			=> p_resp_id,                -- not used
      P_USER_ID			=> p_user_id,
      P_LOGIN_ID		=> p_login_id,
      P_ORG_ID			=> p_org_id,                 -- not used
      P_LINK_ID			=> p_link_id,                -- no change
      P_OBJECT_VERSION_NUMBER   => p_object_version_number,  -- new for 1159
      P_LINK_REC                => l_link_rec,
      X_RETURN_STATUS	        => x_return_status,
      X_OBJECT_VERSION_NUMBER   => x_object_version_number,  -- new for 1159
      X_MSG_COUNT		=> x_msg_count,
      X_MSG_DATA		=> x_msg_data );

EXCEPTION
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MESSAGE.SET_NAME ('CS', 'CS_API_SR_UNKNOWN_ERROR');
      FND_MESSAGE.SET_TOKEN ('P_TEXT',l_api_name_full||'-'||SQLERRM);
      FND_MSG_PUB.ADD;
      FND_MSG_PUB.Count_And_Get(
         p_count => x_msg_count,
         p_data  => x_msg_data);

END UPDATE_INCIDENTLINK;

--
-- Overloaded procedure (new for 1159) that accepts a record structure.
-- Invoking programs can use either one of the procedures.
-- NOTE : Even though the following three columns are accepted as IN params. via the
--        record type, it will not be used in the procedure or modified in the
--        update statement: created_by, creation_date, reciprocal_link_id
--
-- When a link is updated the following operations are performed:
-- 1> End date the link that is being updated.
-- 2> End date the reciprocal link of the link that is being updated.
-- 3> Create a new link with the update link's information
-- 4> Create the coresponding reciprocal link

PROCEDURE UPDATE_INCIDENTLINK (
   P_API_VERSION		IN     NUMBER,
   P_INIT_MSG_LIST	        IN     VARCHAR2,
   P_COMMIT			IN     VARCHAR2,
   P_VALIDATION_LEVEL           IN     NUMBER,
   P_RESP_APPL_ID		IN     NUMBER,        -- not used
   P_RESP_ID			IN     NUMBER,        -- not used
   P_USER_ID			IN     NUMBER,
   P_LOGIN_ID		        IN     NUMBER,
   P_ORG_ID			IN     NUMBER,        -- not used
   P_LINK_ID			IN     NUMBER,        -- no change
   P_OBJECT_VERSION_NUMBER      IN     NUMBER,        -- new for 1159
   P_LINK_REC                   IN     CS_INCIDENT_LINK_REC_TYPE,
   X_RETURN_STATUS	        OUT NOCOPY   VARCHAR2,
   X_OBJECT_VERSION_NUMBER      OUT NOCOPY   NUMBER,  -- new for 1159
   X_MSG_COUNT		        OUT NOCOPY   NUMBER,
   X_MSG_DATA		        OUT NOCOPY   VARCHAR2 )
IS
   l_api_name                   CONSTANT VARCHAR2(30) := 'UPDATE_INCIDENTLINK_1';
   l_api_name_full              CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||l_api_name;

   -- Commented out to allow thise procedure to be called with both the versions 1.2 and 2.0 (bugs 2972584 and 2972611)
   --l_api_version                CONSTANT NUMBER := 2.0;
   l_test                       CHAR(1);

   l_select_id                 VARCHAR2(30);
   l_subject_number            VARCHAR2(90);
   l_select_name               VARCHAR2(240);
   l_from_table                VARCHAR2(240);

   -- Local link rec. to store the link details to be passed to the Insert API.
   l_link_rec                  CS_INCIDENT_LINK_REC_TYPE;

   -- Local variables to be used to get the OUT values from the Create link proc.
   lx_object_version_number    NUMBER;
   lx_reciprocal_link_id       NUMBER;
   lx_link_id                  NUMBER;

   -- Local variables to be used to get the subject and object number from procedure
   -- validate_link_details
   lx_subject_number           VARCHAR2(90);
   lx_object_number            VARCHAR2(90);
   lx_subject_type_name        VARCHAR2(90);
   lx_object_type_name         VARCHAR2(90);

   -- cursor to fetch the existing link details
   cursor c_old_values is
   select *
   from   cs_incident_links
   where  link_id               = p_link_id
   --and    object_version_number = p_object_version_number
   for    update nowait;

   l_old_values_rec   c_old_values%rowtype;

   -- For bugs 2972584 and 2972611
   -- Variable to store the external link ID derived from the internal link ID passed to this procedure
   l_derived_external_link_id   NUMBER;

   -- For bugs 2972584 and 2972611
   -- Variable to store the value passed-in as API version
   l_invoked_version           NUMBER;

   --Added for call to SR Child Audit API after updation of SR Link --anmukher --09/12/03
   lx_return_status            VARCHAR2(3);
   lx_msg_count                NUMBER;
   lx_msg_data                 VARCHAR2(4000);
   lx_audit_id			NUMBER;

BEGIN
   -- Standard start of API savepoint
   SAVEPOINT Update_IncidentLink_PVT;

   -- Initialize message list if p_init_msg_list is set to TRUE
   IF FND_API.To_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.Initialize;
   END IF;

   -- Allow this API to be called with both version numbers, 1.2 and 2.0, introduced for bugs 2972584 and 2972611
   IF p_api_version = 1.2 THEN
   	  l_invoked_version := 1.2;
   ELSIF p_api_version = 2.0 THEN
      l_invoked_version := 2.0;
   END IF;

   -- Standard call to check for call compatibility, changed so that both versions 1.2 and 2.0 may be allowed
   IF NOT FND_API.Compatible_API_Call(l_invoked_version, p_api_version,
					    l_api_name, G_PKG_NAME) THEN
      FND_MSG_PUB.Count_And_Get(
	 p_count => x_msg_count,
	 p_data  => x_msg_data );
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Set the operation mode to update since an update link is being performed.
   G_OPERATION_MODE := 'UPDATE';

   -- check if record exist and is not modified by other users.
   open  c_old_values;
   fetch c_old_values into l_old_values_rec;
   if ( c_old_values%NOTFOUND ) then
      -- record does not exist or has been modified by other users.
      -- Raise error only if the external link ID that has been passed is NULL (i.e. has not been passed for update)
      if (p_link_rec.link_id_ext IS NULL) then -- For bugs 2972584 and 2972611
        close c_old_values;
      	FND_MESSAGE.Set_Name('CS', 'CS_INVALID_INCIDENT_LINK_ID');
        FND_MESSAGE.Set_Token('API_NAME', l_api_name_full);
        FND_MESSAGE.Set_Token('LINK_ID', to_char(p_link_id));
      	FND_MSG_PUB.Add;
      	FND_MSG_PUB.Count_And_Get(
	 p_count => x_msg_count,
	 p_data  => x_msg_data );
      	RAISE FND_API.G_EXC_ERROR;
      end if; -- (p_link_rec.link_id_ext IS NULL)

   ELSIF (l_old_values_rec.object_version_number <> p_object_version_number) THEN
      	FND_MESSAGE.Set_Name('CS', 'CS_RECORD_HAS_BEEN_UPDATED');
      	FND_MSG_PUB.Add;
      	FND_MSG_PUB.Count_And_Get(
	 p_count => x_msg_count,
	 p_data  => x_msg_data );
      	RAISE FND_API.G_EXC_ERROR;
   end if; -- ( c_old_values%NOTFOUND )

   -- record exists, continue processing
   close c_old_values;

   -- Service security implementation for Update link
   -- Included check for Service Security introduced in R11.5.10.
   -- The validation is to make sure that the responsibility creating
   -- the link, has access to the subject and/or object if they are
   -- service requests
   -- Note: Need to figure out how to avoid doing the security check twice
   -- when the link is updated. (as the create link is invoked each time a
   -- link is updated.

   if ( l_old_values_rec.subject_type = 'SR' ) then
      cs_incidentlinks_util.validate_sr_sec_access (
         p_incident_id        => l_old_values_rec.subject_id,
         x_return_status      => x_return_status,
         x_msg_count          => x_msg_count,
         x_msg_data           => x_msg_data );

      if ( x_return_status <> FND_API.G_RET_STS_SUCCESS ) then
         -- Responsibility RESP_NAME does not have access to service
         -- request SR_NUMBER.
         raise FND_API.G_EXC_ERROR;
      end if;
   end if;

   if ( l_old_values_rec.object_type = 'SR' ) then
      cs_incidentlinks_util.validate_sr_sec_access (
         p_incident_id        => l_old_values_rec.object_id,
         x_return_status      => x_return_status,
         x_msg_count          => x_msg_count,
         x_msg_data           => x_msg_data );

      if ( x_return_status <> FND_API.G_RET_STS_SUCCESS ) then
         -- Responsibility RESP_NAME does not have access to service
         -- request SR_NUMBER.
         RAISE FND_API.G_EXC_ERROR;
      end if;
   end if;
   --
   -- END OF SECURITY ACCESS CHECK FOR R11.5.10

   -- ----------------------------------------------------------------------
   -- Apply business-rule validation to all required and passed parameters
   -- if validation level is set.
   -- ----------------------------------------------------------------------
   IF (p_validation_level > FND_API.G_VALID_LEVEL_NONE) THEN
      --
      -- Validate the user and login id's
      --
      CS_ServiceRequest_UTIL.Validate_Who_Info (
	 p_api_name             => l_api_name_full,
         p_parameter_name_usr   => 'p_user_id',
         p_parameter_name_login => 'p_login_id',
         p_user_id              => p_user_id,
         p_login_id             => p_login_id,
         x_return_status        => x_return_status );

      IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
	 FND_MSG_PUB.Count_And_Get(
	    p_count => x_msg_count,
	    p_data  => x_msg_data);

         RAISE FND_API.G_EXC_ERROR;
      END IF;
   END IF;

   -- When updating a link say 'L1', end date 'L1' and its reciprocal; create two new
   -- links with the update information. Invoke the insert API to create the new
   -- links. Validations on the link will be performed based on the validation level
   -- being passed in to the UPDATE API. The insert API in turn will invoke the BES
   -- wrapper API to raise the needed events.
   -- This end dating and creating logic is done so that there is audit info for the
   -- links.(will have to change once the Audit table is designed for the links)

   -- Performing the update of the end dates first as the validation procedure in the
   -- utils pkg. needs to consider only the active links. The utils should have the
   -- context simulated in such a way that the update links do not exist, and do the
   -- validations for the new link data.
   -- If condition added for bugs 2972584 and 2972611
   -- End-date the internal link and its reciprocal only if an internal link ID has been passed
   If (p_link_id IS NOT NULL) Then -- Added for bugs 2972584 and 2972611
   	UPDATE CS_INCIDENT_LINKS  SET
      	end_date_active          = SYSDATE,
      	last_update_date         = SYSDATE,
      	last_updated_by          = p_user_id,
      	last_update_login        = p_login_id,
      	object_version_number    = object_version_number + 1
   	WHERE link_id            = p_link_id
   	AND object_version_number = p_object_version_number;
--    	RETURNING object_version_number into x_object_version_number;
--      Commented this code out since it is not returning the correct object_version_number. The API always end dates
--      an existing updated incident link and creates a new link. Hence if we return the object_version_number from
--      the update statement as above it would be wrong object_version_number.

   	--Added call to SR Child Audit API for auditing end-dating of SR Link --anmukher --09/12/03
        CS_SR_CHILD_AUDIT_PKG.CS_SR_AUDIT_CHILD
       (P_incident_id           => l_old_values_rec.subject_id,
        P_updated_entity_code   => 'SR_LINK',
        p_updated_entity_id     => p_link_id,
        p_entity_update_date    => sysdate,
        p_entity_activity_code  => 'U' ,  /* 'D' (not 'U'), because the link is being end-dated (functional delete) -- Changed to 'U' spusegao 10-17-2003 */
        x_audit_id              => lx_audit_id,
        x_return_status         => lx_return_status,
        x_msg_count             => lx_msg_count ,
        x_msg_data              => lx_msg_data );

        IF (lx_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
     	  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   	END IF;

   	-- end date the reciprocal link as well has to be a success
   	UPDATE CS_INCIDENT_LINKS  SET
      	end_date_active          = SYSDATE,
      	last_update_date         = SYSDATE,
      	last_updated_by          = p_user_id,
      	last_update_login        = p_login_id,
      	object_version_number    = object_version_number + 1
   	where link_id            = l_old_values_rec.reciprocal_link_id;

   	--Added call to SR Child Audit API for auditing end-dating of SR Link --anmukher --09/12/03
        -- audit to be created only for Service requests
        IF (l_old_values_rec.object_type = 'SR') THEN
        CS_SR_CHILD_AUDIT_PKG.CS_SR_AUDIT_CHILD
       (P_incident_id           => l_old_values_rec.object_id,
        P_updated_entity_code   => 'SR_LINK',
        p_updated_entity_id     => l_old_values_rec.reciprocal_link_id,
        p_entity_update_date    => sysdate,
        p_entity_activity_code  => 'U' ,  /* 'D' (not 'U'), because the link is being end-dated (functional delete) -- Changed to 'U' spusegao 10-17-2003 */
        x_audit_id              => lx_audit_id,
        x_return_status         => lx_return_status,
        x_msg_count             => lx_msg_count ,
        x_msg_data              => lx_msg_data );

        IF (lx_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
     	  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   	END IF;
        END IF; -- for object_type check

   End If; -- (p_link_id IS NOT NULL)

   -- populate the link record that will be passed to the create link proc to create the new links

   l_link_rec.subject_id             := nvl(p_link_rec.subject_id, l_old_values_rec.subject_id );
   l_link_rec.subject_type           := nvl(p_link_rec.subject_type, l_old_values_rec.subject_type );
   l_link_rec.object_id              := nvl(p_link_rec.object_id, l_old_values_rec.object_id );
   l_link_rec.object_type            := nvl(p_link_rec.object_type, l_old_values_rec.object_type );
   l_link_rec.object_number          := nvl(p_link_rec.object_number, l_old_values_rec.object_number );
   l_link_rec.link_type_id           := nvl(p_link_rec.link_type_id, l_old_values_rec.link_type_id );
   l_link_rec.request_id             := nvl(p_link_rec.request_id, l_old_values_rec.request_id );
   l_link_rec.program_application_id := nvl(p_link_rec.program_application_id,
					       l_old_values_rec.program_application_id );
   l_link_rec.program_id             := nvl(p_link_rec.program_id, l_old_values_rec.program_id );
   l_link_rec.program_update_date    := nvl(p_link_rec.program_update_date,
					       l_old_values_rec.program_update_date );

   -- For bugs 2972584 and 2972611
   -- For columns initialized to FND_API.G_MISS_CHAR, if FND_API.G_MISS_CHAR is passed, populate with old value in database
   If p_link_rec.link_segment1 = FND_API.G_MISS_CHAR Then
     l_link_rec.link_segment1 		:= l_old_values_rec.attribute1;
   Else
      l_link_rec.link_segment1      	:= p_link_rec.link_segment1;
   End If;

   If p_link_rec.link_segment2 = FND_API.G_MISS_CHAR Then
     l_link_rec.link_segment2 		:= l_old_values_rec.attribute2;
   Else
      l_link_rec.link_segment2      	:= p_link_rec.link_segment2;
   End If;

   If p_link_rec.link_segment3 = FND_API.G_MISS_CHAR Then
     l_link_rec.link_segment3 		:= l_old_values_rec.attribute3;
   Else
      l_link_rec.link_segment3      	:= p_link_rec.link_segment3;
   End If;

   If p_link_rec.link_segment4 = FND_API.G_MISS_CHAR Then
     l_link_rec.link_segment4 		:= l_old_values_rec.attribute4;
   Else
      l_link_rec.link_segment4      	:= p_link_rec.link_segment4;
   End If;

   If p_link_rec.link_segment5 = FND_API.G_MISS_CHAR Then
     l_link_rec.link_segment5 		:= l_old_values_rec.attribute5;
   Else
      l_link_rec.link_segment5      	:= p_link_rec.link_segment5;
   End If;

   If p_link_rec.link_segment6 = FND_API.G_MISS_CHAR Then
     l_link_rec.link_segment6 		:= l_old_values_rec.attribute6;
   Else
      l_link_rec.link_segment6      	:= p_link_rec.link_segment6;
   End If;

   If p_link_rec.link_segment7 = FND_API.G_MISS_CHAR Then
     l_link_rec.link_segment7 		:= l_old_values_rec.attribute7;
   Else
      l_link_rec.link_segment7      	:= p_link_rec.link_segment7;
   End If;

   If p_link_rec.link_segment8 = FND_API.G_MISS_CHAR Then
     l_link_rec.link_segment8 		:= l_old_values_rec.attribute8;
   Else
      l_link_rec.link_segment8      	:= p_link_rec.link_segment8;
   End If;

   If p_link_rec.link_segment9 = FND_API.G_MISS_CHAR Then
     l_link_rec.link_segment9 		:= l_old_values_rec.attribute9;
   Else
      l_link_rec.link_segment9      	:= p_link_rec.link_segment9;
   End If;

   If p_link_rec.link_segment10 = FND_API.G_MISS_CHAR Then
     l_link_rec.link_segment10 		:= l_old_values_rec.attribute10;
   Else
      l_link_rec.link_segment10     	:= p_link_rec.link_segment10;
   End If;

    If p_link_rec.link_segment11 = FND_API.G_MISS_CHAR Then
     l_link_rec.link_segment11 		:= l_old_values_rec.attribute11;
   Else
      l_link_rec.link_segment11     	:= p_link_rec.link_segment11;
   End If;

   If p_link_rec.link_segment12 = FND_API.G_MISS_CHAR Then
     l_link_rec.link_segment12 		:= l_old_values_rec.attribute12;
   Else
      l_link_rec.link_segment12     	:= p_link_rec.link_segment12;
   End If;

   If p_link_rec.link_segment13 = FND_API.G_MISS_CHAR Then
     l_link_rec.link_segment13 		:= l_old_values_rec.attribute13;
   Else
      l_link_rec.link_segment13     	:= p_link_rec.link_segment13;
   End If;

   If p_link_rec.link_segment14 = FND_API.G_MISS_CHAR Then
     l_link_rec.link_segment14 		:= l_old_values_rec.attribute14;
   Else
      l_link_rec.link_segment14     	:= p_link_rec.link_segment14;
   End If;

   If p_link_rec.link_segment15 = FND_API.G_MISS_CHAR Then
     l_link_rec.link_segment15 		:= l_old_values_rec.attribute15;
   Else
      l_link_rec.link_segment15     	:= p_link_rec.link_segment15;
   End If;

   If p_link_rec.link_context = FND_API.G_MISS_CHAR Then
     l_link_rec.link_context 		:= l_old_values_rec.context;
   Else
      l_link_rec.link_context       	:= p_link_rec.link_context;
   End If;

   -- The following assignments were added to resolve bugs 2972584 and 2972611
   -- For columns initialized to NULL, if FND_API.G_MISS_CHAR/NUM is passed, populate with NULL
   -- For the same columns, if NULL is passed, store the old value in the database
   If p_link_rec.from_incident_id = FND_API.G_MISS_NUM Then
     l_link_rec.from_incident_id	:= NULL;
   Else
     l_link_rec.from_incident_id       := nvl(p_link_rec.subject_id, l_old_values_rec.subject_id);
   End If;

   If p_link_rec.from_incident_number = FND_API.G_MISS_CHAR Then
     l_link_rec.from_incident_number	:= NULL;
   Else
     l_link_rec.from_incident_number	:= nvl(p_link_rec.from_incident_number, l_old_values_rec.from_incident_number);
   End If;

   If p_link_rec.to_incident_id = FND_API.G_MISS_NUM Then
     l_link_rec.to_incident_id		:= NULL;
   Else
     l_link_rec.to_incident_id		:= nvl(p_link_rec.object_id, l_old_values_rec.object_id);
   End If;

   If p_link_rec.to_incident_number = FND_API.G_MISS_CHAR Then
     l_link_rec.to_incident_number	:= NULL;
   Else
     l_link_rec.to_incident_number     := nvl(p_link_rec.object_number, l_old_values_rec.object_number);
   End If;

   -- For bugs 2972584 and 2972611
   -- Check if the link being updated is an external link

   IF (l_old_values_rec.subject_type <> 'SR' OR l_old_values_rec.object_type <> 'SR') THEN

   -- If the link to be updated is an external one and an external link ID is not passed,
   -- then derive the external link corresponding to the passed internal link ID

   	IF (p_link_rec.link_id_ext IS NULL) THEN
	  Begin
	    Select link_id
	    Into l_Derived_External_Link_Id
	    From cs_incident_links_ext
	    Where from_incident_id = l_old_values_rec.subject_id
	    And (to_object_id = l_old_values_rec.object_id OR
	         to_object_number = l_old_values_rec.object_number)
	    And to_object_type = l_old_values_rec.object_type;

	  Exception
		When NO_DATA_FOUND then
			-- Check if the external link was created from the reciprocal link
			Begin
			   Select link_id
		   	   Into l_Derived_External_Link_Id
		   	   From cs_incident_links_ext
	     		   Where from_incident_id = l_old_values_rec.object_id
		   	   And to_object_id = l_old_values_rec.subject_id
		   	   And to_object_type = l_old_values_rec.subject_type;
		   	Exception
		   		When OTHERS THEN
		   		  -- Raise an error on parameter p_link_id since old_values_rec was populated based on its value
		  		  CS_ServiceRequest_UTIL.Add_Invalid_Argument_Msg(
		    		  p_token_an	=>  l_api_name_full,
		    		  p_token_v	=>  to_char(p_link_id),
		    		  p_token_p	=>  'p_link_id'
		  		  );
				  RAISE FND_API.G_EXC_ERROR;
			End;
		When OTHERS THEN
		  CS_ServiceRequest_UTIL.Add_Invalid_Argument_Msg(
		    p_token_an	=>  l_api_name_full,
		    p_token_v	=>  to_char(p_link_id),
		    p_token_p	=>  'p_link_id'
		  );
		RAISE FND_API.G_EXC_ERROR;
	  End;
   	END IF; -- (p_link_rec.link_id_ext IS NULL)

     IF (l_link_rec.subject_type <> 'SR' OR l_link_rec.object_type <> 'SR') THEN
        -- If the external link is being updated to an external link, then update the old external link record with the new values
        -- Standard start of API savepoint
	SAVEPOINT Update_IncidentLink_Ext_PVT;

    	BEGIN
            Update cs_incident_links_ext
            Set from_incident_id  = l_link_rec.from_incident_id,
                to_object_id      = l_link_rec.object_id,
                to_object_number  = l_link_rec.object_number,
                to_object_type    = l_link_rec.object_type,
                last_update_date  = sysdate,
                last_updated_by   = p_user_id,
                last_update_login = p_login_id,
                attribute1        = l_link_rec.link_segment1,
                attribute2        = l_link_rec.link_segment2,
                attribute3        = l_link_rec.link_segment3,
                attribute4        = l_link_rec.link_segment4,
                attribute5        = l_link_rec.link_segment5,
                attribute6        = l_link_rec.link_segment6,
                attribute7        = l_link_rec.link_segment7,
                attribute8        = l_link_rec.link_segment8,
                attribute9        = l_link_rec.link_segment9,
                attribute10       = l_link_rec.link_segment10,
                context           = l_link_rec.link_context
            where link_id = nvl(p_link_rec.link_id_ext,l_Derived_External_Link_Id);
    	EXCEPTION
		When OTHERS THEN
			Rollback to Update_IncidentLink_Ext_PVT;
			CS_ServiceRequest_UTIL.Add_Invalid_Argument_Msg(
				p_token_an     =>  l_api_name_full,
				p_token_v =>  to_char(nvl(p_link_rec.link_id_ext,l_Derived_External_Link_Id)),
				p_token_p =>  'p_link_rec.link_id_ext OR l_Derived_External_Link_Id'
			);
			RAISE FND_API.G_EXC_ERROR;
    	END;

     ELSE
        -- If the external link is being updated to an internal link, then delete the old external link record
        -- Standard start of API savepoint
	SAVEPOINT Delete_IncidentLink_Ext_PVT;

	BEGIN
		Delete From cs_incident_links_ext
	       	Where link_id = nvl(p_link_rec.link_id_ext, l_Derived_External_Link_Id);

	EXCEPTION
		When OTHERS THEN
			Rollback to Delete_IncidentLink_Ext_PVT;
			CS_ServiceRequest_UTIL.Add_Invalid_Argument_Msg(
				p_token_an     =>  l_api_name_full,
				p_token_v =>  to_char(nvl(p_link_rec.link_id_ext, l_Derived_External_Link_Id)),
				p_token_p =>  'p_link_rec.link_id_ext OR l_Derived_External_Link_Id'
			);
			RAISE FND_API.G_EXC_ERROR;

	END;

     END IF;  -- (l_link_rec.subject_type <> 'SR' OR l_link_rec.object_type <> 'SR')

   END IF; -- (l_old_values_rec.subject_type <> 'SR' OR l_old_values_rec.object_type <> 'SR')

   -- Invoke the create link proc. to create a new link with the update link information
   -- The validation level is NONE, because all the validations are already performed

   CREATE_INCIDENTLINK (
      P_API_VERSION		=> 2.0,
      P_INIT_MSG_LIST     	=> p_init_msg_list,
      P_COMMIT     		=> p_commit,
      P_VALIDATION_LEVEL  	=> p_validation_level,
      P_RESP_APPL_ID		=> p_resp_appl_id,
      P_RESP_ID		        => p_resp_id, -- not used
      P_USER_ID		        => p_user_id, -- not used
      P_LOGIN_ID		=> p_login_id,
      P_ORG_ID		        => p_org_id, -- not used
      P_LINK_REC                => l_link_rec,
      X_RETURN_STATUS	        => x_return_status,
      X_MSG_COUNT		=> x_msg_count,
      X_MSG_DATA		=> x_msg_data,
      X_OBJECT_VERSION_NUMBER   => lx_object_version_number,
      X_RECIPROCAL_LINK_ID      => lx_reciprocal_link_id,
      X_LINK_ID			=> lx_link_id );

   -- not checking for return status here, because if there is an error, the create proc.
   -- will raise an exception and stop execution.
   -- To be on the safe side, before commiting, included the check for return_status from
   -- the create proc. in case there was an error in the create proc that did not raise
   -- any exception.

   x_object_version_number := lx_object_version_number ;
   IF ( FND_API.To_Boolean(p_commit) AND
	x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
      COMMIT WORK;
   END IF;

   --
   -- Standard call to get message count and if count is 1, get message info
   --
   FND_MSG_PUB.Count_And_Get(
      p_count => x_msg_count,
      p_data  => x_msg_data);

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO UPDATE_INCIDENTLINK_PVT;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(
      p_count => x_msg_count,
      p_data  => x_msg_data);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO UPDATE_INCIDENTLINK_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(
         p_count => x_msg_count,
         p_data  => x_msg_data);

   WHEN OTHERS THEN
      ROLLBACK TO UPDATE_INCIDENTLINK_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MESSAGE.SET_NAME ('CS', 'CS_API_SR_UNKNOWN_ERROR');
      FND_MESSAGE.SET_TOKEN ('P_TEXT',l_api_name_full||'-'||SQLERRM);
      FND_MSG_PUB.ADD;
      FND_MSG_PUB.Count_And_Get(
         p_count => x_msg_count,
         p_data  => x_msg_data);

END update_incidentlink;

   -- New, overloaded procedure with the 11.5.9 signature added for bugs 2972584 and 2972611
   -- This procedure just calls the other Delete_IncidentLink procedure and passes a NULL value for the parameter P_LINK_ID_EXT
PROCEDURE DELETE_INCIDENTLINK (
      P_API_VERSION		IN     NUMBER,
      P_INIT_MSG_LIST	        IN     VARCHAR2 := FND_API.G_FALSE,
      P_COMMIT			IN     VARCHAR2 := FND_API.G_FALSE,
      P_VALIDATION_LEVEL        IN     NUMBER   := FND_API.G_VALID_LEVEL_FULL, -- not used
      P_RESP_APPL_ID		IN     NUMBER   := NULL, -- not used
      P_RESP_ID			IN     NUMBER   := NULL, -- not used
      P_USER_ID			IN     NUMBER   := NULL,
      P_LOGIN_ID		IN     NUMBER   := FND_API.G_MISS_NUM,
      P_ORG_ID			IN     NUMBER   := NULL, -- not used
      P_LINK_ID			IN     NUMBER,           -- no change
      X_RETURN_STATUS	        OUT NOCOPY   VARCHAR2,
      X_MSG_COUNT		OUT NOCOPY   NUMBER,
      X_MSG_DATA		OUT NOCOPY   VARCHAR2 )
IS

   l_api_name		        CONSTANT VARCHAR2(30) := 'DELETE_INCIDENTLINK_1';
   l_api_name_full	        CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||l_api_name;

BEGIN
   -- Invoke the private delete API and pass the derived internal link ID
   	CS_INCIDENTLINKS_PVT.DELETE_INCIDENTLINK (
	   P_API_VERSION		=> P_API_VERSION,
	   P_INIT_MSG_LIST	        => p_init_msg_list,
	   P_COMMIT			=> p_commit,
	   P_VALIDATION_LEVEL		=> FND_API.G_VALID_LEVEL_FULL, -- not used
	   P_RESP_APPL_ID		=> p_resp_appl_id, -- not used
	   P_RESP_ID			=> p_resp_id, -- not used
	   P_USER_ID			=> p_user_id,
	   P_LOGIN_ID			=> p_login_id,
	   P_ORG_ID			=> p_org_id, -- not used
	   P_LINK_ID			=> P_LINK_ID,
	   X_RETURN_STATUS	        => x_return_status,
	   X_MSG_COUNT			=> x_msg_count,
	   X_MSG_DATA			=> x_msg_data,
	   P_LINK_ID_EXT		=> NULL ); -- Added for bugs 2972584 and 2972611, to pass the external link ID

EXCEPTION
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MESSAGE.SET_NAME ('CS', 'CS_API_SR_UNKNOWN_ERROR');
      FND_MESSAGE.SET_TOKEN ('P_TEXT',l_api_name_full||'-'||SQLERRM);
      FND_MSG_PUB.ADD;
      FND_MSG_PUB.Count_And_Get(
	 p_count => x_msg_count,
	 p_data  => x_msg_data);
END;

-- When deleting a link, the link record is not removed from the the table cs_incident_links, it is end dated.
-- In the case of an external link, it is deleted from the table cs_incident_links_ext.

PROCEDURE DELETE_INCIDENTLINK (
   P_API_VERSION		IN     NUMBER,
   P_INIT_MSG_LIST	        IN     VARCHAR2,
   P_COMMIT			IN     VARCHAR2,
   P_VALIDATION_LEVEL           IN     NUMBER, -- not used
   P_RESP_APPL_ID		IN     NUMBER, -- not used
   P_RESP_ID			IN     NUMBER, -- not used
   P_USER_ID			IN     NUMBER,
   P_LOGIN_ID		        IN     NUMBER,
   P_ORG_ID			IN     NUMBER, -- not used
   P_LINK_ID			IN     NUMBER, -- no change
   X_RETURN_STATUS	        OUT NOCOPY   VARCHAR2,
   X_MSG_COUNT		        OUT NOCOPY   NUMBER,
   X_MSG_DATA		        OUT NOCOPY   VARCHAR2,
   P_LINK_ID_EXT                IN     NUMBER ) -- Added for bugs 2972584 and 2972611
IS
   l_api_name		        CONSTANT VARCHAR2(30) := 'DELETE_INCIDENTLINK';
   l_api_name_full	        CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||l_api_name;

   -- Commented out to allow this procedure to be called with both the versions 1.2 and 2.0 (bugs 2972584 and 2972611)
   --l_api_version		CONSTANT NUMBER := 2.0;

   -- local variables for the Business events OUT parameters; Using local variables for
   -- the standard out params, return_status, msg_count and msg_data because, if the
   -- BES API return back a failure status, it means only that the BES raise event has
   -- failed, and has nothing to do with the creation of the link.
   lx_wf_process_id            NUMBER; -- not used in links BES, but in calls to BES from
				       -- the SR API, this is used to stamp the WF process
				       -- id in the SR Header table.
   lx_return_status            VARCHAR2(3);
   lx_msg_count                NUMBER;
   lx_msg_data                 VARCHAR2(4000);

   -- get the details of the link records that is to be deleted; this will be used to pass
   -- to populate local rec. type l_link_rec
   cursor c1 is
   select *
   from   cs_incident_links
   where  link_id = p_link_id;

   c1rec                        C1%ROWTYPE;
   -- local rec. type that will be passed to the BES API.
   l_link_rec                   CS_INCIDENT_LINK_REC_TYPE;
   l_reciprocal_link_type_id    NUMBER; -- to be used to store the reci. link type id to be
					-- passed to the BES wrapper to raise the event for
					-- the reci. link being deleted
   l_subject_number             VARCHAR2(90);

   -- For bugs 2972584 and 2972611
   -- Variable to store the derived internal link ID corresponding to the
   l_Derived_External_Link_Id		NUMBER;

   -- For bugs 2972584 and 2972611
   -- Variable to store the value passed-in as API version
   l_invoked_version           NUMBER;

BEGIN
   -- Standard start of API savepoint
   SAVEPOINT Delete_IncidentLink_PVT;

   -- Initialize message list if p_init_msg_list is set to TRUE
   IF FND_API.To_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.Initialize;
   END IF;

   -- Allow this API to be called with both version numbers, 1.2 and 2.0, introduced for bugs 2972584 and 2972611
   IF p_api_version = 1.2 THEN
   	  l_invoked_version := 1.2;
   ELSIF p_api_version = 2.0 THEN
      l_invoked_version := 2.0;
   END IF;

   -- Standard call to check for call compatibility, changed so that both versions 1.2 and 2.0 may be allowed
   IF NOT FND_API.Compatible_API_Call(l_invoked_version, p_api_version,
						   l_api_name, G_PKG_NAME) THEN
      FND_MSG_PUB.Count_And_Get(
	 p_count => x_msg_count,
	 p_data  => x_msg_data);
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   open  c1;
   fetch c1 into c1rec;

   if ( c1%NOTFOUND ) then
      -- Nested If condition added for bugs 2972584 and 2972611
      -- Raise error only if no external link ID has been passed
      if (p_link_id_ext IS NULL) then
        close c1;
        CS_ServiceRequest_UTIL.Add_Invalid_Argument_Msg(
         p_token_an	=>  l_api_name_full,
         p_token_v	=>  to_char(p_link_id),
         p_token_p	=>  'p_link_id'
         );
        RAISE FND_API.G_EXC_ERROR;
      end if; -- (p_link_id_ext IS NULL)
   end if; -- ( c1%NOTFOUND )

   close c1;

   -- Service security implementation for Delete link
   -- Included check for Service Security introduced in R11.5.10.
   -- The validation is to make sure that the responsibility creating
   -- the link, has access to the subject and/or object if they are
   -- service requests

   if ( c1rec.subject_type = 'SR' ) then
      cs_incidentlinks_util.validate_sr_sec_access (
         p_incident_id        => c1rec.subject_id,
         x_return_status      => x_return_status,
         x_msg_count          => x_msg_count,
         x_msg_data           => x_msg_data );

      if ( x_return_status <> FND_API.G_RET_STS_SUCCESS ) then
         -- Responsibility RESP_NAME does not have access to service
         -- request SR_NUMBER.
         RAISE FND_API.G_EXC_ERROR;
      end if;
   end if;

   if ( c1rec.object_type = 'SR' ) then
      cs_incidentlinks_util.validate_sr_sec_access (
         p_incident_id        => c1rec.object_id,
         x_return_status      => x_return_status,
         x_msg_count          => x_msg_count,
         x_msg_data           => x_msg_data );

      if ( x_return_status <> FND_API.G_RET_STS_SUCCESS ) then
         -- Responsibility RESP_NAME does not have access to service
         -- request SR_NUMBER.
         RAISE FND_API.G_EXC_ERROR;
      end if;
   end if;
   --
   -- END OF SECURITY ACCESS CHECK FOR R11.5.10


   -- end date the link and its reciprocal, only if an internal link ID was passed (for bugs 2972584 and 2972611)
   if ( p_link_id IS NOT NULL) then
     UPDATE CS_INCIDENT_LINKS  SET
        end_date_active          = SYSDATE,
        last_update_date         = SYSDATE,
        last_updated_by          = p_user_id,
        last_update_login        = p_login_id,
        object_version_number    = object_version_number + 1
     WHERE link_id               IN ( p_link_id, c1rec.reciprocal_link_id );
   end if; -- ( p_link_id IS NOT NULL)

   -- For bugs 2972584 and 2972611
   -- Check if the details are for an external link, and if no external link ID is passed, then derive the corresponding
   -- external link ID so that the same may be deleted from the CS_Incident_Links_Ext table

   	IF ( c1rec.subject_type <> 'SR' OR c1rec.object_type <> 'SR' ) THEN

   	  IF ( p_link_id_ext IS NULL ) THEN

	    Begin

	      Select link_id
		  Into l_Derived_External_Link_Id
		  From cs_incident_links_ext
		  Where from_incident_id = c1rec.subject_id
		  And (to_object_id = c1rec.object_id OR
		       to_object_number = c1rec.object_number)
		  And to_object_type = c1rec.object_type;

	     Exception
		  When NO_DATA_FOUND Then
		  -- Check if the external link was created from the reciprocal link
		    Begin
		      Select link_id
		      Into l_Derived_External_Link_Id
		      From cs_incident_links_ext
		      Where from_incident_id = c1rec.object_id
		      And to_object_id = c1rec.subject_id
		      And to_object_type = c1rec.subject_type;
		    Exception
		      When No_Data_Found Then
			Null;
		    End;

		  When OTHERS Then
			CS_ServiceRequest_UTIL.Add_Invalid_Argument_Msg(
				p_token_an     =>  l_api_name_full,
				p_token_v =>  to_char(l_Derived_External_Link_Id),
				p_token_p =>  'l_Derived_External_Link_Id'
			);
			RAISE FND_API.G_EXC_ERROR;
	       End;

	    END IF; -- ( p_link_id_ext IS NULL )

        -- Delete the external link from the _EXT table

	-- Standard start of API savepoint
		SAVEPOINT Delete_IncidentLink_Ext_PVT;

		BEGIN
			Delete From cs_incident_links_ext
	        	Where link_id = nvl(p_link_id_ext, l_Derived_External_Link_Id);

		EXCEPTION
			when OTHERS THEN
				Rollback to Delete_IncidentLink_Ext_PVT;
				CS_ServiceRequest_UTIL.Add_Invalid_Argument_Msg(
					p_token_an     =>  l_api_name_full,
					p_token_v =>  to_char(nvl(p_link_id_ext, l_Derived_External_Link_Id)),
					p_token_p =>  'p_link_id_ext OR l_Derived_External_Link_Id'
				);
				RAISE FND_API.G_EXC_ERROR;

		END;
	END IF; -- ( c1rec.subject_type <> 'SR' OR c1rec.object_type <> 'SR' )

    -- (5250937)
   -- IF FND_API.To_Boolean(p_commit) THEN
   --    COMMIT WORK;
      -- Recreating a savepoint, coz if the BES fails with an unhandled exception, then the
      -- when others in this proc. tries to rollback to the delete savepoint. Since the
      -- commit has happened, the context of the savepoint is lost. By re-creating it here,
      -- there is no loss, and will avoid the ORA-1086 error.
   --    SAVEPOINT Delete_IncidentLink_PVT;

   -- 5250937_eof
      -- *************
      -- Raise BES event that link is deleted. (Only after commit???)
      -- Populate the link rec with the values of the cursor variable
      -- *************
      -- get the subject number from the SR table. For 1159, a link with SR as its subject
      -- can be updated.

	  -- If condition added as part of bug fix for bugs 2972584 and 2972611
	  -- Raise the business events only if the version of the procedure invoked is >= 2.0
	  IF (p_api_version >= 2.0) THEN

	      select max(incident_number)
	      into   l_subject_number
	      from   cs_incidents_all_b
	      where  incident_id = c1rec.subject_id;

	      l_link_rec.OBJECT_ID               := c1rec.object_id;
	      l_link_rec.OBJECT_NUMBER           := c1rec.object_number;
	      l_link_rec.OBJECT_TYPE             := c1rec.object_type;
	      l_link_rec.LINK_TYPE_ID            := c1rec.link_type_id;
	      l_link_rec.LINK_TYPE               := c1rec.link_type;
	      l_link_rec.REQUEST_ID              := c1rec.request_id;
	      l_link_rec.PROGRAM_APPLICATION_ID  := c1rec.program_application_id;
	      l_link_rec.PROGRAM_ID              := c1rec.program_id;
	      l_link_rec.PROGRAM_UPDATE_DATE     := c1rec.program_update_date;
	      l_link_rec.LINK_SEGMENT1           := c1rec.attribute1;
	      l_link_rec.LINK_SEGMENT2           := c1rec.attribute2;
	      l_link_rec.LINK_SEGMENT3           := c1rec.attribute3;
	      l_link_rec.LINK_SEGMENT4           := c1rec.attribute4;
	      l_link_rec.LINK_SEGMENT5           := c1rec.attribute5;
	      l_link_rec.LINK_SEGMENT6           := c1rec.attribute6;
	      l_link_rec.LINK_SEGMENT7           := c1rec.attribute7;
	      l_link_rec.LINK_SEGMENT8           := c1rec.attribute8;
	      l_link_rec.LINK_SEGMENT9           := c1rec.attribute9;
	      l_link_rec.LINK_SEGMENT10          := c1rec.attribute10;
	      l_link_rec.LINK_SEGMENT11          := c1rec.attribute11;
	      l_link_rec.LINK_SEGMENT12          := c1rec.attribute12;
	      l_link_rec.LINK_SEGMENT13          := c1rec.attribute13;
	      l_link_rec.LINK_SEGMENT14          := c1rec.attribute14;
	      l_link_rec.LINK_SEGMENT15          := c1rec.attribute15;
	      l_link_rec.LINK_CONTEXT            := c1rec.context;

	      CS_WF_EVENT_PKG.RAISE_SERVICEREQUEST_EVENT(
		 p_api_version           => 1.0,
		 p_init_msg_list         => FND_API.G_TRUE,
		 p_commit                => p_commit,
		 p_validation_level      => FND_API.G_VALID_LEVEL_FULL,
	         p_event_code            => 'RELATIONSHIP_DELETE_FOR_SR',
	         p_incident_number       => l_subject_number,
	         p_user_id               => p_user_id,
	         p_resp_id               => p_resp_id,
	         p_resp_appl_id          => p_resp_appl_id,
	         p_link_rec              => l_link_rec,
	         p_wf_process_id         => NULL,  -- using default value
	         p_owner_id		 => NULL,  -- using default value
	         p_wf_manual_launch	 => 'N' ,  -- using default value
	         x_wf_process_id         => lx_wf_process_id,
	         x_return_status         => lx_return_status,
	         x_msg_count             => lx_msg_count,
	         x_msg_data              => lx_msg_data );

	      if ( lx_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
		 -- do nothing in this API. The BES wrapper API will have to trap this
		 -- situation and send a notification to the SR owner that the BES has
		 -- not been raised. If the BES API return back a failure status, it
		 -- means only that the BES raise event has failed, and has nothing to
		 -- do with the deletion of the link.
		 null;
	      end if;

	      -- populate a link rec. to pass to the BES wrapper API to raise the event that the
	      -- reciprocal link is deleted
	      -- fetch the reciprocal link_type_id to be passed to the BES API. This select has to be
	      -- a success, but to avoid no data found, using max
	      select max(reciprocal_link_type_id)
	      into   l_reciprocal_link_type_id
	      from   cs_sr_link_types_b
	      where  link_type_id = c1rec.link_type_id;

	      l_link_rec.OBJECT_ID               := c1rec.subject_id;
	      l_link_rec.OBJECT_NUMBER           := l_subject_number;
	      l_link_rec.OBJECT_TYPE             := c1rec.subject_type;
	      l_link_rec.LINK_TYPE_ID            := l_reciprocal_link_type_id;
	      l_link_rec.LINK_TYPE               := c1rec.link_type; -- use the same as it is ignored
	      l_link_rec.REQUEST_ID              := c1rec.request_id;
	      l_link_rec.PROGRAM_APPLICATION_ID  := c1rec.program_application_id;
	      l_link_rec.PROGRAM_ID              := c1rec.program_id;
	      l_link_rec.PROGRAM_UPDATE_DATE     := c1rec.program_update_date;
	      l_link_rec.LINK_SEGMENT1           := c1rec.attribute1;
	      l_link_rec.LINK_SEGMENT2           := c1rec.attribute2;
	      l_link_rec.LINK_SEGMENT3           := c1rec.attribute3;
	      l_link_rec.LINK_SEGMENT4           := c1rec.attribute4;
	      l_link_rec.LINK_SEGMENT5           := c1rec.attribute5;
	      l_link_rec.LINK_SEGMENT6           := c1rec.attribute6;
	      l_link_rec.LINK_SEGMENT7           := c1rec.attribute7;
	      l_link_rec.LINK_SEGMENT8           := c1rec.attribute8;
	      l_link_rec.LINK_SEGMENT9           := c1rec.attribute9;
	      l_link_rec.LINK_SEGMENT10          := c1rec.attribute10;
	      l_link_rec.LINK_SEGMENT11          := c1rec.attribute11;
	      l_link_rec.LINK_SEGMENT12          := c1rec.attribute12;
	      l_link_rec.LINK_SEGMENT13          := c1rec.attribute13;
	      l_link_rec.LINK_SEGMENT14          := c1rec.attribute14;
	      l_link_rec.LINK_SEGMENT15          := c1rec.attribute15;
	      l_link_rec.LINK_CONTEXT            := c1rec.context;

	      CS_WF_EVENT_PKG.RAISE_SERVICEREQUEST_EVENT(
		 p_api_version           => 1.0,
		 p_init_msg_list         => FND_API.G_TRUE,
		 p_commit                => p_commit,
		 p_validation_level      => FND_API.G_VALID_LEVEL_FULL,
	         p_event_code            => 'RELATIONSHIP_DELETE_FOR_SR',
	         p_incident_number       => c1rec.object_number,
	         p_user_id               => p_user_id,
	         p_resp_id               => p_resp_id,
	         p_resp_appl_id          => p_resp_appl_id,
	         p_link_rec              => l_link_rec,
	         p_wf_process_id         => NULL,  -- using default value
	         p_owner_id		 => NULL,  -- using default value
	         p_wf_manual_launch	 => 'N' ,  -- using default value
	         x_wf_process_id         => lx_wf_process_id,
	         x_return_status         => lx_return_status,
	         x_msg_count             => lx_msg_count,
	         x_msg_data              => lx_msg_data );

	      if ( lx_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
		 -- do nothing in this API. The BES wrapper API will have to trap this
		 -- situation and send a notification to the SR owner that the BES has
		 -- not been raised. If the BES API return back a failure status, it
		 -- means only that the BES raise event has failed, and has nothing to
		 -- do with the deletion of the link.
		 null;
	      end if; -- ( lx_return_status <> FND_API.G_RET_STS_SUCCESS )
      END IF; -- (p_api_version >= 2.0)

   -- 5250937
   IF FND_API.To_Boolean(p_commit) THEN
       COMMIT WORK;
   END IF; -- FND_API.To_Boolean(p_commit)
   -- 5250937_eof

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO SAVEPOINT Delete_IncidentLink_PVT;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(
      p_count => x_msg_count,
      p_data  => x_msg_data);

   WHEN OTHERS THEN
      ROLLBACK TO SAVEPOINT Delete_IncidentLink_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MESSAGE.SET_NAME ('CS', 'CS_API_SR_UNKNOWN_ERROR');
      FND_MESSAGE.SET_TOKEN ('P_TEXT',l_api_name_full||'-'||SQLERRM);
      FND_MSG_PUB.ADD;
      FND_MSG_PUB.Count_And_Get(
	 p_count => x_msg_count,
	 p_data  => x_msg_data);

END DELETE_INCIDENTLINK;


PROCEDURE get_doc_number (
   s_sql_statement      in         varchar2,
   s_doc_number         out NOCOPY varchar2)
is
  type doc_type is REF CURSOR;
  doc_cursor doc_type;
/* This is an implementation of NDS Native Dynamic SQL */
begin

    open doc_cursor for s_sql_statement;

    fetch doc_cursor into  s_doc_number;

    if doc_cursor%NOTFOUND then
	    null;    -- Hardcode
    end if;

    close doc_cursor;

end get_doc_number;

PROCEDURE get_doc_details (
   s_sql_statement		in             varchar2,
   s_doc_id			out NOCOPY     number,
   s_doc_number			out NOCOPY     varchar2,
   s_doc_severity		out NOCOPY     varchar2,
   s_doc_status			out NOCOPY     varchar2,
   s_doc_summary		out NOCOPY     varchar2,
   s_doc_prod			out NOCOPY     varchar2,
   s_doc_prod_desc		out NOCOPY     varchar2)
is

  type doc_type is REF CURSOR;
  doc_cursor doc_type;
/* This is an implementation of NDS Native Dynamic SQL */

begin

    open doc_cursor for s_sql_statement;

    fetch doc_cursor into s_doc_id, s_doc_number, s_doc_severity,
					   s_doc_status,s_doc_summary,
					   s_doc_prod,s_doc_prod_desc;

    if doc_cursor%NOTFOUND then
	    null;    -- Hardcode
    end if;

    close doc_cursor;

end get_doc_details;

/* The _EXT procedures are obsoleted for 11.5.9. All external links in 11.5.9 will
be stored in table cs_incident_links. Procedures are not dropped, rather their
implementations will be stubbed out for backward compatability
********************/

PROCEDURE CREATE_INCIDENTLINK_EXT (
   P_API_VERSION		IN     NUMBER,
   P_INIT_MSG_LIST     	        IN     VARCHAR2,
   P_COMMIT     		IN     VARCHAR2,
   P_VALIDATION_LEVEL  	        IN     NUMBER,
   P_RESP_APPL_ID		IN     NUMBER,
   P_RESP_ID		        IN     NUMBER,
   P_USER_ID		        IN     NUMBER,
   P_LOGIN_ID		        IN     NUMBER,
   P_ORG_ID		        IN     NUMBER,
   P_FROM_INCIDENT_ID	        IN     NUMBER,
   P_TO_OBJECT_ID		IN     NUMBER,
   P_TO_OBJECT_NUMBER	        IN     VARCHAR2,
   P_TO_OBJECT_TYPE	        IN     VARCHAR2,
   P_LINK_SEGMENT1		IN     VARCHAR2,
   P_LINK_SEGMENT2		IN     VARCHAR2,
   P_LINK_SEGMENT3		IN     VARCHAR2,
   P_LINK_SEGMENT4		IN     VARCHAR2,
   P_LINK_SEGMENT5		IN     VARCHAR2,
   P_LINK_SEGMENT6		IN     VARCHAR2,
   P_LINK_SEGMENT7		IN     VARCHAR2,
   P_LINK_SEGMENT8		IN     VARCHAR2,
   P_LINK_SEGMENT9		IN     VARCHAR2,
   P_LINK_SEGMENT10	        IN     VARCHAR2,
   P_LINK_CONTEXT		IN     VARCHAR2,
   X_LINK_ID		        OUT NOCOPY   NUMBER,
   X_RETURN_STATUS		OUT NOCOPY   VARCHAR2,
   X_MSG_COUNT		        OUT NOCOPY   NUMBER,
   X_MSG_DATA		        OUT NOCOPY   VARCHAR2 )
IS
BEGIN
   NULL;
END create_incidentlink_ext;

PROCEDURE UPDATE_INCIDENTLINK_EXT (
   P_API_VERSION		IN     NUMBER,
   P_INIT_MSG_LIST	        IN     VARCHAR2,
   P_COMMIT			IN     VARCHAR2,
   P_VALIDATION_LEVEL           IN     NUMBER,
   P_RESP_APPL_ID		IN     NUMBER,
   P_RESP_ID			IN     NUMBER,
   P_USER_ID			IN     NUMBER,
   P_LOGIN_ID		        IN     NUMBER,
   P_ORG_ID			IN     NUMBER,
   P_LINK_ID			IN     NUMBER,
   P_FROM_INCIDENT_ID	        IN     NUMBER,
   P_TO_OBJECT_ID		IN     NUMBER,
   P_TO_OBJECT_TYPE	        IN     VARCHAR2,
   P_LINK_SEGMENT1	        IN     VARCHAR2,
   P_LINK_SEGMENT2	        IN     VARCHAR2,
   P_LINK_SEGMENT3	        IN     VARCHAR2,
   P_LINK_SEGMENT4	        IN     VARCHAR2,
   P_LINK_SEGMENT5	        IN     VARCHAR2,
   P_LINK_SEGMENT6	        IN     VARCHAR2,
   P_LINK_SEGMENT7	        IN     VARCHAR2,
   P_LINK_SEGMENT8	        IN     VARCHAR2,
   P_LINK_SEGMENT9	        IN     VARCHAR2,
   P_LINK_SEGMENT10	        IN     VARCHAR2,
   P_LINK_CONTEXT		IN     VARCHAR2,
   X_RETURN_STATUS	        OUT NOCOPY   VARCHAR2,
   X_MSG_COUNT		        OUT NOCOPY   NUMBER,
   X_MSG_DATA		        OUT NOCOPY   VARCHAR2 )
IS
BEGIN
  NULL;
END update_incidentlink_ext;

PROCEDURE DELETE_INCIDENTLINK_EXT (
  P_API_VERSION		        IN     NUMBER,
  P_INIT_MSG_LIST	        IN     VARCHAR2,
  P_COMMIT			IN     VARCHAR2,
  P_VALIDATION_LEVEL            IN     NUMBER,
  P_RESP_APPL_ID		IN     NUMBER,
  P_RESP_ID			IN     NUMBER,
  P_USER_ID			IN     NUMBER,
  P_LOGIN_ID		        IN     NUMBER,
  P_ORG_ID			IN     NUMBER,
  P_LINK_ID			IN     NUMBER,
  X_RETURN_STATUS	        OUT NOCOPY   VARCHAR2,
  X_MSG_COUNT		        OUT NOCOPY   NUMBER,
  X_MSG_DATA		        OUT NOCOPY   VARCHAR2 )
IS
BEGIN
   NULL;
END delete_incidentlink_ext;

--------------------------------------------------------------------------------
--  Procedure Name            :   DELETE_INCIDENTLINK
--
--  Parameters (other than standard ones)
--  IN
--      p_object_type         :   Type of object for which this procedure is
--                                being called. (Here it will be 'SR')
--      p_processing_set_id   :   Id that helps the API in identifying the
--                                set of SRs for which the child objects have
--                                to be deleted.
--
--  Description
--      This procedure physically deletes all the links attached to a service
--      reqeust including the reciprocal links. The subject_id and object_id
--      are used to identify all the links in which an SR is participating.
--
--  HISTORY
--
----------------+------------+--------------------------------------------------
--  DATE        | UPDATED BY | Change Description
----------------+------------+--------------------------------------------------
--  2-Aug-2005  | varnaray   | Created
--              |            |
----------------+------------+--------------------------------------------------
/*#
 * This procedure physically deletes all the links attached to a service
 * reqeust including the reciprocal links. The subject_id and object_id are
 * used to identify all the links in which an SR is participating.
 * @param p_object_type Type of object for which this procedure is being
 * called. (Here it will be 'SR')
 * @param p_processing_set_id Id that helps the API in identifying the set
 * of SRs for which the child objects have to be deleted.
 * @rep:scope internal
 * @rep:product CS
 * @rep:displayname Delete Service Request Links
 */
PROCEDURE Delete_IncidentLink
(
  p_api_version_number IN  NUMBER := 1.0
, p_init_msg_list      IN  VARCHAR2 := FND_API.G_FALSE
, p_commit             IN  VARCHAR2 := FND_API.G_FALSE
, p_object_type        IN  VARCHAR2
, p_processing_set_id  IN  NUMBER
, x_return_status      OUT NOCOPY  VARCHAR2
, x_msg_count          OUT NOCOPY  NUMBER
, x_msg_data           OUT NOCOPY  VARCHAR2
)
IS
--------------------------------------------------------------------------------
L_API_VERSION   CONSTANT NUMBER       := 1.0;
L_API_NAME      CONSTANT VARCHAR2(30) := 'DELETE_INCIDENTLINK';
L_API_NAME_FULL CONSTANT VARCHAR2(61) := G_PKG_NAME || '.' || L_API_NAME;
L_LOG_MODULE    CONSTANT VARCHAR2(255):= 'cs.plsql.' || L_API_NAME_FULL || '.';

l_row_count     NUMBER := 0;

x_msg_index_out NUMBER;

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF fnd_log.level_procedure >= fnd_log.g_current_runtime_level
  THEN
    FND_LOG.String
    (
      fnd_log.level_procedure
    , L_LOG_MODULE || 'start'
    , 'Inside ' || L_API_NAME_FULL || ', called with parameters below:'
    );
    FND_LOG.String
    (
        fnd_log.level_procedure
    , L_LOG_MODULE || 'param 1'
    , 'p_api_version_number:' || p_api_version_number
    );
    FND_LOG.String
    (
        fnd_log.level_procedure
    , L_LOG_MODULE || 'param 2'
    , 'p_init_msg_list:' || p_init_msg_list
    );
    FND_LOG.String
    (
        fnd_log.level_procedure
    , L_LOG_MODULE || 'param 3'
    , 'p_commit:' || p_commit
    );
    FND_LOG.String
    (
        fnd_log.level_procedure
    , L_LOG_MODULE || 'param 4'
    , 'p_object_type:' || p_object_type
    );
    FND_LOG.String
    (
        fnd_log.level_procedure
    , L_LOG_MODULE || 'param 5'
    , 'p_processing_set_id:' || p_processing_set_id
    );
  END IF ;

  IF NOT FND_API.Compatible_API_Call
  (
    L_API_VERSION
  , p_api_version_number
  , L_API_NAME
  , G_PKG_NAME
  )
  THEN
    FND_MSG_PUB.Count_And_Get
    (
      p_count => x_msg_count
    , p_data  => x_msg_data
    );
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF ;

  IF FND_API.to_Boolean(p_init_msg_list)
  THEN
    FND_MSG_PUB.initialize;
  END IF ;

  ------------------------------------------------------------------------------
  -- Parameter Validations:
  ------------------------------------------------------------------------------

  IF NVL(p_object_type, 'X') <> 'SR'
  THEN
    IF fnd_log.level_unexpected >= fnd_log.g_current_runtime_level
    THEN
      FND_LOG.String
      (
          fnd_log.level_unexpected
      , L_LOG_MODULE || 'object_type_invalid'
      , 'p_object_type has to be SR.'
      );
    END IF ;

    FND_MESSAGE.Set_Name('CS', 'CS_SR_PARAM_VALUE_ERROR');
    FND_MESSAGE.Set_Token('API_NAME', L_API_NAME_FULL);
    FND_MESSAGE.Set_Token('PARAM', 'p_object_type');
    FND_MESSAGE.Set_Token('CURRVAL', p_object_type);
    FND_MSG_PUB.ADD;

    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  ---

  IF p_processing_set_id IS NULL
  THEN
    IF fnd_log.level_unexpected >= fnd_log.g_current_runtime_level
    THEN
      FND_LOG.String
      (
        fnd_log.level_unexpected
      , L_LOG_MODULE || 'proc_set_id_invalid'
      , 'p_processing_set_id should not be NULL.'
      );
    END IF ;

    FND_MESSAGE.Set_Name('CS', 'CS_SR_PARAM_VALUE_ERROR');
    FND_MESSAGE.Set_Token('API_NAME', L_API_NAME_FULL);
    FND_MESSAGE.Set_Token('PARAM', 'p_processing_set_id');
    FND_MESSAGE.Set_Token('CURRVAL', NVL(to_char(p_processing_set_id),'NULL'));
    FND_MSG_PUB.ADD;

    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  ------------------------------------------------------------------------------
  -- Actual Logic starts below:
  ------------------------------------------------------------------------------

  IF fnd_log.level_statement >= fnd_log.g_current_runtime_level
  THEN
    FND_LOG.String
    (
      fnd_log.level_statement
    , L_LOG_MODULE || 'del_sr_link_start'
    , 'deleting data in table cs_incident_links'
    );
  END IF ;

  -- The following statement deletes all the links that are related to
  -- an SR present in the global temp table jtf_object_purge_param_tmp with
  -- purge_status NULL, indicating that the SR is available for purge.

  DELETE /*+ index(l) */ cs_incident_links l
  WHERE
    link_id IN
    (
      SELECT /*+ unnest no_semijoin leading(t) use_concat cardinality(10) */
        l.link_id
      FROM
        jtf_object_purge_param_tmp t
      , cs_incident_links l
      WHERE
          NVL(t.purge_status, 'S') = 'S'
      AND t.processing_set_id = p_processing_set_id
      AND
      (
          l.subject_id = t.object_id
      AND l.subject_type = 'SR'
      OR  l.object_id = t.object_id
      AND l.object_type = 'SR'
      )
    );

  l_row_count := SQL%ROWCOUNT;

  IF fnd_log.level_statement >= fnd_log.g_current_runtime_level
  THEN
    FND_LOG.String
    (
      fnd_log.level_statement
    , L_LOG_MODULE || 'del_sr_link_end'
    , 'after deleting data in table cs_incident_links ' || l_row_count
    );
  END IF ;

  IF fnd_log.level_procedure >= fnd_log.g_current_runtime_level
  THEN
    FND_LOG.String
    (
      fnd_log.level_procedure
    , L_LOG_MODULE || 'end'
    , 'Completed work in ' || L_API_NAME_FULL || ' successfully'
    );
  END IF ;

EXCEPTION

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    IF fnd_log.level_unexpected >= fnd_log.g_current_runtime_level
    THEN
      FND_LOG.String
      (
        fnd_log.level_unexpected
      , L_LOG_MODULE || 'unexpected_error'
      , 'Inside WHEN FND_API.G_EXC_UNEXPECTED_ERROR of ' || L_API_NAME_FULL
      );

      x_msg_count := FND_MSG_PUB.Count_Msg;

      IF x_msg_count > 0
      THEN
        FOR
          i IN 1..x_msg_count
        LOOP
          FND_MSG_PUB.Get
          (
            p_msg_index     => i
          , p_encoded       => 'F'
          , p_data          => x_msg_data
          , p_msg_index_out => x_msg_index_out
          );
          FND_LOG.String
          (
            fnd_log.level_unexpected
          , L_LOG_MODULE || 'unexpected_error'
          , 'Error encountered is : ' || x_msg_data || ' [Index:'
            || x_msg_index_out || ']'
          );
        END LOOP;
      END IF ;
    END IF ;

	WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MESSAGE.Set_Name('CS', 'CS_SR_LNK_DEL_FAIL');
    FND_MESSAGE.Set_Token('API_NAME', L_API_NAME_FULL);
    FND_MESSAGE.Set_Token('ERROR', SQLERRM);
    FND_MSG_PUB.ADD;

    IF fnd_log.level_unexpected >= fnd_log.g_current_runtime_level
    THEN
      FND_LOG.String
      (
        fnd_log.level_unexpected
      , L_LOG_MODULE || 'when_others'
      , 'Inside WHEN OTHERS of ' || L_API_NAME_FULL || '. Oracle Error was:'
      );
      FND_LOG.String
      (
        fnd_log.level_unexpected
      , L_LOG_MODULE || 'when_others'
      , SQLERRM
      );
    END IF ;

END Delete_IncidentLink;
--------------------------------------------------------------------------------

END cs_incidentlinks_pvt;

/
