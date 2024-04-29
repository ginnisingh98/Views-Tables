--------------------------------------------------------
--  DDL for Package Body CS_INCIDENTLINKS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_INCIDENTLINKS_PUB" AS
/* $Header: cspsrlb.pls 120.0 2005/11/08 10:12:05 smisra noship $ */

G_PKG_NAME	        CONSTANT VARCHAR2(30) := 'CS_INCIDENTLINKS_PUB';

   -- This is an overloaded procedure introduced for backward compatibility in 11.5.9.1 for bugs 2972584 and 2972611
   -- The signature is the same as the pre-11.5.9 version of this procedure.

PROCEDURE CREATE_INCIDENTLINK (
   P_API_VERSION	      IN     NUMBER,
   P_INIT_MSG_LIST            IN     VARCHAR2,
   P_COMMIT     	      IN     VARCHAR2,
   P_RESP_APPL_ID	      IN     NUMBER,   -- not used
   P_RESP_ID		      IN     NUMBER,   -- not used
   P_USER_ID		      IN     NUMBER,
   P_LOGIN_ID		      IN     NUMBER,
   P_ORG_ID		      IN     NUMBER,   -- not used
   P_LINK_TYPE		      IN     VARCHAR2, -- no change
   P_FROM_INCIDENT_ID	      IN     NUMBER,
   P_FROM_INCIDENT_NUMBER     IN     VARCHAR2,
   P_TO_INCIDENT_ID	      IN     NUMBER,
   P_TO_INCIDENT_NUMBER	      IN     VARCHAR2,
   P_LINK_SEGMENT1	      IN     VARCHAR2,
   P_LINK_SEGMENT2	      IN     VARCHAR2,
   P_LINK_SEGMENT3	      IN     VARCHAR2,
   P_LINK_SEGMENT4	      IN     VARCHAR2,
   P_LINK_SEGMENT5	      IN     VARCHAR2,
   P_LINK_SEGMENT6	      IN     VARCHAR2,
   P_LINK_SEGMENT7	      IN     VARCHAR2,
   P_LINK_SEGMENT8	      IN     VARCHAR2,
   P_LINK_SEGMENT9	      IN     VARCHAR2,
   P_LINK_SEGMENT10	      IN     VARCHAR2,
   P_LINK_CONTEXT	      IN     VARCHAR2,
   X_RETURN_STATUS	      OUT NOCOPY   VARCHAR2,
   X_MSG_COUNT		      OUT NOCOPY   NUMBER,
   X_MSG_DATA		      OUT NOCOPY   VARCHAR2,
   X_LINK_ID		      OUT NOCOPY   NUMBER )

IS
   l_api_name               CONSTANT VARCHAR2(30) := 'CREATE_INCIDENTLINK_3';
   l_api_name_full          CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||l_api_name;

   l_api_version            CONSTANT NUMBER := 1.2;

   -- Needed to call the private create procedure
   l_link_rec_pvt               CS_INCIDENTLINKS_PVT.CS_INCIDENT_LINK_REC_TYPE;

   -- Needed during call to private create procedure for use as positional
   -- parameters corresponding to the two new 1159 OUT parameters
   lx_reciprocal_link_id	NUMBER;
   lx_object_version_number	NUMBER;
BEGIN
   -- Standard start of API savepoint
   SAVEPOINT CREATE_INCIDENTLINK_PUB;

--#BUG 3630159
 --Added to clear message cache in case of API call wrong version.
-- Initialize message list if p_init_msg_list is set to TRUE
   IF FND_API.To_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.Initialize;
   END IF;

   -- Standard call to check for call compatibility
   IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version,
                                                      l_api_name, G_PKG_NAME) THEN
--      RAISE FND_API.G_EXC_UNEXPECTED_ERROR; #BUG 3630127
        RAISE FND_API.G_EXC_ERROR;
   END IF;



   -- Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- If Link Type does not have equivalent 1158 link type, then return error.
   IF p_link_type NOT IN ('REF', 'DUP', 'PARENT', 'CHILD') THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
         CS_SERVICEREQUEST_UTIL.Add_Invalid_Argument_Msg(
            p_token_an    => l_api_name_full,
            p_token_v     => p_link_type,
            p_token_p     => 'p_link_type' );

         RAISE FND_API.G_EXC_ERROR;
   END IF; --  p_link_type NOT IN ('REF', 'DUP', 'PARENT', 'CHILD')

   -- Populate the link_type_id attribute of record l_link_rec_pvt
   Select decode(p_link_type, 	'REF', 6,
				'DUP', 4,
				'PARENT', 1,
				'CHILD', 2)
   Into l_link_rec_pvt.link_type_id
   From dual;

   -- Populate the remaining attributes of the record l_link_rec_pvt
   l_link_rec_pvt.from_incident_id	  := p_from_incident_id;
   l_link_rec_pvt.from_incident_number	  := p_from_incident_number;
   l_link_rec_pvt.to_incident_id	  := p_to_incident_id;
   l_link_rec_pvt.to_incident_number	  := p_to_incident_number;
   l_link_rec_pvt.link_type		  := p_link_type;
   l_link_rec_pvt.subject_id              := p_from_incident_id;
   l_link_rec_pvt.subject_type            := 'SR';
   l_link_rec_pvt.object_id               := p_to_incident_id;
   l_link_rec_pvt.object_number           := p_to_incident_number;
   l_link_rec_pvt.object_type             := 'SR';
   l_link_rec_pvt.link_segment1      	:= p_link_segment1;
   l_link_rec_pvt.link_segment2     	:= p_link_segment2;
   l_link_rec_pvt.link_segment3     	:= p_link_segment3;
   l_link_rec_pvt.link_segment4     	:= p_link_segment4;
   l_link_rec_pvt.link_segment5     	:= p_link_segment5;
   l_link_rec_pvt.link_segment6     	:= p_link_segment6;
   l_link_rec_pvt.link_segment7     	:= p_link_segment7;
   l_link_rec_pvt.link_segment8     	:= p_link_segment8;
   l_link_rec_pvt.link_segment9     	:= p_link_segment9;
   l_link_rec_pvt.link_segment10     	:= p_link_segment10;
   l_link_rec_pvt.link_context     	:= p_link_context;

   CS_INCIDENTLINKS_PVT.CREATE_INCIDENTLINK (
      P_API_VERSION		=> 1.2,
      P_INIT_MSG_LIST     	=> p_init_msg_list,
      P_COMMIT     		=> p_commit,
      P_VALIDATION_LEVEL  	=> FND_API.G_VALID_LEVEL_FULL,
      P_RESP_APPL_ID		=> p_resp_appl_id, -- not used
      P_RESP_ID		        => p_resp_id, -- not used
      P_USER_ID		        => p_user_id, -- not used
      P_LOGIN_ID		=> p_login_id,
      P_ORG_ID		        => p_org_id, -- not used
      P_LINK_REC            	=> l_link_rec_pvt,
      X_RETURN_STATUS	    	=> x_return_status,
      X_MSG_COUNT		=> x_msg_count,
      X_MSG_DATA		=> x_msg_data,
      X_OBJECT_VERSION_NUMBER   => lx_object_version_number,
      X_RECIPROCAL_LINK_ID      => lx_reciprocal_link_id,
      X_LINK_ID			=> x_link_id );

   IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR;
   ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Standard check of p_commit
   IF FND_API.To_Boolean(p_commit) THEN
      COMMIT WORK;
   END IF;

   -- Standard call to get message count and if count is 1, get message info
   FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data  => x_msg_data);

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO CREATE_INCIDENTLINK_PUB;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(
	 p_count => x_msg_count,
	 p_data  => x_msg_data);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO CREATE_INCIDENTLINK_PUB;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(
	 p_count => x_msg_count,
	 p_data  => x_msg_data);

   WHEN OTHERS THEN
      ROLLBACK TO CREATE_INCIDENTLINK_PUB;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MESSAGE.SET_NAME ('CS', 'CS_API_SR_UNKNOWN_ERROR');
      FND_MESSAGE.SET_TOKEN ('P_TEXT',l_api_name_full||'-'||SQLERRM);
      FND_MSG_PUB.ADD;
      FND_MSG_PUB.Count_And_Get(
	 p_count => x_msg_count,
	 p_data  => x_msg_data);

END CREATE_INCIDENTLINK;


-- Existing procedure. This procedure calls the new overloaded procedure with the
-- record structure.
-- The four parameters that are obsoleted for 1159 p_from_incident_id,
-- p_to_incident_id, p_from_incident_number and  p_to_incident_number are accepted
-- as IN parameter in this procedure for backward compatability. It is not passed
-- to the overloaded procedure.

