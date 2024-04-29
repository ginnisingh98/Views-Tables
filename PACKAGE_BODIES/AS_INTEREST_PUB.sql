--------------------------------------------------------
--  DDL for Package Body AS_INTEREST_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AS_INTEREST_PUB" as
/* $Header: asxpintb.pls 120.2 2005/08/04 22:16:45 appldev ship $ */

--
-- NAME
--   AS_INTEREST_PUB
--
-- PURPOSE
--   Provide public interest record and table type to be used by APIs that
--   import interests/classifications into OSM
--
--   Convert the public interest records into private interest records for use by
--   the AS_INTEREST_PVT.Create_Interest routine
--
--
-- NOTES
--   The procedures in this package are not supported for use by anyone outside
--   of OSM.  The procedures are called from the necessary API's to convert the
--   number into the table type excepted by the Private Interest API routine
--   (create_interest)
--
-- HISTORY
--   11/12/96 JKORNBER    Created
--   08/28/98   AWU         Add update_interest
--                  Add interest_id, customer_id, address_id,
--                  contact_id and lead_id into
--                  interest record
--                  Changed interest rec default value NULL to
--                  FND_API.G_MISS for update purpose
--
--
G_PKG_NAME  CONSTANT VARCHAR2(30):='AS_INTEREST_PUB';
G_FILE_NAME   CONSTANT VARCHAR2(12):='asxpintb.pls';

--------------------------------Public Routines-------------------------------------

  -- Start of Comments
  --
  -- NAME
  --   create_interest
  --
  -- PURPOSE
  --   Create an interest for an existing account/contact/lead.
  --
  -- NOTES
  --
  --
  -- End of Comments

  Procedure create_interest(p_api_version_number  in  number
                           ,p_init_msg_list       in  varchar2 := fnd_api.g_false
                           ,p_commit              in  varchar2 := fnd_api.g_false
               ,p_validation_level      IN  NUMBER
                        := FND_API.G_VALID_LEVEL_FULL
                           ,p_interest_rec        in  interest_rec_type
                           ,p_customer_id         in  number
                           ,p_address_id          in  number
                           ,p_contact_id          in  number
                           ,p_lead_id             in  number
                           ,p_interest_use_code   in  varchar2
                      ,p_check_access_flag   in  varchar2
                      ,p_admin_flag          in  varchar2
                      ,p_admin_group_id      in  number
                      ,p_identity_salesforce_id  in number
                      ,p_access_profile_rec  IN  AS_ACCESS_PUB.ACCESS_PROFILE_REC_TYPE
                           ,p_return_status       OUT NOCOPY varchar2
                           ,p_msg_count           OUT NOCOPY number
                           ,p_msg_data            OUT NOCOPY varchar2
               ,p_interest_out_id     OUT NOCOPY number) is

    l_api_name              constant varchar2(30) := 'Create_Interest';
    l_api_version_number    constant number   := 2.0;
    l_interest_tbl      interest_tbl_type;
    l_pvt_classification_tbl    as_interest_pvt.interest_tbl_type;
    l_pvt_interest_out_tbl      as_interest_pvt.interest_out_tbl_type;
    l_return_status varchar2(1);
    l_mode                      constant varchar2(30) := 'ON-INSERT';
    l_module CONSTANT VARCHAR2(255) := 'as.plsql.intpb.create_interest';

  begin

    -- standard start of api savepoint
    savepoint create_interest_pub;

    -- standard call to check for call compatibility.
    if not fnd_api.compatible_api_call ( l_api_version_number,
                                         p_api_version_number,
                                         l_api_name,
                                         g_pkg_name)
    then
      raise fnd_api.g_exc_unexpected_error;
    end if;


    -- initialize message list if p_init_msg_list is set to true.
    if fnd_api.to_boolean( p_init_msg_list )
    then
      fnd_msg_pub.initialize;
    end if;

    -- Debug Message
    if fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_debug_low)
    then
      fnd_message.set_name('as', 'Public Create Interest: Start');
      fnd_msg_pub.add;
    end if;

    --  Initialize API return status to success
    p_return_status := FND_API.G_RET_STS_SUCCESS;

    l_interest_tbl(1) := p_interest_rec;

    -- Convert account classification values to ids
     Convert_Values_To_Ids ( p_interest_tbl    => l_interest_tbl,
                             p_pvt_interest_tbl  => l_pvt_classification_tbl
                            );

    as_interest_pvt.create_interest ( p_api_version_number    => 2.0
                                     ,p_init_msg_list         => fnd_api.g_false
                                     ,p_commit                => fnd_api.g_false
                                     ,p_validation_level      => p_validation_level
                                     ,p_interest_tbl          => l_pvt_classification_tbl
                                     ,p_customer_id           => p_customer_id
                                     ,p_address_id            => p_address_id
                                     ,p_contact_id            => p_contact_id
                                     ,p_lead_id               => p_lead_id
                                     ,p_interest_use_code     => p_interest_use_code
                                ,p_check_access_flag     => p_check_access_flag
                                ,p_admin_flag            => p_admin_flag
                                ,p_admin_group_id        => p_admin_group_id
                                ,p_identity_salesforce_id  => p_identity_salesforce_id
                              ,p_access_profile_rec    => p_access_profile_rec
                                     ,p_return_status         => l_return_status
                                     ,p_msg_count             => p_msg_count
                                     ,p_msg_data              => p_msg_data
                                     ,p_interest_out_tbl      => l_pvt_interest_out_tbl
                                      );

    p_return_status := l_return_status;
    if l_return_status = fnd_api.g_ret_sts_error then
      raise fnd_api.g_exc_error;
    elsif l_return_status = fnd_api.g_ret_sts_unexp_error then
      raise fnd_api.g_exc_unexpected_error;
    end if;

    p_interest_out_id := l_pvt_interest_out_tbl(1).interest_id;

    --
    -- End of API body.
    --


    AS_RTTAP_ACCOUNT.PROCESS_RTTAP_ACCOUNT
                     (p_interest_rec.customer_id,l_return_status);

    if fnd_api.to_boolean ( p_commit )
    then
      commit work;
    end if;

    -- Debug Message
    if fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_debug_low)
    then
      fnd_message.set_name('AS', 'Public Create Interest: End');
      fnd_msg_pub.add;
    end if;


    -- Standard call to get message count and if count is 1, get message info.
    fnd_msg_pub.count_and_get( p_count => p_msg_count
                              ,p_data  => p_msg_data );

  exception

     WHEN FND_API.G_EXC_ERROR THEN

        AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
           P_MODULE => l_module
          ,P_API_NAME => L_API_NAME
          ,P_PKG_NAME => G_PKG_NAME
          ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
          ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
          ,X_MSG_COUNT => P_MSG_COUNT
          ,X_MSG_DATA => P_MSG_DATA
          ,X_RETURN_STATUS => P_RETURN_STATUS);

     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
           P_MODULE => l_module
          ,P_API_NAME => L_API_NAME
          ,P_PKG_NAME => G_PKG_NAME
          ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
          ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
          ,X_MSG_COUNT => P_MSG_COUNT
          ,X_MSG_DATA => P_MSG_DATA
          ,X_RETURN_STATUS => P_RETURN_STATUS);

     WHEN OTHERS THEN

        AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
           P_MODULE => l_module
          ,P_API_NAME => L_API_NAME
          ,P_PKG_NAME => G_PKG_NAME
          ,P_EXCEPTION_LEVEL => AS_UTILITY_PVT.G_EXC_OTHERS
     ,P_SQLCODE => SQLCODE
           ,P_SQLERRM => SQLERRM
          ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
          ,X_MSG_COUNT => P_MSG_COUNT
          ,X_MSG_DATA => P_MSG_DATA
          ,X_RETURN_STATUS => P_RETURN_STATUS);

  end create_interest;

   -- Start of Comments
