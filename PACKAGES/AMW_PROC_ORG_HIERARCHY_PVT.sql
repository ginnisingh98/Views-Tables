--------------------------------------------------------
--  DDL for Package AMW_PROC_ORG_HIERARCHY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMW_PROC_ORG_HIERARCHY_PVT" AUTHID CURRENT_USER AS
/* $Header: amwvpohs.pls 120.0 2005/05/31 22:31:17 appldev noship $ */

--===================================================================
--    Start of Comments
--   -------------------------------------------------------
--    Record name
--             apo_type
--   -------------------------------------------------------
--   Parameters:
--     CONTROL_COUNT	   			   NUMBER    OPTIONAL DEFAULT = FND_API.G_MISS_NUM,
--     RISK_COUNT                      NUMBER    OPTIONAL DEFAULT = FND_API.G_MISS_NUM,
--	   TOP_PROCESS_ID                  NUMBER    OPTIONAL DEFAULT = FND_API.G_MISS_NUM,
--	   PROCESS_ORGANIZATION_ID         NUMBER    OPTIONAL DEFAULT = FND_API.G_MISS_NUM,
--	   LAST_UPDATE_DATE                DATE      OPTIONAL DEFAULT = FND_API.G_MISS_DATE,
--	   LAST_UPDATED_BY                 NUMBER    OPTIONAL DEFAULT = FND_API.G_MISS_NUM,
--	   CREATION_DATE                   DATE      OPTIONAL DEFAULT = FND_API.G_MISS_DATE,
--	   CREATED_BY                      NUMBER    OPTIONAL DEFAULT = FND_API.G_MISS_NUM,
--	   LAST_UPDATE_LOGIN               NUMBER    OPTIONAL DEFAULT = FND_API.G_MISS_NUM,
--	   PROCESS_ID                      NUMBER    OPTIONAL DEFAULT = FND_API.G_MISS_NUM,
--	   STANDARD_PROCESS_FLAG           VARCHAR2  OPTIONAL DEFAULT = null,
--	   RISK_CATEGORY                   VARCHAR2  OPTIONAL DEFAULT = FND_API.G_MISS_CHAR,
--	   APPROVAL_STATUS                 VARCHAR2  OPTIONAL DEFAULT = FND_API.G_MISS_CHAR,
--	   CERTIFICATION_STATUS            VARCHAR2  OPTIONAL DEFAULT = FND_API.G_MISS_CHAR,
--	   LAST_AUDIT_STATUS               VARCHAR2  OPTIONAL DEFAULT = FND_API.G_MISS_CHAR,
--	   ORGANIZATION_ID                 NUMBER    OPTIONAL DEFAULT = FND_API.G_MISS_NUM,
--	   LAST_CERTIFICATION_DATE         DATE      OPTIONAL DEFAULT = FND_API.G_MISS_DATE,
--	   LAST_AUDIT_DATE                 DATE      OPTIONAL DEFAULT = FND_API.G_MISS_DATE,
--	   NEXT_AUDIT_DATE                 DATE      OPTIONAL DEFAULT = FND_API.G_MISS_DATE,
--	   APPLICATION_OWNER_ID            NUMBER    OPTIONAL DEFAULT = FND_API.G_MISS_NUM,
--	   PROCESS_OWNER_ID                NUMBER    OPTIONAL DEFAULT = FND_API.G_MISS_NUM,
--	   PROCESS_CATEGORY_CODE           VARCHAR2  OPTIONAL DEFAULT = FND_API.G_MISS_CHAR,
--	   SIGNIFICANT_PROCESS_FLAG        VARCHAR2  OPTIONAL DEFAULT = FND_API.G_MISS_CHAR,
--	   FINANCE_OWNER_ID                NUMBER    OPTIONAL DEFAULT = FND_API.G_MISS_NUM,
--	   CREATED_FROM                    VARCHAR2  OPTIONAL DEFAULT = FND_API.G_MISS_CHAR,
--	   REQUEST_ID                      NUMBER    OPTIONAL DEFAULT = FND_API.G_MISS_NUM,
--	   PROGRAM_APPLICATION_ID          NUMBER    OPTIONAL DEFAULT = FND_API.G_MISS_NUM,
--	   PROGRAM_ID                      NUMBER    OPTIONAL DEFAULT = FND_API.G_MISS_NUM,
--	   PROGRAM_UPDATE_DATE             DATE      OPTIONAL DEFAULT = FND_API.G_MISS_DATE,
--	   ATTRIBUTE_CATEGORY              VARCHAR2  OPTIONAL DEFAULT = FND_API.G_MISS_CHAR,
--	   ATTRIBUTE1                      VARCHAR2  OPTIONAL DEFAULT = FND_API.G_MISS_CHAR,
--	   ATTRIBUTE2                      VARCHAR2  OPTIONAL DEFAULT = FND_API.G_MISS_CHAR,
--	   ATTRIBUTE3                      VARCHAR2  OPTIONAL DEFAULT = FND_API.G_MISS_CHAR,
--	   ATTRIBUTE4                      VARCHAR2  OPTIONAL DEFAULT = FND_API.G_MISS_CHAR,
--	   ATTRIBUTE5                      VARCHAR2  OPTIONAL DEFAULT = FND_API.G_MISS_CHAR,
--	   ATTRIBUTE6                      VARCHAR2  OPTIONAL DEFAULT = FND_API.G_MISS_CHAR,
--	   ATTRIBUTE7                      VARCHAR2  OPTIONAL DEFAULT = FND_API.G_MISS_CHAR,
--	   ATTRIBUTE8                      VARCHAR2  OPTIONAL DEFAULT = FND_API.G_MISS_CHAR,
--	   ATTRIBUTE9                      VARCHAR2  OPTIONAL DEFAULT = FND_API.G_MISS_CHAR,
--	   ATTRIBUTE10                     VARCHAR2  OPTIONAL DEFAULT = FND_API.G_MISS_CHAR,
--	   ATTRIBUTE11                     VARCHAR2  OPTIONAL DEFAULT = FND_API.G_MISS_CHAR,
--	   ATTRIBUTE12                     VARCHAR2  OPTIONAL DEFAULT = FND_API.G_MISS_CHAR,
--	   ATTRIBUTE13                     VARCHAR2  OPTIONAL DEFAULT = FND_API.G_MISS_CHAR,
--	   ATTRIBUTE14                     VARCHAR2  OPTIONAL DEFAULT = FND_API.G_MISS_CHAR,
--	   ATTRIBUTE15                     VARCHAR2  OPTIONAL DEFAULT = FND_API.G_MISS_CHAR,
--	   SECURITY_GROUP_ID               NUMBER    OPTIONAL DEFAULT = FND_API.G_MISS_NUM,
--	   OBJECT_VERSION_NUMBER           NUMBER    OPTIONAL DEFAULT = FND_API.G_MISS_NUM,
--	   END_DATE                        DATE      OPTIONAL DEFAULT = FND_API.G_MISS_DATE
--
--    Required
--
--    Defaults
--
--    Note: This is automatic generated record definition, it includes all columns
--          defined in the table, developer must manually add or delete some of the attributes.
--
--   End of Comments