PROCEDURE CREATE_INCIDENTLINK (
   P_API_VERSION		IN     NUMBER,
   P_INIT_MSG_LIST              IN     VARCHAR2,
   P_COMMIT     		IN     VARCHAR2,
   P_RESP_APPL_ID		IN     NUMBER,   -- not used
   P_RESP_ID			IN     NUMBER,   -- not used
   P_USER_ID			IN     NUMBER,
   P_LOGIN_ID		        IN     NUMBER,
   P_ORG_ID			IN     NUMBER,   -- not used
   P_LINK_ID                    IN     NUMBER,   -- new for 1159
   P_SUBJECT_ID                 IN     NUMBER,   -- new for 1159
   P_SUBJECT_TYPE               IN     VARCHAR2, -- new for 1159
   P_OBJECT_ID                  IN     NUMBER,   -- new for 1159
   P_OBJECT_NUMBER              IN     VARCHAR2, -- new for 1159
   P_OBJECT_TYPE                IN     VARCHAR2, -- new for 1159
   P_LINK_TYPE_ID               IN     NUMBER,   -- new for 1159
   P_LINK_TYPE		        IN     VARCHAR2, -- no change
   P_REQUEST_ID                 IN     NUMBER,   -- new for 1159
   P_PROGRAM_APPLICATION_ID     IN     NUMBER,   -- new for 1159
   P_PROGRAM_ID                 IN     NUMBER,   -- new for 1159
   P_PROGRAM_UPDATE_DATE        IN     DATE,     -- new for 1159
   P_FROM_INCIDENT_ID	        IN     NUMBER,   -- obsoleted for 1159
   P_FROM_INCIDENT_NUMBER	IN     VARCHAR2, -- obsoleted for 1159
   P_TO_INCIDENT_ID	        IN     NUMBER,   -- obsoleted for 1159
   P_TO_INCIDENT_NUMBER	        IN     VARCHAR2, -- obsoleted for 1159
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
   P_LINK_SEGMENT11	        IN     VARCHAR2, -- new for 1159
   P_LINK_SEGMENT12	        IN     VARCHAR2, -- new for 1159
   P_LINK_SEGMENT13	        IN     VARCHAR2, -- new for 1159
   P_LINK_SEGMENT14	        IN     VARCHAR2, -- new for 1159
   P_LINK_SEGMENT15	        IN     VARCHAR2, -- new for 1159
   P_LINK_CONTEXT		IN     VARCHAR2, -- new for 1159
   X_RETURN_STATUS	        OUT NOCOPY   VARCHAR2,
   X_MSG_COUNT		        OUT NOCOPY   NUMBER,
   X_MSG_DATA		        OUT NOCOPY   VARCHAR2,
   X_RECIPROCAL_LINK_ID         OUT NOCOPY   NUMBER, -- new for 1159
   X_OBJECT_VERSION_NUMBER      OUT NOCOPY   NUMBER, -- new for 1159
   X_LINK_ID			OUT NOCOPY   NUMBER )

IS
   l_api_name               CONSTANT VARCHAR2(30) := 'CREATE_INCIDENTLINK_1';
   l_api_name_full          CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||l_api_name;

   -- The following is the newly created (for 1159) record structure that will be
   -- populated and passed to the overloaded create procedure.
   l_link_rec_pub               CS_INCIDENT_LINK_REC_TYPE;
BEGIN

   l_link_rec_pub.link_id                  := p_link_id;              -- new for 1159
   l_link_rec_pub.subject_id               := p_subject_id;           -- new for 1159
   l_link_rec_pub.subject_type             := p_subject_type;         -- new for 1159
   l_link_rec_pub.object_id                := p_object_id;            -- new for 1159
   l_link_rec_pub.object_number            := p_object_number;        -- new for 1159
   l_link_rec_pub.object_type              := P_OBJECT_TYPE;          -- new for 1159
   l_link_rec_pub.link_type_id             := p_link_type_id;         -- new for 1159
   l_link_rec_pub.link_type                := p_link_type;            -- no change
   l_link_rec_pub.request_id               := p_request_id;           -- new for 1159
   l_link_rec_pub.program_application_id   := p_program_application_id;   -- new for 1159
   l_link_rec_pub.program_id               := p_program_id;           -- new for 1159
   l_link_rec_pub.program_update_date      := p_program_update_date;  -- new for 1159
   l_link_rec_pub.link_segment1            := p_link_segment1;
   l_link_rec_pub.link_segment2            := p_link_segment2;
   l_link_rec_pub.link_segment3            := p_link_segment3;
   l_link_rec_pub.link_segment4            := p_link_segment4;
   l_link_rec_pub.link_segment5            := p_link_segment5;
   l_link_rec_pub.link_segment6            := p_link_segment6;
   l_link_rec_pub.link_segment7            := p_link_segment7;
   l_link_rec_pub.link_segment8            := p_link_segment8;
   l_link_rec_pub.link_segment9            := p_link_segment9;
   l_link_rec_pub.link_segment10           := p_link_segment10;
   l_link_rec_pub.link_segment11           := p_link_segment11;   -- new for 1159
   l_link_rec_pub.link_segment12           := p_link_segment12;   -- new for 1159
   l_link_rec_pub.link_segment13           := p_link_segment13;   -- new for 1159
   l_link_rec_pub.link_segment14           := p_link_segment14;   -- new for 1159
   l_link_rec_pub.link_segment15           := p_link_segment15;   -- new for 1159
   l_link_rec_pub.link_context             := p_link_context;     -- new for 1159

   CREATE_INCIDENTLINK (
      P_API_VERSION		=> p_api_version,
      P_INIT_MSG_LIST           => p_init_msg_list,
      P_COMMIT     		=> p_commit,
      P_RESP_APPL_ID		=> p_resp_appl_id,           -- not used
      P_RESP_ID			=> p_resp_id,                -- not used
      P_USER_ID			=> p_user_id,
      P_LOGIN_ID		=> p_login_id,
      P_ORG_ID			=> p_org_id,                 -- not used
      P_LINK_REC                => l_link_rec_pub,
      X_RETURN_STATUS	        => x_return_status,
      X_MSG_COUNT		=> x_msg_count,
      X_MSG_DATA		=> x_msg_data,
      X_OBJECT_VERSION_NUMBER   => x_object_version_number,  -- new for 1159
      X_RECIPROCAL_LINK_ID      => x_reciprocal_link_id,     -- new for 1159
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

-- Overloaded procedure (new for 1159) that accepts a record structure. This
-- then calls the private create links procedure. Invoking procedures are
-- recommended to use this procedure.

PROCEDURE CREATE_INCIDENTLINK (
   P_API_VERSION		IN     NUMBER,
   P_INIT_MSG_LIST              IN     VARCHAR2,
   P_COMMIT     		IN     VARCHAR2,
   P_RESP_APPL_ID		IN     NUMBER, -- not used
   P_RESP_ID			IN     NUMBER, -- not used
   P_USER_ID			IN     NUMBER,
   P_LOGIN_ID		        IN     NUMBER,
   P_ORG_ID			IN     NUMBER, -- not used
   P_LINK_REC                   IN     CS_INCIDENT_LINK_REC_TYPE,
   X_RETURN_STATUS	        OUT NOCOPY   VARCHAR2,
   X_MSG_COUNT		        OUT NOCOPY   NUMBER,
   X_MSG_DATA		        OUT NOCOPY   VARCHAR2,
   X_OBJECT_VERSION_NUMBER      OUT NOCOPY   NUMBER, -- new for 1159
   X_RECIPROCAL_LINK_ID         OUT NOCOPY   NUMBER, -- new for 1159
   X_LINK_ID			OUT NOCOPY   NUMBER )
IS
   l_api_name               CONSTANT VARCHAR2(30) := 'CREATE_INCIDENTLINK_2';
   l_api_name_full          CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||l_api_name;

   l_api_version            CONSTANT NUMBER := 2.0;

   -- Needed to call the private create procedure
   l_link_rec               CS_INCIDENTLINKS_PVT.CS_INCIDENT_LINK_REC_TYPE;
BEGIN
   -- Standard start of API savepoint
   SAVEPOINT CREATE_INCIDENTLINK_PUB;

--#BUG 3630159
 --Added to clear message cache in case of API call wrong version.
-- Initialize message list if p_init_msg_list is set to TRUE
   IF FND_API.To_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.Initialize;
   END IF;

   -- Standard call to check for call compatibility
   IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version,
                                                      l_api_name, G_PKG_NAME) THEN
  --    RAISE FND_API.G_EXC_UNEXPECTED_ERROR; #BUG 3630127
        RAISE FND_API.G_EXC_ERROR;
   END IF;

   -- Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Populate the private procedure's record type
   l_link_rec.link_id                 := p_link_rec.LINK_ID;
   l_link_rec.subject_id              := p_link_rec.SUBJECT_ID;
   l_link_rec.subject_type            := p_link_rec.SUBJECT_TYPE;
   l_link_rec.object_id               := p_link_rec.OBJECT_ID;
   l_link_rec.object_number           := p_link_rec.OBJECT_NUMBER;
   l_link_rec.object_type             := p_link_rec.OBJECT_TYPE;
   l_link_rec.link_type_id            := p_link_rec.LINK_TYPE_ID;
   l_link_rec.link_type               := p_link_rec.LINK_TYPE;
   l_link_rec.request_id              := p_link_rec.REQUEST_ID;
   l_link_rec.program_application_id  := p_link_rec.PROGRAM_APPLICATION_ID;
   l_link_rec.program_id              := p_link_rec.PROGRAM_ID;
   l_link_rec.program_update_date     := p_link_rec.PROGRAM_UPDATE_DATE;
   l_link_rec.link_segment1           := p_link_rec.LINK_SEGMENT1;
   l_link_rec.link_segment2           := p_link_rec.LINK_SEGMENT2;
   l_link_rec.link_segment3           := p_link_rec.LINK_SEGMENT3;
   l_link_rec.link_segment4           := p_link_rec.LINK_SEGMENT4;
   l_link_rec.link_segment5           := p_link_rec.LINK_SEGMENT5;
   l_link_rec.link_segment6           := p_link_rec.LINK_SEGMENT6;
   l_link_rec.link_segment7           := p_link_rec.LINK_SEGMENT7;
   l_link_rec.link_segment8           := p_link_rec.LINK_SEGMENT8;
   l_link_rec.link_segment9           := p_link_rec.LINK_SEGMENT9;
   l_link_rec.link_segment10          := p_link_rec.LINK_SEGMENT10;
   l_link_rec.link_segment11          := p_link_rec.LINK_SEGMENT11;
   l_link_rec.link_segment12          := p_link_rec.LINK_SEGMENT12;
   l_link_rec.link_segment13          := p_link_rec.LINK_SEGMENT13;
   l_link_rec.link_segment14          := p_link_rec.LINK_SEGMENT14;
   l_link_rec.link_segment15          := p_link_rec.LINK_SEGMENT15;
   l_link_rec.link_context            := p_link_rec.LINK_CONTEXT;

   CS_INCIDENTLINKS_PVT.CREATE_INCIDENTLINK (
      P_API_VERSION		=> 2.0,
      P_INIT_MSG_LIST     	=> p_init_msg_list,
      P_COMMIT     		=> p_commit,
      P_VALIDATION_LEVEL  	=> FND_API.G_VALID_LEVEL_FULL,
      P_RESP_APPL_ID		=> p_resp_appl_id, -- not used
      P_RESP_ID		        => p_resp_id, -- not used
      P_USER_ID		        => p_user_id, -- not used
      P_LOGIN_ID		=> p_login_id,
      P_ORG_ID		        => p_org_id, -- not used
      P_LINK_REC                => l_link_rec,
      X_RETURN_STATUS	        => x_return_status,
      X_MSG_COUNT		=> x_msg_count,
      X_MSG_DATA		=> x_msg_data,
      X_OBJECT_VERSION_NUMBER   => x_object_version_number,
      X_RECIPROCAL_LINK_ID      => x_reciprocal_link_id,
      X_LINK_ID			=> x_link_id );

   IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR;
   ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Standard check of p_commit
   IF FND_API.To_Boolean(p_commit) THEN
      COMMIT WORK;
   END IF;

   -- Standard call to get message count and if count is 1, get message info
   FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data  => x_msg_data);

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO CREATE_INCIDENTLINK_PUB;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(
	 p_count => x_msg_count,
	 p_data  => x_msg_data);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO CREATE_INCIDENTLINK_PUB;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(
	 p_count => x_msg_count,
	 p_data  => x_msg_data);

   WHEN OTHERS THEN
      ROLLBACK TO CREATE_INCIDENTLINK_PUB;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MESSAGE.SET_NAME ('CS', 'CS_API_SR_UNKNOWN_ERROR');
      FND_MESSAGE.SET_TOKEN ('P_TEXT',l_api_name_full||'-'||SQLERRM);
      FND_MSG_PUB.ADD;
      FND_MSG_PUB.Count_And_Get(
	 p_count => x_msg_count,
	 p_data  => x_msg_data);