--
--  API name    : Update Interest
--  Type        : Public
--  Function    : Update Account, Contact, or Lead Classification Interest
--  Pre-reqs    : Account, contact, or lead exists
--  Parameters
--  IN      :
--          p_api_version_number    IN  NUMBER      Required
--          p_init_msg_list     IN  VARCHAR2    Optional
--              Default = FND_API.G_FALSE
--          p_commit            IN  VARCHAR2    Optional
--              Default = FND_API.G_FALSE
--          p_validation_level  IN  NUMBER      Optional
--              Default = FND_API.G_VALID_LEVEL_FULL
--          p_identity_salesforce_id  IN    NUMBER      Optional
--          p_interest_rec      IN INTEREST_REC_TYPE    Required
--          p_interest_use_code IN  VARCHAR2    Required
--              (LEAD_CLASSIFICATION, COMPANY_CLASSIFICATION,
--               CONTACT_INTEREST)
--
--  OUT     :
--          x_return_status     OUT VARCHAR2(1)
--          x_msg_count     OUT NUMBER
--          x_msg_data      OUT VARCHAR2(2000)
--          x_interest_id       OUT     NUMBER
--
--
--  Version :   Current version 2.0
--              Initial Version
--           Initial version    2.0
--
--  Notes:          For each interest, the interest type must be denoted properly
--              (i.e. for updating lead classifications, the interest
--              type must be denoted as a lead classification interest)
--
--
-- End of Comments

