--------------------------------------------------------
--  DDL for Package Body AS_SALES_MEMBER_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AS_SALES_MEMBER_PUB" as
/* $Header: asxpsmbb.pls 120.2 2005/06/14 01:31:52 appldev  $ */

--
-- NAME
--   AS_SALES_MEMBER_PUB
--
-- HISTORY
--   6/19/98        ALHUNG        CREATED
--
--

G_PKG_NAME      CONSTANT VARCHAR2(30):='AS_SALES_MEMBER_PUB';
G_FILE_NAME     CONSTANT VARCHAR2(12):='asxpsmbb.pls';


/***************************  PUBLIC ROUTINES  *********************************/
  --
  -- NAME
  --   Convert_Partner_to_ID
  --
  -- PURPOSE
  --
  --
  -- NOTES
  --
  --
  -- HISTORY
  --
  --
  PROCEDURE Convert_Partner_to_ID
(    p_api_version_number   IN     NUMBER
    ,p_init_msg_list        IN     VARCHAR2
            := FND_API.G_FALSE
    ,p_partner_customer_id  IN     Number
    ,p_partner_address_id   IN     Number
    ,x_return_status        OUT NOCOPY /* file.sql.39 change */    Varchar2
    ,x_msg_count            OUT NOCOPY /* file.sql.39 change */    NUMBER
    ,x_msg_data             OUT NOCOPY /* file.sql.39 change */    VARCHAR2
    ,x_sales_member_rec     OUT NOCOPY /* file.sql.39 change */    Sales_Member_Rec_Type) IS

    Cursor Get_Ptr_Salesforce_id(p_partner_customer_id IN Number,
                                 p_partner_address_id IN Number ) IS
        Select  force.salesforce_id
               ,force.type
               ,force.start_date_active
               ,force.end_date_active
               ,force.Employee_Person_id
               --,force.Sales_Group_id
               ,force.Partner_address_id
               ,force.Partner_customer_id
               --,force.Partner_contact_id
        from AS_SALESFORCE_V force
        where partner_customer_id = p_partner_customer_id AND
              partner_address_id = p_partner_address_id;

    l_api_name            CONSTANT VARCHAR2(30) := 'Convert_Partner_to_ID';
    l_api_version_number  CONSTANT NUMBER   := 2.0;
    l_module CONSTANT VARCHAR2(255) := 'as.plsql.smbp.Convert_Partner_to_ID';

    Begin

        -- Standard call to check for call compatibility.
        IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                   p_api_version_number,
                                   l_api_name,
                                   G_PKG_NAME)
        THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;


      -- Initialize message list if p_init_msg_list is set to TRUE.
        IF FND_API.to_Boolean( p_init_msg_list ) THEN
          FND_MSG_PUB.initialize;
        END IF;

        -- Debug Message
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
		  AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,'AS_SALES_MEMBER_PUB.Convert_Partner_To_Id Begin');
        END IF;

        Open Get_Ptr_Salesforce_id(p_partner_customer_id, p_partner_address_id);
        IF (Get_Ptr_Salesforce_id%ROWCOUNT > 1) Then

            IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS) THEN
                       AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,'AS_SALES_MEMBER_PUB - Found duplicated partner');
            END IF;
        End if;

        Fetch Get_Ptr_Salesforce_id INTO  x_sales_member_rec.salesforce_id
                                         ,x_sales_member_rec.type
                                         ,x_sales_member_rec.start_date_active
                                         ,x_sales_member_rec.end_date_active
                                         ,x_sales_member_rec.employee_person_id
                                         --,x_sales_member_rec.sales_group_id
                                         ,x_sales_member_rec.partner_address_id
                                         ,x_sales_member_rec.partner_customer_id;
                                         --,x_sales_member_rec.partner_contact_id ;
        Close Get_Ptr_Salesforce_id;

        x_return_status := FND_API.G_RET_STS_SUCCESS;


        -- Standard call to get message count and if count is 1, get message info.
        FND_MSG_PUB.Count_And_Get
          ( p_count           =>      x_msg_count,
            p_data            =>      x_msg_data   );

        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
             AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,'AS_SALES_MEMBER_PUB.Convert_Partner_To_Id End');
        END IF;


    EXCEPTION

        WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS) THEN
             AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,'AS_SALES_MEMBER_PUB - Cannot Find Sales Partner');
        END IF;

        x_return_status := FND_API.G_RET_STS_ERROR ;
        x_sales_member_rec := G_MISS_SALES_MEMBER_REC;

        WHEN FND_API.G_EXC_ERROR THEN

          x_return_status := FND_API.G_RET_STS_ERROR ;

          FND_MSG_PUB.Count_And_Get
              ( p_count           =>      x_msg_count,
                p_data            =>      x_msg_data
              );


        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

          FND_MSG_PUB.Count_And_Get
              ( p_count           =>      x_msg_count,
                p_data            =>      x_msg_data
              );


        WHEN OTHERS THEN


          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

          IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
          THEN
              FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
          END IF;

          FND_MSG_PUB.Count_And_Get
              ( p_count         =>      x_msg_count,
                p_data            =>      x_msg_data
              );

    End Convert_Partner_to_ID;

  --
  -- NAME
  --   Convert_SFID_to_Values
  --
  -- PURPOSE
  --
  --
  -- NOTES
  --
  --
  -- HISTORY
  --
  --
  PROCEDURE Convert_SFID_to_Values