END CREATE_INCIDENTLINK;

   -- This is an overloaded procedure introduced for backward compatibility in 11.5.9.1 for bugs 2972584 and 2972611
   -- The signature is the same as the pre 11.5.9 version of this procedure.

PROCEDURE UPDATE_INCIDENTLINK (
     P_API_VERSION		IN     NUMBER,
     P_INIT_MSG_LIST		IN     VARCHAR2        := FND_API.G_FALSE,
     P_COMMIT			IN     VARCHAR2        := FND_API.G_FALSE,
     P_RESP_APPL_ID	    	IN     NUMBER          := NULL,
     P_RESP_ID			IN     NUMBER          := NULL,
     P_USER_ID			IN     NUMBER          := NULL,
     P_LOGIN_ID		    	IN     NUMBER          := FND_API.G_MISS_NUM,
     P_ORG_ID			IN     NUMBER          := NULL,
     P_LINK_ID			IN     NUMBER,
     P_FROM_INCIDENT_ID	        IN     NUMBER          := NULL,
     P_FROM_INCIDENT_NUMBER	IN     VARCHAR2        := NULL,
     P_TO_INCIDENT_ID	        IN     NUMBER          := NULL,
     P_TO_INCIDENT_NUMBER	IN     VARCHAR2        := NULL,
     P_LINK_TYPE		IN     VARCHAR2        := NULL,
     P_LINK_SEGMENT1		IN     VARCHAR2        := FND_API.G_MISS_CHAR,
     P_LINK_SEGMENT2		IN     VARCHAR2        := FND_API.G_MISS_CHAR,
     P_LINK_SEGMENT3		IN     VARCHAR2        := FND_API.G_MISS_CHAR,
     P_LINK_SEGMENT4		IN     VARCHAR2        := FND_API.G_MISS_CHAR,
     P_LINK_SEGMENT5		IN     VARCHAR2        := FND_API.G_MISS_CHAR,
     P_LINK_SEGMENT6		IN     VARCHAR2        := FND_API.G_MISS_CHAR,
     P_LINK_SEGMENT7		IN     VARCHAR2        := FND_API.G_MISS_CHAR,
     P_LINK_SEGMENT8		IN     VARCHAR2        := FND_API.G_MISS_CHAR,
     P_LINK_SEGMENT9		IN     VARCHAR2        := FND_API.G_MISS_CHAR,
     P_LINK_SEGMENT10		IN     VARCHAR2        := FND_API.G_MISS_CHAR,
     P_LINK_CONTEXT	    	IN     VARCHAR2        := FND_API.G_MISS_CHAR,
     X_RETURN_STATUS		OUT NOCOPY    VARCHAR2,
     X_MSG_COUNT		OUT NOCOPY    NUMBER,
     X_MSG_DATA		    	OUT NOCOPY    VARCHAR2)

IS
    l_api_name		        CONSTANT VARCHAR2(30) := 'UPDATE_INCIDENTLINK_3';
    l_api_name_full	        CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||l_api_name;
    l_api_version	        CONSTANT NUMBER := 1.2;

    -- Variables to be used as positional parameters for the required IN and the OUT parameter introduced in 11.5.9
    l_object_version_number    NUMBER;
    lx_object_version_number   NUMBER;

    -- Record type variable to be populated and passed to the private update procedure
    l_link_rec_pvt 	CS_INCIDENTLINKS_PVT.CS_INCIDENT_LINK_REC_TYPE;
BEGIN

   -- Standard start of API savepoint
   SAVEPOINT UPDATE_INCIDENTLINK_PUB;

--#BUG 3630159
 --Added to clear message cache in case of API call wrong version.