PROCEDURE Update_Interest
(   p_api_version_number    IN  NUMBER,
    p_init_msg_list     IN  VARCHAR2    := FND_API.G_FALSE,
    p_commit            IN      VARCHAR2    := FND_API.G_FALSE,
    p_validation_level  IN  NUMBER      :=FND_API.G_VALID_LEVEL_FULL,
        p_identity_salesforce_id  IN    NUMBER := NULL,
    p_interest_rec      IN  INTEREST_REC_TYPE := G_MISS_INTEREST_REC,
    p_interest_use_code IN  VARCHAR2,
    p_check_access_flag   IN VARCHAR2,
    p_admin_flag          IN VARCHAR2,
    p_admin_group_id      IN NUMBER,
     p_access_profile_rec  IN  AS_ACCESS_PUB.ACCESS_PROFILE_REC_TYPE,
    x_return_status     OUT NOCOPY  VARCHAR2,
    x_msg_count     OUT NOCOPY  NUMBER,
    x_msg_data      OUT NOCOPY  VARCHAR2,
    x_interest_id       OUT NOCOPY     NUMBER
) is

    l_api_name            CONSTANT VARCHAR2(30) := 'Update_Interest';
    l_api_version_number  CONSTANT NUMBER       := 2.0;
    l_return_status     VARCHAR2(1);
    l_rowid         ROWID;
    l_interest_id NUMBER;
    l_identity_sales_member_rec      AS_SALES_MEMBER_PUB.Sales_member_rec_Type;
    l_interest_rec as_interest_pvt.interest_rec_type;
    l_interest_tbl as_interest_pub.interest_tbl_type;
    l_pvt_interest_tbl as_interest_pvt.interest_tbl_type;
    l_mode                      constant varchar2(30) := 'ON-UPDATE';
    l_lead_id NUMBER;
    l_address_id NUMBER;
    l_module CONSTANT VARCHAR2(255) := 'as.plsql.intpb.Update_Interest';


  BEGIN

    -- Standard Start of API savepoint
    SAVEPOINT UPDATE_INTEREST_PUB;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call( l_api_version_number,
                                        p_api_version_number,
                                        l_api_name,
                                        G_PKG_NAME)
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;


    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list )
    THEN
      FND_MSG_PUB.initialize;
    END IF;

    -- Debug Message
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)
    THEN
      FND_MESSAGE.Set_Name('AS', 'Pub Interest API: Start');
      FND_MSG_PUB.Add;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    l_return_status := FND_API.G_RET_STS_SUCCESS;

    /*
     Commented by gbatra as assumption is that ids are always passed
     Convert_Interest_Values_To_Ids (p_interest_type            => p_interest_rec.interest_type,
                                            p_interest_type_id              => p_interest_rec.interest_type_id,
                                            p_primary_interest_code         => p_interest_rec.primary_interest_code,
                                            p_primary_interest_code_id      => p_interest_rec.primary_interest_code_id,
                                            p_secondary_interest_code       => p_interest_rec.secondary_interest_code,
                                            p_secondary_interest_code_id    => p_interest_rec.secondary_interest_code_id,
                        p_description           => p_interest_rec.description,
                                            p_return_status                 => l_return_status,
                                            p_out_interest_type_id          => l_interest_rec.interest_type_id,
                                            p_out_primary_interest_code_id  => l_interest_rec.primary_interest_code_id,
                                            p_out_second_interest_code_id   => l_interest_rec.secondary_interest_code_id,
                        p_out_description           => l_interest_rec.description
                                            );
    */
    l_interest_rec.interest_type_id             := p_interest_rec.interest_type_id;
    l_interest_rec.primary_interest_code_id     := p_interest_rec.primary_interest_code_id;
    l_interest_rec.secondary_interest_code_id   := p_interest_rec.secondary_interest_code_id;
    l_interest_rec.description                  := p_interest_rec.description;
    l_interest_rec.product_category_id          := p_interest_rec.product_category_id;
    l_interest_rec.product_cat_set_id           := p_interest_rec.product_cat_set_id;
    l_interest_rec.interest_id := p_interest_rec.interest_id;
    l_interest_rec.customer_id := p_interest_rec.customer_id;
    l_interest_rec.address_id := p_interest_rec.address_id;
    l_interest_rec.contact_id := p_interest_rec.contact_id;
    l_interest_rec.lead_id := p_interest_rec.lead_id;
    l_interest_rec.last_update_date := p_interest_rec.last_update_date;
    l_interest_rec.last_updated_by := p_interest_rec.last_updated_by;
    l_interest_rec.creation_date    := p_interest_rec.creation_date;
    l_interest_rec.created_by := p_interest_rec.created_by;
    l_interest_rec.last_update_login := p_interest_rec.last_update_login;
    l_interest_rec.status_code := p_interest_rec.status_code;
    l_interest_rec.status := p_interest_rec.status;
    l_interest_rec.attribute_category     :=   p_interest_rec.attribute_category ;
    l_interest_rec.attribute1         :=   p_interest_rec.attribute1  ;
    l_interest_rec.attribute2             :=   p_interest_rec.attribute2  ;
    l_interest_rec.attribute3             :=   p_interest_rec.attribute3  ;
    l_interest_rec.attribute4             :=   p_interest_rec.attribute4  ;
    l_interest_rec.attribute5             :=   p_interest_rec.attribute5  ;
    l_interest_rec.attribute6             :=   p_interest_rec.attribute6  ;
    l_interest_rec.attribute7             :=   p_interest_rec.attribute7  ;
    l_interest_rec.attribute8             :=   p_interest_rec.attribute8  ;
    l_interest_rec.attribute9             :=   p_interest_rec.attribute9  ;
    l_interest_rec.attribute10            :=   p_interest_rec.attribute10 ;
    l_interest_rec.attribute11            :=   p_interest_rec.attribute11 ;
    l_interest_rec.attribute12            :=   p_interest_rec.attribute12 ;
    l_interest_rec.attribute13            :=   p_interest_rec.attribute13 ;
    l_interest_rec.attribute14            :=   p_interest_rec.attribute14 ;
    l_interest_rec.attribute15            :=   p_interest_rec.attribute15 ;

    AS_INTEREST_PVT.Update_Interest ( p_api_version_number    => 2.0,
                                      p_init_msg_list         => FND_API.G_FALSE,
                                      p_commit                => FND_API.G_FALSE,
                                      p_validation_level      => p_validation_level,
                      p_identity_salesforce_id=> p_identity_salesforce_id,
                                      p_interest_rec          => l_interest_rec,
                                      p_interest_use_code     => p_interest_use_code,
                                 p_check_access_flag     => p_check_access_flag,
                                 p_admin_flag            => p_admin_flag,
                                 p_admin_group_id        => p_admin_group_id,
                               p_access_profile_rec    => p_access_profile_rec,
                                      x_return_status         => x_return_status,
                                      x_msg_count             => x_msg_count,
                                      x_msg_data              => x_msg_data,
                                      x_interest_id       => l_interest_id
    );

    x_interest_id := p_interest_rec.interest_id;
