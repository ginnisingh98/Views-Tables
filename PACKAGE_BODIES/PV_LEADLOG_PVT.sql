--------------------------------------------------------
--  DDL for Package Body PV_LEADLOG_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PV_LEADLOG_PVT" as
/* $Header: pvxvlalb.pls 115.14 2002/11/20 02:06:16 pklin ship $ */

--
-- NAME
--   PV_LEADASN_PVT
--
-- PURPOSE
--   Private API for creating pv_leads
--   uses.
--
-- NOTES
--   This pacakge should not be used by any non-osm sources.  All non OSM
--   sources should use the Public create_account API
--
--
--
-- HISTORY

G_PKG_NAME  CONSTANT VARCHAR2(30):='PV_LEADLOG_PVT';
G_FILE_NAME   CONSTANT VARCHAR2(12):='pvxvlalb.pls';

G_APPL_ID         NUMBER := FND_GLOBAL.Prog_Appl_Id;
G_LOGIN_ID        NUMBER := FND_GLOBAL.Conc_Login_Id;
G_PROGRAM_ID      NUMBER := FND_GLOBAL.Conc_Program_Id;
G_USER_ID         NUMBER := FND_GLOBAL.User_Id;
G_REQUEST_ID      NUMBER := FND_GLOBAL.Conc_Request_Id;




  --
  -- NAME
  --   InsertAssignRow
  --
  -- PURPOSE
  --
  -- NOTES
  --
  --
  --
  --

PROCEDURE InsertAssignLogRow (
        X_Rowid                   OUT NOCOPY    ROWID     ,
        x_assignlog_ID            OUT NOCOPY    NUMBER       ,
        p_Lead_assignment_ID      IN     NUMBER       ,
        p_Last_Updated_By         IN     NUMBER       ,
        p_Last_Update_Date        IN     DATE         ,
	p_Object_Version_number   IN     NUMBER       ,
        p_Last_Update_Login       IN     NUMBER       ,
        p_Created_By              IN     NUMBER       ,
        p_Creation_Date           IN     DATE         ,
        p_lead_id                 IN     NUMBER       ,
	p_duration                IN     NUMBER       ,
        p_partner_id              IN     NUMBER       ,
        p_assign_sequence         IN     NUMBER       ,
        p_status_date             IN     DATE         ,
        p_status                  IN     VARCHAR2     ,
        p_cm_id                   IN     NUMBER       ,
        p_wf_pt_user              IN     VARCHAR2     ,
        p_wf_cm_user              IN     VARCHAR2     ,
        p_wf_item_type            IN     VARCHAR2     ,
        p_wf_item_key             IN     VARCHAR2     ,
        p_trans_type              IN     NUMBER       ,
        p_error_txt               IN     VARCHAR2     ,
        p_status_change_comments  IN     VARCHAR2     ,
        x_return_status           OUT NOCOPY    VARCHAR2) IS


     CURSOR C IS
        SELECT  rowid
        FROM    pv_assignment_logs
        WHERE   assignment_ID  = X_assignlog_ID;

     l_assignment_id   number;

BEGIN


  x_return_status := 'S';

  select pv_assignment_logs_s.nextval
  into   l_assignment_ID
  from   sys.dual;



   insert into pv_assignment_logs (
	    ASSIGNMENT_ID  ,
	    LAST_UPDATE_DATE,
	    LAST_UPDATED_BY,
	    CREATION_DATE,
	    CREATED_BY,
	    OBJECT_VERSION_NUMBER,
	    LAST_UPDATE_LOGIN,
	    LEAD_ID,
	    DURATION,
	    LEAD_ASSIGNMENT_ID,
	    PARTNER_ID,
	    ASSIGN_SEQUENCE,
	    CM_ID,
	    WF_PT_USER,
	    WF_CM_USER,
	    WF_ITEM_TYPE,
	    WF_ITEM_KEY,
	    STATUS_DATE,
	    STATUS,
	    TRANS_TYPE,
	    ERROR_TXT,
	    STATUS_CHANGE_COMMENTS)
	 Values (
	    l_assignment_id       ,
	    p_Last_Update_Date    ,
	    p_Last_Updated_By     ,
	    p_Creation_Date       ,
	    p_Created_By          ,
	    p_Object_version_number,
	    p_Last_Update_Login   ,
	    p_lead_id             ,
	    p_duration            ,
	    p_Lead_assignment_ID  ,
	    p_partner_id          ,
	    p_assign_sequence     ,
	    p_cm_id               ,
	    p_wf_pt_user          ,
	    p_wf_cm_user          ,
	    p_wf_item_type        ,
	    p_wf_item_key         ,
	    p_status_date         ,
	    p_status              ,
	    p_trans_type          ,
	    p_error_txt           ,
	    p_status_change_comments);

      X_assignlog_ID := l_assignment_id;

      OPEN C;
      FETCH C INTO X_Rowid;
      IF (C%NOTFOUND)
      THEN
          CLOSE C;
          Raise NO_DATA_FOUND;
      END IF;
      CLOSE C;