-- Initialize message list if p_init_msg_list is set to TRUE
   IF FND_API.To_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.Initialize;
   END IF;

   -- Standard call to check for call compatibility
   IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
   --   RAISE FND_API.G_EXC_UNEXPECTED_ERROR; #BUG 3630127
        RAISE FND_API.G_EXC_ERROR;
   END IF;

      -- Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- If Link Type does not have equivalent 1158 link type, then return error.
   IF p_link_type NOT IN ('REF', 'DUP', 'PARENT', 'CHILD') THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
         CS_SERVICEREQUEST_UTIL.Add_Invalid_Argument_Msg(
            p_token_an    => l_api_name_full,
            p_token_v     => p_link_type,
            p_token_p     => 'p_link_type' );

         RAISE FND_API.G_EXC_ERROR;
   END IF; --  p_link_type NOT IN ('REF', 'DUP', 'PARENT', 'CHILD')

   -- Populate the link_type_id attribute of record l_link_rec_pvt
   Select decode(p_link_type, 	'REF', 6,
				'DUP', 4,
				'PARENT', 1,
				'CHILD', 2)
   Into l_link_rec_pvt.link_type_id
   From dual;

   -- Populate the record type variable, l_link_rec_pvt with the values that have been passed

   l_link_rec_pvt.from_incident_id	:= p_from_incident_id;
   l_link_rec_pvt.from_incident_number  := p_from_incident_number;
   l_link_rec_pvt.to_incident_id	:= p_to_incident_id;
   l_link_rec_pvt.to_incident_number	:= p_to_incident_number;
   l_link_rec_pvt.link_type		:= p_link_type;
   l_link_rec_pvt.subject_id            := p_from_incident_id;
   l_link_rec_pvt.subject_type          := 'SR';
   l_link_rec_pvt.object_id             := p_to_incident_id;
   l_link_rec_pvt.object_number      	:= p_to_incident_number;
   l_link_rec_pvt.object_type           := 'SR';
   l_link_rec_pvt.link_segment1         := p_link_segment1;
   l_link_rec_pvt.link_segment2         := p_link_segment2;
   l_link_rec_pvt.link_segment3         := p_link_segment3;
   l_link_rec_pvt.link_segment4         := p_link_segment4;
   l_link_rec_pvt.link_segment5         := p_link_segment5;
   l_link_rec_pvt.link_segment6         := p_link_segment6;
   l_link_rec_pvt.link_segment7         := p_link_segment7;
   l_link_rec_pvt.link_segment8         := p_link_segment8;
   l_link_rec_pvt.link_segment9         := p_link_segment9;
   l_link_rec_pvt.link_segment10        := p_link_segment10;
   l_link_rec_pvt.link_context          := p_link_context;

   -- Retrieve the current object version number of the link record so it may be passed to the private API
   	Begin
   		Select object_version_number
		Into l_object_version_number
		From cs_incident_links
		Where link_id = p_link_id;
	Exception
		When OTHERS Then
			Rollback to UPDATE_INCIDENTLINK_PUB;
			CS_ServiceRequest_UTIL.Add_Invalid_Argument_Msg(
				p_token_an     	=>  l_api_name_full,
				p_token_v 	=>  to_char(p_link_id),
				p_token_p 	=>  'p_link_id'
			);
			RAISE FND_API.G_EXC_ERROR;
	End;

   -- Invoke the 11.5.9 private update procedure

   	CS_INCIDENTLINKS_PVT.UPDATE_INCIDENTLINK (
      P_API_VERSION		 => 1.2,
      P_INIT_MSG_LIST	     	 => p_init_msg_list,
      P_COMMIT			 => p_commit,
      P_VALIDATION_LEVEL     	 => FND_API.G_VALID_LEVEL_FULL,
      P_RESP_APPL_ID		 => p_resp_appl_id,
      P_RESP_ID			 => p_resp_id,
      P_USER_ID			 => p_user_id,
      P_LOGIN_ID		 => p_login_id,
      P_ORG_ID			 => p_org_id,
      P_LINK_ID			 => p_link_id,
      P_OBJECT_VERSION_NUMBER    => l_object_version_number,
      P_LINK_REC             	 => l_link_rec_pvt,
      X_RETURN_STATUS	      	 => x_return_status,
      X_OBJECT_VERSION_NUMBER 	 => lx_object_version_number,
      X_MSG_COUNT		 => x_msg_count,
      X_MSG_DATA		 => x_msg_data);

   -- Check return status and raise error if needed
   IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR;
   ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Standard check of p_commit
   IF FND_API.To_Boolean(p_commit) THEN
      COMMIT WORK;
   END IF;

   -- Standard call to get message count and if count is 1, get message info
   FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data  => x_msg_data);

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO UPDATE_INCIDENTLINK_PUB;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(
	 p_count => x_msg_count,
	 p_data  => x_msg_data );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO UPDATE_INCIDENTLINK_PUB;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(
	 p_count => x_msg_count,
	 p_data  => x_msg_data );

   WHEN OTHERS THEN
      ROLLBACK TO UPDATE_INCIDENTLINK_PUB;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MESSAGE.SET_NAME ('CS', 'CS_API_SR_UNKNOWN_ERROR');
      FND_MESSAGE.SET_TOKEN ('P_TEXT',l_api_name_full||'-'||SQLERRM);
      FND_MSG_PUB.ADD;
      FND_MSG_PUB.Count_And_Get(
	 p_count => x_msg_count,
	 p_data  => x_msg_data );

END UPDATE_INCIDENTLINK;

-- Existing procedure. This procedure calls the new overloaded procedure with the
-- record structure.
-- The four parameters that are obsoleted for 1159 p_from_incident_id,
-- p_to_incident_id, p_from_incident_number and  p_to_incident_number are accepted
-- as IN parameter in this procedure for backward compatability. It is not passed
-- to the overloaded procedure.
PROCEDURE UPDATE_INCIDENTLINK (
   P_API_VERSION		IN     NUMBER,
   P_INIT_MSG_LIST	        IN     VARCHAR2,
   P_COMMIT			IN     VARCHAR2,
   P_RESP_APPL_ID		IN     NUMBER,   -- not used
   P_RESP_ID			IN     NUMBER,   -- not used
   P_USER_ID			IN     NUMBER,
   P_LOGIN_ID		        IN     NUMBER,
   P_ORG_ID			IN     NUMBER,   -- not used
   P_LINK_ID			IN     NUMBER,   -- no change
   P_OBJECT_VERSION_NUMBER      IN     NUMBER,   -- new for 1159
   P_SUBJECT_ID                 IN     NUMBER,   -- new for 1159
   P_SUBJECT_TYPE               IN     VARCHAR2, -- new for 1159
   P_LINK_TYPE_ID               IN     NUMBER,   -- new for 1159
   P_LINK_TYPE		        IN     VARCHAR2, -- no change
   P_OBJECT_ID                  IN     NUMBER,   -- new for 1159
   P_OBJECT_NUMBER              IN     VARCHAR2, -- new for 1159
   P_OBJECT_TYPE                IN     VARCHAR2, -- new for 1159
   P_REQUEST_ID                 IN     NUMBER,   -- new for 1159
   P_PROGRAM_APPLICATION_ID     IN     NUMBER,   -- new for 1159
   P_PROGRAM_ID                 IN     NUMBER,   -- new for 1159
   P_PROGRAM_UPDATE_DATE        IN     DATE,     -- new for 1159
   P_FROM_INCIDENT_ID	        IN     NUMBER,   -- not used
   P_FROM_INCIDENT_NUMBER	IN     VARCHAR2, -- not used
   P_TO_INCIDENT_ID	        IN     NUMBER,   -- not used
   P_TO_INCIDENT_NUMBER	        IN     VARCHAR2, -- not used
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
   P_LINK_SEGMENT11	        IN     VARCHAR2, -- new for 1159
   P_LINK_SEGMENT12	        IN     VARCHAR2, -- new for 1159
   P_LINK_SEGMENT13	        IN     VARCHAR2, -- new for 1159
   P_LINK_SEGMENT14	        IN     VARCHAR2, -- new for 1159
   P_LINK_SEGMENT15	        IN     VARCHAR2, -- new for 1159
   P_LINK_CONTEXT		IN     VARCHAR2,
   X_RETURN_STATUS	        OUT NOCOPY   VARCHAR2,
   X_OBJECT_VERSION_NUMBER      OUT NOCOPY   NUMBER, -- new for 1159
   X_MSG_COUNT		        OUT NOCOPY   NUMBER,
   X_MSG_DATA		        OUT NOCOPY   VARCHAR2  )
IS
   l_api_name               CONSTANT VARCHAR2(30) := 'UPDATE_INCIDENTLINK_1';
   l_api_name_full          CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||l_api_name;

   -- The following is the newly created (for 1159) record structure that will be
   -- populated and passed to the overloaded create procedure.
   l_link_rec_pub               CS_INCIDENT_LINK_REC_TYPE;

BEGIN

   l_link_rec_pub.link_type_id            := p_link_type_id;
   l_link_rec_pub.link_type	          := p_link_type;
   l_link_rec_pub.object_id               := p_object_id;
   l_link_rec_pub.object_number           := p_object_number;
   l_link_rec_pub.object_type             := p_object_type;
   l_link_rec_pub.request_id              := p_request_id;
   l_link_rec_pub.program_application_id  := p_program_application_id;
   l_link_rec_pub.program_id              := p_program_id;
   l_link_rec_pub.program_update_date     := p_program_update_date;
   l_link_rec_pub.link_segment1	          := p_link_segment1;
   l_link_rec_pub.link_segment2	          := p_link_segment2;
   l_link_rec_pub.link_segment3	          := p_link_segment3;
   l_link_rec_pub.link_segment4	          := p_link_segment4;
   l_link_rec_pub.link_segment5	          := p_link_segment5;
   l_link_rec_pub.link_segment6	          := p_link_segment6;
   l_link_rec_pub.link_segment7	          := p_link_segment7;
   l_link_rec_pub.link_segment8	          := p_link_segment8;
   l_link_rec_pub.link_segment9	          := p_link_segment9;
   l_link_rec_pub.link_segment10          := p_link_segment10;
   l_link_rec_pub.link_segment11          := p_link_segment11;
   l_link_rec_pub.link_segment12          := p_link_segment12;
   l_link_rec_pub.link_segment13          := p_link_segment13;
   l_link_rec_pub.link_segment14          := p_link_segment14;
   l_link_rec_pub.link_segment15          := p_link_segment15;
   l_link_rec_pub.link_context	          := p_link_context;

   -- For bug 3642716
   l_link_rec_pub.subject_id := p_subject_id;

   UPDATE_INCIDENTLINK (
      P_API_VERSION		=> p_api_version,
      P_INIT_MSG_LIST	        => p_init_msg_list,
      P_COMMIT			=> p_commit,
      P_RESP_APPL_ID		=> p_resp_appl_id,  -- not used
      P_RESP_ID			=> p_resp_id,  -- not used
      P_USER_ID			=> p_user_id,
      P_LOGIN_ID		=> p_login_id,
      P_ORG_ID			=> p_org_id,   -- not used
      P_LINK_ID			=> p_link_id,  -- no change
      P_OBJECT_VERSION_NUMBER   => p_object_version_number,  -- new for 1159
      P_LINK_REC                => l_link_rec_pub,
      X_RETURN_STATUS	        => x_return_status,
      X_OBJECT_VERSION_NUMBER   => x_object_version_number, -- new for 1159
      X_MSG_COUNT		=> x_msg_count,
      X_MSG_DATA		=> x_msg_data ) ;

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