-- Success Message
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS) and
       x_return_status = FND_API.G_RET_STS_SUCCESS
    THEN
      FND_MESSAGE.Set_Name('AS', 'API_SUCCESS');
      FND_MESSAGE.Set_Token('ROW', 'AS_INTEREST', TRUE);
      FND_MSG_PUB.Add;
    END IF;

    l_address_id := p_interest_rec.address_id;
    l_lead_id := p_interest_rec.lead_id;
    IF l_lead_id = FND_API.G_MISS_NUM THEN
        l_lead_id := NULL;
    END IF;

    AS_RTTAP_ACCOUNT.PROCESS_RTTAP_ACCOUNT
                     (p_interest_rec.customer_id,x_return_status);

    -- Standard check of p_commit.
    IF FND_API.To_Boolean ( p_commit )
    THEN
      COMMIT WORK;
    END IF;

    -- Debug Message
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)
    THEN
      FND_MESSAGE.Set_Name('AS', 'Pub Interest API: End');
      FND_MSG_PUB.Add;
    END IF;

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get( p_count           =>      x_msg_count,
                               p_data            =>      x_msg_data
                              );

    EXCEPTION

     WHEN FND_API.G_EXC_ERROR THEN
        AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
           P_MODULE => l_module
          ,P_API_NAME => L_API_NAME
          ,P_PKG_NAME => G_PKG_NAME
          ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
          ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
          ,X_MSG_COUNT => X_MSG_COUNT
          ,X_MSG_DATA => X_MSG_DATA
          ,X_RETURN_STATUS => X_RETURN_STATUS);

     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
           P_MODULE => l_module
          ,P_API_NAME => L_API_NAME
          ,P_PKG_NAME => G_PKG_NAME
          ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
          ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
          ,X_MSG_COUNT => X_MSG_COUNT
          ,X_MSG_DATA => X_MSG_DATA
          ,X_RETURN_STATUS => X_RETURN_STATUS);

     WHEN OTHERS THEN
        AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
           P_MODULE => l_module
          ,P_API_NAME => L_API_NAME
          ,P_PKG_NAME => G_PKG_NAME
          ,P_EXCEPTION_LEVEL => AS_UTILITY_PVT.G_EXC_OTHERS
     ,P_SQLCODE => SQLCODE
           ,P_SQLERRM => SQLERRM
          ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
          ,X_MSG_COUNT => X_MSG_COUNT
          ,X_MSG_DATA => X_MSG_DATA
          ,X_RETURN_STATUS => X_RETURN_STATUS);

  END Update_Interest;


  -- Purpose
  --
  --   This procedure takes as input a public interest table which may contain
  --   both values and or ids.  The values are then converted into ids and a
  --   private interest table is returned for use in calling the Private
  --   Create_Interest API
  --
  -- Notes
  --
  --   IDs take precedence over values, if both are present for a field
  --   then the ID is used and a warning message is created
  --
  --   If one interest record fails, then we continue processing the rest of
  --   the interest records and return an error message for the failure.
  --   The failed record will not be returned in the pvt_interest_tbl since
  --   it would fail on insert into the database.
  --
  --
  PROCEDURE Convert_Values_To_Ids ( p_interest_tbl        IN  INTEREST_TBL_TYPE,
                                    p_pvt_interest_tbl    OUT NOCOPY AS_INTEREST_PVT.INTEREST_TBL_TYPE)
  IS
    l_interest_count  CONSTANT NUMBER         := p_interest_tbl.count;

    l_any_errors      BOOLEAN  := FALSE;
    l_any_row_errors  BOOLEAN  := FALSE;

    l_val             VARCHAR2(30);
    l_return_status   VARCHAR2(1)  := FND_API.G_RET_STS_SUCCESS;

    l_pvt_interest_rec   AS_INTEREST_PVT.INTEREST_REC_TYPE;

    Cursor C_Get_Int_Status (X_Int_Status VARCHAR2, X_Product_Category_Id NUMBER, X_Product_Cat_Set_Id NUMBER) IS
      SELECT  ais.interest_status_code
      FROM  as_interest_statuses ais, as_lookups lkp
      WHERE nls_upper(X_Int_Status) = nls_upper(lkp.meaning)
        and product_category_id = X_Product_Category_Id
        and product_cat_set_id = X_Product_Cat_Set_Id
        and ais.interest_status_code = lkp.lookup_code
        and lkp.lookup_type = 'INTEREST_STATUS';

  BEGIN

    -- Debug Message
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
      FND_MESSAGE.Set_Name('AS', 'Int ValuesToIds: Start');
      FND_MSG_PUB.Add;
    END IF;

    -- Loop through the interest table and convert values to ids
    --
    FOR l_curr_row in 1..l_interest_count
    LOOP

      ----------------- Start of Processing Interest Record  -----------------------
      BEGIN

        -- Progress Message
        --
 /*       IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS) THEN
          FND_MESSAGE.Set_Name ('AS', 'API_PROCESSING_ROW');
          FND_MESSAGE.Set_Token ('ROW', 'AS_INTEREST', TRUE);
          FND_MESSAGE.Set_Token ('RECORD_NUM', to_char(l_curr_row), FALSE);
          FND_MSG_PUB.Add;
        END IF;
*/

        -- For each value - id pair, if id exists use it, otherwise convert values to ids
        -- if necessary.
        -- This is done for: Interest Type, Primary Interest, Secondary Interest, Status
        --
        /*
        Commented by gbatra as assumption is that ids are always passed
        Convert_Interest_Values_To_Ids (
                    p_interest_type                 => p_interest_tbl(l_curr_row).interest_type,
                    p_interest_type_id              => p_interest_tbl(l_curr_row).interest_type_id,
                    p_primary_interest_code         => p_interest_tbl(l_curr_row).primary_interest_code,
                    p_primary_interest_code_id      => p_interest_tbl(l_curr_row).primary_interest_code_id,
                    p_secondary_interest_code       => p_interest_tbl(l_curr_row).secondary_interest_code,
                    p_secondary_interest_code_id    => p_interest_tbl(l_curr_row).secondary_interest_code_id,
            p_description           => p_interest_tbl(l_curr_row).description,
                    p_return_status                 => l_return_status,
                    p_out_interest_type_id          => p_pvt_interest_tbl(l_curr_row).interest_type_id,
                    p_out_primary_interest_code_id  => p_pvt_interest_tbl(l_curr_row).primary_interest_code_id,
                    p_out_second_interest_code_id   => p_pvt_interest_tbl(l_curr_row).secondary_interest_code_id,
            p_out_description           => p_pvt_interest_tbl(l_curr_row).description
                    );

        -- Process the return status from the procedure
        --
        IF ( l_return_status <> FND_API.G_RET_STS_SUCCESS )
        THEN
          l_any_row_errors := TRUE;
        END IF;
        */


        -- Convert Interest Status
        --
        IF (p_interest_tbl(l_curr_row).status_code is not NULL
            and p_interest_tbl(l_curr_row).status_code <> FND_API.G_MISS_CHAR)
        THEN

          p_pvt_interest_tbl(l_curr_row).status_code :=
          p_interest_tbl(l_curr_row).status_code;

          IF (p_interest_tbl(l_curr_row).status is not NULL
                and p_interest_tbl(l_curr_row).status <> FND_API.G_MISS_CHAR)
          THEN
            IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN
              FND_MESSAGE.Set_Name ('AS', 'API_ATTRIBUTE_IGNORED');
              FND_MESSAGE.Set_Token ('COLUMN', 'STATUS', FALSE);
              FND_MSG_PUB.Add;
            END IF;
          END IF;

        ELSIF (p_interest_tbl(l_curr_row).status is not NULL
                and p_interest_tbl(l_curr_row).status <> FND_API.G_MISS_CHAR)
        THEN
          OPEN C_Get_Int_Status (p_interest_tbl(l_curr_row).status,
          p_pvt_interest_tbl(l_curr_row).product_category_id,
          p_pvt_interest_tbl(l_curr_row).product_cat_set_id);
          FETCH C_Get_Int_Status INTO l_val;
          CLOSE C_Get_Int_Status;
          p_pvt_interest_tbl(l_curr_row).status_code := l_val;

          IF (l_val IS NULL)
          THEN
            IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
            THEN
              FND_MESSAGE.Set_Name ('AS', 'API_ATTRIBUTE_CONVERSION_ERROR');
              FND_MESSAGE.Set_Token ('COLUMN', 'STAUTS', FALSE);
              FND_MESSAGE.Set_Token('VALUE', p_interest_tbl(l_curr_row).status, FALSE);
              FND_MSG_PUB.Add;
            END IF;
            l_any_row_errors := TRUE;
          END IF;
        ELSE
          p_pvt_interest_tbl(l_curr_row).status_code := NULL;
        END IF;


        -- Now copy the rest of the interest record columns from the public record
        -- to the private record
       p_pvt_interest_tbl(l_curr_row).interest_id        := p_interest_tbl(l_curr_row).interest_id;
       p_pvt_interest_tbl(l_curr_row).interest_type_id   := p_interest_tbl(l_curr_row).interest_type_id;
       p_pvt_interest_tbl(l_curr_row).primary_interest_code_id   := p_interest_tbl(l_curr_row).primary_interest_code_id;
       p_pvt_interest_tbl(l_curr_row).secondary_interest_code_id := p_interest_tbl(l_curr_row).secondary_interest_code_id;
       p_pvt_interest_tbl(l_curr_row).description                := p_interest_tbl(l_curr_row).description;
       p_pvt_interest_tbl(l_curr_row).product_category_id        := p_interest_tbl(l_curr_row).product_category_id;
       p_pvt_interest_tbl(l_curr_row).product_cat_set_id         := p_interest_tbl(l_curr_row).product_cat_set_id;
        p_pvt_interest_tbl(l_curr_row).Attribute_Category := p_interest_tbl(l_curr_row).Attribute_Category;
        p_pvt_interest_tbl(l_curr_row).Attribute1         := p_interest_tbl(l_curr_row).Attribute1;
        p_pvt_interest_tbl(l_curr_row).Attribute2         := p_interest_tbl(l_curr_row).Attribute2;
        p_pvt_interest_tbl(l_curr_row).Attribute3         := p_interest_tbl(l_curr_row).Attribute3;
        p_pvt_interest_tbl(l_curr_row).Attribute4         := p_interest_tbl(l_curr_row).Attribute4;
        p_pvt_interest_tbl(l_curr_row).Attribute5         := p_interest_tbl(l_curr_row).Attribute5;
        p_pvt_interest_tbl(l_curr_row).Attribute6         := p_interest_tbl(l_curr_row).Attribute6;
        p_pvt_interest_tbl(l_curr_row).Attribute7         := p_interest_tbl(l_curr_row).Attribute7;
        p_pvt_interest_tbl(l_curr_row).Attribute8         := p_interest_tbl(l_curr_row).Attribute8;
        p_pvt_interest_tbl(l_curr_row).Attribute9         := p_interest_tbl(l_curr_row).Attribute9;
        p_pvt_interest_tbl(l_curr_row).Attribute10        := p_interest_tbl(l_curr_row).Attribute10;
        p_pvt_interest_tbl(l_curr_row).Attribute11        := p_interest_tbl(l_curr_row).Attribute11;
        p_pvt_interest_tbl(l_curr_row).Attribute12        := p_interest_tbl(l_curr_row).Attribute12;
        p_pvt_interest_tbl(l_curr_row).Attribute13        := p_interest_tbl(l_curr_row).Attribute13;
        p_pvt_interest_tbl(l_curr_row).Attribute14        := p_interest_tbl(l_curr_row).Attribute14;
        p_pvt_interest_tbl(l_curr_row).Attribute15        := p_interest_tbl(l_curr_row).Attribute15;


        -- If there was an error in processing the row, then raise an error
        --
        IF l_any_row_errors
        THEN
            raise FND_API.G_EXC_ERROR;
        END IF;

        EXCEPTION
          WHEN OTHERS THEN
            l_any_errors := TRUE;
            l_any_row_errors := FALSE;
            p_pvt_interest_tbl(l_curr_row) := l_pvt_interest_rec;

      END;
        ---------------- End of Processing Interest Record  -----------------------

    END LOOP;

    -- Debug Message
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)
    THEN
        FND_MESSAGE.Set_Name('AS', 'Int ValuesToIds: End');
        FND_MSG_PUB.Add;
    END IF;


    IF l_any_errors
    THEN
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
      THEN
        FND_MESSAGE.Set_Name('AS', 'API_ERRORS_IN_VALUES_TO_IDS');
        FND_MESSAGE.Set_Token('ROW', 'AS_INTEREST', TRUE);
        FND_MSG_PUB.Add;
      END IF;
    END IF;

  END Convert_Values_To_Ids;


  -- Purpose
  --  Procedure converts interest type, primary, and secondar values to ids
  --
  -- Notes
  --    This procedure is public so that it can be called by other API's.
  --    Currently this procedure is used by the Create_Opportunity API to
  --    convert the expected purchase values to ids and from the interest
  --    Convert value to Ids routine found above
  --
  PROCEDURE Convert_Interest_Values_To_Ids (p_interest_type                 IN  VARCHAR2,
                                            p_interest_type_id              IN  NUMBER,
                                            p_primary_interest_code         IN  VARCHAR2,
                                            p_primary_interest_code_id      IN  NUMBER,
                                            p_secondary_interest_code       IN  VARCHAR2,
                                            p_secondary_interest_code_id    IN  NUMBER,
                        p_description           IN  VARCHAR2,
                                            p_return_status                 OUT NOCOPY VARCHAR2,
                                            p_out_interest_type_id          OUT NOCOPY NUMBER,
                                            p_out_primary_interest_code_id  OUT NOCOPY NUMBER,
                                            p_out_second_interest_code_id   OUT NOCOPY NUMBER,
                        p_out_description           OUT NOCOPY VARCHAR2
                                            ) IS
    Cursor C_Get_Int_Type (X_Int_Type VARCHAR2) IS
      SELECT  interest_type_id
      FROM  as_interest_types_vl
      WHERE nls_upper(X_Int_Type) = nls_upper(interest_type)
      and (interest_type like nls_upper(substr(X_Int_Type, 1, 1) || '%') or
         interest_type like lower(substr(X_Int_Type, 1, 1) || '%'));

    Cursor C_Get_Int_Code (X_Int_Code VARCHAR2, X_Int_Type_Id NUMBER) IS
      SELECT  interest_code_id
      FROM  as_interest_codes_v
     WHERE nls_upper(X_Int_Code) = nls_upper(code)
      and   interest_type_id = X_Int_Type_Id;


    CURSOR interest_code_desc( p_interest_code_id number
                              ,p_interest_type_id number) IS
      SELECT description
      FROM as_interest_codes_v
      WHERE interest_code_id = p_interest_code_id
      and interest_type_id = p_interest_type_id;

    CURSOR interest_type_desc(p_interest_type_id number) IS
      SELECT description
      FROM as_interest_types_vl
      WHERE interest_type_id = p_interest_type_id;

    l_description varchar2(255);
    l_interest_type_id  NUMBER;
    l_interest_code_id  NUMBER;
    l_secondary_interest_code_id  NUMBER;
  BEGIN

    p_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Initialize Out Variables
    p_out_interest_type_id    := NULL;
    p_out_primary_interest_code_id  := NULL;
    p_out_second_interest_code_id := NULL;
    p_out_description := NULL;

    -- Convert Interest Type
    --
    IF (p_interest_type_id is not NULL and
        p_interest_type_id <> FND_API.G_MISS_NUM)
    THEN
      p_out_interest_type_id := p_interest_type_id;
      l_interest_type_id := p_interest_type_id;

      IF (p_interest_type is not NULL and
          p_interest_type <> FND_API.G_MISS_CHAR)
      THEN
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN
          FND_MESSAGE.Set_Name ('AS', 'API_ATTRIBUTE_IGNORED');
          FND_MESSAGE.Set_Token ('COLUMN', 'INTEREST_TYPE', FALSE);
          FND_MSG_PUB.Add;
        END IF;
      END IF;

    ELSIF (p_interest_type is not NULL and
          p_interest_type <> FND_API.G_MISS_CHAR)
    THEN
      OPEN C_Get_Int_Type ( p_interest_type );
      FETCH C_Get_Int_Type INTO l_interest_type_id;

      IF (C_Get_Int_Type%NOTFOUND) THEN
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
          FND_MESSAGE.Set_Name ('AS', 'API_ATTRIBUTE_CONVERSION_ERROR');
          FND_MESSAGE.Set_Token ('COLUMN', 'INTEREST_TYPE', FALSE);
          FND_MESSAGE.Set_Token('VALUE', p_interest_type, FALSE);
          FND_MSG_PUB.Add;
        END IF;

        -- This will raise an exception immediately, since all other processing
        -- is dependent upon interest_type existing
        --
        raise FND_API.G_EXC_ERROR;

      ELSE
        p_out_interest_type_id := l_interest_type_id;
      END IF;

      CLOSE C_Get_Int_Type;
    ELSE
      -- If no interest type (value or id) exists, then this row is invalid
      --
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
      THEN
        FND_MESSAGE.Set_Name ('AS','API_MISSING_ID');
        FND_MESSAGE.Set_Token ('COLUMN', 'INTEREST_TYPE', FALSE);
        FND_MSG_PUB.Add;
      END IF;

      -- This will raise an exception immediately, since all other processing
      -- is dependent upon interest_type existing
      --
      raise FND_API.G_EXC_ERROR;
    END IF;


    -- Convert Primary Code
    --
    IF (p_primary_interest_code_id is not NULL and
        p_primary_interest_code_id <> FND_API.G_MISS_NUM)
    THEN
      p_out_primary_interest_code_id := p_primary_interest_code_id;
      l_interest_code_id := p_primary_interest_code_id;

      IF (p_primary_interest_code is not NULL and
          p_primary_interest_code <> FND_API.G_MISS_CHAR)
      THEN
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN
          FND_MESSAGE.Set_Name ('AS','API_ATTRIBUTE_IGNORED');
          FND_MESSAGE.Set_Token ('COLUMN', 'PRIMARY_INTEREST_CODE', FALSE);
          FND_MSG_PUB.Add;
        END IF;
      END IF;

    ELSIF (p_primary_interest_code is not NULL and
           p_primary_interest_code <> FND_API.G_MISS_CHAR)
    THEN
      OPEN C_Get_Int_Code ( p_primary_interest_code, l_interest_type_id );
      FETCH C_Get_Int_Code INTO l_interest_code_id;
      IF (C_Get_Int_Code%NOTFOUND) THEN
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          FND_MESSAGE.Set_Name ('AS', 'API_ATTRIBUTE_CONVERSION_ERROR');
          FND_MESSAGE.Set_Token ('COLUMN', 'PRIMARY_INTEREST_CODE', FALSE);
          FND_MESSAGE.Set_Token('VALUE', p_primary_interest_code, FALSE);
          FND_MSG_PUB.Add;
        END IF;

        p_return_status := FND_API.G_RET_STS_ERROR;

      ELSE
        p_out_primary_interest_code_id := l_interest_code_id;
      END IF;
      CLOSE C_Get_Int_Code;
    END IF;


    -- Convert Secondary Code
    --
    IF (p_secondary_interest_code_id is not NULL and
        p_secondary_interest_code_id <> FND_API.G_MISS_NUM)
    THEN
      p_out_second_interest_code_id := p_secondary_interest_code_id;
      l_secondary_interest_code_id := p_secondary_interest_code_id;

      IF (p_secondary_interest_code is not NULL and
          p_secondary_interest_code <> FND_API.G_MISS_CHAR)
      THEN
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN
          FND_MESSAGE.Set_Name ('AS', 'API_ATTRIBUTE_IGNORED');
          FND_MESSAGE.Set_Token ('COLUMN', 'SECONDARY_INTEREST_CODE', FALSE);
          FND_MSG_PUB.Add;
        END IF;
      END IF;

    ELSIF (p_secondary_interest_code is not NULL and
           p_secondary_interest_code <> FND_API.G_MISS_CHAR)
    THEN
      OPEN C_Get_Int_Code ( p_secondary_interest_code, l_interest_type_id );
      FETCH C_Get_Int_Code INTO l_secondary_interest_code_id;
     IF(C_Get_Int_Code%NOTFOUND) THEN
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          FND_MESSAGE.Set_Name ('AS', 'API_ATTRIBUTE_CONVERSION_ERROR');
          FND_MESSAGE.Set_Token ('COLUMN', 'SECONDARY_INTEREST_CODE', FALSE);
          FND_MESSAGE.Set_Token('VALUE', p_secondary_interest_code, FALSE);
          FND_MSG_PUB.Add;
        END IF;
        p_return_status := FND_API.G_RET_STS_ERROR;

      ELSE
        p_out_second_interest_code_id := l_secondary_interest_code_id;

      END IF;
      CLOSE C_Get_Int_Code;
    END IF;

    -- Calculate description field.
    -- If not null use description, otherwise
    -- If not null use secondary description, otherwise
    -- If not null use primary description, otherwise
    -- If not null use interest type description, otherwise
    --
    IF (p_Description is null and
        p_Description = FND_API.G_MISS_CHAR)
    THEN
        IF l_Secondary_Interest_Code_Id is not null
    THEN
            open interest_code_desc(l_Secondary_Interest_Code_Id
                                   ,l_Interest_Type_Id);
            fetch interest_code_desc into p_out_description;

            IF interest_code_desc%NOTFOUND THEN
              IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
              THEN
                FND_MESSAGE.Set_Name('AS', 'API_INVALID_ID');
                FND_MESSAGE.Set_Token('COLUMN', 'SECONDARY_INTEREST_CODE_ID,INTEREST_TYPE_ID', FALSE);
                FND_MESSAGE.Set_Token('VALUE', to_char(l_Secondary_Interest_Code_Id)
                                   || ',' || to_char(l_Interest_Type_Id), FALSE);
                FND_MSG_PUB.ADD;
              END IF;
              close interest_code_desc;
              RAISE FND_API.G_EXC_ERROR;

            ELSE
              close interest_code_desc;
            END IF;

          ELSIF l_Interest_Code_Id is not null then
            open interest_code_desc(l_Interest_Code_Id
                                   ,l_Interest_Type_Id);
            fetch interest_code_desc into p_out_description;

            IF interest_code_desc%NOTFOUND THEN
              IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
              THEN
                FND_MESSAGE.Set_Name('AS', 'API_INVALID_ID');
                FND_MESSAGE.Set_Token('COLUMN', 'PRIMARY_INTEREST_CODE_ID,INTEREST_TYPE_ID', FALSE);
                FND_MESSAGE.Set_Token('VALUE', to_char(l_Interest_Code_Id)
                                   || ',' || to_char(l_Interest_Type_Id), FALSE);
                FND_MSG_PUB.ADD;
              END IF;

              close interest_code_desc;
              RAISE FND_API.G_EXC_ERROR;

            ELSE
              close interest_code_desc;
            END IF;

          ELSE
            open interest_type_desc(l_Interest_Type_Id);
            fetch interest_type_desc into p_out_description;

            IF interest_type_desc%NOTFOUND THEN
              IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
              THEN
                FND_MESSAGE.Set_Name('AS', 'API_INVALID_ID');
                FND_MESSAGE.Set_Token('COLUMN', 'INTEREST_TYPE_ID', FALSE);
                FND_MESSAGE.Set_Token('VALUE', l_Interest_Type_Id, FALSE);
                FND_MSG_PUB.ADD;
              END IF;
              close interest_type_desc;
              RAISE FND_API.G_EXC_ERROR;
            ELSE
              close interest_type_desc;
            END IF;
          END IF;

        ELSE
          p_out_description := p_Description;
        END IF;


  END Convert_Interest_Values_To_Ids;