--===================================================================

  TYPE apo_type IS RECORD(
       CONTROL_COUNT	   			   NUMBER := null,
  	   RISK_COUNT                      NUMBER := null,
	   TOP_PROCESS_ID                  NUMBER := null,
	   PROCESS_ORGANIZATION_ID         NUMBER := null,
	   LAST_UPDATE_DATE                DATE := null,
	   LAST_UPDATED_BY                 NUMBER := null,
	   CREATION_DATE                   DATE := null,
	   CREATED_BY                      NUMBER := null,
	   LAST_UPDATE_LOGIN               NUMBER := null,
	   PROCESS_ID                      NUMBER := null,
	   STANDARD_PROCESS_FLAG           VARCHAR2(1) := null,
	   RISK_CATEGORY                   VARCHAR2(30) := null,
	   APPROVAL_STATUS                 VARCHAR2(30) := null,
	   CERTIFICATION_STATUS            VARCHAR2(30) := null,
	   LAST_AUDIT_STATUS               VARCHAR2(30) := null,
	   ORGANIZATION_ID                 NUMBER := null,
	   LAST_CERTIFICATION_DATE         DATE := null,
	   LAST_AUDIT_DATE                 DATE := null,
	   NEXT_AUDIT_DATE                 DATE := null,
	   APPLICATION_OWNER_ID            NUMBER := null,
	   PROCESS_OWNER_ID                NUMBER := null,
	   PROCESS_CATEGORY_CODE           VARCHAR2(30) := null,
	   SIGNIFICANT_PROCESS_FLAG        VARCHAR2(1) := null,
	   FINANCE_OWNER_ID                NUMBER := null,
	   CREATED_FROM                    VARCHAR2(30) := null,
	   REQUEST_ID                      NUMBER := null,
	   PROGRAM_APPLICATION_ID          NUMBER := null,
	   PROGRAM_ID                      NUMBER := null,
	   PROGRAM_UPDATE_DATE             DATE := null,
	   ATTRIBUTE_CATEGORY              VARCHAR2(30) := null,
	   ATTRIBUTE1                      VARCHAR2(150) := null,
	   ATTRIBUTE2                      VARCHAR2(150) := null,
	   ATTRIBUTE3                      VARCHAR2(150) := null,
	   ATTRIBUTE4                      VARCHAR2(150) := null,
	   ATTRIBUTE5                      VARCHAR2(150) := null,
	   ATTRIBUTE6                      VARCHAR2(150) := null,
	   ATTRIBUTE7                      VARCHAR2(150) := null,
	   ATTRIBUTE8                      VARCHAR2(150) := null,
	   ATTRIBUTE9                      VARCHAR2(150) := null,
	   ATTRIBUTE10                     VARCHAR2(150) := null,
	   ATTRIBUTE11                     VARCHAR2(150) := null,
	   ATTRIBUTE12                     VARCHAR2(150) := null,
	   ATTRIBUTE13                     VARCHAR2(150) := null,
	   ATTRIBUTE14                     VARCHAR2(150) := null,
	   ATTRIBUTE15                     VARCHAR2(150) := null,
	   SECURITY_GROUP_ID               NUMBER := null,
	   OBJECT_VERSION_NUMBER           NUMBER := null,
	   END_DATE                        DATE := null
  );

  g_miss_apo_type apo_type;

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Process_Process_Hierarchy
--   Type
--           Public
--   Pre-Req
--
--   Parameters
--
--   IN
--       p_process_id              IN   NUMBER     Optional  Default = null
--       p_organization_id         IN   NUMBER     Optional  Default = null
--       p_mode                    IN   VARCHAR2   Required  Default = 'ASSOCIATE'
--       p_apo_type                IN   apo_type   Optional  Default = null
--       p_commit                  IN   VARCHAR2   Required  Default = FND_API_G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--
--   OUT
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--   Version : Current version 1.0
--   Note:
--
--   End of Comments
--   ==============================================================================
--

  procedure process_process_hierarchy(
    p_process_id in number := null,
	p_organization_id in number := null,
	p_mode in varchar2 := 'ASSOCIATE',
	p_level in number := 0,
	p_apo_type in apo_type := g_miss_apo_type,
	p_commit in varchar2 := FND_API.G_FALSE,
	p_validation_level IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
	p_init_msg_list IN VARCHAR2 := FND_API.G_FALSE,
    x_return_status out nocopy varchar2,
    x_msg_count out nocopy number,
    x_msg_data out nocopy varchar2
  );

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Associate_Process_Org
--   Type
--           Private
--   Pre-Req
--
--   Parameters
--
--   IN
--       p_apo_type                IN   apo_type   Optional  Default = null
--       p_process_id              IN   NUMBER     Optional  Default = null
--       p_top_process_id          IN   NUMBER     Optional  Default = null
--       p_organization_id         IN   NUMBER     Optional  Default = null
--       p_parent_process_id       IN   NUMBER     Optional  Default = null
--       p_mode                    IN   VARCHAR2   Required  Default = 'ASSOCIATE'
--       p_commit                  IN   VARCHAR2   Required  Default = FND_API_G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--
--   OUT
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--   Version : Current version 1.0
--   Note:
--
--   End of Comments
--   ==============================================================================
--

  procedure associate_process_org(
    p_apo_type in apo_type := g_miss_apo_type,
	p_process_id in number := null,
	p_top_process_id in number := null,
	p_organization_id in number := null,
	p_parent_process_id in number := null,
	p_rcm_assoc in varchar2 := 'N',
    p_batch_id in number := null,
	p_rcm_org_intf_id in number := null,
    p_risk_id in number := null,
    p_control_id in number := null,
	p_mode in varchar2 := 'ASSOCIATE',
	p_commit in varchar2 := FND_API.G_FALSE,
	p_validation_level IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
	p_init_msg_list IN VARCHAR2 := FND_API.G_FALSE,
    x_return_status out nocopy varchar2,
    x_msg_count out nocopy number,
    x_msg_data out nocopy varchar2
  );