-- Overloaded procedure (new for 1159) that accepts a record structure. This
-- procedure calls the update procedure with the detailed list of parameters.
-- Invoking programs can use either one of the procedures.

PROCEDURE UPDATE_INCIDENTLINK (
   P_API_VERSION		IN     NUMBER,
   P_INIT_MSG_LIST	        IN     VARCHAR2,
   P_COMMIT			IN     VARCHAR2,
   P_RESP_APPL_ID		IN     NUMBER,  -- not used
   P_RESP_ID			IN     NUMBER,  -- not used
   P_USER_ID			IN     NUMBER,
   P_LOGIN_ID		        IN     NUMBER,
   P_ORG_ID			IN     NUMBER,  -- not used
   P_LINK_ID			IN     NUMBER,  -- no change
   P_OBJECT_VERSION_NUMBER      IN     NUMBER,  -- new for 1159
   P_LINK_REC                   IN     CS_INCIDENT_LINK_REC_TYPE,
   X_RETURN_STATUS	        OUT NOCOPY   VARCHAR2,
   X_OBJECT_VERSION_NUMBER      OUT NOCOPY   NUMBER, -- new for 1159
   X_MSG_COUNT		        OUT NOCOPY   NUMBER,
   X_MSG_DATA		        OUT NOCOPY   VARCHAR2  )

IS
   l_api_name		        CONSTANT VARCHAR2(30) := 'UPDATE_INCIDENTLINK_2';
   l_api_name_full	        CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||l_api_name;
   l_api_version	        CONSTANT NUMBER := 2.0;

   -- Needed to call the private create procedure
   l_link_rec                   CS_INCIDENTLINKS_PVT.CS_INCIDENT_LINK_REC_TYPE;
BEGIN
   -- Standard start of API savepoint
   SAVEPOINT UPDATE_INCIDENTLINK_PUB;

--#BUG 3630159
 --Added to clear message cache in case of API call wrong version.
-- Initialize message list if p_init_msg_list is set to TRUE
   IF FND_API.To_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.Initialize;
   END IF;

   -- Standard call to check for call compatibility
   IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
   --   RAISE FND_API.G_EXC_UNEXPECTED_ERROR; #BUG 3630127
        RAISE FND_API.G_EXC_ERROR;
   END IF;


   -- Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Populate the private procedure's record type
   l_link_rec.subject_id              := p_link_rec.SUBJECT_ID;
   l_link_rec.subject_type            := p_link_rec.SUBJECT_TYPE;
   l_link_rec.object_id               := p_link_rec.OBJECT_ID;
   l_link_rec.object_number           := p_link_rec.OBJECT_NUMBER;
   l_link_rec.object_type             := p_link_rec.OBJECT_TYPE;
   l_link_rec.link_type_id            := p_link_rec.LINK_TYPE_ID;
   l_link_rec.link_type               := p_link_rec.LINK_TYPE;
   l_link_rec.request_id              := p_link_rec.REQUEST_ID;
   l_link_rec.program_application_id  := p_link_rec.PROGRAM_APPLICATION_ID;
   l_link_rec.program_id              := p_link_rec.PROGRAM_ID;
   l_link_rec.program_update_date     := p_link_rec.PROGRAM_UPDATE_DATE;
   l_link_rec.link_segment1           := p_link_rec.LINK_SEGMENT1;
   l_link_rec.link_segment2           := p_link_rec.LINK_SEGMENT2;
   l_link_rec.link_segment3           := p_link_rec.LINK_SEGMENT3;
   l_link_rec.link_segment4           := p_link_rec.LINK_SEGMENT4;
   l_link_rec.link_segment5           := p_link_rec.LINK_SEGMENT5;
   l_link_rec.link_segment6           := p_link_rec.LINK_SEGMENT6;
   l_link_rec.link_segment7           := p_link_rec.LINK_SEGMENT7;
   l_link_rec.link_segment8           := p_link_rec.LINK_SEGMENT8;
   l_link_rec.link_segment9           := p_link_rec.LINK_SEGMENT9;
   l_link_rec.link_segment10          := p_link_rec.LINK_SEGMENT10;
   l_link_rec.link_segment11          := p_link_rec.LINK_SEGMENT11;
   l_link_rec.link_segment12          := p_link_rec.LINK_SEGMENT12;
   l_link_rec.link_segment13          := p_link_rec.LINK_SEGMENT13;
   l_link_rec.link_segment14          := p_link_rec.LINK_SEGMENT14;
   l_link_rec.link_segment15          := p_link_rec.LINK_SEGMENT15;
   l_link_rec.link_context            := p_link_rec.LINK_CONTEXT;

   CS_INCIDENTLINKS_PVT.UPDATE_INCIDENTLINK (
      P_API_VERSION		=> 2.0,
      P_INIT_MSG_LIST	        => p_init_msg_list,
      P_COMMIT			=> p_commit,
      P_VALIDATION_LEVEL        => FND_API.G_VALID_LEVEL_FULL,
      P_RESP_APPL_ID		=> p_resp_appl_id,
      P_RESP_ID			=> p_resp_id,
      P_USER_ID			=> p_user_id,
      P_LOGIN_ID		=> p_login_id,
      P_ORG_ID			=> p_org_id,
      P_LINK_ID			=> p_link_id,
      P_OBJECT_VERSION_NUMBER   => p_object_version_number,
      P_LINK_REC                => l_link_rec,
      X_RETURN_STATUS	        => x_return_status,
      X_OBJECT_VERSION_NUMBER   => x_object_version_number,
      X_MSG_COUNT		=> x_msg_count,
      X_MSG_DATA		=> x_msg_data );

   IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR;
   ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Standard check of p_commit
   IF FND_API.To_Boolean(p_commit) THEN
      COMMIT WORK;
   END IF;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO UPDATE_INCIDENTLINK_PUB;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(
	 p_count => x_msg_count,
	 p_data  => x_msg_data );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO UPDATE_INCIDENTLINK_PUB;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(
	 p_count => x_msg_count,
	 p_data  => x_msg_data );

   WHEN OTHERS THEN
      ROLLBACK TO UPDATE_INCIDENTLINK_PUB;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MESSAGE.SET_NAME ('CS', 'CS_API_SR_UNKNOWN_ERROR');
      FND_MESSAGE.SET_TOKEN ('P_TEXT',l_api_name_full||'-'||SQLERRM);
      FND_MSG_PUB.ADD;
      FND_MSG_PUB.Count_And_Get(
	 p_count => x_msg_count,
	 p_data  => x_msg_data );

END UPDATE_INCIDENTLINK;

PROCEDURE DELETE_INCIDENTLINK (
   P_API_VERSION		IN     NUMBER,
   P_INIT_MSG_LIST	        IN     VARCHAR2,
   P_COMMIT			IN     VARCHAR2,
   P_RESP_APPL_ID		IN     NUMBER, -- not used
   P_RESP_ID			IN     NUMBER, -- not used
   P_USER_ID			IN     NUMBER, -- not used
   P_LOGIN_ID		        IN     NUMBER,
   P_ORG_ID			IN     NUMBER, -- not used
   P_LINK_ID			IN     NUMBER, -- no change
   X_RETURN_STATUS	        OUT NOCOPY   VARCHAR2,
   X_MSG_COUNT		        OUT NOCOPY   NUMBER,
   X_MSG_DATA		        OUT NOCOPY   VARCHAR2 )
IS
   l_api_name		        CONSTANT VARCHAR2(30) := 'DELETE_INCIDENTLINK';
   l_api_name_full		CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||l_api_name;
   -- Commented out for bugs 2972584 and 2972611
   --l_api_version		CONSTANT NUMBER := 2.0;

   -- Variable to store the version of the API that has been invoked, added for bugs 2972584 and 2972611
   l_invoked_version        NUMBER;

BEGIN
   -- Standard start of API savepoint
   SAVEPOINT DELETE_INCIDENTLINK_PUB;

--#BUG 3630159
 --Added to clear message cache in case of API call wrong version.