PROCEDURE Delete_Interest
(   p_api_version_number    IN  NUMBER,
    p_init_msg_list     IN  VARCHAR2    := FND_API.G_FALSE,
    p_commit            IN      VARCHAR2    := FND_API.G_FALSE,
    p_validation_level  IN  NUMBER      :=FND_API.G_VALID_LEVEL_FULL,
        p_identity_salesforce_id  IN    NUMBER,
    p_interest_rec      IN  INTEREST_REC_TYPE := G_MISS_INTEREST_REC,
    p_interest_use_code IN  VARCHAR2,
     p_check_access_flag   in  varchar2,
     p_admin_flag          in  varchar2,
     p_admin_group_id      in  number,
     p_access_profile_rec  IN  AS_ACCESS_PUB.ACCESS_PROFILE_REC_TYPE,
    x_return_status     OUT NOCOPY  VARCHAR2,
    x_msg_count     OUT NOCOPY  NUMBER,
    x_msg_data      OUT NOCOPY  VARCHAR2
) is
 l_api_name            CONSTANT VARCHAR2(30) := 'Delete_Interest';
 l_api_version_number  CONSTANT NUMBER       := 2.0;
 l_interest_rec  AS_INTEREST_PVT.Interest_Rec_Type;
 l_debug BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
 l_module CONSTANT VARCHAR2(255) := 'as.plsql.intpb.Delete_Interest';
