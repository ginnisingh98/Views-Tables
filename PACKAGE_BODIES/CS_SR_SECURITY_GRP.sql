--------------------------------------------------------
--  DDL for Package Body CS_SR_SECURITY_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_SR_SECURITY_GRP" AS
/* $Header: csgsecb.pls 115.5 2004/04/16 22:52:07 spusegao noship $ */

G_PKG_NAME          CONSTANT VARCHAR2(30) := 'CS_SR_SECURITY_GRP';

-- Added for Security Project of 11.5.10
PROCEDURE VALIDATE_USER_RESPONSIBILITY (
   p_api_version                 IN      NUMBER,
   p_init_msg_list               IN      VARCHAR2,
   p_commit                      IN      VARCHAR2,
   p_incident_id                 IN      NUMBER,
   x_resp_access_status          OUT     NOCOPY    VARCHAR2,
   x_return_status               OUT     NOCOPY    VARCHAR2,
   x_msg_count                   OUT     NOCOPY    NUMBER,
   x_msg_data                    OUT     NOCOPY    VARCHAR2 )
IS
   CURSOR c_sr_access_csr IS
   SELECT 'Y'
   FROM   cs_sr_access_resp_sec
   WHERE  incident_id  = p_incident_id ;

   l_access_status VARCHAR2(3) :=NULL;
   l_api_name_full VARCHAR2(70):= G_PKG_NAME||'.'||'VALIDATE_USER_RESPONSIBILITY';

BEGIN

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   OPEN  c_sr_access_csr;
   FETCH c_sr_access_csr INTO l_access_status;

   IF (c_sr_access_csr%NOTFOUND) THEN
     l_access_status := 'N';
   ELSE
     l_access_status := 'Y';
   END IF;

   CLOSE c_sr_access_csr;

   x_resp_access_status := l_access_status;

EXCEPTION
   WHEN OTHERS THEN
      close c_sr_access_csr;
      x_return_status      := FND_API.G_RET_STS_UNEXP_ERROR;
      x_resp_access_status := 'N';
      fnd_message.set_name ('CS', 'CS_API_SR_UNKNOWN_ERROR');
      fnd_message.set_token ('P_TEXT',l_api_name_full||'-'||SQLERRM);
      fnd_msg_pub.add;

END Validate_User_Responsibility;

-- Added for Security Project of 11.5.10
PROCEDURE Validate_Resource (
   p_api_version                IN       NUMBER,
   p_init_msg_list              IN       VARCHAR2,
   p_commit                     IN       VARCHAR2,
   p_sr_rec                   	IN       SR_REC_TYPE,
   px_resource_tbl              IN OUT   NOCOPY    RESOURCE_VALIDATE_TBL_TYPE,
   x_return_status              OUT      NOCOPY    VARCHAR2,
   x_msg_count                  OUT      NOCOPY    NUMBER,
   x_msg_data                   OUT      NOCOPY    VARCHAR2 )
IS
   lx_resource_tbl        Resource_Validate_Tbl_Type := resource_validate_tbl_type();
   l_access               VARCHAR2(3);
   l_current_count        NUMBER;

   l_api_name_full        VARCHAR2(50) := G_PKG_NAME||'.'||'Validate_resource';

   CURSOR c_resource_csr(c_resource_id NUMBER) IS
   SELECT 'Y'
   FROM   cs_jtf_rs_resource_extns_sec
   WHERE  resource_id = c_resource_id;

   l_dummy varchar2(50);

   j                      NUMBER := 1;

BEGIN

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- set the SR Type id context with the passed in SR type.
   CS_SR_SECURITY_CONTEXT.SET_SR_SECURITY_CONTEXT (
      p_context_attribute         => 'SRTYPE_ID',
      p_context_attribute_value   => p_sr_rec.incident_type_id);

   FOR i IN 1..px_resource_tbl.COUNT
   LOOP
      if ( px_resource_tbl(i).resource_type NOT IN ('RS_GROUP', 'RS_TEAM' ) ) then
         OPEN  c_resource_csr(px_resource_tbl(i).resource_id);
         FETCH c_resource_csr INTO l_access;

         if(c_resource_csr%FOUND) then
	    lx_resource_tbl.extend;
            lx_resource_tbl(j) := px_resource_tbl(i);
	    j   := j + 1;
         end if;
         close c_resource_csr;
      else
           lx_resource_tbl.extend;
           lx_resource_tbl(j) := px_resource_tbl(i);
           j   := j + 1;
      end if;  -- if ( px_resource_tbl(i).resource_type NOT IN ('RS_GROUP', 'RS_TEAM'
   END LOOP;

   px_resource_tbl  := lx_resource_tbl;
   x_return_status  := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
   WHEN OTHERS THEN
      if ( c_resource_csr%ISOPEN ) then
         close c_resource_csr;
      end if;

      fnd_message.set_name ('CS', 'CS_API_SR_UNKNOWN_ERROR');
      fnd_message.set_token ('P_TEXT',l_api_name_full||'-'||SQLERRM);
      fnd_msg_pub.ADD;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END Validate_Resource;

END CS_SR_SECURITY_GRP;

/