-- Initialize message list if p_init_msg_list is set to TRUE
   IF FND_API.To_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.Initialize;
   END IF;

   -- Allow this API to be called with both version numbers, 1.2 and 2.0, added for bugs 2972584 and 2972611
   IF p_api_version = 1.2 THEN
   	  l_invoked_version := 1.2;
   ELSIF p_api_version = 2.0 THEN
      l_invoked_version := 2.0;
   END IF;

   -- Standard call to check for call compatibility, variable l_invoked_version used for bugs 2972584 and 2972611
   IF NOT FND_API.Compatible_API_Call(l_invoked_version, p_api_version,
					   l_api_name, G_PKG_NAME) THEN
   --   RAISE FND_API.G_EXC_UNEXPECTED_ERROR; #BUG 3630127
        RAISE FND_API.G_EXC_ERROR;
   END IF;


   -- Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Variable l_invoked_version used in call to Create_IncidentLink, for bugs 2972584 and 2972611
   CS_INCIDENTLINKS_PVT.DELETE_INCIDENTLINK (
      P_API_VERSION		=> l_invoked_version,
      P_INIT_MSG_LIST	        => p_init_msg_list,
      P_COMMIT			=> p_commit,
      P_VALIDATION_LEVEL        => FND_API.G_VALID_LEVEL_FULL, -- not used
      P_RESP_APPL_ID		=> p_resp_appl_id, -- not used
      P_RESP_ID			=> p_resp_id, -- not used
      P_USER_ID			=> p_user_id,
      P_LOGIN_ID		=> p_login_id,
      P_ORG_ID			=> p_org_id, -- not used
      P_LINK_ID			=> p_link_id, -- no change
      X_RETURN_STATUS	        => x_return_status,
      X_MSG_COUNT		=> x_msg_count,
      X_MSG_DATA		=> x_msg_data );

   IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR;
   ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Standard check of p_commit
   IF FND_API.To_Boolean(p_commit) THEN
      COMMIT WORK;
   END IF;

   -- Standard call to get message count and if count is 1, get message info
   FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data  => x_msg_data);

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO DELETE_INCIDENTLINK_PUB;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(
	 p_count => x_msg_count,
	 p_data  => x_msg_data);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO DELETE_INCIDENTLINK_PUB;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(
	 p_count => x_msg_count,
	 p_data  => x_msg_data);

   WHEN OTHERS THEN
      ROLLBACK TO DELETE_INCIDENTLINK_PUB;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MESSAGE.SET_NAME ('CS', 'CS_API_SR_UNKNOWN_ERROR');
      FND_MESSAGE.SET_TOKEN ('P_TEXT',l_api_name_full||'-'||SQLERRM);
      FND_MSG_PUB.ADD;
      FND_MSG_PUB.Count_And_Get(
	 p_count => x_msg_count,
	 p_data  => x_msg_data);

END DELETE_INCIDENTLINK;


/******************
   The _EXT procedures are restored for backward compatibility.
   For bugs 2972584 and 2972611
********************/
-- Implementation logic restored and enhanced for bugs 2972584 and 2972611
PROCEDURE CREATE_INCIDENTLINK_EXT (
   P_API_VERSION				IN     NUMBER,
   P_INIT_MSG_LIST              		IN     VARCHAR2,
   P_COMMIT     				IN     VARCHAR2,
   X_RETURN_STATUS				OUT NOCOPY   VARCHAR2,
   X_MSG_COUNT		        		OUT NOCOPY   NUMBER,
   X_MSG_DATA		        		OUT NOCOPY   VARCHAR2,
   P_RESP_APPL_ID				IN     NUMBER,
   P_RESP_ID		        		IN     NUMBER,
   P_USER_ID		        		IN     NUMBER,
   P_LOGIN_ID		        		IN     NUMBER,
   P_ORG_ID		        		IN     NUMBER,
   P_FROM_INCIDENT_ID	        		IN     NUMBER,
   P_FROM_INCIDENT_NUMBER			IN     NUMBER,
   P_TO_OBJECT_ID				IN     NUMBER,
   P_TO_OBJECT_TYPE	        		IN     VARCHAR2,
   P_LINK_SEGMENT1				IN     VARCHAR2,
   P_LINK_SEGMENT2				IN     VARCHAR2,
   P_LINK_SEGMENT3				IN     VARCHAR2,
   P_LINK_SEGMENT4				IN     VARCHAR2,
   P_LINK_SEGMENT5				IN     VARCHAR2,
   P_LINK_SEGMENT6				IN     VARCHAR2,
   P_LINK_SEGMENT7				IN     VARCHAR2,
   P_LINK_SEGMENT8				IN     VARCHAR2,
   P_LINK_SEGMENT9				IN     VARCHAR2,
   P_LINK_SEGMENT10	        		IN     VARCHAR2,
   P_LINK_CONTEXT				IN     VARCHAR2,
   X_LINK_ID		        		OUT NOCOPY   NUMBER )
IS

l_api_name				CONSTANT VARCHAR2(30) := 'create_incidentlink_ext';
l_api_name_full				CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||l_api_name;
l_api_version				CONSTANT NUMBER := 1.2;

-- local variables defined for use as positional parameters for the OUT parameters
-- that were added in the 11.5.9 siganture of the private create API
lx_reciprocal_link_id			NUMBER;
lx_object_version_number		NUMBER;

lx_link_id				NUMBER;

-- For bugs 2972584 and 2972611
-- local record type variable to be populated and passed to the private create API
l_link_rec_pvt		 		CS_INCIDENTLINKS_PVT.CS_INCIDENT_LINK_REC_TYPE;

-- Variables needed to store the values of the old columns
l_from_incident_id      number;
l_to_object_id        number;
l_to_object_number    varchar2(70);

BEGIN

--#BUG 3630159
 --Added to clear message cache in case of API call wrong version.
-- Initialize message list if p_init_msg_list is set to TRUE
   IF FND_API.To_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.Initialize;
   END IF;

   -- Standard call to check for call compatibility
   IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version,
                                                      l_api_name, G_PKG_NAME) THEN
   --   RAISE FND_API.G_EXC_UNEXPECTED_ERROR; #BUG 3630127
        RAISE FND_API.G_EXC_ERROR;
   END IF;

   -- Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Populate the record type variable with the values that have been passed

   	l_link_rec_pvt.from_incident_id		:= p_from_incident_id;
	l_link_rec_pvt.from_incident_number	:= p_from_incident_number;
	l_link_rec_pvt.to_incident_id		:= p_to_object_id;
	l_link_rec_pvt.subject_id		:= p_from_incident_id;
	l_link_rec_pvt.subject_type		:= 'SR';
	l_link_rec_pvt.object_id		:= p_to_object_id;
	l_link_rec_pvt.object_type		:= p_to_object_type;
	l_link_rec_pvt.link_type_id		:= 6;
	l_link_rec_pvt.link_segment1		:= p_link_segment1;
	l_link_rec_pvt.link_segment2		:= p_link_segment2;
	l_link_rec_pvt.link_segment3		:= p_link_segment3;
	l_link_rec_pvt.link_segment4		:= p_link_segment4;
	l_link_rec_pvt.link_segment5		:= p_link_segment5;
	l_link_rec_pvt.link_segment6		:= p_link_segment6;
	l_link_rec_pvt.link_segment7		:= p_link_segment7;
	l_link_rec_pvt.link_segment8		:= p_link_segment8;
	l_link_rec_pvt.link_segment9		:= p_link_segment9;
	l_link_rec_pvt.link_segment10		:= p_link_segment10;
	l_link_rec_pvt.link_context		:= p_link_context;

	-- Invoke the private create API that accepts a record structure as IN parameter
	-- and pass 1.2 as the API version.
	CS_INCIDENTLINKS_PVT.CREATE_INCIDENTLINK (
		P_API_VERSION			=> 1.2,
		P_INIT_MSG_LIST			=> p_init_msg_list,
		P_COMMIT			=> p_commit,
		P_VALIDATION_LEVEL		=> FND_API.G_VALID_LEVEL_FULL,
		P_RESP_APPL_ID			=> p_resp_appl_id,	-- not used
		P_RESP_ID			=> p_resp_id,		-- not used
		P_USER_ID			=> p_user_id,		-- not used
		P_LOGIN_ID			=> p_login_id,
		P_ORG_ID			=> p_org_id,		-- not used
		P_LINK_REC			=> l_link_rec_pvt,
		X_RETURN_STATUS			=> x_return_status,
		X_MSG_COUNT			=> x_msg_count,
		X_MSG_DATA			=> x_msg_data,
		X_OBJECT_VERSION_NUMBER		=> lx_object_version_number,
		X_RECIPROCAL_LINK_ID		=> lx_reciprocal_link_id,
		X_LINK_ID			=> lx_link_id);


   -- Check return status and raise error if required
   IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR;
   ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Standard check of p_commit
   IF FND_API.To_Boolean(p_commit) THEN
      COMMIT WORK;
   END IF;

   -- Retrieve the created external link ID based on the internal link ID returned by the private Create API
   -- First retrieve the internal link attributes with which to search for the external link in the external link table
   Begin
     Select subject_id, object_id, object_number
     Into l_from_incident_id, l_to_object_id, l_to_object_number
     From cs_incident_links
     Where link_id = lx_link_id;

   Exception
     When Others Then
       NULL;
   End;

   -- Now query the external link table to retrieve the external link ID based on the retrieved attributes
   Begin
     Select link_id
     Into lx_link_id
     From cs_incident_links_ext
     Where from_incident_id = l_from_incident_id
     And   to_object_id     = l_to_object_id
     And   to_object_number = l_to_object_number;
   Exception
     When Others Then
       NULL;
   End;

   -- Return the retrieved external link ID to the calling program by assigning it to the OUT parameter x_link_id
   x_link_id := lx_link_id;

   -- Standard call to get message count and if count is 1, get message info
   FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data  => x_msg_data);

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(
	 p_count => x_msg_count,
	 p_data  => x_msg_data);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(
	 p_count => x_msg_count,
	 p_data  => x_msg_data);

   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MESSAGE.SET_NAME ('CS', 'CS_API_SR_UNKNOWN_ERROR');
      FND_MESSAGE.SET_TOKEN ('P_TEXT',l_api_name_full||'-'||SQLERRM);
      FND_MSG_PUB.ADD;
      FND_MSG_PUB.Count_And_Get(
	 p_count => x_msg_count,
	 p_data  => x_msg_data);