EXCEPTION
   WHEN OTHERS THEN
	 x_return_status := 'E';

END InsertAssignLogRow;


  --
  -- NAME
  --   CreateAssignLog
  --
  -- PURPOSE
  --   Private API to update customer, address, site uses in ra tables for OSM
  --
  -- NOTES
  --   This is a private API, which should only be called from PV.  All
  --
  --
  --

  PROCEDURE CreateAssignLog
    ( p_api_version_number  IN   NUMBER,
      p_init_msg_list       IN   VARCHAR2           := FND_API.G_FALSE,
      p_commit              IN   VARCHAR2           := FND_API.G_FALSE,
      p_validation_level    IN   NUMBER             := FND_API.G_VALID_LEVEL_FULL,
      p_assignlog_rec       IN   ASSIGNLOG_REC_TYPE := G_MISS_ASSIGNLOG_REC,
      x_assignment_id       OUT NOCOPY  NUMBER,
      x_return_status       OUT NOCOPY  VARCHAR2,
      x_msg_count           OUT NOCOPY  NUMBER,
      x_msg_data            OUT NOCOPY  VARCHAR2)
  IS


    l_api_name              CONSTANT VARCHAR2(30) := 'CreateAssignLog';
    l_api_version_number    CONSTANT NUMBER       := 1.0;
    l_assignment_id         NUMBER;
    l_rowid                 ROWID;
    l_return_status         VARCHAR2(1);    -- Local return status for calling
    l_return_status_full    varchar2(1);
    l_assignlog_rec         ASSIGNLOG_REC_TYPE := p_assignlog_rec;



  BEGIN

    -- Standard Start of API savepoint
    SAVEPOINT CREATE_AssignLog_PVT;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (l_api_version_number,
                                        p_api_version_number,
                                        l_api_name,
                                        G_PKG_NAME)
    THEN
      IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_ERROR)
      THEN
        fnd_message.Set_Name('PV', 'API_UNEXP_ERROR_IN_PROCESSING');
        fnd_message.Set_Token('ROW', 'PV_LEADLOG', TRUE);
        fnd_msg_pub.ADD;
      END IF;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;


    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list )
    THEN
      fnd_msg_pub.initialize;
    END IF;

    -- Debug Message
    IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW)
    THEN
      fnd_message.Set_Name('PV', 'Pvt Acc API: Start');
      fnd_msg_pub.Add;
    END IF;

    --  Initialize API return status to success
    --
    x_return_status      := FND_API.G_RET_STS_SUCCESS;
    l_return_status_full := FND_API.G_RET_STS_SUCCESS;
    l_assignment_id      := NULL;

    --
    -- API body
    --


    -- ******************************************************************
    -- Validate Environment
    -- ******************************************************************
    IF G_User_Id IS NULL
    THEN
      IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_ERROR)
      THEN
        fnd_message.Set_Name('PV', 'UT_CANNOT_GET_PROFILE_VALUE');
        fnd_message.Set_Token('PROFILE', 'USER_ID', FALSE);
        fnd_msg_pub.ADD;
      END IF;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    -- ******************************************************************



    InsertAssignLogRow (
           X_Rowid                   =>  l_rowid                         ,
           x_assignlog_ID            =>  l_assignment_id                 ,
           p_Lead_assignment_ID      =>  l_assignlog_rec.Lead_assignment_ID ,
           p_Last_Updated_By         =>  G_USER_ID                       ,
           p_Last_Update_Date        =>  SYSDATE                         ,
           p_Last_Update_Login       =>  G_LOGIN_ID                      ,
           p_Created_By              =>  G_USER_ID                       ,
           p_Creation_Date           =>  SYSDATE                         ,
           p_Object_Version_Number   =>  l_assignlog_rec.object_version_number,
           p_lead_id                 =>  l_assignlog_rec.lead_id         ,
           p_duration                =>  l_assignlog_rec.duration        ,
           p_partner_id              =>  l_assignlog_rec.partner_id      ,
           p_assign_sequence         =>  l_assignlog_rec.assign_sequence ,
           p_status_date             =>  l_assignlog_rec.status_date     ,
           p_status                  =>  l_assignlog_rec.status          ,
           p_cm_id                   =>  l_assignlog_rec.cm_id           ,
           p_wf_pt_user              =>  l_assignlog_rec.wf_pt_user      ,
           p_wf_cm_user              =>  l_assignlog_rec.wf_cm_user      ,
           p_wf_item_type            =>  l_assignlog_rec.wf_item_type    ,
           p_wf_item_key             =>  l_assignlog_rec.wf_item_key     ,
           p_trans_type              =>  l_assignlog_rec.trans_type      ,
           p_error_txt               =>  l_assignlog_rec.error_txt       ,
           p_status_change_comments  =>  l_assignlog_rec.status_change_comments,
           x_return_status           =>  l_return_status);

   if l_return_status <>  FND_API.G_RET_STS_SUCCESS then
	 raise FND_API.G_EXC_ERROR;
   end if;



    x_assignment_id  := l_assignment_id;

    -- Debug Message
    IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW)
    THEN
      fnd_message.Set_Name('PV', 'Pvt Acc API: Insert Addr Rec');
      fnd_msg_pub.Add;
    END IF;


    --
    -- End of API body.
    --

    -- Success Message
    IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_SUCCESS) and
       l_return_status_full = FND_API.G_RET_STS_SUCCESS
    THEN
      fnd_message.Set_Name('PV', 'API_SUCCESS');
      fnd_message.Set_Token('ROW', 'AS_ACCOUNT', TRUE);
      fnd_msg_pub.Add;
    END IF;

    IF FND_API.To_Boolean ( p_commit )
    THEN
      COMMIT WORK;
    END IF;

    -- Debug Message
    IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW)
    THEN
      fnd_message.Set_Name('PV', 'Pvt Acc API: End');
      fnd_msg_pub.Add;
    END IF;

    -- Standard call to get message count and if count is 1, get message info.
    fnd_msg_pub.Count_And_Get ( p_count => x_msg_count,
                                p_data  => x_msg_data
                               );

  EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

      ROLLBACK TO CREATE_AssignLog_PVT;
      x_return_status := FND_API.G_RET_STS_ERROR ;

      fnd_msg_pub.Count_And_Get ( p_count => x_msg_count,
                                  p_data  => x_msg_data
                                 );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

      ROLLBACK TO CREATE_AssignLog_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

      fnd_msg_pub.Count_And_Get ( p_count => x_msg_count,
                                  p_data  => x_msg_data
                                 );

    WHEN OTHERS THEN

      ROLLBACK TO CREATE_AssignLog_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

      IF fnd_msg_pub.Check_Msg_Level ( fnd_msg_pub.G_MSG_LVL_UNEXP_ERROR )
      THEN
        fnd_msg_pub.Add_Exc_Msg ( G_PKG_NAME,l_api_name );
      END IF;

      fnd_msg_pub.Count_And_Get ( p_count => x_msg_count,
                                  p_data  => x_msg_data
                                 );

  END CreateAssignLog;


  --
  -- NAME
  --   InsertLeadStatusLogRow
  --
  -- PURPOSE
  --
  -- NOTES
  --
  --
  --
  --

