--------------------------------------------------------
--  DDL for Package Body OKE_K_ACCESS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKE_K_ACCESS_PVT" AS
/* $Header: OKEVKASB.pls 115.10 2002/11/20 20:44:25 who ship $ */

WF_Type        VARCHAR2(80);
WF_Item_Type   VARCHAR2(8);
WF_Process     VARCHAR2(30);

--
-- Private Procedures
--
PROCEDURE ASSIGNMENT_EXISTS
( P_PROJECT_PARTY_ID           IN      NUMBER
, P_OBJECT_TYPE                IN      VARCHAR2
, P_OBJECT_ID                  IN      NUMBER
, P_ROLE_ID                    IN      NUMBER
, P_PERSON_ID                  IN      NUMBER
, P_START_DATE_ACTIVE          IN      DATE
, P_END_DATE_ACTIVE            IN      DATE
, X_RETURN_STATUS              OUT     NOCOPY VARCHAR2
) IS

CURSOR c IS
  SELECT project_role_id
  FROM   pa_project_parties
  WHERE  project_party_id <> nvl( P_Project_Party_ID , -9999 )
  AND    object_type        = P_Object_Type
  AND    object_id          = P_Object_ID
  AND    resource_type_id   = 101
  AND    resource_source_id = P_Person_ID
  AND (  --
         -- Two date ranges overlap
         --
         GREATEST( trunc(P_Start_Date_Active) , trunc(start_date_active) ) <=
            LEAST( nvl( trunc(end_date_active) , trunc(P_End_Date_Active) )
                 , nvl( trunc(P_End_Date_Active) , trunc(end_date_active) ) )
      OR --
         -- Two open ended assignments
         --
         ( P_End_Date_Active is NULL AND end_date_active is NULL )
      );

L_Role_ID   NUMBER;

BEGIN

  OPEN c;
  FETCH c INTO L_Role_ID;

  IF ( c%notfound ) THEN
    CLOSE c;
    X_Return_Status := FND_API.G_RET_STS_SUCCESS;
    RETURN;
  END IF;

  CLOSE c;

  IF ( L_Role_ID <> P_Role_ID ) THEN
    FND_MESSAGE.Set_Name('OKE' , 'OKE_SEC_MULTI_ROLE_ASSIGNED');
  ELSE
    FND_MESSAGE.Set_Name('OKE' , 'OKE_SEC_OVERLAP_ROLE_ASSIGNED');
  END IF;
  FND_MESSAGE.Set_Token('EMP' , pa_utils.GetEmpName(P_Person_ID));
  FND_MSG_PUB.Add;
  X_Return_Status := FND_API.G_RET_STS_ERROR;

EXCEPTION
WHEN OTHERS THEN
  FND_MSG_PUB.ADD_EXC_MSG( p_pkg_name       => 'OKE_K_ACCESS_PVT'
                         , p_procedure_name => 'ASSIGNMENT_EXISTS'
                         , p_error_text     => substr(sqlerrm , 1 , 240) );
  X_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;

END ASSIGNMENT_EXISTS;


PROCEDURE VALIDATE_START_END_DATES
( P_START_DATE_ACTIVE          IN      DATE
, P_END_DATE_ACTIVE            IN      DATE
, X_RETURN_STATUS              OUT     NOCOPY VARCHAR2
) IS

BEGIN

  IF ( P_End_Date_Active IS NOT NULL
     AND P_End_Date_Active < P_Start_Date_Active ) THEN
    FND_MESSAGE.Set_Name('OKE' , 'OKE_INVALID_EFFDATE_PAIR');
    FND_MSG_PUB.Add;
    X_Return_Status := FND_API.G_RET_STS_ERROR;
  ELSE
    X_Return_Status := FND_API.G_RET_STS_SUCCESS;
    RETURN;
  END IF;

END VALIDATE_START_END_DATES;