(   p_api_version_number                   IN     NUMBER,
    p_init_msg_list                        IN     VARCHAR2
                                := FND_API.G_FALSE,
    p_salesforce_id                        IN     NUMBER,

    x_return_status                        OUT NOCOPY /* file.sql.39 change */    VARCHAR2,
    x_msg_count                            OUT NOCOPY /* file.sql.39 change */    NUMBER,
    x_msg_data                             OUT NOCOPY /* file.sql.39 change */    VARCHAR2,
    x_sales_member_rec                     OUT NOCOPY /* file.sql.39 change */    Sales_Member_Rec_Type ) IS


    Cursor C_GetSalesMember(p_salesforce_id Number) IS
        Select salesforce_id, type, start_date_active, end_date_active, employee_person_id,
              -- sales_group_id,
			partner_customer_id, partner_address_id
               --partner_contact_id
        From   AS_SALESFORCE_V
        Where  salesforce_id = p_salesforce_id;

    Cursor C_GetPersonInfo(p_person_id Number) IS
        Select last_name, first_name, full_name, email_address
        From per_people_f
        Where person_id = p_person_id;

    l_api_name    CONSTANT VARCHAR2(30) := 'Convert_SFID_to_Values';
    l_api_version_number  CONSTANT NUMBER   := 2.0;
    l_module CONSTANT VARCHAR2(255) := 'as.plsql.smbp.Convert_SFID_to_Values';

  BEGIN

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                   p_api_version_number,
                                   l_api_name,
                                   G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;


      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list ) THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Debug Message
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)
      THEN
          AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'AS_SALES_MEMBER_PUB.Convert_SFID_to_Values - BEGIN');
      END IF;

      --  Initialize API return status to success
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- API body
      --


      -- ******************************************************************
      -- Validate Environment
      -- ******************************************************************

      -- This simple conversion rountine does not check environment



      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)
      THEN
           AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'AS_SALES_MEMBER_PUB - Searching Sales Member');
      END IF;



      -- Invoke cursor to find sales member with salesforce_id
      Begin
          Open C_GetSalesMember(p_salesforce_id);
          Fetch C_GetSalesMember into
              x_sales_member_rec.salesforce_id,
              x_sales_member_rec.type,
              x_sales_member_rec.start_date_active,
              x_sales_member_rec.end_date_active,
              x_sales_member_rec.employee_person_id,
              --x_sales_member_rec.sales_group_id,
              x_sales_member_rec.partner_customer_id,
              x_sales_member_rec.partner_address_id;
              --x_sales_member_rec.partner_contact_id;
          Close C_GetSalesMember;


      -- If salesmember is a person, lookup person info.
          If (x_sales_member_rec.type = 'EMPLOYEE') Then
              IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
                AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,'AS_SALES_MEMBER_PUB - Searching Sales Person Info');
              END IF;

              Open C_GetPersonInfo(x_sales_member_rec.employee_person_id);
              Fetch C_GetPersonInfo into
                  x_sales_member_rec.last_name,
                  x_sales_member_rec.first_name,
                  x_sales_member_rec.full_name,
                  x_sales_member_rec.email_address;
              Close C_GetPersonInfo;

      -- Else if salesmember is a sales partner, call Accounts API's for info
          Elsif (x_sales_member_rec.type = 'PARTNER') Then
              IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
                AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,'AS_SALES_MEMBER_PUB - Searching Sales Partner Info');
              END IF;
              -- CODE TO BE INSERTED
              -- Need to invoke Accounts API here for the info
          End if;


      EXCEPTION

          WHEN NO_DATA_FOUND THEN

          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
             AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'AS_SALES_MEMBER_PUB Cannot find Salesmember Info');
          END IF;

          x_return_status := FND_API.G_RET_STS_ERROR ;

          FND_MSG_PUB.Count_And_Get
              ( p_count           =>      x_msg_count,
                p_data            =>      x_msg_data
              );
            return;

      End;

      -- End of API body.
      --

      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- Success Message
      -- MMSG
      /*
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS)
      THEN
          FND_MESSAGE.Set_Name('AS', 'API_SUCCESS');
          FND_MESSAGE.Set_Token('ROW', 'AS_OPPORTUNITY', TRUE);
          FND_MSG_PUB.Add;
      END IF;
         */

      -- Debug Message
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)
      THEN
          AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,'AS_SALES_MEMBER_PUB.Convert_SFID_to_Values End');
          --FND_MESSAGE.Set_Name('AS_SALES_MEMBER_PUB.Convert_SFID_to_Values End');
          --FND_MSG_PUB.Add;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      ( p_count           =>      x_msg_count,
          p_data          =>      x_msg_data
      );


  EXCEPTION

      WHEN FND_API.G_EXC_ERROR THEN

          x_return_status := FND_API.G_RET_STS_ERROR ;

          FND_MSG_PUB.Count_And_Get
              ( p_count           =>      x_msg_count,
                p_data            =>      x_msg_data
              );


      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

          FND_MSG_PUB.Count_And_Get
              ( p_count           =>      x_msg_count,
                p_data            =>      x_msg_data
              );


      WHEN OTHERS THEN


          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

          IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
          THEN
              FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
          END IF;

          FND_MSG_PUB.Count_And_Get
              ( p_count         =>      x_msg_count,
                p_data            =>      x_msg_data
              );

  END Convert_SFID_to_Values;


END AS_SALES_MEMBER_PUB;

/