PROCEDURE InsertLeadStatusLogRow (
   X_Rowid                   OUT NOCOPY    ROWID     ,
   x_assignlog_ID            OUT NOCOPY    NUMBER       ,
   p_Last_Updated_By         IN     NUMBER       ,
   p_Last_Update_Date        IN     DATE         ,
	p_Object_Version_number   IN     NUMBER       ,
   p_Last_Update_Login       IN     NUMBER       ,
   p_Created_By              IN     NUMBER       ,
   p_Creation_Date           IN     DATE         ,
   p_lead_id                 IN     NUMBER       ,
   p_partner_id              IN     NUMBER       ,
   p_status_date             IN     DATE         ,
   p_from_status             IN     VARCHAR2     ,
   p_to_status               IN     VARCHAR2     ,
   x_return_status       OUT NOCOPY  VARCHAR2,
   x_msg_count           OUT NOCOPY  NUMBER,
   x_msg_data            OUT NOCOPY  VARCHAR2) IS

     CURSOR C IS
        SELECT  rowid
        FROM    pv_assignment_logs
        WHERE   assignment_ID  = X_assignlog_ID;

    l_assignment_id   number;
    l_api_name              CONSTANT VARCHAR2(30) := 'InsertLeadStatusLogRow';

BEGIN


	x_return_status      := FND_API.G_RET_STS_SUCCESS;

  select pv_assignment_logs_s.nextval
  into   l_assignment_ID
  from   sys.dual;


   insert into pv_assignment_logs (
	    ASSIGNMENT_ID  ,
	    LAST_UPDATE_DATE,
	    LAST_UPDATED_BY,
	    CREATION_DATE,
	    CREATED_BY,
	    OBJECT_VERSION_NUMBER,
	    LAST_UPDATE_LOGIN,
	    LEAD_ID,
	    PARTNER_ID,
	    STATUS_DATE,
	    FROM_LEAD_STATUS,
	    TO_LEAD_STATUS)
	 Values (
	    l_assignment_id       ,
	    p_Last_Update_Date    ,
	    p_Last_Updated_By     ,
	    p_Creation_Date       ,
	    p_Created_By          ,
	    p_Object_version_number,
	    p_Last_Update_Login   ,
	    p_lead_id             ,
	    p_partner_id          ,
	    p_status_date         ,
	    p_from_status         ,
	    p_to_status);

      X_assignlog_ID := l_assignment_id;

      OPEN C;
      FETCH C INTO X_Rowid;
      IF (C%NOTFOUND)
      THEN
          CLOSE C;
          Raise NO_DATA_FOUND;
      END IF;
      CLOSE C;

EXCEPTION
WHEN OTHERS THEN


	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

	FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);

	fnd_msg_pub.Count_And_Get( p_encoded   =>  FND_API.G_FALSE,
										p_count     =>  x_msg_count,
										p_data      =>  x_msg_data);


END InsertLeadStatusLogRow;


end pv_leadlog_pvt;

/