--
-- Public Procedures
--
PROCEDURE CREATE_CONTRACT_ACCESS
( P_COMMIT                     IN      VARCHAR2
, P_OBJECT_TYPE                IN      VARCHAR2
, P_OBJECT_ID                  IN      NUMBER
, P_ROLE_ID                    IN      NUMBER
, P_PERSON_ID                  IN      NUMBER
, P_START_DATE_ACTIVE          IN      DATE
, P_END_DATE_ACTIVE            IN OUT  NOCOPY DATE
, X_PROJECT_PARTY_ID           OUT     NOCOPY NUMBER
, X_RESOURCE_ID                OUT     NOCOPY NUMBER
, X_ASSIGNMENT_ID              OUT     NOCOPY NUMBER
, X_RECORD_VERSION_NUMBER      OUT     NOCOPY NUMBER
, X_RETURN_STATUS              OUT     NOCOPY VARCHAR2
, X_MSG_COUNT                  OUT     NOCOPY NUMBER
, X_MSG_DATA                   OUT     NOCOPY VARCHAR2
) IS

  CURSOR c IS
    SELECT Record_Version_Number
    FROM   PA_Project_Parties PPP
    WHERE  Project_Party_ID = X_Project_Party_ID;

BEGIN

  FND_MSG_PUB.initialize;

  Validate_Start_End_Dates
  ( P_Start_Date_Active     => P_Start_Date_Active
  , P_End_Date_Active       => P_End_Date_Active
  , X_Return_Status         => X_Return_Status
  );

  IF ( X_Return_Status <> FND_API.G_RET_STS_SUCCESS ) THEN
    RETURN;
  END IF;

  Assignment_Exists
  ( P_Project_Party_ID      => NULL
  , P_Object_Type           => P_Object_Type
  , P_Object_ID             => P_Object_ID
  , P_Role_ID               => P_Role_ID
  , P_Person_ID             => P_Person_ID
  , P_Start_Date_Active     => P_Start_Date_Active
  , P_End_Date_Active       => P_End_Date_Active
  , X_Return_Status         => X_Return_Status
  );

  IF ( X_Return_Status <> FND_API.G_RET_STS_SUCCESS ) THEN
    RETURN;
  END IF;

  PA_PROJECT_PARTIES_PVT.Create_Project_Party
  ( P_Commit                => P_Commit
  , P_Validate_Only         => FND_API.G_FALSE
  , P_Validation_Level      => FND_API.G_VALID_LEVEL_FULL
  , P_Debug_Mode            => 'N'
  , P_Object_ID             => P_Object_ID
  , P_Object_Type           => P_Object_Type
  , P_Resource_Type_ID      => 101
  , P_Project_Role_ID       => P_Role_ID
  , P_Resource_Source_ID    => P_Person_ID
  , P_Start_Date_Active     => P_Start_Date_Active
  , P_Scheduled_Flag        => 'N'
  , P_Calling_Module        => 'FORM'
  , P_Project_ID            => NULL
  , P_Project_End_Date      => NULL
  , P_End_Date_Active       => P_End_Date_Active
  , X_Project_Party_ID      => X_Project_Party_ID
  , X_Resource_ID           => X_Resource_ID
  , X_Assignment_ID         => X_Assignment_ID
  , X_WF_Type               => WF_Type
  , X_WF_Item_Type          => WF_Item_Type
  , X_WF_Process            => WF_Process
  , X_Return_Status         => X_Return_Status
  , X_Msg_Count             => X_Msg_Count
  , X_Msg_Data              => X_Msg_Data
  );

  IF ( X_Return_Status <> FND_API.G_RET_STS_SUCCESS ) THEN
    RETURN;
  END IF;

  OPEN c;
  FETCH c INTO X_Record_Version_Number;
  IF ( c%notfound ) THEN
    CLOSE c;
    X_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;
  END IF;
  CLOSE c;

END CREATE_CONTRACT_ACCESS;


PROCEDURE LOCK_ROW
( P_OBJECT_TYPE                IN      VARCHAR2
, P_OBJECT_ID                  IN      NUMBER
, P_ROLE_ID                    IN      NUMBER
, P_PERSON_ID                  IN      NUMBER
, P_START_DATE_ACTIVE          IN      DATE
, P_END_DATE_ACTIVE            IN      DATE
, P_PROJECT_PARTY_ID           IN      NUMBER
, P_RESOURCE_ID                IN      NUMBER
) IS