END CREATE_INCIDENTLINK_EXT;


-- Implementation logic restored and enhanced for bugs 2972584 and 2972611
PROCEDURE UPDATE_INCIDENTLINK_EXT (
   P_API_VERSION	    IN     NUMBER,
   P_INIT_MSG_LIST	    IN     VARCHAR2,
   P_COMMIT		    IN     VARCHAR2,
   X_RETURN_STATUS	    OUT NOCOPY   VARCHAR2,
   X_MSG_COUNT		    OUT NOCOPY   NUMBER,
   X_MSG_DATA		    OUT NOCOPY   VARCHAR2,
   P_RESP_APPL_ID	    IN     NUMBER,
   P_RESP_ID		    IN     NUMBER,
   P_USER_ID		    IN     NUMBER,
   P_LOGIN_ID		    IN     NUMBER,
   P_ORG_ID		    IN     NUMBER,
   P_LINK_ID		    IN     NUMBER,
   P_FROM_INCIDENT_ID	    IN     NUMBER,
   P_FROM_INCIDENT_NUMBER   IN     VARCHAR2,
   P_TO_OBJECT_ID	    IN     NUMBER,
   P_TO_OBJECT_TYPE	    IN     VARCHAR2,
   P_LINK_SEGMENT1	    IN     VARCHAR2,
   P_LINK_SEGMENT2	    IN     VARCHAR2,
   P_LINK_SEGMENT3	    IN     VARCHAR2,
   P_LINK_SEGMENT4	    IN     VARCHAR2,
   P_LINK_SEGMENT5	    IN     VARCHAR2,
   P_LINK_SEGMENT6	    IN     VARCHAR2,
   P_LINK_SEGMENT7	    IN     VARCHAR2,
   P_LINK_SEGMENT8	    IN     VARCHAR2,
   P_LINK_SEGMENT9	    IN     VARCHAR2,
   P_LINK_SEGMENT10	    IN     VARCHAR2,
   P_LINK_CONTEXT	    IN     VARCHAR2 )
IS

   l_api_name				CONSTANT VARCHAR2(30) := 'update_incidentlink_ext';
   l_api_name_full			CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||l_api_name;
   l_api_version			CONSTANT NUMBER := 1.2;

   -- Variable to store the internal link ID derived from the external link ID passed to this procedure
   l_derived_internal_link_id           NUMBER;

   -- Cursor to fetch details of the external link to be updated
   cursor c_ext_link is
   select *
   from cs_incident_links_ext
   where link_id = p_link_id;

   -- Cursor variable to store data fetched from the cursor
   l_ext_link_rec	                c_ext_link%ROWTYPE;

   -- Variables to be used as positional parameters for the required IN parameter and the OUT parameter added in 11.5.9
   l_object_version_number		NUMBER;
   lx_object_version_number		NUMBER;

   -- Record type variable to be populated and passed to the private update procedure
   l_link_rec_pvt                       CS_INCIDENTLINKS_PVT.CS_INCIDENT_LINK_REC_TYPE;

   -- Variable to hold the derived from_incident_id in case from_incident_number is passed and not from_incident_id
   l_from_incident_id			NUMBER := NULL;
BEGIN

--#BUG 3630159
 --Added to clear message cache in case of API call wrong version.
-- Initialize message list if p_init_msg_list is set to TRUE
   IF FND_API.To_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.Initialize;
   END IF;

   -- Standard call to check for call compatibility
   IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version,
                                                      l_api_name, G_PKG_NAME) THEN
   --   RAISE FND_API.G_EXC_UNEXPECTED_ERROR; #BUG 3630127
        RAISE FND_API.G_EXC_ERROR;
   END IF;

   -- Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Added as part of fix for bugs 2972584 and 2972611
   -- Fetch the details of the existing external link
   open  c_ext_link;
   fetch c_ext_link into l_ext_link_rec;

   if ( c_ext_link%NOTFOUND ) then
      -- record does not exist, raise error
      close c_ext_link;
      CS_SERVICEREQUEST_UTIL.Add_Invalid_Argument_Msg(
            p_token_an    => l_api_name_full,
            p_token_v     => p_link_id,
            p_token_p     => 'p_link_id' );

      RAISE FND_API.G_EXC_ERROR;
   end if;

   close c_ext_link;

   -- Derive the internal link ID corresponding to the external link ID passed to this procedure
   -- Also retrieve the object_version_number for the link record in the same query
   	Begin
          Select link_id, object_version_number
	  Into l_derived_internal_link_id, l_object_version_number
	  From Cs_Incident_Links
	  Where subject_id = l_ext_link_rec.from_incident_id
	  And subject_type = 'SR'
	  And object_id = l_ext_link_rec.to_object_id
	  And object_type = l_ext_link_rec.to_object_type
	  And end_date_active is NULL
	  For update of object_version_number;
	Exception
	  When NO_DATA_FOUND then
	        -- In case the external link was created with object type as 'SR' '
		Begin
	          Select link_id, object_version_number
	          Into l_derived_internal_link_id, l_object_version_number
	          From Cs_Incident_Links
	          Where object_id = l_ext_link_rec.from_incident_id
	          And object_type = 'SR'
	          And subject_id = l_ext_link_rec.to_object_id
	          And subject_type = l_ext_link_rec.to_object_type
	          And end_date_active is NULL
	          For update of object_version_number;
	        Exception
		  When NO_DATA_FOUND then
		    null;
		End;
	  When OTHERS THEN
		CS_ServiceRequest_UTIL.Add_Invalid_Argument_Msg(
			p_token_an	=>  l_api_name_full,
			p_token_v 	=>  to_char(p_link_id),
			p_token_p	=>  'p_link_id'
		);
		RAISE FND_API.G_EXC_ERROR;
	End;

    -- For Bugs 2972584 and 2972611
    -- Populate the record type variable with the values that have been passed in

    -- If p_from_incident_number is passed, and p_from_incident_id is NULL, then
    -- derive the value of from_incident_id from the cs_incidents_all_b table based on the value of from_incident_number
    If (p_from_incident_id IS NULL) And (p_from_incident_number IS NOT NULL) Then
      Begin
        Select incident_id
        Into l_from_incident_id
        From cs_incidents_all_b
        Where incident_number = p_from_incident_number;
      Exception
        When No_Data_Found Then
          Null;
      End;
      l_link_rec_pvt.from_incident_id := l_from_incident_id;
    Else
      l_link_rec_pvt.from_incident_id 	:= nvl(p_from_incident_id, l_ext_link_rec.from_incident_id);
    End if; -- (p_from_incident_id IS NULL) And (p_from_incident_number IS NOT NULL)

    l_link_rec_pvt.from_incident_number := p_from_incident_number;
    l_link_rec_pvt.to_incident_id   	:= nvl(p_to_object_id, l_ext_link_rec.to_object_id);
    l_link_rec_pvt.subject_id       	:= nvl(p_from_incident_id, l_ext_link_rec.from_incident_id);
    l_link_rec_pvt.subject_type	    	:= 'SR';
    l_link_rec_pvt.object_id        	:= nvl(p_to_object_id, l_ext_link_rec.to_object_id);
    -- Assign G_MISS_CHAR to Object Number to avoid a validation failure in CS_INCIDENTLINKS_UTIL.VALIDATE_LINK_DETAILS
    l_link_rec_pvt.object_number       	:= FND_API.G_MISS_CHAR;
    l_link_rec_pvt.object_type	    	:= nvl(p_to_object_type, l_ext_link_rec.to_object_type);
    l_link_rec_pvt.link_type_id	    	:= 6;

    If p_link_segment1 = FND_API.G_MISS_CHAR Then
      l_link_rec_pvt.link_segment1      := l_ext_link_rec.attribute1;
    Else
      l_link_rec_pvt.link_segment1      := p_link_segment1;
    End If;

    If p_link_segment2 = FND_API.G_MISS_CHAR Then
      l_link_rec_pvt.link_segment2      := l_ext_link_rec.attribute2;
    Else
      l_link_rec_pvt.link_segment2      := p_link_segment2;
    End If;

    If p_link_segment3 = FND_API.G_MISS_CHAR Then
      l_link_rec_pvt.link_segment3      := l_ext_link_rec.attribute3;
    Else
      l_link_rec_pvt.link_segment3      := p_link_segment3;
    End If;

    If p_link_segment4 = FND_API.G_MISS_CHAR Then
      l_link_rec_pvt.link_segment4      := l_ext_link_rec.attribute4;
    Else
      l_link_rec_pvt.link_segment4      := p_link_segment4;
    End If;

    If p_link_segment5 = FND_API.G_MISS_CHAR Then
      l_link_rec_pvt.link_segment5      := l_ext_link_rec.attribute5;
    Else
      l_link_rec_pvt.link_segment5      := p_link_segment5;
    End If;

    If p_link_segment6 = FND_API.G_MISS_CHAR Then
      l_link_rec_pvt.link_segment6      := l_ext_link_rec.attribute6;
    Else
      l_link_rec_pvt.link_segment6      := p_link_segment6;
    End If;

    If p_link_segment7 = FND_API.G_MISS_CHAR Then
      l_link_rec_pvt.link_segment7      := l_ext_link_rec.attribute7;
    Else
      l_link_rec_pvt.link_segment7      := p_link_segment7;
    End If;

    If p_link_segment8 = FND_API.G_MISS_CHAR Then
      l_link_rec_pvt.link_segment8      := l_ext_link_rec.attribute8;
    Else
      l_link_rec_pvt.link_segment8      := p_link_segment8;
    End If;

    If p_link_segment9 = FND_API.G_MISS_CHAR Then
      l_link_rec_pvt.link_segment9      := l_ext_link_rec.attribute9;
    Else
      l_link_rec_pvt.link_segment9      := p_link_segment9;
    End If;

    If p_link_segment10 = FND_API.G_MISS_CHAR Then
      l_link_rec_pvt.link_segment10      := l_ext_link_rec.attribute10;
    Else
      l_link_rec_pvt.link_segment10      := p_link_segment10;
    End If;

    If p_link_context = FND_API.G_MISS_CHAR Then
      l_link_rec_pvt.link_context      := l_ext_link_rec.context;
    Else
      l_link_rec_pvt.link_context      := p_link_context;
    End If;

    -- Pass the external link ID to the private API thru the new attribute link_id_ext in the private record type
    l_link_rec_pvt.link_id_ext		:= p_link_id; -- Added specifically for bugs 2972584 and 2972611

    -- Invoke the 11.5.9 private update procedure and pass 1.2 as the version to be invoked
    CS_INCIDENTLINKS_PVT.UPDATE_INCIDENTLINK (
      P_API_VERSION	      => 1.2,
      P_INIT_MSG_LIST	      => p_init_msg_list,
      P_COMMIT		      => p_commit,
      P_VALIDATION_LEVEL      => FND_API.G_VALID_LEVEL_FULL,
      P_RESP_APPL_ID	      => p_resp_appl_id,
      P_RESP_ID		      => p_resp_id,
      P_USER_ID		      => p_user_id,
      P_LOGIN_ID	      => p_login_id,
      P_ORG_ID		      => p_org_id,
      P_LINK_ID		      => l_derived_internal_link_id,
      P_OBJECT_VERSION_NUMBER => l_object_version_number,
      P_LINK_REC              => l_link_rec_pvt,
      X_RETURN_STATUS	      => x_return_status,
      X_OBJECT_VERSION_NUMBER => lx_object_version_number,
      X_MSG_COUNT	      => x_msg_count,
      X_MSG_DATA	      => x_msg_data);

   -- Check return status and raise error if required
   IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR;
   ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Standard check of p_commit
   IF FND_API.To_Boolean(p_commit) THEN
      COMMIT WORK;
   END IF;

   -- Standard call to get message count and if count is 1, get message info
   FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data  => x_msg_data);

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(
	 p_count => x_msg_count,
	 p_data  => x_msg_data);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(
	 p_count => x_msg_count,
	 p_data  => x_msg_data);

   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MESSAGE.SET_NAME ('CS', 'CS_API_SR_UNKNOWN_ERROR');
      FND_MESSAGE.SET_TOKEN ('P_TEXT',l_api_name_full||'-'||SQLERRM);
      FND_MSG_PUB.ADD;
      FND_MSG_PUB.Count_And_Get(
	 p_count => x_msg_count,
	 p_data  => x_msg_data);