--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Process_Amw_Process_Org
--   Type
--           Private
--   Pre-Req
--
--   Parameters
--
--   IN
--       p_apo_type                IN   apo_type   Optional  Default = null
--       p_do_insert               IN   VARCHAR2   Optional  Default = 'INSERT'
--       p_org_count               IN   NUMBER     Optional  Default = 0
--       p_commit                  IN   VARCHAR2   Required  Default = FND_API_G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--
--
--   OUT
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--   Version : Current version 1.0
--   Note:
--
--   End of Comments
--   ==============================================================================
--

  procedure process_amw_process_org(
    p_apo_type in apo_type := g_miss_apo_type,
	p_do_insert in varchar2 := 'INSERT',
	p_org_count in number := 0,
	p_rcm_assoc in varchar2 := 'N',
    p_batch_id in number := null,
	p_rcm_org_intf_id in number := null,
    p_risk_id in number := null,
    p_control_id in number := null,
	p_commit in varchar2 := FND_API.G_FALSE,
	p_validation_level IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
	p_init_msg_list IN VARCHAR2 := FND_API.G_FALSE,
    x_return_status out nocopy varchar2,
    x_msg_count out nocopy number,
    x_msg_data out nocopy varchar2
  );

  procedure process_amw_rcm_org(
    p_batch_id in number := null,
	p_rcm_org_intf_id in number := null,
    p_process_organization_id in number := null,
    p_organization_id in number := null,
	p_process_id in number := null,
    p_risk_id in number := null,
    p_control_id in number := null,
	p_commit in varchar2 := FND_API.G_FALSE,
	p_validation_level IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
	p_init_msg_list IN VARCHAR2 := FND_API.G_FALSE,
    x_return_status out nocopy varchar2,
    x_msg_count out nocopy number,
    x_msg_data out nocopy varchar2
  );

  procedure process_amw_acct_assoc(
    p_assoc_mode in varchar2 := 'ASSOCIATE',
    p_process_id in number,
    p_process_organization_id in number,
    p_commit in varchar2 := FND_API.G_FALSE,
	p_validation_level IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
	p_init_msg_list IN VARCHAR2 := FND_API.G_FALSE,
	x_return_status out nocopy varchar2,
    x_msg_count out nocopy number,
    x_msg_data out nocopy varchar2
  );

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Process_Amw_Risk_Assoc
--   Type
--           Private
--   Pre-Req
--
--   Parameters
--
--   IN
--       p_assoc_mode              IN   VARCHAR2   Otional   Default = 'ASSOCIATE'
--       p_process_id              IN   number     Required
--       p_process_organization_id IN   number     Required
--       p_commit                  IN   VARCHAR2   Required  Default = FND_API_G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--   OUT
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--   Version : Current version 1.0
--   Note:
--
--   End of Comments
--   ==============================================================================
--

  procedure process_amw_risk_assoc(
      p_assoc_mode in varchar2 := 'ASSOCIATE',
      p_process_id in number,
      p_process_organization_id in number,
	  p_commit in varchar2 := FND_API.G_FALSE,
	  p_validation_level IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
	  p_init_msg_list IN VARCHAR2 := FND_API.G_FALSE,
      x_return_status out nocopy varchar2,
      x_msg_count out nocopy number,
      x_msg_data out nocopy varchar2
    );

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Process_Amw_Control_Assoc
--   Type
--           Private
--   Pre-Req
--
--   Parameters
--
--   IN
--       p_assoc_mode              IN   VARCHAR2   Otional   Default = 'ASSOCIATE'
--       p_risk_association_id     IN   number     Required
--       p_risk_id                 IN   number     Required
--       p_commit                  IN   VARCHAR2   Required  Default = FND_API_G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--   OUT
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--   Version : Current version 1.0
--   Note:
--
--   End of Comments
--   ==============================================================================
--

  procedure process_amw_control_assoc(
      p_assoc_mode in varchar2 := 'ASSOCIATE',
      p_risk_association_id in number,
      p_risk_id in number,
	  p_commit in varchar2 := FND_API.G_FALSE,
	  p_validation_level IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
	  p_init_msg_list IN VARCHAR2 := FND_API.G_FALSE,
      x_return_status out nocopy varchar2,
      x_msg_count out nocopy number,
      x_msg_data out nocopy varchar2
    );

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Process_Amw_Ap_Assoc
--   Type
--           Private
--   Pre-Req
--
--   Parameters
--
--   IN
--       p_assoc_mode              IN   VARCHAR2   Otional   Default = 'ASSOCIATE'
--       p_control_association_id  IN   number     Required
--       p_control_id              IN   number     Required
--       p_commit                  IN   VARCHAR2   Required  Default = FND_API_G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--   OUT
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--   Version : Current version 1.0
--   Note:
--
--   End of Comments
--   ==============================================================================
--

  procedure process_amw_ap_assoc(
      p_assoc_mode in varchar2 := 'ASSOCIATE',
      p_control_association_id in number,
      p_control_id in number,
	  p_commit in varchar2 := FND_API.G_FALSE,
	  p_validation_level IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
	  p_init_msg_list IN VARCHAR2 := FND_API.G_FALSE,
      x_return_status out nocopy varchar2,
      x_msg_count out nocopy number,
      x_msg_data out nocopy varchar2
    );

  PROCEDURE process_hierarchy_count (
      p_process_id                IN              NUMBER := NULL,
      p_organization_id   		  IN              NUMBER := NULL,
      p_risk_count				  in			  number := null,
	  p_control_count			  in			  number := null,
	  p_mode          			  IN              VARCHAR2 := 'ASSOCIATE',
      p_commit                    IN              VARCHAR2 := fnd_api.g_false,
      x_return_status             OUT NOCOPY      VARCHAR2,
      x_msg_count                 OUT NOCOPY      NUMBER,
      x_msg_data                  OUT NOCOPY      VARCHAR2
   );

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Validate_Apo_Type
--   Type
--           Private
--   Pre-Req
--
--   Parameters
--
--   IN
--       p_api_version_number      IN   NUMBER     REQUIRED
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       p_apo_type                IN   apo_type   Required
--
--   OUT
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--   Version : Current version 1.0
--   Note:
--
--   End of Comments
--   ==============================================================================
--

  PROCEDURE validate_apo_type(
    p_api_version_number IN NUMBER,
    p_init_msg_list IN VARCHAR2 := FND_API.G_FALSE,
    p_validation_level IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
    p_apo_type IN apo_type,
    x_return_status OUT nocopy VARCHAR2,
    x_msg_count OUT nocopy NUMBER,
    x_msg_data OUT nocopy VARCHAR2
    );

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Check_Apo_Row
--   Type
--           Private
--   Pre-Req
--
--   Parameters
--
--   IN
--       p_apo_type                IN   apo_type   Required
--       p_validation_mode         IN   VARCHAR2   Optional  Default = JTF_PLSQL_API.g_create
--
--   OUT
--       x_return_status           OUT  VARCHAR2
--   Version : Current version 1.0
--   Note:
--
--   End of Comments
--   ==============================================================================
--
  PROCEDURE check_apo_row(
    p_apo_type IN apo_type,
    p_validation_mode IN VARCHAR2 := JTF_PLSQL_API.g_create,
    x_return_status OUT nocopy VARCHAR2
  );

  FUNCTION GET_parent_process_id(p_process_id in number,
  		   						 p_organization_id in number) return number;

END AMW_PROC_ORG_HIERARCHY_PVT; -- Package spec

 

/