BEGIN

   PA_PROJECT_PARTIES_PKG.Lock_Row
   ( X_Project_Party_ID     => P_Project_Party_ID
   , X_Object_ID            => P_Object_ID
   , X_Object_Type          => P_Object_Type
   , X_Project_ID           => NULL
   , X_Resource_ID          => P_Resource_ID
   , X_Resource_Type_ID     => 101
   , X_Resource_Source_ID   => P_Person_ID
   , X_Project_Role_ID      => P_Role_ID
   , X_Start_Date_Active    => P_Start_Date_Active
   , X_Scheduled_Flag       => 'N'
   , X_End_Date_Active      => P_End_Date_Active
   );

END LOCK_ROW;


PROCEDURE UPDATE_CONTRACT_ACCESS
( P_COMMIT                     IN      VARCHAR2
, P_OBJECT_TYPE                IN      VARCHAR2
, P_OBJECT_ID                  IN      NUMBER
, P_ROLE_ID                    IN      NUMBER
, P_PERSON_ID                  IN      NUMBER
, P_START_DATE_ACTIVE          IN      DATE
, P_END_DATE_ACTIVE            IN OUT  NOCOPY DATE
, P_PROJECT_PARTY_ID           IN      NUMBER
, P_RECORD_VERSION_NUMBER      IN      NUMBER
, P_RESOURCE_ID                IN      NUMBER
, P_ASSIGNMENT_ID              IN      NUMBER
, X_ASSIGNMENT_ID              OUT     NOCOPY NUMBER
, X_RETURN_STATUS              OUT     NOCOPY VARCHAR2
, X_MSG_COUNT                  OUT     NOCOPY NUMBER
, X_MSG_DATA                   OUT     NOCOPY VARCHAR2
) IS

BEGIN

  FND_MSG_PUB.initialize;

  Validate_Start_End_Dates
  ( P_Start_Date_Active     => P_Start_Date_Active
  , P_End_Date_Active       => P_End_Date_Active
  , X_Return_Status         => X_Return_Status
  );

  IF ( X_Return_Status <> FND_API.G_RET_STS_SUCCESS ) THEN
    RETURN;
  END IF;

  Assignment_Exists
  ( P_Project_Party_ID      => P_Project_Party_ID
  , P_Object_Type           => P_Object_Type
  , P_Object_ID             => P_Object_ID
  , P_Role_ID               => P_Role_ID
  , P_Person_ID             => P_Person_ID
  , P_Start_Date_Active     => P_Start_Date_Active
  , P_End_Date_Active       => P_End_Date_Active
  , X_Return_Status         => X_Return_Status
  );

  IF ( X_Return_Status <> FND_API.G_RET_STS_SUCCESS ) THEN
    RETURN;
  END IF;

  PA_PROJECT_PARTIES_PVT.Update_Project_Party
  ( P_Commit                       => P_Commit
  , P_Validate_Only                => FND_API.G_FALSE
  , P_Validation_Level             => FND_API.G_VALID_LEVEL_FULL
  , P_Debug_Mode                   => 'N'
  , P_Object_ID                    => P_Object_ID
  , P_Object_Type                  => P_Object_Type
  , P_Project_Role_ID              => P_Role_ID
  , P_Resource_Type_ID             => 101
  , P_Resource_Source_ID           => P_Person_ID
  , P_Resource_ID                  => P_Resource_ID
  , P_Start_Date_Active            => P_Start_Date_Active
  , P_Scheduled_Flag               => 'N'
  , P_Record_Version_Number        => P_Record_Version_Number
  , P_Calling_Module               => 'FORM'
  , P_Project_ID                   => NULL
  , P_Project_End_Date             => NULL
  , P_Project_Party_ID             => P_Project_Party_ID
  , P_Assignment_ID                => FND_API.G_MISS_NUM
  , P_Assign_Record_Version_Number => FND_API.G_MISS_NUM
  , P_End_Date_Active              => P_End_Date_Active
  , X_Assignment_ID                => X_Assignment_ID
  , X_WF_Type                      => WF_Type
  , X_WF_Item_Type                 => WF_Item_Type
  , X_WF_Process                   => WF_Process
  , X_Return_Status                => X_Return_Status
  , X_Msg_Count                    => X_Msg_Count
  , X_Msg_Data                     => X_Msg_Data
  );

END UPDATE_CONTRACT_ACCESS;

END OKE_K_ACCESS_PVT;

/