begin
    SAVEPOINT DELETE_INTEREST_PUB;
     -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                           p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Debug Message
      IF l_debug THEN
      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'Public API: ' || l_api_name || 'start');

      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                           'Start time: ' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- API body
      --
      IF l_debug THEN
      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                   'Public API: Calling AS_ACCESS_PVT.delete_interest');
      END IF;

    l_interest_rec.interest_id := p_interest_rec.interest_id;
    l_interest_rec.customer_id := p_interest_rec.customer_id;
    l_interest_rec.address_id := p_interest_rec.address_id;
    l_interest_rec.lead_id := p_interest_rec.lead_id;

    as_interest_pvt.Delete_Interest ( p_api_version_number    => 2.0,
                                      p_init_msg_list         => FND_API.G_FALSE,
                                      p_commit                => FND_API.G_FALSE,
                                      p_validation_level      => p_validation_level,
                      p_identity_salesforce_id=> p_identity_salesforce_id,
                                      p_interest_rec          => l_interest_rec,
                                      p_interest_use_code     => p_interest_use_code,
                                 p_check_access_flag     => p_check_access_flag,
                                 p_admin_flag            => p_admin_flag,
                                 p_admin_group_id        => p_admin_group_id,
                               p_access_profile_rec    => p_access_profile_rec,
                                      x_return_status         => x_return_status,
                                      x_msg_count             => x_msg_count,
                                      x_msg_data              => x_msg_data
                        );


     IF x_return_status = FND_API.G_RET_STS_ERROR then
                raise FND_API.G_EXC_ERROR;
      elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
               raise FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;


      --
      -- End of API body.
      --

      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;


      -- Debug Message
      IF l_debug THEN
      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'Public API: ' || l_api_name || 'end');

      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'End time:'
                                   || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));
      END IF;


      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

      EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_MODULE => l_module
                  ,P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_MODULE => l_module
                  ,P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN OTHERS THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_MODULE => l_module
                  ,P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => AS_UTILITY_PVT.G_EXC_OTHERS
         ,P_SQLCODE => SQLCODE
           ,P_SQLERRM => SQLERRM
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

End delete_interest;



END AS_INTEREST_PUB;

/