END UPDATE_INCIDENTLINK_EXT;

-- Implementation logic restored and enhanced for bugs 2972584 and 2972611
PROCEDURE DELETE_INCIDENTLINK_EXT (
   P_API_VERSION		IN     NUMBER,
   P_INIT_MSG_LIST		IN     VARCHAR2,
   P_COMMIT		        IN     VARCHAR2,
   X_RETURN_STATUS		OUT NOCOPY   VARCHAR2,
   X_MSG_COUNT		        OUT NOCOPY   NUMBER,
   X_MSG_DATA		        OUT NOCOPY   VARCHAR2,
   P_RESP_APPL_ID		IN     NUMBER,
   P_RESP_ID		        IN     NUMBER,
   P_USER_ID		        IN     NUMBER,
   P_LOGIN_ID		        IN     NUMBER,
   P_ORG_ID		        IN     NUMBER,
   P_LINK_ID		        IN     NUMBER )
IS
   l_api_name		CONSTANT VARCHAR2(30) := 'delete_incidentlink_ext';
   l_api_name_full		CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||l_api_name;
   l_api_version		CONSTANT NUMBER := 1.2;

   -- Variable to store the internal link ID corresponding to the external link to be deleted
   	l_derived_internal_link_id	 NUMBER;

	-- Cursor to fetch the details of the external link to be deleted
	cursor c_ext_link is
	select * from cs_incident_links_ext
	where link_id = p_link_id;

	-- Cursor variable to store the external link details
	l_ext_link_rec               c_ext_link%ROWTYPE;


BEGIN

--#BUG 3630159
 --Added to clear message cache in case of API call wrong version.
-- Initialize message list if p_init_msg_list is set to TRUE
   IF FND_API.To_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.Initialize;
   END IF;

   -- Standard call to check for call compatibility
   IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version,
                                                      l_api_name, G_PKG_NAME) THEN
 --   RAISE FND_API.G_EXC_UNEXPECTED_ERROR; #BUG 3630127
        RAISE FND_API.G_EXC_ERROR;
   END IF;

   -- Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Added as part of fix for bugs 2972584 and 2972611
   -- Fetch the details of the existing external link
   open  c_ext_link;
   fetch c_ext_link into l_ext_link_rec;

   if ( c_ext_link%NOTFOUND ) then
      -- record does not exist - raise error
      close c_ext_link;
      CS_SERVICEREQUEST_UTIL.Add_Invalid_Argument_Msg(
            p_token_an    => l_api_name_full,
            p_token_v     => p_link_id,
            p_token_p     => 'p_link_id' );

      RAISE FND_API.G_EXC_ERROR;
   end if;

   close c_ext_link;

   -- Added as part of fix for bugs 2972584 and 2972611
   -- Derive the internal link ID corresponding to the passed external link ID
   Begin
		Select link_id
		Into l_derived_internal_link_id
		From Cs_Incident_Links
		Where subject_id = l_ext_link_rec.from_incident_id
		And subject_type = 'SR'
		And object_id = l_ext_link_rec.to_object_id
		And object_type = l_ext_link_rec.to_object_type
		And end_date_active is NULL;
   Exception
     When No_Data_Found then
	 --	In case the external link was created with object type as 'SR'
		Begin
			Select link_id
			Into l_derived_internal_link_id
			From Cs_Incident_Links
			Where object_id = l_ext_link_rec.from_incident_id
			And object_type = 'SR'
			And subject_id = l_ext_link_rec.to_object_id
			And subject_type = l_ext_link_rec.to_object_type
			And end_date_active is NULL;
     		Exception
			When No_Data_Found then
				 Null;

		  	When OTHERS THEN
			CS_ServiceRequest_UTIL.Add_Invalid_Argument_Msg(
				p_token_an     =>  l_api_name_full,
				p_token_v =>  to_char(p_link_id),
				p_token_p =>  'p_link_id'
			);
			RAISE FND_API.G_EXC_ERROR;
	 	End;
   End;

   -- Invoke the private delete API and pass the derived internal link ID
   	CS_INCIDENTLINKS_PVT.DELETE_INCIDENTLINK (
	   P_API_VERSION		=> 1.2,
	   P_INIT_MSG_LIST	        => p_init_msg_list,
	   P_COMMIT			=> p_commit,
	   P_VALIDATION_LEVEL		=> FND_API.G_VALID_LEVEL_FULL, -- not used
	   P_RESP_APPL_ID		=> p_resp_appl_id, -- not used
	   P_RESP_ID			=> p_resp_id, -- not used
	   P_USER_ID			=> p_user_id,
	   P_LOGIN_ID			=> p_login_id,
	   P_ORG_ID			=> p_org_id, -- not used
	   P_LINK_ID			=> l_derived_internal_link_id,
	   X_RETURN_STATUS	        => x_return_status,
	   X_MSG_COUNT			=> x_msg_count,
	   X_MSG_DATA			=> x_msg_data,
	   P_LINK_ID_EXT		=> p_link_id ); -- Added for bugs 2972584 and 2972611, to pass the external link ID

   -- Check return status and raise error if required
   IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR;
   ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Standard check of p_commit
   IF FND_API.To_Boolean(p_commit) THEN
      COMMIT WORK;
   END IF;

   -- Standard call to get message count and if count is 1, get message info
   FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data  => x_msg_data);

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(
	 p_count => x_msg_count,
	 p_data  => x_msg_data);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get(
	 p_count => x_msg_count,
	 p_data  => x_msg_data);

   WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MESSAGE.SET_NAME ('CS', 'CS_API_SR_UNKNOWN_ERROR');
     FND_MESSAGE.SET_TOKEN ('P_TEXT',l_api_name_full||'-'||SQLERRM);
     FND_MSG_PUB.ADD;
     FND_MSG_PUB.Count_And_Get(
	 p_count => x_msg_count,
	 p_data  => x_msg_data);

END DELETE_INCIDENTLINK_EXT;


END CS_INCIDENTLINKS_PUB;

/
