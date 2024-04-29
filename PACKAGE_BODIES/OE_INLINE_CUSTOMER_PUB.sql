--------------------------------------------------------
--  DDL for Package Body OE_INLINE_CUSTOMER_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_INLINE_CUSTOMER_PUB" AS
/* $Header: OEXPINLB.pls 120.7.12010000.2 2008/11/14 11:57:23 ckasera ship $ */

-- { Start of Global Variable used in Api

G_INITIALIZED               VARCHAR2(1)  := FND_API.G_FALSE;
G_EMAIL_REQUIRED            VARCHAR2(1)  := 'N';
G_AUTO_PARTY_NUMBERING      VARCHAR2(1)  := 'N';
G_AUTO_CUST_NUMBERING       VARCHAR2(1)  := 'N';
G_AUTO_CONTACT_NUMBERING    VARCHAR2(1)  := 'N';
G_AUTO_LOCATION_NUMBERING   VARCHAR2(1)  := 'N';
G_AUTO_SITE_NUMBERING       VARCHAR2(1)  := 'N';

G_CREATED_BY_MODULE           CONSTANT VARCHAR2(30) := 'ONT_OI_ADD_CUSTOMER';
-- End of Global Variable used in Api}

-- { Start of procedure Initialize_Global
PROCEDURE Initialize_Global( x_return_status OUT NOCOPY /* file.sql.39 change */ Varchar2)
IS
   l_sysparm_rec            ar_system_parameters%rowtype;
   l_sys_parm_rec           ar_system_parameters_all%rowtype;
   --
   l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
   --
Begin

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'ENTERING PROCEDURE INITIALIZE_GLOBAL' ) ;
   END IF;
   x_return_status            := FND_API.G_RET_STS_SUCCESS;

   -- { Start of the ar_system_parameters select and assignment

   IF oe_code_control.code_release_level < '110510' THEN
      Select  *
      Into    l_sysparm_rec
      From    ar_system_parameters;
   ELSE
      l_Sys_Parm_Rec := OE_Sys_Parameters_Pvt.Get_AR_Sys_Params;
   END IF;


    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'AFTER SELECT FROM AR_SYSTEM_PARAMETES' ) ;
    END IF;

   IF oe_code_control.code_release_level < '110510' THEN
      G_AUTO_CUST_NUMBERING     := nvl(l_sysparm_rec.generate_customer_number,'Y');
      G_AUTO_LOCATION_NUMBERING := nvl(l_sysparm_rec.auto_site_numbering,'Y');
   ELSE
      G_AUTO_CUST_NUMBERING     := nvl(l_sys_parm_rec.generate_customer_number,'Y');
      G_AUTO_LOCATION_NUMBERING := nvl(l_sys_parm_rec.auto_site_numbering,'Y');
   END IF;

   -- End of the ar_system_parameters select and assignment}

   -- { Start for global values from profile
   fnd_profile.get('ONT_MANDATE_CUSTOMER_EMAIL',G_EMAIL_REQUIRED);
   fnd_profile.get('HZ_GENERATE_PARTY_NUMBER',G_AUTO_PARTY_NUMBERING);
   fnd_profile.get('HZ_GENERATE_CONTACT_NUMBER',G_AUTO_CONTACT_NUMBERING);
   fnd_profile.get('HZ_GENERATE_PARTY_SITE_NUMBER',G_AUTO_SITE_NUMBERING);

   G_EMAIL_REQUIRED          :=  nvl(G_EMAIL_REQUIRED,'Y');
   G_AUTO_PARTY_NUMBERING    :=  nvl(G_AUTO_PARTY_NUMBERING,'Y');
   G_AUTO_CONTACT_NUMBERING  :=  nvl(G_AUTO_CONTACT_NUMBERING,'Y');
   G_AUTO_SITE_NUMBERING     :=  nvl(G_AUTO_SITE_NUMBERING, 'Y');

   -- End for global values from profile }
   G_INITIALIZED              := FND_API.G_TRUE;
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'EXITING PROCEDURE INITIALIZE_GLOBAL' ) ;
   END IF;
Exception
   When Others Then
     x_return_status            := FND_API.G_RET_STS_UNEXP_ERROR;
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'PROBLEM IN CALL TO INITIALIZE_GLOBAL. ABORT PROCESSING' ) ;
     END IF;
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'UNEXPECTED ERROR: '||SQLERRM ) ;
     END IF;
     fnd_message.set_name('ONT','ONT_OI_INL_API_FAILED');
     fnd_message.set_token('API_NAME', 'Initialize_Global');
     oe_msg_pub.add;
     OE_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,'Unexpected error occured: ' || sqlerrm);
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'EXITING PROCEDURE INITIALIZE_GLOBAL' ) ;
     END IF;
End Initialize_Global;
-- End of procedure Initialize_Global}

-- { Start of procedure Validate Party Number
--   This will be to validate if the party_number passed
--   is already used or not. If used that that is an error
--   report it.
PROCEDURE Validate_Party_Number( p_party_number      IN  Varchar2,
                                 p_party_type        IN  Varchar2,
                                 x_party_id          OUT NOCOPY /* file.sql.39 change */ Number,
                                 x_party_name        OUT NOCOPY /* file.sql.39 change */ Varchar2,
                                 x_return_status     OUT NOCOPY /* file.sql.39 change */ Varchar2)
IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
Begin

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ENTERNING VALIDATE PARTY NUMBER API' ) ;
    END IF;
    Select party_id,
           party_name
    Into   x_party_id,
           x_party_name
    From   hz_parties
    Where  party_number   =  p_party_number
    And    party_type     =  p_party_type;

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'AFTER SELECT OF PARTY INFO.' ) ;
    END IF;
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'EXITING VALIDATE PARTY NUMBER API WITH PARTY ID' ) ;
    END IF;
Exception
    When No_Data_Found Then
     x_return_status := FND_API.G_RET_STS_SUCCESS;
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'EXITING VALIDATE PARTY NUMBER API WITHOUT PARTY ID' ) ;
     END IF;
    When Others Then
     x_return_status            := FND_API.G_RET_STS_UNEXP_ERROR;
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'PROBLEM IN CALL TO VALIDATE PARTY. ABORT PROCESSING' ) ;
     END IF;
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'UNEXPECTED ERROR: '||SQLERRM ) ;
     END IF;
     fnd_message.set_name('ONT','ONT_OI_INL_API_FAILED');
     fnd_message.set_token('API_NAME', 'Validate_Party_Number');
     oe_msg_pub.add;
     OE_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,'Unexpected error occured: ' || sqlerrm);
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'EXITING VALIDATE PARTY NUMBER API WITHOUT PARTY ID' ) ;
     END IF;
End Validate_Party_Number;
-- End of procedure Validate_Party_Number}

-- { Start of update Error Flag for the error Record
PROCEDURE Update_Error_Flag(
                           p_rowid          IN     Rowid)
IS
  PRAGMA AUTONOMOUS_TRANSACTION;

  --
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
  --

BEGIN

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'ENTERING PROCEDURE UPDATE_ERROR_FLAG' ) ;
   END IF;

   Update Oe_Customer_Info_Iface_All
   Set    Error_Flag  = 'Y'
   Where  rowid       = p_rowid;
   Commit;

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'EXITING PROCEDURE UPDATE_ERROR_FLAG' ) ;
   END IF;
Exception

    when others then
        IF l_debug_level > 0 THEN
                OE_DEBUG_PUB.add ('Update Error Flag: Unexpected Error : '||sqlerrm);
        END IF;

END Update_Error_Flag;
-- End of Update Error Flag }


PROCEDURE Update_Address_id(type_of_address IN VARCHAR2,
                            usage_site_id   IN  NUMBER,
                            row_id IN rowid  )
IS
    Pragma AUTONOMOUS_TRANSACTION;
    l_address_id_ship      NUMBER;
    l_address_id_bill      NUMBER;
    l_address_id_deliver   NUMBER;
    l_dummy                VARCHAR2(2);

  --
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
  --

BEGIN
     IF l_debug_level > 0 THEN

         oe_debug_pub.add (' Entering  Update_Address_id');
         oe_debug_pub.add (' locking table for: '||type_of_address);
         oe_debug_pub.add (' p_usage_site_id :'|| usage_site_id);
         oe_debug_pub.add (' Row Id :'||row_id );

     END IF;

    SELECT new_address_id_ship,new_address_id_bill,new_address_id_Deliver
      into l_address_id_ship, l_address_id_bill, l_address_id_deliver
    FROM   oe_customer_info_iface_all
    WHERE  rowid = row_id
    FOR UPDATE NOWAIT;

  If  type_of_address = 'SHIP_TO'  AND
      l_address_id_ship is NULL Then

    UPDATE oe_customer_info_iface_all
    SET    new_address_id_ship =  usage_site_id
    WHERE  rowid = row_id;

  Elsif  type_of_address = 'BILL_TO' AND
         l_address_id_bill is NULL  Then

    UPDATE oe_customer_info_iface_all
          SET new_address_id_bill =  usage_site_id
    WHERE rowid = row_id;

  Elsif type_of_address = 'DELIVER_TO' AND
        l_address_id_deliver is NULL Then
    UPDATE oe_customer_info_iface_all
         SET new_address_id_Deliver =  usage_site_id
    WHERE rowid = row_id;
 End if;
 Commit;

    IF l_debug_level > 0 THEN
        oe_debug_pub.add (' Type of Address : '|| type_of_address);
        oe_debug_pub.add ('Update_Address_id: ' || usage_site_id);
    END IF;

EXCEPTION
    when no_data_found then
        null;

    when others then
        IF l_debug_level > 0 THEN
                OE_DEBUG_PUB.add ('Update_address_id: Unexpected Error : '||sqlerrm);
        END IF;

END Update_Address_Id;

-- { Start of Create Cust Relationship
-- This api will be called from Order Import Specific api for
-- creating the relationship between the sold to customer and
-- other type(ship/deliver/invoice) customer is being created
-- thru the Add customer process
PROCEDURE Create_Cust_Relationship(
                           p_cust_acct_id          IN     Number,
                           p_related_cust_acct_id  IN     Number,
                           p_reciprocal_flag       IN     Varchar2 Default 'N',
                           p_org_id                IN     Number,
                           x_return_status            OUT NOCOPY /* file.sql.39 change */ Varchar2,
                           x_msg_count                OUT NOCOPY /* file.sql.39 change */ Number,
                           x_msg_data                 OUT NOCOPY /* file.sql.39 change */ Varchar2
                                          )
IS

l_cust_rel_rec   HZ_CUST_ACCOUNT_V2PUB.cust_acct_relate_rec_type;
l_return_status  Varchar2(1);
l_need_cust_rel  Varchar2(1);

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'ENTERING PROCEDURE CREATE_CUST_RELATIONSHIP' ) ;
   END IF;

   l_need_cust_rel := OE_Sys_Parameters.Value('CUSTOMER_RELATIONSHIPS_FLAG');

   If l_need_cust_rel In ('N', 'A') Then
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'NO NEED TO CREATE RELATIONSHIP' ) ;
      END IF;
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'EXITING PROCEDURE CREATE_CUST_RELATIONSHIP' ) ;
      END IF;
      Return;
   End If;
   l_cust_rel_rec.cust_account_id          := p_cust_acct_id;
   l_cust_rel_rec.related_cust_account_id  := p_related_cust_acct_id;
   l_cust_rel_rec.relationship_type        := 'ALL';
   l_cust_rel_rec.customer_reciprocal_flag := p_reciprocal_flag;
   l_cust_rel_rec.created_by_module := G_CREATED_BY_MODULE;
   l_cust_rel_rec.application_id := 660;
   l_cust_rel_rec.org_id         := p_org_id;

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'CUST_ACCOUNT_ID:'||P_CUST_ACCT_ID||':RELATED_CUST_ACCOUNT_ID:'||P_RELATED_CUST_ACCT_ID ) ;
   END IF;
   HZ_CUST_ACCOUNT_V2PUB.Create_Cust_Acct_Relate
                    (
                    p_cust_acct_relate_rec    =>  l_cust_rel_rec,
                    x_return_status           =>  l_return_status,
                    x_msg_count               =>  x_msg_count,
                    x_msg_data                =>  x_msg_data
                    );

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'RETURN STATS ' || L_RETURN_STATUS ) ;
   END IF;
   If l_return_status <> FND_API.G_RET_STS_SUCCESS Then
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'RETURN ERROR MESSAGE COUNT FROM HZ ' || OE_MSG_PUB.GET ( P_MSG_INDEX => X_MSG_COUNT ) ) ;
      END IF;
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'RETURN ERROR MESSAGE FROM ACC RELATE '|| X_MSG_DATA ) ;
      END IF;
      x_return_status  := l_return_status;
      oe_msg_pub.transfer_msg_stack;
      fnd_msg_pub.delete_msg;
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'EXITING PROCEDURE CREATE_CUST_RELATIONSHIP' ) ;
      END IF;
      return;
   Else
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'NEW CUSTOMER RELATIONSHIP IS CREATED' ) ;
      END IF;
   End if;

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'EXITING PROCEDURE CREATE_CUST_RELATIONSHIP' ) ;
   END IF;
EXCEPTION
  When Others Then
     x_return_status            := FND_API.G_RET_STS_UNEXP_ERROR;
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'PROBLEM IN CALL TO CREATE_CUST_RELATIONSHIP. ABORT PROCESSING' ) ;
         oe_debug_pub.add(  'UNEXPECTED ERROR: '||SQLERRM ) ;
     END IF;
     fnd_message.set_name('ONT','ONT_OI_INL_API_FAILED');
     fnd_message.set_token('API_NAME', 'Create_Cust_Relationship');
     oe_msg_pub.add;
     OE_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,'Unexpected error occured: ' || sqlerrm);
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'EXITING CREATE_CUST_RELATIONSHIP API WITH ERROR' ) ;
     END IF;
END create_cust_relationship;
-- End of Create Cust Relationship}

-- {Start of procedure Check and Create Contact
PROCEDURE Check_and_Create_Contact(p_contact_party_id IN     Number,
                                   p_cust_acct_id     IN     Number,
                                   p_usage_type       IN     Varchar2,
                                   x_contact_id          OUT NOCOPY /* file.sql.39 change */ Number,
                                   x_return_status       OUT NOCOPY /* file.sql.39 change */ Varchar2
                                  ) IS

    -- if role found at site level then we create an acct level role
    -- also
    Cursor c_cust_acct_role IS
        Select cust_account_role_id
          From hz_cust_account_roles
         Where party_id           = p_contact_party_id
           And cust_account_id    = p_cust_acct_id
           And role_type          = 'CONTACT'
           And status = 'A'
           And cust_acct_site_id is null;

    CURSOR c_usage_type(l_role_id in number) IS
        SELECT responsibility_type
          FROM hz_role_responsibility
         WHERE cust_account_role_id = l_role_id;
           --AND responsibility_type = in_usage_type;

    l_cust_account_role_id Number;
    l_select               Number;
    l_msg_count            Number;
    l_msg_data             Varchar2(4000);
    l_responsibility_id    Number;
    l_create_role          Varchar2(10) := 'UNKNOWN';
    l_role_resp_rec        HZ_CUST_ACCOUNT_ROLE_V2PUB.role_responsibility_rec_type;
    l_return_status        Varchar2(1);

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ENTERING CHECK AND CREATE CONTACT API' ) ;
    END IF;
    -- checking to see if there is cust_account_role for the party contact
    Open  c_cust_acct_role;
    Fetch c_cust_acct_role
     Into l_cust_account_role_id;

    -- {Start of the If of NOTFOUND
    If c_cust_acct_role%NOTFOUND then
        x_contact_id := null;
    Elsif c_cust_acct_role%FOUND then

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'A CUST ACCT ROLE USAGE TYPE = '|| P_USAGE_TYPE ) ;
        END IF;

        --if cust_acct_role is found  then we check the usage_type of this
        --role
        -- {Start of the loop for c_usage_type
        FOR c_record in c_usage_type(l_cust_account_role_id)
        LOOP
            IF l_debug_level  > 0 THEN
                oe_debug_pub.add(  'LOOP FOR ROLE TYPE' ) ;
            END IF;
            If c_record.responsibility_type = p_usage_type then
                IF l_debug_level  > 0 THEN
                    oe_debug_pub.add(  'ROLE TYPE FOUND' ) ;
                END IF;
                l_create_role := 'FOUND';
            Else
                IF l_debug_level  > 0 THEN
                    oe_debug_pub.add(  'ROLE TYPE NOT FOUND' ) ;
                END IF;
                if l_create_role <> 'FOUND' then
                    l_create_role := 'NOTFOUND';
                end if;

            End If;
        END LOOP;
        -- End of the loop for c_usage_type}

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'IF THE TYPE OF ROLE IS NOTFOUND THEN WE WILL' ) ;
        END IF;
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'CREATE NEW ROLE DEPENDING ON THE TYPE OF USAGE' ) ;
        END IF;
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'PASSED. ELSE IF IT IS REMAIN UNKNOWN OR FOUND' ) ;
        END IF;
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'IN THAT CASE RETURN THE EXISITING ID I.E.' ) ;
        END IF;
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'L_CUST_ACCOUNT_ROLE_ID =>' || L_CUST_ACCOUNT_ROLE_ID ) ;
        END IF;

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'L_CREATE_ROLE => '||L_CREATE_ROLE ) ;
        END IF;
        -- { Start of the l_create_role
        If l_create_role = 'NOTFOUND' then
            -- role usage type is only created if the user comes from the
            -- site levels.Its not created for account level contacts
            -- { Start of the usage If
            If p_usage_type in ('SHIP_TO','BILL_TO','DELIVER_TO') then
               l_role_resp_rec.cust_account_role_id := l_cust_account_role_id;
               l_role_resp_rec.responsibility_type  := p_usage_type;
               l_role_resp_rec.primary_flag         := 'Y';
               l_role_resp_rec.created_by_module    := G_CREATED_BY_MODULE;
               l_role_resp_rec.application_id       := 660;

                IF l_debug_level  > 0 THEN
                    oe_debug_pub.add(  'CREATING ROLE RESP. CALLING HZ_API' ) ;
                END IF;
            -- {Start Call hz api to create role resp
               HZ_CUST_ACCOUNT_ROLE_V2PUB.Create_Role_Responsibility(
                      p_role_responsibility_rec       => l_role_resp_rec,
                      x_return_status      => l_return_status,
                      x_msg_count          => l_msg_count,
                      x_msg_data           => l_msg_data,
                      x_responsibility_id  => l_responsibility_id
                                          );
            -- End Call hz api to create role resp }

             -- Let us check the status of the call to hz api
             IF l_debug_level  > 0 THEN
                 oe_debug_pub.add(  'RETURN STATS ' || L_RETURN_STATUS ) ;
             END IF;
             If l_return_status <> FND_API.G_RET_STS_SUCCESS Then
               IF l_debug_level  > 0 THEN
                   oe_debug_pub.add(  'RETURN ERROR MESSAGE COUNT FROM HZ ' || OE_MSG_PUB.GET ( P_MSG_INDEX => L_MSG_COUNT ) ) ;
               END IF;
               IF l_debug_level  > 0 THEN
                   oe_debug_pub.add(  'RETURN ERROR MESSAGE FROM HZ ' || L_MSG_DATA ) ;
               END IF;
               x_return_status  := l_return_status;
               oe_msg_pub.transfer_msg_stack;
               fnd_msg_pub.delete_msg;
               IF l_debug_level  > 0 THEN
                   oe_debug_pub.add(  'EXITING CREATE ROLE RESPONSIBILITY API WITH ERROR' ) ;
               END IF;
               return;
             Else
               IF l_debug_level  > 0 THEN
                   oe_debug_pub.add(  'NEW RESPO. ID FOR SITE => '|| L_RESPONSIBILITY_ID ) ;
               END IF;
             End If;
             -- End if of Let us check the status of the call to hz api
            End If;
            -- End of the usage If}

        End If;
        -- End of the l_create_role}
        x_contact_id := l_cust_account_role_id;

    End If;
    -- End of the If of NOTFOUND}

    Close c_cust_acct_role;
    --oe_debug_pub.add('out contact_id ='||out_contact_id);
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'EXISING CHECK AND CREATE CONTACT API' ) ;
    END IF;

EXCEPTION
    WHEN others then
     x_return_status            := FND_API.G_RET_STS_UNEXP_ERROR;
     If c_cust_acct_role%ISOPEN then
        CLOSE c_cust_acct_role;
     End If;
     If c_usage_type%ISOPEN then
        CLOSE c_usage_type;
     End If;
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'PROBLEM IN CALL TO CHECK_AND_CREATE_CONTACT. ABORT PROCESSING' ) ;
     END IF;
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'UNEXPECTED ERROR: '||SQLERRM ) ;
     END IF;
     fnd_message.set_name('ONT','ONT_OI_INL_API_FAILED');
     fnd_message.set_token('API_NAME', 'Check_and_Create_Contact');
     oe_msg_pub.add;
     OE_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,'Unexpected error occured: ' || sqlerrm);
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'EXITING CHECK AND CREATE AND CREATE CONTACT API' ) ;
     END IF;

END Check_and_Create_Contact;
-- End of procedure Check and Create Contact}


-- { Start of procedure Create Contact Point(Phone and Email)
--   This will be used to create the contact points for
--   customer as well as contact
PROCEDURE Create_Contact_Point(
                 p_contact_point_type IN  Varchar2,
                 p_owner_table_id     IN  Number,
                 p_email              IN  Varchar2,
                 p_phone_area_code    IN  Varchar2,
                 p_phone_number       IN  Varchar2,
                 p_phone_extension    IN  Varchar2,
                 p_phone_country_code IN  Varchar2,
                 x_return_status      OUT NOCOPY /* file.sql.39 change */ Varchar2,
                 x_msg_count          OUT NOCOPY /* file.sql.39 change */ Number,
                 x_msg_data           OUT NOCOPY /* file.sql.39 change */ Varchar2
                )
IS
l_contact_point_id   Number;
l_contact_points_rec HZ_CONTACT_POINT_V2PUB.contact_point_rec_type;
l_email_rec          HZ_CONTACT_POINT_V2PUB.email_rec_type;
l_phone_rec          HZ_CONTACT_POINT_V2PUB.phone_rec_type;
l_return_status      Varchar2(1);
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ENTERING CREATE CONTACT POINT API' ) ;
    END IF;

    x_return_status                         := FND_API.G_RET_STS_SUCCESS;
    l_contact_points_rec.contact_point_type := p_contact_point_type;
    l_contact_points_rec.status             := 'A';
    l_contact_points_rec.owner_table_name   := 'HZ_PARTIES';
    l_contact_points_rec.owner_table_id     := p_owner_table_id;
    l_contact_points_rec.primary_flag       := 'Y';
    l_contact_points_rec.created_by_module  := G_CREATED_BY_MODULE;
    l_contact_points_rec.application_id     := 660;

    -- Select the nextval from sequence for contact point
    Select hz_contact_points_s.nextval
    Into   l_contact_points_rec.contact_point_id
    From   dual;

    If p_contact_point_type = 'EMAIL' Then

       l_email_rec.email_address := p_email;

       -- { Start Call hz api to create contact point
       HZ_CONTACT_POINT_V2PUB.Create_Contact_Point(
                  p_contact_point_rec         =>  l_contact_points_rec,
                  p_email_rec                  =>  l_email_rec,
                  x_return_status              =>  l_return_status,
                  x_msg_count                  =>  x_msg_count,
                  x_msg_data                   =>  x_msg_data,
                  x_contact_point_id           =>  l_contact_point_id
                  );
       -- End Call hz api to create contact point }

       -- Let us check the status of the call to hz api
       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'RETURN STATS ' || L_RETURN_STATUS ) ;
       END IF;
       If l_return_status <> FND_API.G_RET_STS_SUCCESS Then
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'RETURN ERROR MESSAGE COUNT FROM HZ ' || OE_MSG_PUB.GET ( P_MSG_INDEX => X_MSG_COUNT ) ) ;
          END IF;
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'RETURN ERROR MESSAGE FROM HZ ' || X_MSG_DATA ) ;
          END IF;
          x_return_status  := l_return_status;
          oe_msg_pub.transfer_msg_stack;
          fnd_msg_pub.delete_msg;
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'EXITING CREATE CONTACT POINT API WITH ERROR' ) ;
          END IF;
          return;
       Else
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'NEW CONTACT ID FOR EMAIL => '|| L_CONTACT_POINT_ID ) ;
          END IF;
       End if;
    Elsif p_contact_point_type = 'PHONE' Then

       l_phone_rec.phone_area_code     := p_phone_area_code;
       l_phone_rec.phone_number        := p_phone_number;
       l_phone_rec.phone_extension     := p_phone_extension;
       l_phone_rec.phone_line_type     := 'GEN';
       l_phone_rec.phone_country_code  := p_phone_country_code;

       -- { Start Call hz api to create contact point
        HZ_CONTACT_POINT_V2PUB.Create_Contact_Point(
                  p_contact_point_rec         =>  l_contact_points_rec,
                  p_phone_rec                  =>  l_phone_rec,
                  x_return_status              =>  l_return_status,
                  x_msg_count                  =>  x_msg_count,
                  x_msg_data                   =>  x_msg_data,
                  x_contact_point_id           =>  l_contact_point_id
                  );
       -- End Call hz api to create contact point }

       -- Let us check the status of the call to hz api
       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'RETURN STATS ' || L_RETURN_STATUS ) ;
       END IF;
       If l_return_status <> FND_API.G_RET_STS_SUCCESS Then
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'RETURN ERROR MESSAGE COUNT FROM HZ ' || OE_MSG_PUB.GET ( P_MSG_INDEX => X_MSG_COUNT ) ) ;
          END IF;
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'RETURN ERROR MESSAGE FROM HZ ' || X_MSG_DATA ) ;
          END IF;
          x_return_status  := l_return_status;
          oe_msg_pub.transfer_msg_stack;
          fnd_msg_pub.delete_msg;
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'EXITING CREATE CONTACT POINT API WITH ERROR' ) ;
          END IF;
          return;
       Else
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'NEW CONTACT ID FOR PHONE =>' || L_CONTACT_POINT_ID ) ;
          END IF;
       End if;

    END IF;
Exception
   When Others Then
     x_return_status            := FND_API.G_RET_STS_UNEXP_ERROR;
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'PROBLEM IN CALL TO CREATE CONTACT PT. ABORT PROCESSING' ) ;
     END IF;
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'UNEXPECTED ERROR: '||SQLERRM ) ;
     END IF;
     fnd_message.set_name('ONT','ONT_OI_INL_API_FAILED');
     fnd_message.set_token('API_NAME', 'Create_Contact_Point');
     oe_msg_pub.add;
     OE_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,'Unexpected error occured: ' || sqlerrm);
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'EXITING CREATE CONTACT POINT API WITH ERROR' ) ;
     END IF;

END create_contact_point;
-- End of procedure Create Contact Point(Phone and Email) }

-- { Start of procedure Create_Account
PROCEDURE Create_Account(
                           p_customer_info_ref       IN     Varchar2,
                           p_orig_sys_document_ref   IN     Varchar2,
                           p_orig_sys_line_ref       IN     Varchar2,
                           p_order_source_id         IN     Number,
                           x_cust_account_id         IN OUT NOCOPY /* file.sql.39 change */ Number,
                           x_cust_account_number     IN OUT NOCOPY /* file.sql.39 change */ Varchar2,
                           x_cust_party_id           OUT NOCOPY /* file.sql.39 change */    Number,
                           x_existing_value          OUT NOCOPY /* file.sql.39 change */    Varchar2,
                           x_return_status           OUT NOCOPY /* file.sql.39 change */    Varchar2
                         )
IS

   l_customer_info_ref Varchar2(50) := p_customer_info_ref;
   l_person_rec        HZ_PARTY_V2PUB.person_rec_type;
   l_organization_rec  HZ_PARTY_V2PUB.organization_rec_type;
   l_party_rec         HZ_PARTY_V2PUB.party_rec_type;
   l_cust_profile_rec  HZ_CUSTOMER_PROFILE_V2PUB.customer_profile_rec_type;
   l_account_rec       HZ_CUST_ACCOUNT_V2PUB.cust_account_rec_type;
   l_party_id          Number;
   l_party_number      varchar2(30);
   l_party_name        Varchar2(360);
   l_msg_data          Varchar2(2000);
   l_msg_count         Number;
   l_return_status     Varchar2(1);
   x_profile_id        Number;
   l_duplicate_account Number;
   l_no_record_exists  BOOLEAN := TRUE;

   -- Following cursor will fetch the data for the passed ref and type --
   -- information. For the account creation.                           --
   -- {
   Cursor l_customer_info_cur Is
          Select party_number,
                 organization_name,
                 person_first_name,
                 person_last_name,
                 person_middle_name,
                 person_name_suffix,
                 person_title,
                 customer_type,
                 email_address,
                 phone_area_code,
                 phone_number,
                 phone_extension,
                 new_account_id,
                 new_account_number,
                 new_party_id,
                 customer_number,
                 attribute_category,
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
                 attribute11,
                 attribute12,
                 attribute13,
                 attribute14,
                 attribute15,
                 attribute16,
                 attribute17,
                 attribute18,
                 attribute19,
                 attribute20,
                 global_attribute_category,
                 global_attribute1,
                 global_attribute2,
                 global_attribute3,
                 global_attribute4,
                 global_attribute5,
                 global_attribute6,
                 global_attribute7,
                 global_attribute8,
                 global_attribute9,
                 global_attribute10,
                 global_attribute11,
                 global_attribute12,
                 global_attribute13,
                 global_attribute14,
                 global_attribute15,
                 global_attribute16,
                 global_attribute17,
                 global_attribute18,
                 global_attribute19,
                 global_attribute20,
                 rowid,
                 phone_country_code
           from  oe_customer_info_iface_all
           where customer_info_ref = l_customer_info_ref
           and   customer_info_type_code     = 'ACCOUNT';

   -- End of Cursor definition for l_customer_info_cur }
   --
   l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
   --
Begin

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'ENTERING IN CREATE_ACCOUNT PROCEDURE' ) ;
   END IF;
   x_return_status               :=  FND_API.G_RET_STS_SUCCESS;
   x_existing_value              :=  'N';

  --{ If to check whether Add Customer privilege is set
  If OE_ORDER_IMPORT_SPECIFIC_PVT.G_ONT_ADD_CUSTOMER = 'Y' Then
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'ADD CUSTOMER PRIVILEGE IS THERE' ) ;
   END IF;
   OE_MSG_PUB.set_msg_context(
         p_entity_code                => 'OI_INL_ADDCUST'
        ,p_entity_ref                 => null
        ,p_entity_id                  => null
        ,p_header_id                  => null
        ,p_line_id                    => null
--      ,p_batch_request_id           => p_x_header_rec.request_id
        ,p_order_source_id            => p_order_source_id
        ,p_orig_sys_document_ref      => p_orig_sys_document_ref
        ,p_change_sequence            => null
        ,p_orig_sys_document_line_ref => p_orig_sys_line_ref
        ,p_orig_sys_shipment_ref      => p_customer_info_ref
        ,p_source_document_type_id    => null
        ,p_source_document_id         => null
        ,p_source_document_line_id    => null
        ,p_attribute_code             => null
        ,p_constraint_id              => null
        );

   -- { Start Customer Loop
   For customer_rec In l_customer_info_cur Loop
   -- { Start of Begin for Loop
   Begin
   l_no_record_exists := FALSE;
   -- Check if the Data is already used to create the New
   -- Customer then return that value and exit out of the
   -- process

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'INSIDE LOOP FOR THE CUSTOMER_INFO_CUR' ) ;
   END IF;

   If customer_rec.New_Account_Id Is Not Null Then
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'NEW ACCOUNT ID IS THERE , RETURING THE EXISTING VAL' ) ;
      END IF;
      x_cust_account_id             := customer_rec.New_Account_id;
      x_cust_account_number         := customer_rec.New_Account_number;
      x_cust_party_id               := customer_rec.New_Party_Id;
      x_existing_value              := 'Y';
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'EXITING IN CREATE_ACCOUNT PROCEDURE WITH CURRENT VAL' ) ;
      END IF;
      return;
   End If;

   -- { Start Check for the Duplidate Account information
   If customer_rec.customer_type = 'ORGANIZATION' Then
      l_duplicate_account     := Oe_value_to_id.sold_to_org(
            p_sold_to_org     => customer_rec.organization_name,
            p_customer_number => customer_rec.customer_number);
   Elsif customer_rec.customer_type = 'PERSON' Then
      l_duplicate_account    := oe_value_to_id.sold_to_org(
            p_sold_to_org    =>  customer_rec.person_first_name || ' ' ||
                                 customer_rec.person_last_name,
            p_customer_number => customer_rec.customer_number);
   End If;
   If l_duplicate_account <> FND_API.G_MISS_NUM Then
      -- Raise Error and Abort Processing
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'TRYING TO ENTER THE ACCOUNT WHICH ALREADY EXISTS' ) ;
      END IF;
      fnd_message.set_name('ONT','ONT_OI_INL_DUPLICATE');
      fnd_message.set_token('TYPE', 'ACCOUNT');
      fnd_message.set_token('REFERENCE', p_customer_info_ref);
      oe_msg_pub.add;
      x_return_status      := FND_API.G_RET_STS_ERROR;
      Update_Error_Flag(p_rowid  =>  customer_rec.rowid);
      Return;
   Else
     -- As the data is not duplicate but the call to oe_value_to_id
     -- has entered one error message in stack(necessary evil!)
     -- What to do => here is solution delete it
     oe_msg_pub.delete_msg(oe_msg_pub.g_msg_count);
   End if; -- Duplicate account check
   -- End Check for the Duplicate Information }

   -- { Start Check for the Required Information
   If G_EMAIL_REQUIRED = 'Y' and
      customer_rec.email_address is Null Then
      -- Raise Error and Abort Processing
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'EMAIL REQUIRED BUT NOT ENTERED' ) ;
      END IF;
      fnd_message.set_name('ONT','ONT_OI_INL_REQD');
      fnd_message.set_token('API_NAME', 'Create_Account');
      fnd_message.set_token('FIELD_REQD',  'EMAIL_ADDRESS');
      oe_msg_pub.add;
      x_return_status      := FND_API.G_RET_STS_ERROR;
      Update_Error_Flag(p_rowid  =>  customer_rec.rowid);
   End If; -- If G_EMAIL_REQUIRED

   If G_AUTO_PARTY_NUMBERING = 'N' and
      customer_rec.party_number is Null Then
      -- Raise Error and Abort Processing
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'PARTY NUMBER REQUIRED BUT NOT ENTERED' ) ;
      END IF;
      fnd_message.set_name('ONT','ONT_OI_INL_REQD');
      fnd_message.set_token('API_NAME', 'Create_Account');
      fnd_message.set_token('FIELD_REQD',  'PARTY_NUMBER');
      oe_msg_pub.add;
      x_return_status      := FND_API.G_RET_STS_ERROR;
      Update_Error_Flag(p_rowid  =>  customer_rec.rowid);
   End If; -- If G_AUTO_PARTY_NUMBERING

   If G_AUTO_CUST_NUMBERING = 'N' and
      customer_rec.customer_number is Null Then
      -- Raise Error and Abort Processing
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'CUSTOMER NUMBER REQUIRED BUT NOT ENTERED' ) ;
      END IF;
      fnd_message.set_name('ONT','ONT_OI_INL_REQD');
      fnd_message.set_token('API_NAME', 'Create_Account');
      fnd_message.set_token('FIELD_REQD',  'CUSTOMER_NUMBER');
      oe_msg_pub.add;
      x_return_status      := FND_API.G_RET_STS_ERROR;
      Update_Error_Flag(p_rowid  =>  customer_rec.rowid);
   End If; -- If G_AUTO_CUST_NUMBERING
   -- End Check for the Required Information }

   -- { Start Check to see if the Party Number is passed
   --   if yes then see if it is new or already exists

   If customer_rec.party_number is Not Null Then

      Validate_Party_Number(
               p_party_number       =>  customer_rec.party_number,
               p_party_type         =>  customer_rec.customer_type,
               x_party_id           =>  l_party_id,
               x_party_name         =>  l_party_name,
               x_return_status      =>  l_return_status);
      If l_return_status <> FND_API.G_RET_STS_SUCCESS Then
         x_return_status := l_return_status;
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'EXITING IN CREATE_ACCOUNT PROCEDURE WITH ERROR' ) ;
         END IF;
         return;
      End If;
   End If;

   -- End Check to see if the Party Number is passed}

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'PARTY NAME => ' || L_PARTY_NAME ) ;
   END IF;
   -- { Start if
   If customer_rec.person_first_name is not Null And
      customer_rec.organization_name is not Null Then

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'BOTH PERSON AND ORGANIZATION INFORMATION CAN NOT BE POPULATED TOGETHER , POPULATE WHAT YOU ARE CREATING' ) ;
      END IF;
      fnd_message.set_name('ONT','ONT_OI_INL_BOTH_PARTY_CUST');
      oe_msg_pub.add;
      x_return_status  := FND_API.G_RET_STS_ERROR;
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'EXITING IN CREATE_ACCOUNT PROCEDURE WITH ERROR' ) ;
      END IF;
      Update_Error_Flag(p_rowid  =>  customer_rec.rowid);
      Return;
   End if;
   -- End If }

   -- Assign values to l_account_rec which will be passed to hz
   -- api to create account

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'START ASSIGNING THE COLUMNS TO THE HZ RECORD STRUCTURE' ) ;
   END IF;

   l_account_rec.attribute_category    := customer_rec.attribute_category;
   l_account_rec.attribute1            := customer_rec.attribute1;
   l_account_rec.attribute2            := customer_rec.attribute2;
   l_account_rec.attribute3            := customer_rec.attribute3;
   l_account_rec.attribute4            := customer_rec.attribute4;
   l_account_rec.attribute5            := customer_rec.attribute5;
   l_account_rec.attribute6            := customer_rec.attribute6;
   l_account_rec.attribute7            := customer_rec.attribute7;
   l_account_rec.attribute8            := customer_rec.attribute8;
   l_account_rec.attribute9            := customer_rec.attribute9;
   l_account_rec.attribute10           := customer_rec.attribute10;
   l_account_rec.attribute11           := customer_rec.attribute11;
   l_account_rec.attribute12           := customer_rec.attribute12;
   l_account_rec.attribute13           := customer_rec.attribute13;
   l_account_rec.attribute14           := customer_rec.attribute14;
   l_account_rec.attribute15           := customer_rec.attribute15;
   l_account_rec.attribute16           := customer_rec.attribute16;
   l_account_rec.attribute17           := customer_rec.attribute17;
   l_account_rec.attribute18           := customer_rec.attribute18;
   l_account_rec.attribute19           := customer_rec.attribute19;
   l_account_rec.attribute20           := customer_rec.attribute20;

   l_account_rec.global_attribute_category   :=
                                  customer_rec.global_attribute_category;
   l_account_rec.global_attribute1     := customer_rec.global_attribute1;
   l_account_rec.global_attribute2     := customer_rec.global_attribute2;
   l_account_rec.global_attribute3     := customer_rec.global_attribute3;
   l_account_rec.global_attribute4     := customer_rec.global_attribute4;
   l_account_rec.global_attribute5     := customer_rec.global_attribute5;
   l_account_rec.global_attribute6     := customer_rec.global_attribute6;
   l_account_rec.global_attribute7     := customer_rec.global_attribute7;
   l_account_rec.global_attribute8     := customer_rec.global_attribute8;
   l_account_rec.global_attribute9     := customer_rec.global_attribute9;
   l_account_rec.global_attribute10    := customer_rec.global_attribute10;
   l_account_rec.global_attribute11    := customer_rec.global_attribute11;
   l_account_rec.global_attribute12    := customer_rec.global_attribute12;
   l_account_rec.global_attribute13    := customer_rec.global_attribute13;
   l_account_rec.global_attribute14    := customer_rec.global_attribute14;
   l_account_rec.global_attribute15    := customer_rec.global_attribute15;
   l_account_rec.global_attribute16    := customer_rec.global_attribute16;
   l_account_rec.global_attribute17    := customer_rec.global_attribute17;
   l_account_rec.global_attribute18    := customer_rec.global_attribute18;
   l_account_rec.global_attribute19    := customer_rec.global_attribute19;
   l_account_rec.global_attribute20    := customer_rec.global_attribute20;

   -- This information will have the customer_number is the auto
   -- generation of the account number is set to 'N'.
   -- ar_system_parameters.generate_customer_number is the column
   -- to check for the value
   -- If the value is 'N' and interface table do not have value
   -- for the New_Account_Number then the call to hz api will return
   -- error that the value need to be passed and that will be displayed
   -- in log file and as well as error form.
   l_account_rec.account_number        := customer_rec.new_account_number;
   l_account_rec.created_by_module     := G_CREATED_BY_MODULE;
   l_account_rec.application_id        := 660;

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'END ASSIGNING THE COLUMNS TO THE HZ ACCOUNT STRUCTURE' ) ;
   END IF;

   -- { Start of the If for the customer_type condition
   -- Type is PERSON
   If customer_rec.customer_type = 'PERSON' Then

     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'INSIDE CUSTOMER_TYPE PERSON' ) ;
     END IF;
     l_person_rec.person_first_name       := customer_rec.person_first_name;
     l_person_rec.person_last_name        := customer_rec.person_last_name;
     l_person_rec.person_middle_name      := customer_rec.person_middle_name;
     l_person_rec.person_name_suffix      := customer_rec.person_name_suffix;
     l_person_rec.person_pre_name_adjunct := customer_rec.person_title;
     l_party_rec.party_number      := customer_rec.party_number;
     If customer_rec.party_number Is Not Null And
        l_party_id is Not Null                Then
        l_party_rec.party_id       := l_party_id;
     End If;

     l_person_rec.party_rec        := l_party_rec;

     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'BEFORE CALL TO CREATE_ACCOUNT FOR TYPE PERSON' ) ;
     END IF;
     -- { Start Call hz api to create customer account
     HZ_CUST_ACCOUNT_V2PUB.Create_Cust_Account
                 (
                  p_person_rec           =>  l_person_rec,
                  p_cust_account_rec          =>  l_account_rec,
                  p_customer_profile_rec     =>  l_cust_profile_rec,
                  x_party_id             =>  x_cust_party_id,
                  x_party_number         =>  l_party_number,
                  x_cust_account_id      =>  x_cust_account_id,
                  x_account_number  =>  x_cust_account_number,
                  x_profile_id           =>  x_profile_id,
                  x_return_status        =>  l_return_status,
                  x_msg_count            =>  l_msg_count,
                  x_msg_data             =>  l_msg_data
                 );
     -- End Call hz api to create customer account}

     -- Let us check the status of the call to hz api
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'RETURN STATS ' || L_RETURN_STATUS ) ;
     END IF;
     If l_return_status <> FND_API.G_RET_STS_SUCCESS Then
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'RETURN ERROR MESSAGE COUNT FROM HZ ' || OE_MSG_PUB.GET ( P_MSG_INDEX => L_MSG_COUNT ) ) ;
        END IF;
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'RETURN ERROR MESSAGE FROM HZ ' || L_MSG_DATA ) ;
        END IF;
        x_return_status  := l_return_status;
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'EXITING IN CREATE_ACCOUNT PROCEDURE WITH ERROR' ) ;
        END IF;
        Update_Error_Flag(p_rowid  =>  customer_rec.rowid);
        oe_msg_pub.transfer_msg_stack;
        fnd_msg_pub.delete_msg;
        return;
     Else
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'NEW CUSTOMER NUMBER => ' || X_CUST_ACCOUNT_NUMBER ) ;
        END IF;
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'NEW CUSTOMER ID => ' || X_CUST_ACCOUNT_ID ) ;
        END IF;
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'NEW PARTY ID => ' || X_CUST_PARTY_ID ) ;
        END IF;

        Update  oe_customer_info_iface_all
        Set     New_Party_Id       =  x_cust_party_id,
                New_Party_Number   =  l_party_number,
                New_Account_Id     =  x_cust_account_id,
                New_Account_Number =  x_cust_account_Number
        Where   rowid              =  customer_rec.rowid;

     End if;

     -- Now we have our account created, so we are set to create the
     -- contact point information for that account, i.e., phone and
     -- email inforation.
     -- { Start for create contact point EMAIL
     If customer_rec.email_address is Not Null Then
        Create_Contact_Point(
                  p_contact_point_type   => 'EMAIL',
                  p_owner_table_id       => x_cust_party_id,
                  p_email                => customer_rec.email_address,
                  p_phone_area_code      => NULL,
                  p_phone_number         => NULL,
                  p_phone_extension      => NULL,
                  p_phone_country_code   => NULL,
                  x_return_status        => l_return_status,
                  x_msg_count            => l_msg_count,
                  x_msg_data             => l_msg_data
                             );
     -- Let us check the status of the call to hz api
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'RETURN STATS ' || L_RETURN_STATUS ) ;
     END IF;
     If l_return_status <> FND_API.G_RET_STS_SUCCESS Then
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'RETURN ERROR MESSAGE FROM CONTACT EML '|| L_MSG_DATA ) ;
        END IF;
        x_return_status  := l_return_status;
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'EXITING IN CREATE_ACCOUNT PROCEDURE WITH ERROR' ) ;
        END IF;
--        Update_Error_Flag(p_rowid  =>  customer_rec.rowid);
        return;
     Else
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'NEW EMAIL => ' || CUSTOMER_REC.EMAIL_ADDRESS ) ;
        END IF;
     End if;

     End If;
     -- End for create contact point EMAIL}

     -- { Start for create contact point PHONE
     If customer_rec.phone_number is Not Null Then
        Create_Contact_Point(
                  p_contact_point_type   => 'PHONE',
                  p_owner_table_id       => x_cust_party_id,
                  p_email                => NULL,
                  p_phone_area_code      => customer_rec.phone_area_code,
                  p_phone_number         => customer_rec.phone_number,
                  p_phone_extension      => customer_rec.phone_extension,
                  p_phone_country_code   => customer_rec.phone_country_code,
		  x_return_status        => l_return_status,
                  x_msg_count            => l_msg_count,
                  x_msg_data             => l_msg_data
                             );
     -- Let us check the status of the call to hz api
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'RETURN STATS ' || L_RETURN_STATUS ) ;
     END IF;
     If l_return_status <> FND_API.G_RET_STS_SUCCESS Then
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'RETURN ERROR MESSAGE FROM CONTACT PH '|| L_MSG_DATA ) ;
        END IF;
        x_return_status  := l_return_status;
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'EXITING IN CREATE_ACCOUNT PROCEDURE WITH ERROR' ) ;
        END IF;
  --      Update_Error_Flag(p_rowid  =>  customer_rec.rowid);
        return;
     Else
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'NEW PHONE => ' || CUSTOMER_REC.PHONE_NUMBER ) ;
        END IF;
     End if;

     End If;
     -- End for create contact point PHONE}

   -- Type is ORGANIZATION
   Elsif customer_rec.customer_type = 'ORGANIZATION' Then

     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'INSIDE CUSTOMER_TYPE ORGANIZATION' ) ;
     END IF;
     l_organization_rec.organization_name  := customer_rec.organization_name;
-- ???  l_organization_rec.organization_name_phonetic  :=  p_alternate_name;
-- ???  l_organization_rec.tax_reference:=p_tax_reference;
-- ???  l_organization_rec.jgzz_fiscal_code:=p_taxpayer_id;
     l_party_rec.party_number              := customer_rec.party_number;

     If customer_rec.party_number Is Not Null And
        l_party_id is Not Null                Then
        l_party_rec.party_id               := l_party_id;
     End If;
     l_organization_rec.party_rec          := l_party_rec;

     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'BEFORE CALL TO CREATE_ACCOUNT FOR TYPE ORGANIZATION' ) ;
     END IF;
     -- { Start Call hz api to create customer account type Organization
     HZ_CUST_ACCOUNT_V2PUB.Create_Cust_Account
                 (
                  p_organization_rec     =>  l_organization_rec,
                  p_cust_account_rec     =>  l_account_rec,
                  p_customer_profile_rec =>  l_cust_profile_rec,
                  x_party_id             =>  x_cust_party_id,
                  x_party_number         =>  l_party_number,
                  x_cust_account_id      =>  x_cust_account_id,
                  x_account_number       =>  x_cust_account_number,
                  x_profile_id           =>  x_profile_id,
                  x_return_status        =>  l_return_status,
                  x_msg_count            =>  l_msg_count,
                  x_msg_data             =>  l_msg_data
                 );
     -- End Call hz api to create customer account type Organization}

     -- Let us check the status of the call to hz api
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'RETURN STATS ' || L_RETURN_STATUS ) ;
     END IF;
     If l_return_status <> FND_API.G_RET_STS_SUCCESS Then
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'RETURN ERROR MESSAGE COUNT FROM HZ ' || OE_MSG_PUB.GET ( P_MSG_INDEX => L_MSG_COUNT ) ) ;
        END IF;
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'RETURN ERROR MESSAGE FROM HZ ' || L_MSG_DATA ) ;
        END IF;
        x_return_status  := l_return_status;
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'EXITING IN CREATE_ACCOUNT PROCEDURE WITH ERROR' ) ;
        END IF;
        Update_Error_Flag(p_rowid  =>  customer_rec.rowid);
        oe_msg_pub.transfer_msg_stack;
        fnd_msg_pub.delete_msg;
        return;
     Else
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'NEW CUSTOMER NUMBER => ' || X_CUST_ACCOUNT_NUMBER ) ;
        END IF;
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'NEW CUSTOMER ID => ' || X_CUST_ACCOUNT_ID ) ;
        END IF;
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'NEW PARTY ID => ' || X_CUST_PARTY_ID ) ;
        END IF;

        Update  oe_customer_info_iface_all
        Set     New_Party_Id       =  x_cust_party_id,
                New_Party_Number   =  l_party_number,
                New_Account_Id     =  x_cust_account_id,
                New_Account_Number =  x_cust_account_Number
        Where   rowid              =  customer_rec.rowid;

     End if;

     -- Now we have our account created, so we are set to create the
     -- contact point information for that account, i.e., phone and
     -- email inforation.
     -- { Start for create contact point EMAIL
     If customer_rec.email_address is Not Null Then
        Create_Contact_Point(
                  p_contact_point_type   => 'EMAIL',
                  p_owner_table_id       => x_cust_party_id,
                  p_email                => customer_rec.email_address,
                  p_phone_area_code      => NULL,
                  p_phone_number         => NULL,
                  p_phone_extension      => NULL,
                  p_phone_country_code   => NULL,
                  x_return_status        => l_return_status,
                  x_msg_count            => l_msg_count,
                  x_msg_data             => l_msg_data
                             );
     -- Let us check the status of the call to hz api
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'RETURN STATS ' || L_RETURN_STATUS ) ;
     END IF;
     If l_return_status <> FND_API.G_RET_STS_SUCCESS Then
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'RETURN ERROR MESSAGE FROM CONTACT EML '|| L_MSG_DATA ) ;
        END IF;
        x_return_status  := l_return_status;
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'EXITING IN CREATE_ACCOUNT PROCEDURE WITH ERROR' ) ;
        END IF;
--        Update_Error_Flag(p_rowid  =>  customer_rec.rowid);
        return;
     Else
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'NEW EMAIL => ' || CUSTOMER_REC.EMAIL_ADDRESS ) ;
        END IF;
     End if;

     End If;
     -- End for create contact point EMAIL}

     -- { Start for create contact point PHONE
     If customer_rec.phone_number is Not Null Then
        Create_Contact_Point(
                  p_contact_point_type   => 'PHONE',
                  p_owner_table_id       => x_cust_party_id,
                  p_email                => NULL,
                  p_phone_area_code      => customer_rec.phone_area_code,
                  p_phone_number         => customer_rec.phone_number,
                  p_phone_extension      => customer_rec.phone_extension,
                  p_phone_country_code   => customer_rec.phone_country_code,
		  x_return_status        => l_return_status,
                  x_msg_count            => l_msg_count,
                  x_msg_data             => l_msg_data
                             );
     -- Let us check the status of the call to hz api
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'RETURN STATS ' || L_RETURN_STATUS ) ;
     END IF;
     If l_return_status <> FND_API.G_RET_STS_SUCCESS Then
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'RETURN ERROR MESSAGE FROM CONTACT PH '|| L_MSG_DATA ) ;
        END IF;
        x_return_status  := l_return_status;
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'EXITING IN CREATE_ACCOUNT PROCEDURE WITH ERROR' ) ;
        END IF;
  --      Update_Error_Flag(p_rowid  =>  customer_rec.rowid);
        return;
     Else
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'NEW PHONE => ' || CUSTOMER_REC.PHONE_NUMBER ) ;
        END IF;
     End if;

     End If;
     -- End for create contact point PHONE}

   Else
     -- Wrong Type is passed Error out
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'WRONG TYPE OF CUSTOMER INFORMATION PASSED.' ) ;
     END IF;
     x_return_status := FND_API.G_RET_STS_ERROR;
     fnd_message.set_name('ONT','ONT_OI_INL_INV_CUST_TYPE');
     oe_msg_pub.add;
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'EXITING IN CREATE_ACCOUNT PROCEDURE WITH ERROR' ) ;
     END IF;
     Update_Error_Flag(p_rowid  =>  customer_rec.rowid);
     Return;
   End If;
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'EXITING IN CREATE_ACCOUNT PROCEDURE ' ) ;
   END IF;
   -- End of the If for the customer_type condition}
   Exception
   When Others Then
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'PROBLEM IN CALL TO CREATE_ACCOUNT. ABORT PROCESSING' ) ;
     END IF;
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'UNEXPECTED ERROR: '||SQLERRM ) ;
     END IF;
     fnd_message.set_name('ONT','ONT_OI_INL_API_FAILED');
     fnd_message.set_token('API_NAME', 'Create_Account');
     oe_msg_pub.add;
     x_return_status            := FND_API.G_RET_STS_UNEXP_ERROR;
     Update_Error_Flag(p_rowid  =>  customer_rec.rowid);
     OE_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,'Unexpected error occured: ' || sqlerrm);
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'EXITING IN CREATE_ACCOUNT PROCEDURE WITH ERROR' ) ;
     END IF;
   End;
   -- End of Begin after Loop }
   End Loop;
   -- End Customer Loop }
   If l_no_record_exists Then
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'NO RECORD FOUND FOR THE PASSED REF , PLEASE CHECK DATA' ) ;
     END IF;
     fnd_message.set_name('ONT','ONT_OI_INL_NO_DATA');
     fnd_message.set_token('REFERENCE', p_customer_info_ref);
     oe_msg_pub.add;
     x_return_status            := FND_API.G_RET_STS_ERROR;
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'EXITING IN CREATE_ACCOUNT PROCEDURE WITH ERROR' ) ;
     END IF;
   End If;

  Else
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ADD CUSTOMER PRIVILEGE IS NOT THERE' ) ;
    END IF;
    fnd_message.set_name('ONT','ONT_OI_INL_SET_PARAMETER');
    fnd_message.set_token('TYPE', 'Customers');
    oe_msg_pub.add;
    x_return_status            := FND_API.G_RET_STS_ERROR;
  End If;
  -- End If to check whether Add Customer privilege is set}
Exception
   When Others Then
     x_return_status            := FND_API.G_RET_STS_UNEXP_ERROR;
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'PROBLEM IN CALL TO CREATE_ACCOUNT. ABORT PROCESSING' ) ;
         oe_debug_pub.add(  'UNEXPECTED ERROR: '||SQLERRM ) ;
     END IF;
     fnd_message.set_name('ONT','ONT_OI_INL_API_FAILED');
     fnd_message.set_token('API_NAME', 'Create_Account');
     oe_msg_pub.add;
     OE_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,'Unexpected error occured: ' || sqlerrm);
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'EXITING IN CREATE_ACCOUNT PROCEDURE WITH ERROR' ) ;
     END IF;
End Create_Account;
-- End of procedure Create_Account}


-- { Start procedure validate_customer_number
Procedure Validate_Customer_Number(p_customer_number  In  VARCHAR2,
                                   x_party_id         Out NOCOPY /* file.sql.39 change */ NUMBER,
                                   x_account_id       Out NOCOPY /* file.sql.39 change */ NUMBER,
                                   x_return_status    Out NOCOPY /* file.sql.39 change */ VARCHAR2
                                  )
Is
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
Begin

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'ENTERNING VALIDATE_CUSTOMER_NUMBER API' ) ;
  END IF;
  Select party_id, cust_account_id
    Into x_party_id, x_account_id
    From hz_cust_accounts
   Where account_number = p_customer_number;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'EXITING VALIDATE_CUSTOMER_NUMBER API' ) ;
  END IF;
Exception
  When NO_DATA_FOUND Then
     x_return_status := FND_API.G_RET_STS_ERROR;
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'NO RECORD FOUND FOR THE PASSED EXISTING CUSTOMER , PLEASE CHECK DATA' ) ;
     END IF;
     fnd_message.set_name('ONT','ONT_OI_INL_NO_DATA');
     fnd_message.set_token('REFERENCE', p_customer_number);
     oe_msg_pub.add;
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'EXITING IN CREATE_ACCOUNT PROCEDURE WITH ERROR' ) ;
     END IF;
End validate_customer_number;


-- { Start procedure Create Address
PROCEDURE Create_Address(p_customer_info_ref       IN     Varchar2,
                         p_type_of_address         IN     Varchar2,
                         p_orig_sys_document_ref   IN     Varchar2,
                         p_orig_sys_line_ref       IN     Varchar2,
                         p_order_source_id         IN     Number,
                         p_org_id                  IN     Number,
                         x_usage_site_id           OUT NOCOPY /* file.sql.39 change */    Number,
                         x_return_status           OUT NOCOPY /* file.sql.39 change */    Varchar2
                        )
IS

  l_customer_info_ref        Varchar2(50) := p_customer_info_ref;
  CURSOR address_info_cur IS
  Select parent_customer_ref,
        current_customer_number,
        current_customer_id,
        country,
        address1,
        address2,
        address3,
        address4,
        city,
        postal_code,
        state,
        province,
        county,
        is_ship_to_address,
        is_bill_to_address,
        is_deliver_to_address,
        new_address_id_ship,
        new_address_id_bill,
        new_address_id_deliver,
        location_number,
        site_number,
        attribute_category,
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
        attribute11,
        attribute12,
        attribute13,
        attribute14,
        attribute15,
        attribute16,
        attribute17,
        attribute18,
        attribute19,
        attribute20,
        global_attribute_category,
        global_attribute1,
        global_attribute2,
        global_attribute3,
        global_attribute4,
        global_attribute5,
        global_attribute6,
        global_attribute7,
        global_attribute8,
        global_attribute9,
        global_attribute10,
        global_attribute11,
        global_attribute12,
        global_attribute13,
        global_attribute14,
        global_attribute15,
        global_attribute16,
        global_attribute17,
        global_attribute18,
        global_attribute19,
        global_attribute20,
        rowid
  From  oe_customer_info_iface_all
  WHERE customer_info_ref =  l_customer_info_ref
  AND   customer_info_type_code = 'ADDRESS';

  l_customer_info_id         Number;
  l_customer_info_number     Varchar2(30);
  l_customer_party_id        Number;
  l_return_status            Varchar2(1);
  l_location_rec             HZ_LOCATION_V2PUB.location_rec_type;
  l_msg_count                Number;
  l_msg_data                 Varchar2(4000);
  l_location_id              Number;
  l_party_site_rec           HZ_PARTY_SITE_V2PUB.party_site_rec_type;
  --g_auto_site_numbering      Varchar2(1);
  --g_auto_location_numbering  Varchar2(1);
  l_party_site_id            Number;
  l_party_site_number        Varchar2(80);
  l_account_site_rec         HZ_CUST_ACCOUNT_SITE_V2PUB.cust_acct_site_rec_type;
  l_customer_site_id         Number;
  l_acct_site_uses           HZ_CUST_ACCOUNT_SITE_V2PUB.cust_site_use_rec_type;
  l_cust_profile_rec         HZ_CUSTOMER_PROFILE_V2PUB.customer_profile_rec_type;
  l_site_use_id_ship         Number;
  l_site_use_id_bill         Number;
  l_site_use_id_deliver      Number;
  l_location_number          Varchar2(40);
  l_address_style            Varchar2(40);
  l_site_number              Varchar2(80);
  l_existing_value           Varchar2(1) := 'N';
  l_no_record_exists  BOOLEAN := TRUE;
  l_ship_to_org              Varchar2(240) := 'Dummy';
  l_duplicate_address        Number;
  l_site_id_exists	     Varchar2(1);
  l_val_addr       Varchar2(1):= 'Y';  ---bug 7299729
  l_temp_Usage_to_cust_id NUMBER DEFAULT NULL; --bug 7299729
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
Begin
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'ENTERING PROCEDURE CREATE ADDRESS' ) ;
   END IF;

   x_return_status :=  FND_API.G_RET_STS_SUCCESS;

   OE_MSG_PUB.set_msg_context(
         p_entity_code                => 'OI_INL_ADDCUST'
        ,p_entity_ref                 => null
        ,p_entity_id                  => null
        ,p_header_id                  => null
        ,p_line_id                    => null
--      ,p_batch_request_id           => p_x_header_rec.request_id
        ,p_order_source_id            => p_order_source_id
        ,p_orig_sys_document_ref      => p_orig_sys_document_ref
        ,p_change_sequence            => null
        ,p_orig_sys_document_line_ref => p_orig_sys_line_ref
        ,p_orig_sys_shipment_ref      => p_customer_info_ref
        ,p_source_document_type_id    => null
        ,p_source_document_id         => null
        ,p_source_document_line_id    => null
        ,p_attribute_code             => null
        ,p_constraint_id              => null
        );

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'TYPE_OF_USAGE => ' || P_TYPE_OF_ADDRESS ) ;
   END IF;
   FOR address_info_rec IN address_info_cur LOOP
    BEGIN
     l_no_record_exists := FALSE;
     If p_type_of_address = 'SHIP_TO' and
        nvl(address_info_rec.is_ship_to_address, 'N') <> 'Y' Then
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'USAGE IS NOT SET FOR SHIP_TO. PLEASE CORRECT DATA' ) ;
        END IF;
        fnd_message.set_name('ONT','ONT_OI_INL_NO_USAGE_SET');
        fnd_message.set_token('USAGE', 'SHIP_TO');
        fnd_message.set_token('REFERENCE', p_customer_info_ref);
        oe_msg_pub.add;
        x_return_status := FND_API.G_RET_STS_ERROR;
        Return;
     Elsif p_type_of_address = 'BILL_TO' and
        nvl(address_info_rec.is_bill_to_address, 'N') <> 'Y' Then
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'USAGE IS NOT SET FOR BILL_TO. PLEASE CORRECT DATA' ) ;
        END IF;
        fnd_message.set_name('ONT','ONT_OI_INL_NO_USAGE_SET');
        fnd_message.set_token('USAGE', 'BILL_TO');
        fnd_message.set_token('REFERENCE', p_customer_info_ref);
        oe_msg_pub.add;
        x_return_status := FND_API.G_RET_STS_ERROR;
        Return;
     Elsif p_type_of_address = 'DELIVER_TO' and
        nvl(address_info_rec.is_deliver_to_address, 'N') <> 'Y' Then
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'USAGE IS NOT SET FOR DELIVER_TO. PLEASE CORRECT DATA' ) ;
        END IF;
        fnd_message.set_name('ONT','ONT_OI_INL_NO_USAGE_SET');
        fnd_message.set_token('USAGE', 'DELIVER_TO');
        fnd_message.set_token('REFERENCE', p_customer_info_ref);
        oe_msg_pub.add;
        x_return_status := FND_API.G_RET_STS_ERROR;
        Return;
     End If;

     If address_info_rec.is_ship_to_address = 'Y' AND
        address_info_rec.new_address_id_ship IS NOT NULL AND
        p_type_of_address = 'SHIP_TO' Then

	begin  --bug#5566811
	  select 'Y' into l_site_id_exists
	  from hz_cust_site_uses
	  where site_use_id=address_info_rec.new_address_id_ship
	         and status='A';

		 if l_site_id_exists='Y' then
			 x_usage_site_id := address_info_rec.new_address_id_ship;
			 x_return_status :=  FND_API.G_RET_STS_SUCCESS;
			  IF l_debug_level  > 0 THEN
			   oe_debug_pub.add(  'RETURNING EXISING SHIP_TO ID=> '|| X_USAGE_SITE_ID ) ;
			 END IF;
			 RETURN;

		 end if;
	  exception
		when no_data_found then
		x_usage_site_id:=null;
	  end;


     Elsif address_info_rec.is_bill_to_address = 'Y' AND
           address_info_rec.new_address_id_bill IS NOT NULL And
           p_type_of_address = 'BILL_TO' Then

	 begin  --bug#5566811
	  select 'Y' into l_site_id_exists
	  from hz_cust_site_uses
	  where site_use_id=address_info_rec.new_address_id_bill
	         and status='A';

		 if l_site_id_exists='Y' then
			 x_usage_site_id := address_info_rec.new_address_id_bill;
			 x_return_status :=  FND_API.G_RET_STS_SUCCESS;
			  IF l_debug_level  > 0 THEN
			   oe_debug_pub.add(  'RETURNING EXISING BILL_TO ID=> '|| X_USAGE_SITE_ID ) ;
			 END IF;
			 RETURN;

		 end if;
	  exception
		when no_data_found then
		x_usage_site_id:=null;
	  end;


     Elsif address_info_rec.is_deliver_to_address = 'Y' AND
           address_info_rec.new_address_id_deliver IS NOT NULL And
           p_type_of_address = 'DELIVER_TO' Then

	  begin  --bug#5566811
	  select 'Y' into l_site_id_exists
	  from hz_cust_site_uses
	  where site_use_id=address_info_rec.new_address_id_deliver
	         and status='A';

		 if l_site_id_exists='Y' then
			 x_usage_site_id := address_info_rec.new_address_id_deliver;
			 x_return_status :=  FND_API.G_RET_STS_SUCCESS;
			  IF l_debug_level  > 0 THEN
			   oe_debug_pub.add(  'RETURNING EXISING DELIVER_TO ID=> '|| X_USAGE_SITE_ID ) ;
			 END IF;
			 RETURN;

		 end if;
	  exception
		when no_data_found then
		x_usage_site_id:=null;
	  end;


     END IF;


     -- {Start of OR
     If (address_info_rec.Current_Customer_Number IS NULL) And
        (address_info_rec.Current_Customer_Id IS NULL) Then

       -- { Start of If for parent_customer_ref Null
       If address_info_rec.parent_customer_ref IS NULL
       Then
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'PARENT_CUSTOMER_INFO_REF IS NULL' ) ;
         END IF;
         fnd_message.set_name('ONT','ONT_OI_INL_NO_PARENT_REF');
         fnd_message.set_token('REFERENCE',  p_customer_info_ref);
         oe_msg_pub.add;
         -- call msg routine
         x_return_status := FND_API.G_RET_STS_ERROR;
         Return;
       Else
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'BEFORE CALLING CREATE ACCOUNT PROCEDURE' ) ;
         END IF;
         -- call Create_Account api
         create_account(p_customer_info_ref => address_info_rec.parent_customer_ref,
                   p_orig_sys_document_ref => p_orig_sys_document_ref,
                   p_orig_sys_line_ref     => p_orig_sys_line_ref,
                   p_order_source_id     => p_order_source_id,
                   x_cust_account_id     => l_customer_info_id,
                   x_cust_account_number => l_customer_info_number,
                   x_cust_party_id       => l_customer_party_id,
                   x_existing_value      => l_existing_value,
                   x_return_status       => l_return_status
                 );
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'AFTER CALLING CREATE ACCOUNT PROCEDURE' ) ;
         END IF;
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'CUST_ACCOUNT_ID = '||L_CUSTOMER_INFO_ID ) ;
         END IF;
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'CUST_PARTY_ID = '||L_CUSTOMER_PARTY_ID ) ;
         END IF;

         If l_return_status <> FND_API.G_RET_STS_SUCCESS Then
           IF l_debug_level  > 0 THEN
               oe_debug_pub.add(  'RETURN STATUS AFTER CREATE_ACCOUNT IS ERROR' ) ;
           END IF;
           x_return_status := l_return_status;
           Return;
         End If;

         -- { Start of G_SOLD_TO_CUST
         If G_SOLD_TO_CUST is Not Null And
            l_existing_value <> 'Y' Then
            Create_Cust_Relationship(
                           p_cust_acct_id          => l_customer_info_id,
                           p_related_cust_acct_id  => G_SOLD_TO_CUST,
                           p_org_id                => p_org_id,
                           x_return_status         => l_return_status,
                           x_msg_count             => l_msg_count,
                           x_msg_data              => l_msg_data);

            IF l_debug_level  > 0 THEN
                oe_debug_pub.add(  'AFTER CREATE_CUST_RELATIONSHIP' ) ;
            END IF;

            If l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
               IF l_debug_level  > 0 THEN
                   oe_debug_pub.add(  'RETURN ERROR MESSAGE COUNT FROM HZ ' || OE_MSG_PUB.GET ( P_MSG_INDEX => L_MSG_COUNT ) ) ;
               END IF;
               IF l_debug_level  > 0 THEN
                   oe_debug_pub.add(  'RETURN ERROR MESSAGE FROM HZ ' || L_MSG_DATA ) ;
               END IF;
               Update_Error_Flag(p_rowid  =>  address_info_rec.rowid);
               x_return_status  := l_return_status;
              Return;
            End if;
         End If;
         -- End of G_SOLD_TO_CUST}

       End If;
       -- End of If for parent_customer_ref Null}
     Else
       -- {Start of Current_Customer Is Not Null
       If address_info_rec.Current_Customer_id IS NOT NULL Then
         l_customer_info_id := address_info_rec.Current_Customer_id;
         Begin
           Select party_id
             Into l_customer_party_id
             From hz_cust_accounts
            Where cust_account_id = l_customer_info_id;
         Exception
           When No_Data_Found Then
             IF l_debug_level  > 0 THEN
                 oe_debug_pub.add(  'NO RECORD FOUND FOR THE PASSED EXISTING CUSTOMER , PLEASE CHECK DATA' ) ;
             END IF;
             fnd_message.set_name('ONT','ONT_OI_INL_NO_DATA');
             fnd_message.set_token('REFERENCE', address_info_rec.Current_Customer_id);
             oe_msg_pub.add;
             x_return_status := FND_API.G_RET_STS_ERROR;
             Return;
         End;
       Else
         --Validate customer
          Validate_Customer_Number(p_customer_number => address_info_rec.Current_Customer_Number,
                                   x_party_id  => l_customer_party_id,
                                   x_account_id  => l_customer_info_id,
                                   x_return_status => l_return_status
                                  );
          If l_return_status <> FND_API.G_RET_STS_SUCCESS Then
            x_return_status := l_return_status;
            Return;
          End If;

       End If;
       -- End of Current_Customer Is Not Null}

     End If;
     -- End of OR}
      l_val_addr :=OE_Sys_Parameters.VALUE('OE_ADDR_VALID_OIMP'); --bug 7299729
         IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'Customer validation for OI '||l_val_addr ) ;
          END IF;


   IF NOT (l_val_addr = 'N' ) THEN      ---skip duplicate check bug 7299729
       IF (l_val_addr = 'S') THEN      ---for single customer check bug 7299729
            l_temp_Usage_to_cust_id := l_customer_info_id ;

       END IF ;

     -- {Start of If for duplicate checking
     If p_type_of_address = 'SHIP_TO' Then
       l_duplicate_address := Oe_Value_To_Id.Ship_To_Org(
         p_ship_to_address1 => address_info_rec.address1,
         p_ship_to_address2 => address_info_rec.address2,
         p_ship_to_address3 => address_info_rec.address3,
         p_ship_to_address4 => address_info_rec.address4,
         p_ship_to_location => address_info_rec.location_number,
         p_ship_to_org      => l_ship_to_org,
         p_sold_to_org_id   => l_customer_info_id,
         p_ship_to_city     => address_info_rec.city,
         p_ship_to_state    => address_info_rec.state,
         p_ship_to_postal_code => address_info_rec.postal_code,
         p_ship_to_country  => address_info_rec.country,
         p_ship_to_customer_id =>l_temp_usage_to_cust_id   --bug 7299729
         );
       If l_duplicate_address <> FND_API.G_MISS_NUM Then
        -- Raise Error and Abort Processing
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'TRYING TO ENTER THE SHIP TO WHICH ALREADY EXISTS' ) ;
          END IF;
          fnd_message.set_name('ONT','ONT_OI_INL_DUPLICATE');
          fnd_message.set_token('TYPE', 'SHIP_TO ADDRESS');
          fnd_message.set_token('REFERENCE', p_customer_info_ref);
          oe_msg_pub.add;
          x_return_status      := FND_API.G_RET_STS_ERROR;
          Update_Error_Flag(p_rowid  =>  address_info_rec.rowid);
          Return;
       Else
         -- As the data is not duplicate but the call to oe_value_to_id
         -- has entered one error message in stack(necessary evil!)
         -- What to do => here is solution delete it
         oe_msg_pub.delete_msg(oe_msg_pub.g_msg_count);
       End if; -- duplicate ship_to_org check
     Elsif p_type_of_address = 'BILL_TO' Then
       l_duplicate_address := Oe_Value_To_Id.Invoice_To_Org(
         p_invoice_to_address1 => address_info_rec.address1,
         p_invoice_to_address2 => address_info_rec.address2,
         p_invoice_to_address3 => address_info_rec.address3,
         p_invoice_to_address4 => address_info_rec.address4,
         p_invoice_to_location => address_info_rec.location_number,
         p_invoice_to_org      => l_ship_to_org,
         p_sold_to_org_id   => l_customer_info_id,
         p_invoice_to_city     => address_info_rec.city,
         p_invoice_to_state    => address_info_rec.state,
         p_invoice_to_postal_code => address_info_rec.postal_code,
         p_invoice_to_country  => address_info_rec.country,
         p_invoice_to_customer_id =>l_temp_usage_to_cust_id   --bug 7299729
         );
       If l_duplicate_address <> FND_API.G_MISS_NUM Then
        -- Raise Error and Abort Processing
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'TRYING TO ENTER THE BILL TO WHICH ALREADY EXISTS' ) ;
          END IF;
          fnd_message.set_name('ONT','ONT_OI_INL_DUPLICATE');
          fnd_message.set_token('TYPE', 'BILL_TO ADDRESS');
          fnd_message.set_token('REFERENCE', p_customer_info_ref);
          oe_msg_pub.add;
          x_return_status      := FND_API.G_RET_STS_ERROR;
          Update_Error_Flag(p_rowid  =>  address_info_rec.rowid);
          Return;
       Else
         -- As the data is not duplicate but the call to oe_value_to_id
         -- has entered one error message in stack(necessary evil!)
         -- What to do => here is solution delete it
         oe_msg_pub.delete_msg(oe_msg_pub.g_msg_count);
       End if; -- duplicate bill_to_org check
     Elsif p_type_of_address = 'DELIVER_TO' Then
       l_duplicate_address := Oe_Value_To_Id.Deliver_To_Org(
         p_deliver_to_address1 => address_info_rec.address1,
         p_deliver_to_address2 => address_info_rec.address2,
         p_deliver_to_address3 => address_info_rec.address3,
         p_deliver_to_address4 => address_info_rec.address4,
         p_deliver_to_location => address_info_rec.location_number,
         p_deliver_to_org      => l_ship_to_org,
         p_sold_to_org_id      => l_customer_info_id,
         p_deliver_to_city     => address_info_rec.city,
         p_deliver_to_state    => address_info_rec.state,
         p_deliver_to_postal_code => address_info_rec.postal_code,
         p_deliver_to_country  => address_info_rec.country,
         p_deliver_to_customer_id =>l_temp_usage_to_cust_id   --bug 7299729
         );
       If l_duplicate_address <> FND_API.G_MISS_NUM Then
        -- Raise Error and Abort Processing
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'TRYING TO ENTER THE DELIVER TO WHICH ALREADY EXISTS' ) ;
          END IF;
          fnd_message.set_name('ONT','ONT_OI_INL_DUPLICATE');
          fnd_message.set_token('TYPE', 'DELIVER_TO ADDRESS');
          fnd_message.set_token('REFERENCE', p_customer_info_ref);
          oe_msg_pub.add;
          x_return_status      := FND_API.G_RET_STS_ERROR;
          Update_Error_Flag(p_rowid  =>  address_info_rec.rowid);
          Return;
       Else
         -- As the data is not duplicate but the call to oe_value_to_id
         -- has entered one error message in stack(necessary evil!)
         -- What to do => here is solution delete it
         oe_msg_pub.delete_msg(oe_msg_pub.g_msg_count);
       End if; -- duplicate deliver_to_org check
     End If;
     -- End Of If For duplicate checking}
   END IF; ----end of skip duplicate check --bug 7299729

     --check if site number is passed, else error
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'AUTO_SITE_NUMBERING = '|| G_AUTO_SITE_NUMBERING ) ;
     END IF;
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'AUTO_LOCATION_NUMBERING = '|| G_AUTO_LOCATION_NUMBERING ) ;
     END IF;

     IF nvl(G_AUTO_SITE_NUMBERING, 'Y') = 'N' AND
        address_info_rec.site_number IS NULL
     THEN
       fnd_message.set_name('ONT','ONT_OI_INL_REQD');
       fnd_message.set_token('API_NAME', 'Create_Address');
       fnd_message.set_token('FIELD_REQD',  'SITE_NUMBER');
       oe_msg_pub.add;
       x_return_status := FND_API.G_RET_STS_ERROR;
       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'SPECIFY SITE NUMBER , PROFILE NO AUTO' ) ;
       END IF;
       RETURN;
     ELSIF nvl(G_AUTO_SITE_NUMBERING, 'Y') = 'N' AND
           address_info_rec.site_number IS NOT NULL
     THEN
       l_site_number := address_info_rec.site_number;
     END IF;

     IF nvl(g_auto_location_numbering, 'Y') = 'N' AND
        address_info_rec.location_number IS NULL
     THEN
       fnd_message.set_name('ONT','ONT_OI_INL_REQD');
       fnd_message.set_token('API_NAME', 'Create_Address');
       fnd_message.set_token('FIELD_REQD',  'LOCATION_NUMBER');
       oe_msg_pub.add;
       x_return_status := FND_API.G_RET_STS_ERROR;
       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'SPECIFY LOCATION NUMBER' ) ;
       END IF;
       RETURN;
     ELSIF nvl(g_auto_location_numbering, 'Y') = 'N' AND
       address_info_rec.location_number IS NOT NULL
     THEN
       l_location_number := address_info_rec.location_number;
     END IF;

     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'CALL CREATE_LOCATION API' ) ;
     END IF;

     l_location_rec.country := address_info_rec.country;
     l_location_rec.address1 := address_info_rec.address1;
     l_location_rec.address2 := address_info_rec.address2;
     l_location_rec.address3 := address_info_rec.address3;
     l_location_rec.address4 := address_info_rec.address4;
     l_location_rec.city := address_info_rec.city;
     l_location_rec.state := address_info_rec.state;
     l_location_rec.postal_code:= address_info_rec.postal_code;
     l_location_rec.province:= address_info_rec.province;
     l_location_rec.county:= address_info_rec.county;
     l_location_rec.address_style:= l_address_style;
     l_location_rec.attribute_category := address_info_rec.attribute_category;
     l_location_rec.attribute1 := address_info_rec.attribute1;
     l_location_rec.attribute2 := address_info_rec.attribute2;
     l_location_rec.attribute3 := address_info_rec.attribute3;
     l_location_rec.attribute4 := address_info_rec.attribute4;
     l_location_rec.attribute5 := address_info_rec.attribute5;
     l_location_rec.attribute6 := address_info_rec.attribute6;
     l_location_rec.attribute7 := address_info_rec.attribute7;
     l_location_rec.attribute8 := address_info_rec.attribute8;
     l_location_rec.attribute9 := address_info_rec.attribute9;
     l_location_rec.attribute10 := address_info_rec.attribute10;
     l_location_rec.attribute11 := address_info_rec.attribute11;
     l_location_rec.attribute12 := address_info_rec.attribute12;
     l_location_rec.attribute13 := address_info_rec.attribute13;
     l_location_rec.attribute14 := address_info_rec.attribute14;
     l_location_rec.attribute15 := address_info_rec.attribute15;
     l_location_rec.attribute16 := address_info_rec.attribute16;
     l_location_rec.attribute17 := address_info_rec.attribute17;
     l_location_rec.attribute18 := address_info_rec.attribute18;
     l_location_rec.attribute19 := address_info_rec.attribute19;
     l_location_rec.attribute20 := address_info_rec.attribute20;
     l_location_rec.created_by_module := G_CREATED_BY_MODULE;
     l_location_rec.application_id    := 660;
     HZ_LOCATION_V2PUB.Create_Location(
                                     p_init_msg_list  => Null
                                    ,p_location_rec   => l_location_rec
                                    ,x_return_status  => l_return_status
                                    ,x_msg_count      => l_msg_count
                                    ,x_msg_data       => l_msg_data
                                    ,x_location_id    => l_location_id
                                    );
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'AFTER HZ CREATE_LOCATION' ) ;
     END IF;
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'LOCATION ID = '||L_LOCATION_ID ) ;
     END IF;

     -- Let us check the status of the call to hz api
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'RETURN STATS ' || L_RETURN_STATUS ) ;
     END IF;
     If l_return_status <> FND_API.G_RET_STS_SUCCESS Then
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'HZ CREATE_LOCATION API ERROR ' ) ;
        END IF;
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'RETURN ERROR MESSAGE COUNT FROM HZ ' || OE_MSG_PUB.GET ( P_MSG_INDEX => L_MSG_COUNT ) ) ;
        END IF;
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'RETURN ERROR MESSAGE FROM HZ ' || L_MSG_DATA ) ;
        END IF;
        x_return_status  := l_return_status;
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'EXITING IN CREATE_ADDRESS PROCEDURE WITH ERROR' ) ;
        END IF;
        Update_Error_Flag(p_rowid  =>  address_info_rec.rowid);
        oe_msg_pub.transfer_msg_stack;
        fnd_msg_pub.delete_msg;
        return;
     End If;

     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'CALL CREATE_PARTY_SITE API' ) ;
     END IF;

     l_party_site_rec.party_id:=  l_customer_party_id;
     l_party_site_rec.location_id := l_location_id;
     l_party_site_rec.party_site_number := l_site_number;
     l_party_site_rec.attribute_category := address_info_rec.attribute_category;
     l_party_site_rec.attribute1 := address_info_rec.attribute1;
     l_party_site_rec.attribute2 := address_info_rec.attribute2;
     l_party_site_rec.attribute3 := address_info_rec.attribute3;
     l_party_site_rec.attribute4 := address_info_rec.attribute4;
     l_party_site_rec.attribute5 := address_info_rec.attribute5;
     l_party_site_rec.attribute6 := address_info_rec.attribute6;
     l_party_site_rec.attribute7 := address_info_rec.attribute7;
     l_party_site_rec.attribute8 := address_info_rec.attribute8;
     l_party_site_rec.attribute9 := address_info_rec.attribute9;
     l_party_site_rec.attribute10 := address_info_rec.attribute10;
     l_party_site_rec.attribute11 := address_info_rec.attribute11;
     l_party_site_rec.attribute12 := address_info_rec.attribute12;
     l_party_site_rec.attribute13 := address_info_rec.attribute13;
     l_party_site_rec.attribute14 := address_info_rec.attribute14;
     l_party_site_rec.attribute15 := address_info_rec.attribute15;
     l_party_site_rec.attribute16 := address_info_rec.attribute16;
     l_party_site_rec.attribute17 := address_info_rec.attribute17;
     l_party_site_rec.attribute18 := address_info_rec.attribute18;
     l_party_site_rec.attribute19 := address_info_rec.attribute19;
     l_party_site_rec.attribute20 := address_info_rec.attribute20;
     l_party_site_rec.created_by_module := G_CREATED_BY_MODULE;
     l_party_site_rec.application_id    := 660;

     HZ_PARTY_SITE_V2PUB.Create_Party_Site
                          (
                           p_party_site_rec => l_party_site_rec,
                           x_party_site_id => l_party_site_id,
                           x_party_site_number => l_party_site_number,
                           x_return_status => l_return_status,
                           x_msg_count => l_msg_count,
                           x_msg_data =>  l_msg_data
                          );
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'AFTER HZ CREATE_PARTY_SITE API' ) ;
     END IF;
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'PARTY_SITE_ID = '||L_PARTY_SITE_ID ) ;
     END IF;
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'PARTY_SITE_NUMBER = '||L_PARTY_SITE_NUMBER ) ;
     END IF;

     -- Let us check the status of the call to hz api
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'RETURN STATS ' || L_RETURN_STATUS ) ;
     END IF;
     If l_return_status <> FND_API.G_RET_STS_SUCCESS Then
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'HZ CREATE_PARTY_SITE API ERROR ' ) ;
        END IF;
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'RETURN ERROR MESSAGE COUNT FROM HZ ' || OE_MSG_PUB.GET ( P_MSG_INDEX => L_MSG_COUNT ) ) ;
        END IF;
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'RETURN ERROR MESSAGE FROM HZ ' || L_MSG_DATA ) ;
        END IF;
        x_return_status  := l_return_status;
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'EXITING IN CREATE_ADDRESS PROCEDURE WITH ERROR' ) ;
        END IF;
        Update_Error_Flag(p_rowid  =>  address_info_rec.rowid);
        oe_msg_pub.transfer_msg_stack;
        fnd_msg_pub.delete_msg;
        return;
     End If;

     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'BEFORE HZ CREATE_ACCOUNT_SITE API' ) ;
     END IF;

     l_account_site_rec.party_site_id := l_party_site_id;
     l_account_site_rec.cust_account_id := l_customer_info_id;
     l_account_site_rec.attribute_category := address_info_rec.attribute_category;
     l_account_site_rec.attribute1 := address_info_rec.attribute1;
     l_account_site_rec.attribute2 := address_info_rec.attribute2;
     l_account_site_rec.attribute3 := address_info_rec.attribute3;
     l_account_site_rec.attribute4 := address_info_rec.attribute4;
     l_account_site_rec.attribute5 := address_info_rec.attribute5;
     l_account_site_rec.attribute6 := address_info_rec.attribute6;
     l_account_site_rec.attribute7 := address_info_rec.attribute7;
     l_account_site_rec.attribute8 := address_info_rec.attribute8;
     l_account_site_rec.attribute9 := address_info_rec.attribute9;
     l_account_site_rec.attribute10 := address_info_rec.attribute10;
     l_account_site_rec.attribute11 := address_info_rec.attribute11;
     l_account_site_rec.attribute12 := address_info_rec.attribute12;
     l_account_site_rec.attribute13 := address_info_rec.attribute13;
     l_account_site_rec.attribute14 := address_info_rec.attribute14;
     l_account_site_rec.attribute15 := address_info_rec.attribute15;
     l_account_site_rec.attribute16 := address_info_rec.attribute16;
     l_account_site_rec.attribute17 := address_info_rec.attribute17;
     l_account_site_rec.attribute18 := address_info_rec.attribute18;
     l_account_site_rec.attribute19 := address_info_rec.attribute19;
     l_account_site_rec.attribute20 := address_info_rec.attribute20;
     l_account_site_rec.global_attribute_category := address_info_rec.global_attribute_category;
     l_account_site_rec.global_attribute1 := address_info_rec.global_attribute1;
     l_account_site_rec.global_attribute2 := address_info_rec.global_attribute2;
     l_account_site_rec.global_attribute3 := address_info_rec.global_attribute3;
     l_account_site_rec.global_attribute4 := address_info_rec.global_attribute4;
     l_account_site_rec.global_attribute5 := address_info_rec.global_attribute5;
     l_account_site_rec.global_attribute6 := address_info_rec.global_attribute6;
     l_account_site_rec.global_attribute7 := address_info_rec.global_attribute7;
     l_account_site_rec.global_attribute8 := address_info_rec.global_attribute8;
     l_account_site_rec.global_attribute9 := address_info_rec.global_attribute9;
     l_account_site_rec.global_attribute10 := address_info_rec.global_attribute10;
     l_account_site_rec.global_attribute11 := address_info_rec.global_attribute11;
     l_account_site_rec.global_attribute12 := address_info_rec.global_attribute12;
     l_account_site_rec.global_attribute13 := address_info_rec.global_attribute13;
     l_account_site_rec.global_attribute14 := address_info_rec.global_attribute14;
     l_account_site_rec.global_attribute15 := address_info_rec.global_attribute15;
     l_account_site_rec.global_attribute16 := address_info_rec.global_attribute16;
     l_account_site_rec.global_attribute17 := address_info_rec.global_attribute17;
     l_account_site_rec.global_attribute18 := address_info_rec.global_attribute18;
     l_account_site_rec.global_attribute19 := address_info_rec.global_attribute19;
     l_account_site_rec.global_attribute20 := address_info_rec.global_attribute20;
     l_account_site_rec.created_by_module := G_CREATED_BY_MODULE;
     l_account_site_rec.application_id    := 660;
     l_account_site_rec.org_id            := p_org_id;

     HZ_CUST_ACCOUNT_SITE_V2PUB.Create_Cust_Acct_Site
                              (
                               p_cust_acct_site_rec => l_account_site_rec,
                               x_return_status => l_return_status,
                               x_msg_count => l_msg_count,
                               x_msg_data => l_msg_data,
                               x_cust_acct_site_id => l_customer_site_id
                              );
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'AFTER HZ CREATE_ACCOUNT_SITE API' ) ;
     END IF;
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'CUSTOMER_SITE_ID = '||L_CUSTOMER_SITE_ID ) ;
     END IF;

     -- Let us check the status of the call to hz api
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'RETURN STATS ' || L_RETURN_STATUS ) ;
     END IF;
     If l_return_status <> FND_API.G_RET_STS_SUCCESS Then
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'HZ CREATE_ACCOUNT_SITE API ERROR ' ) ;
        END IF;
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'RETURN ERROR MESSAGE COUNT FROM HZ ' || OE_MSG_PUB.GET ( P_MSG_INDEX => L_MSG_COUNT ) ) ;
        END IF;
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'RETURN ERROR MESSAGE FROM HZ ' || L_MSG_DATA ) ;
        END IF;
        x_return_status  := l_return_status;
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'EXITING IN CREATE_ADDRESS PROCEDURE WITH ERROR' ) ;
        END IF;
        Update_Error_Flag(p_rowid  =>  address_info_rec.rowid);
        oe_msg_pub.transfer_msg_stack;
        fnd_msg_pub.delete_msg;
        return;
     End If;

     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'BEFORE HZ CREATE_ACCOUNT_SITE_USES API' ) ;
     END IF;

     l_acct_site_uses.cust_acct_site_id := l_customer_site_id;
     l_acct_site_uses.location := l_location_number;
     l_acct_site_uses.created_by_module := G_CREATED_BY_MODULE;
     l_acct_site_uses.application_id    := 660;
     l_acct_site_uses.org_id            := p_org_id;

     IF address_info_rec.is_ship_to_address = 'Y' THEN
       l_acct_site_uses.site_use_code := 'SHIP_TO';
       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'BEFORE HZ CREATE_ACCT_SITE_USES FOR SHIP_TO' ) ;
       END IF;
       HZ_CUST_ACCOUNT_SITE_V2PUB.Create_Cust_Site_Use
             (
              p_cust_site_use_rec => l_acct_site_uses,
              p_customer_profile_rec => l_cust_profile_rec,
              p_create_profile => FND_API.G_FALSE,
              x_return_status => l_return_status,
              x_msg_count => l_msg_count,
              x_msg_data => l_msg_data,
              x_site_use_id => l_site_use_id_ship
             );
       -- Let us check the status of the call to hz api
       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'RETURN STATS ' || L_RETURN_STATUS ) ;
       END IF;
       If l_return_status <> FND_API.G_RET_STS_SUCCESS Then
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'HZ CREATE_SITE_USAGE API ERROR ' ) ;
          END IF;
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'RETURN ERROR MESSAGE COUNT FROM HZ ' || OE_MSG_PUB.GET ( P_MSG_INDEX => L_MSG_COUNT ) ) ;
          END IF;
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'RETURN ERROR MESSAGE FROM HZ ' || L_MSG_DATA ) ;
          END IF;
          x_return_status  := l_return_status;
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'EXITING IN CREATE_ADDRESS PROCEDURE WITH ERROR' ) ;
          END IF;
          Update_Error_Flag(p_rowid  =>  address_info_rec.rowid);
          oe_msg_pub.transfer_msg_stack;
          fnd_msg_pub.delete_msg;
          return;
       End If;

       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'AFTER HZ CREATE_ACCT_SITE_USES FOR SHIP_TO' ) ;
       END IF;
       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'SITE_USE_ID_SHIP = '||L_SITE_USE_ID_SHIP ) ;
       END IF;
       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'L_RETURN_STATUS = '||L_RETURN_STATUS ) ;
       END IF;
       If p_type_of_address = 'SHIP_TO' Then
          x_usage_site_id := l_site_use_id_ship;
       End if;

       Update_Address_id(  type_of_address => 'SHIP_TO',
                           usage_site_id   => l_site_use_id_ship,
                           row_id          =>  address_info_rec.rowid  );

      END IF;

      IF address_info_rec.is_bill_to_address = 'Y' THEN
        l_acct_site_uses.site_use_code := 'BILL_TO';
       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'BEFORE HZ CREATE_ACCT_SITE_USES FOR BILL_TO' ) ;
       END IF;
        HZ_CUST_ACCOUNT_SITE_V2PUB.Create_Cust_Site_Use
             (
              p_cust_site_use_rec => l_acct_site_uses,
              p_customer_profile_rec => l_cust_profile_rec,
              p_create_profile => FND_API.G_FALSE,
              x_return_status => l_return_status,
              x_msg_count => l_msg_count,
              x_msg_data => l_msg_data,
              x_site_use_id => l_site_use_id_bill
             );
         -- Let us check the status of the call to hz api
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'RETURN STATS ' || L_RETURN_STATUS ) ;
         END IF;
         If l_return_status <> FND_API.G_RET_STS_SUCCESS Then
            IF l_debug_level  > 0 THEN
                oe_debug_pub.add(  'HZ CREATE_SITE_USAGE API ERROR ' ) ;
            END IF;
            IF l_debug_level  > 0 THEN
                oe_debug_pub.add(  'RETURN ERROR MESSAGE COUNT FROM HZ ' || OE_MSG_PUB.GET ( P_MSG_INDEX => L_MSG_COUNT ) ) ;
            END IF;
            IF l_debug_level  > 0 THEN
                oe_debug_pub.add(  'RETURN ERROR MESSAGE FROM HZ ' || L_MSG_DATA ) ;
            END IF;
            x_return_status  := l_return_status;
            IF l_debug_level  > 0 THEN
                oe_debug_pub.add(  'EXITING IN CREATE_ADDRESS PROCEDURE WITH ERROR' ) ;
            END IF;
            Update_Error_Flag(p_rowid  =>  address_info_rec.rowid);
            oe_msg_pub.transfer_msg_stack;
            fnd_msg_pub.delete_msg;
            return;
         End If;

       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'AFTER HZ CREATE_ACCT_SITE_USES FOR BILL_TO' ) ;
       END IF;
       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'SITE_USE_ID_BILL = '||L_SITE_USE_ID_BILL ) ;
       END IF;
       If p_type_of_address = 'BILL_TO' Then
          x_usage_site_id := l_site_use_id_bill;
       End if;

       Update_Address_id(  type_of_address => 'BILL_TO',
                           usage_site_id   => l_site_use_id_bill,
                           row_id          =>  address_info_rec.rowid  );
      END IF;

      IF address_info_rec.is_deliver_to_address = 'Y' THEN
        l_acct_site_uses.site_use_code := 'DELIVER_TO';
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'BEFORE HZ CREATE_ACCT_SITE_USES FOR DELIVER_TO ' ) ;
        END IF;
        HZ_CUST_ACCOUNT_SITE_V2PUB.Create_Cust_Site_Use
             (
              p_cust_site_use_rec => l_acct_site_uses,
              p_customer_profile_rec => l_cust_profile_rec,
              p_create_profile => FND_API.G_FALSE,
              x_return_status => l_return_status,
              x_msg_count => l_msg_count,
              x_msg_data => l_msg_data,
              x_site_use_id => l_site_use_id_deliver
             );
         -- Let us check the status of the call to hz api
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'RETURN STATS ' || L_RETURN_STATUS ) ;
         END IF;
         If l_return_status <> FND_API.G_RET_STS_SUCCESS Then
            IF l_debug_level  > 0 THEN
                oe_debug_pub.add(  'HZ CREATE_SITE_USAGE API ERROR ' ) ;
            END IF;
            IF l_debug_level  > 0 THEN
                oe_debug_pub.add(  'RETURN ERROR MESSAGE COUNT FROM HZ ' || OE_MSG_PUB.GET ( P_MSG_INDEX => L_MSG_COUNT ) ) ;
            END IF;
            IF l_debug_level  > 0 THEN
                oe_debug_pub.add(  'RETURN ERROR MESSAGE FROM HZ ' || L_MSG_DATA ) ;
            END IF;
            IF l_debug_level  > 0 THEN
                oe_debug_pub.add(  'RETURN ERROR MESSAGE FROM HZ ' || L_MSG_DATA ) ;
            END IF;
            x_return_status  := l_return_status;
            IF l_debug_level  > 0 THEN
                oe_debug_pub.add(  'EXITING IN CREATE_ADDRESS PROCEDURE WITH ERROR' ) ;
            END IF;
            Update_Error_Flag(p_rowid  =>  address_info_rec.rowid);
            oe_msg_pub.transfer_msg_stack;
            fnd_msg_pub.delete_msg;
            return;
         End If;

         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'AFTER HZ CREATE_ACCT_SITE_USES FOR DELIVER_TO' ) ;
         END IF;
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'SITE_USE_ID_DELIVER = '||L_SITE_USE_ID_DELIVER ) ;
         END IF;
         If p_type_of_address = 'DELIVER_TO' Then
           x_usage_site_id := l_site_use_id_deliver;
         End if;
       Update_Address_id(  type_of_address => 'DELIVER_TO',
                           usage_site_id   => l_site_use_id_deliver,
                           row_id          =>  address_info_rec.rowid  );

       END IF;

    EXCEPTION
     When Others Then
       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'PROBLEM IN CALL TO CREATE_ADDRESS. ABORT PROCESSING' ) ;
       END IF;
       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'UNEXPECTED ERROR: '||SQLERRM ) ;
       END IF;
       fnd_message.set_name('ONT','ONT_OI_INL_API_FAILED');
       fnd_message.set_token('API_NAME', 'Create_Address');
       oe_msg_pub.add;
       x_return_status            := FND_API.G_RET_STS_UNEXP_ERROR;
       Update_Error_Flag(p_rowid  =>  address_info_rec.rowid);
       OE_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,'Unexpected error occured: ' || sqlerrm);
       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'EXITING IN CREATE_ADDRESS PROCEDURE WITH ERROR' ) ;
       END IF;

    END;
    -- End of Begin after loop
   END LOOP;
    -- End of For loop
   If l_no_record_exists Then
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'NO RECORD FOUND FOR THE PASSED REF , PLEASE CHECK DATA' ) ;
     END IF;
     fnd_message.set_name('ONT','ONT_OI_INL_NO_DATA');
     fnd_message.set_token('REFERENCE', p_customer_info_ref);
     oe_msg_pub.add;
     x_return_status            := FND_API.G_RET_STS_ERROR;
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'EXITING IN CREATE_ADDRESS PROCEDURE WITH ERROR' ) ;
     END IF;
   End If;

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'EXITING PROCEDURE CREATE ADDRESS' ) ;
   END IF;
Exception
   When Others Then
     x_return_status            := FND_API.G_RET_STS_UNEXP_ERROR;
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'PROBLEM IN CALL TO CREATE_ADDRESS. ABORT PROCESSING' ) ;
         oe_debug_pub.add(  'UNEXPECTED ERROR: '||SQLERRM ) ;
     END IF;
     fnd_message.set_name('ONT','ONT_OI_INL_API_FAILED');
     fnd_message.set_token('API_NAME', 'Create_Address');
     oe_msg_pub.add;
     OE_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,'Unexpected error occured: ' || sqlerrm);
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'EXITING IN CREATE_ADDRESS PROCEDURE WITH ERROR' ) ;
     END IF;

End Create_Address;
-- End procedure Create Address }


-- { Start procedure Create Contact
PROCEDURE Create_Contact(
                           p_customer_info_ref       IN     Varchar2,
                           p_cust_account_id         IN OUT NOCOPY /* file.sql.39 change */ Number,
                           p_cust_account_number     IN OUT NOCOPY /* file.sql.39 change */ Varchar2,
                           p_type_of_contact         IN     Varchar2,
                           p_orig_sys_document_ref   IN     Varchar2,
                           p_orig_sys_line_ref       IN     Varchar2,
                           p_order_source_id         IN     Number,
                           x_contact_id              OUT NOCOPY /* file.sql.39 change */    Number,
                           x_contact_name            OUT NOCOPY /* file.sql.39 change */    Varchar2,
                           x_return_status           OUT NOCOPY /* file.sql.39 change */    Varchar2
                         )
IS
   l_person_rec               HZ_PARTY_V2PUB.person_rec_type;
   l_party_rec                HZ_PARTY_V2PUB.party_rec_type;

   l_contact_party_id         Number;
   l_contact_party_number     Varchar2(50);
   l_customer_party_id        Number;
   l_customer_party_number    Varchar2(50);
   l_profile_id               Number;

   l_return_status            Varchar2(1);

-- l_party_rel_rec            HZ_RELATIONSHIP_V2PUB.relationship_rec_type;
   x_rel_party_id             Number;
   x_rel_party_number         hz_parties.party_number%TYPE;
   x_party_relationship_id    Number;

   l_org_contact_rec          HZ_PARTY_CONTACT_V2PUB.org_contact_rec_type;
   x_org_contact_id           Number;

   x_cust_account_role_id     Number;
   l_cust_acct_roles_rec      HZ_CUST_ACCOUNT_ROLE_V2PUB.cust_account_role_rec_type;

   l_gen_contact_number       Varchar2(1);

   l_customer_info_id         Number;
   l_customer_info_number     Varchar2(30);
   l_customer_info_ref        Varchar2(50) := p_customer_info_ref;
   l_type_of_contact          Varchar2(10) := p_type_of_contact;
   l_usage_site_id            Number;
   l_ship_to_org_id           Number;
   l_bill_to_org_id           Number;
   l_deliver_to_org_id        Number;
   l_ret_contact_id           Number;
   l_existing_value           Varchar2(1) := 'N';

   l_msg_data                 Varchar2(2000);
   l_msg_count                Number;
   l_contact_name             Varchar2(2000);
   l_sold_to_contact          Number;
   l_no_record_exists         BOOLEAN := TRUE;

   -- Following cursor will fetch the data for the passed ref and type --
   -- information. For the contact creation.                           --
   -- {
   Cursor l_contact_info_cur Is
          Select person_first_name,
                 person_last_name,
                 person_middle_name,
                 person_name_suffix,
                 person_title,
                 email_address,
                 phone_area_code,
                 phone_number,
                 phone_extension,
                 current_customer_number,
                 current_customer_id,
                 parent_customer_ref,
                 new_contact_id,
                 new_party_id,
                 is_ship_to_address,
                 is_bill_to_address,
                 is_deliver_to_address,
                 rowid,
                 phone_country_code
           from  oe_customer_info_iface_all
           where customer_info_ref = l_customer_info_ref
           and   customer_info_type_code     = 'CONTACT';

   -- End of Cursor definition for l_contact_info_cur }

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
Begin
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'ENTERING PROCEDURE CREATE CONTACT' ) ;
   END IF;

   x_return_status                        := FND_API.G_RET_STS_SUCCESS;

   OE_MSG_PUB.set_msg_context(
         p_entity_code                => 'OI_INL_ADDCUST'
        ,p_entity_ref                 => null
        ,p_entity_id                  => null
        ,p_header_id                  => null
        ,p_line_id                    => null
--      ,p_batch_request_id           => p_x_header_rec.request_id
        ,p_order_source_id            => p_order_source_id
        ,p_orig_sys_document_ref      => p_orig_sys_document_ref
        ,p_change_sequence            => null
        ,p_orig_sys_document_line_ref => p_orig_sys_line_ref
        ,p_orig_sys_shipment_ref      => p_customer_info_ref
        ,p_source_document_type_id    => null
        ,p_source_document_id         => null
        ,p_source_document_line_id    => null
        ,p_attribute_code             => null
        ,p_constraint_id              => null
        );

   -- { Start Contact Loop
   For contact_rec In l_contact_info_cur Loop
   -- { Start of Begin for Loop
   Begin
     l_no_record_exists := FALSE;
   -- Check if the Data is already used to create the New
   -- Customer then return that value and exit out of the
   -- process

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'INSIDE LOOP FOR THE CUSTOMER_INFO_CUR' ) ;
   END IF;

   If contact_rec.New_Contact_Id Is Not Null And
      l_type_of_contact = 'SOLD_TO' Then
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'NEW CONTACT ID IS THERE , RETURING THE EXISTING VAL' ) ;
      END IF;
      x_contact_id                   := contact_rec.New_Contact_id;
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'EXITING PROCEDURE CREATE CONTACT WITH CURRENT VAL' ) ;
      END IF;
      RETURN;
   End If;

   -- {Start Check if the contact is being created for the site then
      --then if that contact is alreary for that site then return the
      --contact_id otherwise need to make contact for new site too.
   If contact_rec.New_Contact_Id Is Not Null and
      l_type_of_contact Is Not Null Then
      If (l_type_of_contact = 'SHIP_TO' and
         contact_rec.is_ship_to_address = 'Y') Or
         (l_type_of_contact = 'BILL_TO' and
         contact_rec.is_bill_to_address = 'Y') Or
         (l_type_of_contact = 'DELIVER_TO' and
         contact_rec.is_deliver_to_address = 'Y') Then
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'NEW CONTACT ID IS THERE FOR SITE ' || L_TYPE_OF_CONTACT || ' , RETURING THE EXISTING VAL' ) ;
         END IF;
         x_contact_id                   := contact_rec.New_Contact_id;
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'EXITING PROCEDURE CREATE CONTACT WITH CURRENT VAL' ) ;
         END IF;
         RETURN;
      End If;
   End If;
   -- End of the site level contact check}

   -- {Start of the checking of existing customer or not
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'LET US CHECK IF THIS IS FOR EXISTING CUSTOMER' ) ;
   END IF;

   If (contact_rec.current_customer_id IS NULL) And
      (contact_rec.current_customer_number) IS NULL Then
     --{Start of if parent rec is passed or not
     If contact_rec.parent_customer_ref is Null Then
       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'NO PARENT CUSTOMER REF POPULATED. CHECK THE DATA' ) ;
       END IF;
       x_return_status  := FND_API.G_RET_STS_ERROR;
       fnd_message.set_name('ONT','ONT_OI_INL_NO_PARENT_INFO');
       fnd_message.set_token('REFERENCE', p_customer_info_ref);
       oe_msg_pub.add;
       return;
     End If;
     -- End of if parent rec is passed or not}

     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'BEFORE CALLING CREATE ACCOUNT PROCEDURE' ) ;
     END IF;
     -- call Create_Account api
     Create_Account( p_customer_info_ref    => contact_rec.parent_customer_ref,
                   p_orig_sys_document_ref => p_orig_sys_document_ref,
                   p_orig_sys_line_ref     => p_orig_sys_line_ref,
                   p_order_source_id     => p_order_source_id,
                   x_cust_account_id      => l_customer_info_id,
                   x_cust_account_number  => l_customer_info_number,
                   x_cust_party_id        => l_customer_party_id,
                   x_existing_value       => l_existing_value,
                   x_return_status        => l_return_status
                 );
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'AFTER CALLING CREATE ACCOUNT PROCEDURE' ) ;
     END IF;

     -- Check for the return status of the api
     -- to return the proper information to the called program.
     If l_return_status <> FND_API.G_RET_STS_SUCCESS Then
       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'RETURN STATUS IS NOT SUCCESS , AFTER CREATE ACC. FOR CONTACT' ) ;
       END IF;
       x_return_status := l_return_status;
       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'EXITING PROCEDURE CREATE CONTACT WITH ERROR' ) ;
       END IF;
       Return;
     End if;
     -- End of the checking of the Parent Info and creation}

   Else
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'FOR EXISTING CUSTOMER' ) ;
     END IF;
     If contact_rec.current_customer_id IS NOT NULL Then
       l_customer_info_id := contact_rec.Current_Customer_id;
       Begin
         Select party_id
           Into l_customer_party_id
           From hz_cust_accounts
          Where cust_account_id = l_customer_info_id;
       Exception
         When No_Data_Found Then
           IF l_debug_level  > 0 THEN
               oe_debug_pub.add(  'NO RECORD FOUND FOR THE PASSED EXISTING CUSTOMER , PLEASE CHECK DATA' ) ;
           END IF;
           fnd_message.set_name('ONT','ONT_OI_INL_NO_DATA');
           fnd_message.set_token('REFERENCE', contact_rec.Current_Customer_id);
           oe_msg_pub.add;
           x_return_status := FND_API.G_RET_STS_ERROR;
           Return;
       End;
     Else
       --Validate customer
          Validate_Customer_Number(p_customer_number => contact_rec.Current_Customer_Number,
                                   x_party_id  => l_customer_party_id,
                                   x_account_id  => l_customer_info_id,
                                   x_return_status => l_return_status
                                  );
          If l_return_status <> FND_API.G_RET_STS_SUCCESS Then
            x_return_status := l_return_status;
            Return;
          End If;
      End If;
    End If;
    -- End of the checking of existing customer or not}

   -- { Start of duplicate check for contact
   -- concatenate to get name of contact
   Select contact_rec.person_last_name || DECODE(contact_rec.person_first_name,  NULL, NULL, ', '|| contact_rec.PERSON_FIRST_NAME) || DECODE(contact_rec.Person_Name_Suffix, NULL, NULL, ', '||contact_rec.Person_Name_Suffix)
    Into l_contact_name
    From Dual;

   -- { Start of If for duplicate contact check
   If l_type_of_contact = 'SOLD_TO' Then
     l_sold_to_contact := Oe_Value_To_Id.Sold_To_Contact(
       p_sold_to_contact    => l_contact_name,
       p_sold_to_org_id     => l_customer_info_id);
       If l_sold_to_contact <> FND_API.G_MISS_NUM Then
        -- Raise Error and Abort Processing
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'TRYING TO ENTER THE SOLD_TO CONTACT WHICH ALREADY EXISTS' ) ;
          END IF;
          fnd_message.set_name('ONT','ONT_OI_INL_DUPLICATE');
          fnd_message.set_token('REFERENCE', p_customer_info_ref);
          oe_msg_pub.add;
          x_return_status      := FND_API.G_RET_STS_ERROR;
          Update_Error_Flag(p_rowid  =>  contact_rec.rowid);
          Return;
       Else
         -- As the data is not duplicate but the call to oe_value_to_id
         -- has entered one error message in stack(necessary evil!)
         -- What to do => here is solution delete it
         oe_msg_pub.delete_msg(oe_msg_pub.g_msg_count);
       End if; -- duplicate sold_to contact check
    Elsif l_type_of_contact = 'SHIP_TO' Then
      l_sold_to_contact := Oe_Value_To_Id.Ship_To_Contact(
        p_ship_to_contact    => l_contact_name,
        p_ship_to_org_id     => l_usage_site_id);
       If l_sold_to_contact <> FND_API.G_MISS_NUM Then
        -- Raise Error and Abort Processing
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'TRYING TO ENTER THE SHIP_TO CONTACT WHICH ALREADY EXISTS' ) ;
          END IF;
          fnd_message.set_name('ONT','ONT_OI_INL_DUPLICATE');
          fnd_message.set_token('REFERENCE', p_customer_info_ref);
          oe_msg_pub.add;
          x_return_status      := FND_API.G_RET_STS_ERROR;
          Update_Error_Flag(p_rowid  =>  contact_rec.rowid);
          Return;
       Else
         -- As the data is not duplicate but the call to oe_value_to_id
         -- has entered one error message in stack(necessary evil!)
         -- What to do => here is solution delete it
         oe_msg_pub.delete_msg(oe_msg_pub.g_msg_count);
       End if; -- duplicate ship_to contact check
    Elsif l_type_of_contact = 'BILL_TO' Then
      l_sold_to_contact := Oe_Value_To_Id.Invoice_To_Contact(
        p_invoice_to_contact    => l_contact_name,
        p_invoice_to_org_id     => l_usage_site_id);
       If l_sold_to_contact <> FND_API.G_MISS_NUM Then
        -- Raise Error and Abort Processing
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'TRYING TO ENTER THE BILL_TO CONTACT WHICH ALREADY EXISTS' ) ;
          END IF;
          fnd_message.set_name('ONT','ONT_OI_INL_DUPLICATE');
          fnd_message.set_token('REFERENCE', p_customer_info_ref);
          oe_msg_pub.add;
          x_return_status      := FND_API.G_RET_STS_ERROR;
          Update_Error_Flag(p_rowid  =>  contact_rec.rowid);
          Return;
       Else
         -- As the data is not duplicate but the call to oe_value_to_id
         -- has entered one error message in stack(necessary evil!)
         -- What to do => here is solution delete it
         oe_msg_pub.delete_msg(oe_msg_pub.g_msg_count);
       End if; -- duplicate bill_to contact check
    Elsif l_type_of_contact = 'DELIVER_TO' Then
      l_sold_to_contact := Oe_Value_To_Id.Deliver_To_Contact(
        p_deliver_to_contact    => l_contact_name,
        p_deliver_to_org_id     => l_usage_site_id);
       If l_sold_to_contact <> FND_API.G_MISS_NUM Then
        -- Raise Error and Abort Processing
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'TRYING TO ENTER THE DELIVER_TO CONTACT WHICH ALREADY EXISTS' ) ;
          END IF;
          fnd_message.set_name('ONT','ONT_OI_INL_DUPLICATE');
          fnd_message.set_token('REFERENCE', p_customer_info_ref);
          oe_msg_pub.add;
          x_return_status      := FND_API.G_RET_STS_ERROR;
          Update_Error_Flag(p_rowid  =>  contact_rec.rowid);
          Return;
       Else
         -- As the data is not duplicate but the call to oe_value_to_id
         -- has entered one error message in stack(necessary evil!)
         -- What to do => here is solution delete it
         oe_msg_pub.delete_msg(oe_msg_pub.g_msg_count);
       End if; -- duplicate deliver_to contact check
    End if;
    -- End of If for duplicate contact check}



   -- { Start Let us now check to see that we are here just to create
   --   a new site level contact for the exiting contact or the contact
   --   itself is not there and we have to go thru the whole process
   If contact_rec.New_Contact_Id Is Not Null Then
      Check_and_Create_Contact(p_contact_party_id => contact_rec.new_party_id,
                               p_cust_acct_id     => l_customer_info_id,
                               p_usage_type       => l_type_of_contact,
                               x_contact_id       => l_ret_contact_id,
                               x_return_status    => l_return_status
                               );
      If contact_rec.New_Contact_Id = l_ret_contact_id Then
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'GENERATED CONTACT ID IS => ' || L_RET_CONTACT_ID ) ;
         END IF;
         x_contact_id                   := contact_rec.New_Contact_id;
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'EXITING PROCEDURE CREATE CONTACT WITH CURRENT VAL' ) ;
         END IF;
         RETURN;
      Else
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'THERE IS SOME PROBLEM , PLEASE INVESTIGATE.' ) ;
         END IF;
      End If;
   End If;

   -- End of the check }


   l_person_rec.person_first_name       :=  contact_rec.person_first_name;
   l_person_rec.person_last_name        :=  contact_rec.person_last_name;
   l_person_rec.person_pre_name_adjunct :=  contact_rec.person_title;
   l_person_rec.created_by_module :=  G_CREATED_BY_MODULE;
   l_person_rec.application_id    :=  660;

   If G_AUTO_PARTY_NUMBERING = 'N' Then
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'BEFORE SELECTING NEXTVAL FROM PARTY SEQUENCE' ) ;
      END IF;
      Select hz_party_number_s.nextval
      Into   l_party_rec.party_number
      From   Dual;
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'AFTER SELECTING NEW PARTY SEQUENCE ' || L_PARTY_REC.PARTY_NUMBER ) ;
      END IF;
   End If; -- If G_AUTO_PARTY_NUMBERING

   l_person_rec.party_rec        := l_party_rec;

   -- { Start Before Calling hz api to create person for contact
    HZ_PARTY_V2PUB.Create_Person(
                      p_person_rec        => l_person_rec,
                      x_party_id          => l_contact_party_id,
                      x_party_number      => l_contact_party_number,
                      x_profile_id        => l_profile_id,
                      x_return_status     => l_return_status,
                      x_msg_count         => l_msg_count,
                      x_msg_data          => l_msg_data
                      );

   -- End Call hz api to create contact person }
    -- Let us check the status of the call to hz api
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'RETURN STATS ' || L_RETURN_STATUS ) ;
    END IF;
    If l_return_status <> FND_API.G_RET_STS_SUCCESS Then
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'HZ CREATE_PERSON API ERROR ' ) ;
      END IF;
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'RETURN ERROR MESSAGE COUNT FROM HZ ' || OE_MSG_PUB.GET ( P_MSG_INDEX => L_MSG_COUNT ) ) ;
      END IF;
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'RETURN ERROR MESSAGE FROM HZ ' || L_MSG_DATA ) ;
      END IF;
      x_return_status  := l_return_status;
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'EXITING IN CREATE_CONTACT PROCEDURE WITH ERROR' ) ;
      END IF;
      Update_Error_Flag(p_rowid  =>  contact_rec.rowid);
      oe_msg_pub.transfer_msg_stack;
      fnd_msg_pub.delete_msg;
      return;
    End If;

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'NEW PARTY ID FOR CONTACT =>' || L_CONTACT_PARTY_ID ) ;
      END IF;
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'NEW PARTY NUMBER FOR CONTACT =>' || L_CONTACT_PARTY_NUMBER ) ;
      END IF;

   If G_AUTO_PARTY_NUMBERING = 'N' Then
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'BEFORE SELECTING NEXTVAL FROM PARTY SEQUENCE FOR ORG' ) ;
      END IF;
      Select hz_party_number_s.nextval
      Into   l_org_contact_rec.party_rel_rec.party_rec.party_number
      From   Dual;
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'AFTER SELECTING NEW PARTY SEQUENCE ' || L_ORG_CONTACT_REC.PARTY_REL_REC.PARTY_REC.PARTY_NUMBER ) ;
      END IF;
   End If; -- If G_AUTO_PARTY_NUMBERING

   l_org_contact_rec.party_rel_rec.subject_id           := l_contact_party_id;
   l_org_contact_rec.party_rel_rec.object_id            := l_customer_party_id;
   l_org_contact_rec.party_rel_rec.relationship_type := 'CONTACT';
   l_org_contact_rec.party_rel_rec.relationship_code := 'CONTACT_OF';
   l_org_contact_rec.party_rel_rec.start_date           := sysdate;
   l_org_contact_rec.party_rel_rec.subject_table_name   := 'HZ_PARTIES';
   l_org_contact_rec.party_rel_rec.object_table_name    := 'HZ_PARTIES';
   l_org_contact_rec.party_rel_rec.created_by_module    := G_CREATED_BY_MODULE;
   l_org_contact_rec.party_rel_rec.application_id       := 660;
   l_org_contact_rec.party_rel_rec.subject_type := 'PERSON';
   Select party_type
   Into l_org_contact_rec.party_rel_rec.object_type
   From HZ_PARTIES
   Where party_id = l_customer_party_id;

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'SUBJECT_ID:'||L_CONTACT_PARTY_ID||':OBJECT_ID:'||L_CUSTOMER_PARTY_ID||':OBJECT_TYPE'||L_ORG_CONTACT_REC.PARTY_REL_REC.OBJECT_TYPE ) ;
   END IF;
   If G_AUTO_CONTACT_NUMBERING = 'N' Then
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'BEFORE SELECTING NEXTVAL FROM CONTACT SEQ' ) ;
      END IF;
      Select hz_contact_numbers_s.nextval
      Into   l_org_contact_rec.contact_number
      From   Dual;
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'AFTER SELECTING NEW CONTACT SEQUENCE ' || L_ORG_CONTACT_REC.CONTACT_NUMBER ) ;
      END IF;
   End If; -- If G_AUTO_CONTACT_NUMBERING


   l_org_contact_rec.title           := contact_rec.person_title;
   l_org_contact_rec.created_by_module   := G_CREATED_BY_MODULE;
   l_org_contact_rec.application_id      := 660;

   -- { Start Before Calling hz api to create org contact

   HZ_PARTY_CONTACT_V2PUB.Create_Org_Contact (
                      p_org_contact_rec  => l_org_contact_rec,
                      x_party_id         => x_rel_party_id,
                      x_party_number     => x_rel_party_number,
                      x_party_rel_id     => x_party_relationship_id,
                      x_org_contact_id   => x_org_contact_id,
                      x_return_status    => l_return_status,
                      x_msg_count        => l_msg_count,
                      x_msg_data         => l_msg_data
                                          );
   -- End Call hz api to create org contact }
    -- Let us check the status of the call to hz api
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'RETURN STATS ' || L_RETURN_STATUS ) ;
    END IF;
    If l_return_status <> FND_API.G_RET_STS_SUCCESS Then
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'HZ CREATE_ORG_CONTACT API ERROR ' ) ;
      END IF;
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'RETURN ERROR MESSAGE COUNT FROM HZ ' || OE_MSG_PUB.GET ( P_MSG_INDEX => L_MSG_COUNT ) ) ;
      END IF;
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'RETURN ERROR MESSAGE FROM HZ ' || L_MSG_DATA ) ;
      END IF;
      x_return_status  := l_return_status;
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'EXITING IN CREATE_CONTACT PROCEDURE WITH ERROR' ) ;
      END IF;
      Update_Error_Flag(p_rowid  =>  contact_rec.rowid);
      oe_msg_pub.transfer_msg_stack;
      fnd_msg_pub.delete_msg;
      return;
    End If;

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'NEW REL PARTY ID FOR CONTACT =>' || X_REL_PARTY_ID ) ;
    END IF;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'NEW REL PARTY NUMBER CONTCT =>' || X_REL_PARTY_NUMBER ) ;
    END IF;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'NEW ORG CONTCT ID =>' || X_ORG_CONTACT_ID ) ;
    END IF;

   -- { Let us create the Contact's contact point EMAIL and PHONE
   If contact_rec.email_address is Not Null Then
      Create_Contact_Point(
                p_contact_point_type   => 'EMAIL',
                p_owner_table_id       => x_rel_party_id,
                p_email                => contact_rec.email_address,
                p_phone_area_code      => NULL,
                p_phone_number         => NULL,
                p_phone_extension      => NULL,
                p_phone_country_code   => NULL,
                x_return_status        => l_return_status,
                x_msg_count            => l_msg_count,
                x_msg_data             => l_msg_data
                );
   -- Let us check the status of the call to hz api
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'RETURN STATS ' || L_RETURN_STATUS ) ;
   END IF;
   If l_return_status <> FND_API.G_RET_STS_SUCCESS Then
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'RETURN ERROR MESSAGE FROM CONTACT EML '|| L_MSG_DATA ) ;
      END IF;
      x_return_status  := l_return_status;
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'EXITING PROCEDURE CREATE CONTACT WITH ERROR' ) ;
      END IF;
      return;
   Else
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'NEW EMAIL => ' || CONTACT_REC.EMAIL_ADDRESS ) ;
      END IF;
   End if;

   End If;
   -- End for create contact point EMAIL}

   -- { Start for create contact point PHONE
   If contact_rec.phone_number is Not Null Then
      Create_Contact_Point(
                p_contact_point_type   => 'PHONE',
                p_owner_table_id       => x_rel_party_id,
                p_email                => NULL,
                p_phone_area_code      => contact_rec.phone_area_code,
                p_phone_number         => contact_rec.phone_number,
                p_phone_extension      => contact_rec.phone_extension,
                p_phone_country_code   => contact_rec.phone_country_code,
                x_return_status        => l_return_status,
                x_msg_count            => l_msg_count,
                x_msg_data             => l_msg_data
                );
   -- Let us check the status of the call to hz api
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'RETURN STATS ' || L_RETURN_STATUS ) ;
   END IF;
   If l_return_status <> FND_API.G_RET_STS_SUCCESS Then
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'RETURN ERROR MESSAGE FROM CONTACT PH '|| L_MSG_DATA ) ;
      END IF;
      x_return_status  := l_return_status;
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'EXITING PROCEDURE CREATE CONTACT WITH ERROR' ) ;
      END IF;
      return;
   Else
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'NEW PHONE => ' || CONTACT_REC.PHONE_NUMBER ) ;
      END IF;
   End if;

   End If;
   -- End for create contact point PHONE}

   -- { Start create CONTACT role for the new contact

    l_cust_acct_roles_rec.party_id          := x_rel_party_id;
    l_cust_acct_roles_rec.cust_account_id   := l_customer_info_id;
    l_cust_acct_roles_rec.role_type         := 'CONTACT';
 -- l_cust_acct_roles_rec.begin_date        := sysdate;
    l_cust_acct_roles_rec.cust_acct_site_id := NULL;
    l_cust_acct_roles_rec.created_by_module := G_CREATED_BY_MODULE;
    l_cust_acct_roles_rec.application_id    := 660;

    HZ_CUST_ACCOUNT_ROLE_V2PUB.Create_Cust_Account_Role(
                p_cust_account_role_rec  => l_cust_acct_roles_rec,
                x_return_status          => l_return_status,
                x_msg_count              => l_msg_count,
                x_msg_data               => l_msg_data,
                x_cust_account_role_id   => x_cust_account_role_id
                );

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'RETURN STATS ' || L_RETURN_STATUS ) ;
   END IF;
   -- Let us check the status of the call to hz api
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'RETURN STATS ' || L_RETURN_STATUS ) ;
   END IF;
   If l_return_status <> FND_API.G_RET_STS_SUCCESS Then
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'HZ CREATE_CUST_ACCT_ROLES API ERROR ' ) ;
     END IF;
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'RETURN ERROR MESSAGE COUNT FROM HZ ' || OE_MSG_PUB.GET ( P_MSG_INDEX => L_MSG_COUNT ) ) ;
     END IF;
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'RETURN ERROR MESSAGE FROM HZ ' || L_MSG_DATA ) ;
     END IF;
     x_return_status  := l_return_status;
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'EXITING IN CREATE_CONTACT PROCEDURE WITH ERROR' ) ;
     END IF;
     Update_Error_Flag(p_rowid  =>  contact_rec.rowid);
     oe_msg_pub.transfer_msg_stack;
     fnd_msg_pub.delete_msg;
     return;
   End If;
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'NEW CUST ACC. ROLE => ' || X_CUST_ACCOUNT_ROLE_ID ) ;
   END IF;
   x_contact_id   := x_cust_account_role_id;

   If contact_rec.New_Contact_Id Is Null and
      l_type_of_contact Is Not Null Then
      Check_and_Create_Contact(p_contact_party_id => x_rel_party_id,
                               p_cust_acct_id     => l_customer_info_id,
                               p_usage_type       => l_type_of_contact,
                               x_contact_id       => l_ret_contact_id,
                               x_return_status    => l_return_status
                               );
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'NEW CONTACT ID IS THERE FOR SITE ' || L_TYPE_OF_CONTACT || ' , RETURING THE EXISTING VAL' ) ;
      END IF;
      x_contact_id                   := l_ret_Contact_id;
   End If;

   -- Let us select the Name to Pass back to calling api
   Select party_name
   Into   x_contact_name
   From   hz_parties
   Where  party_id = l_contact_party_id;
   -- End of select to get name

   -- Now Update the table with the new values

   Update  oe_customer_info_iface_all
   Set     New_Contact_Id        =  x_contact_id,
           New_Party_Id          =  x_rel_party_id,
           is_ship_to_address    =
              decode(l_type_of_contact,'SHIP_TO','Y',is_ship_to_address),
           is_bill_to_address    =
              decode(l_type_of_contact,'BILL_TO','Y',is_bill_to_address),
           is_deliver_to_address =
              decode(l_type_of_contact,'DELIVER_TO','Y',is_deliver_to_address)
   Where   rowid              =  contact_rec.rowid;

--   x_contact_id   := l_contact_party_id;
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'EXITING PROCEDURE CREATE CONTACT ' ) ;
   END IF;
   -- End CONTACT role for the new contact}

   Exception
   When Others Then
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'PROBLEM IN CALL TO CREATE_CONTACT. ABORT PROCESSING' ) ;
     END IF;
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'UNEXPECTED ERROR: '||SQLERRM ) ;
     END IF;
     fnd_message.set_name('ONT','ONT_OI_INL_API_FAILED');
     fnd_message.set_token('API_NAME', 'Create_Contact');
     oe_msg_pub.add;
     x_return_status            := FND_API.G_RET_STS_UNEXP_ERROR;
     Update_Error_Flag(p_rowid  =>  contact_rec.rowid);
     OE_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,'Unexpected error occured: ' || sqlerrm);
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'EXITING IN CREATE_CONTACT PROCEDURE WITH ERROR' ) ;
     END IF;
   End;
   -- End of Begin after Loop }

   End Loop;
   -- End Contact Loop }

   If l_no_record_exists Then
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'NO RECORD FOUND FOR THE PASSED REF , PLEASE CHECK DATA' ) ;
     END IF;
     fnd_message.set_name('ONT','ONT_OI_INL_NO_DATA');
     fnd_message.set_token('REFERENCE', p_customer_info_ref);
     oe_msg_pub.add;
     x_return_status            := FND_API.G_RET_STS_ERROR;
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'EXITING IN CREATE_CONTACT PROCEDURE WITH ERROR' ) ;
     END IF;
   End If;

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'EXITING PROCEDURE CREATE CONTACT' ) ;
   END IF;
 Exception
   When Others Then
     x_return_status            := FND_API.G_RET_STS_UNEXP_ERROR;
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'PROBLEM IN CALL TO CREATE_CONTACT. ABORT PROCESSING' ) ;
         oe_debug_pub.add(  'UNEXPECTED ERROR: '||SQLERRM ) ;
     END IF;
     fnd_message.set_name('ONT','ONT_OI_INL_API_FAILED');
     fnd_message.set_token('API_NAME', 'Create_Contact');
     oe_msg_pub.add;
     OE_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,'Unexpected error occured: ' || sqlerrm);
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'EXITING IN CREATE_CONTACT PROCEDURE WITH ERROR' ) ;
     END IF;
End Create_Contact;
-- End procedure Create Contact }


-- { Start of procedure Create_Customer_Info

PROCEDURE Create_Customer_Info(
          p_customer_info_ref       IN     Varchar2,
          p_customer_info_type_code IN     Varchar2,
          p_usage                   IN     Varchar2,
          p_orig_sys_document_ref   IN     Varchar2,
          p_orig_sys_line_ref       IN     Varchar2,
          p_order_source_id         IN     Number,
          p_org_id                  IN     Number,
          x_customer_info_id        OUT NOCOPY /* file.sql.39 change */    Number,
          x_customer_info_number    OUT NOCOPY /* file.sql.39 change */    Varchar2,
          x_return_status           OUT NOCOPY /* file.sql.39 change */    Varchar2
          )
Is
   l_customer_info_ref       Varchar2(50)      := p_customer_info_ref;
   l_customer_info_id        Number;
   l_customer_info_number    Varchar2(30);
   l_customer_party_id       Number;
   l_contact_id              Number;
   l_contact_name            Varchar2(360);
   l_type_of_contact         Varchar2(10)      := p_usage;
   l_type_of_address         Varchar2(10)      := p_usage;
   l_return_status           Varchar2(1)       := FND_API.G_RET_STS_SUCCESS;
   l_usage_site_id           Number;
   l_ship_to_org_id          Number;
   l_bill_to_org_id          Number;
   l_deliver_to_org_id       Number;
   l_existing_value          Varchar2(1)       := 'N';
   l_orig_sys_line_ref       Varchar2(50)      := p_orig_sys_line_ref;

   -- Following cursor will fetch the data for the passed ref and type --
   -- information. For the address creation.                           --
   -- {
   Cursor l_address_info_cur Is
          Select country,
                 address1,
                 address2,
                 address3,
                 address4,
                 city,
                 postal_code,
                 state,
                 province,
                 county,
                 is_ship_to_address,
                 is_bill_to_address,
                 is_deliver_to_address,
                 attribute_category,
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
                 attribute11,
                 attribute12,
                 attribute13,
                 attribute14,
                 attribute15,
                 attribute16,
                 attribute17,
                 attribute18,
                 attribute19,
                 attribute20,
                 global_attribute_category,
                 global_attribute1,
                 global_attribute2,
                 global_attribute3,
                 global_attribute4,
                 global_attribute5,
                 global_attribute6,
                 global_attribute7,
                 global_attribute8,
                 global_attribute9,
                 global_attribute10,
                 global_attribute11,
                 global_attribute12,
                 global_attribute13,
                 global_attribute14,
                 global_attribute15,
                 global_attribute16,
                 global_attribute17,
                 global_attribute18,
                 global_attribute19,
                 global_attribute20
           from  oe_customer_info_iface_all
           where customer_info_ref = l_customer_info_ref
           and   customer_info_type_code     = 'ADDRESS';

   -- End of Cursor definition for l_address_info_cur }

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
Begin

   x_return_status     := FND_API.G_RET_STS_SUCCESS;
   --   Initialize the system paramter and profile option used
   --   later in processing
   If G_INITIALIZED = FND_API.G_FALSE Then
      Initialize_Global(l_return_status);
   End If;

   --   Check for the type of entry need to be created based on the
   --   paramenter passed p_customer_info_type_code 'ACCOUNT', 'CONTACT' or
   --   'ADDRESS'
   --   Depending on that call the respective api/processing...

   -- Null p_orig_sys_line_ref if add ct info is called for Header
   If l_orig_sys_line_ref = FND_API.G_MISS_CHAR Then
     l_orig_sys_line_ref := Null;
   End If;

   -- { Start of if for p_customer_info_type_code
   if p_customer_info_type_code = 'ACCOUNT' then
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'BEFORE CALLING CREATE ACCOUNT PROCEDURE' ) ;
      END IF;
      -- call Create_Account api
      Create_Account( p_customer_info_ref    => p_customer_info_ref,
                      p_orig_sys_document_ref => p_orig_sys_document_ref,
                      p_orig_sys_line_ref    => l_orig_sys_line_ref,
                      p_order_source_id      => p_order_source_id,
                      x_cust_account_id      => l_customer_info_id,
                      x_cust_account_number  => l_customer_info_number,
                      x_cust_party_id        => l_customer_party_id,
                      x_existing_value       => l_existing_value,
                      x_return_status        => l_return_status
                    );

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'AFTER CALLING CREATE ACCOUNT PROCEDURE' ) ;
      END IF;

      -- Check for the return status of the api
      -- to return the proper information to the called program.
      if l_return_status <> FND_API.G_RET_STS_SUCCESS then
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'RETURN STATUS IS NOT SUCCESS , AFTER CREATE ACC.' ) ;
        END IF;
        x_return_status := l_return_status;
      else
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'RETURN STATUS IS SUCCESS , AFTER CREATE ACCOUNT' ) ;
        END IF;
        x_customer_info_id          := l_customer_info_id;
        x_customer_info_number      := l_customer_info_number;
        x_return_status             := l_return_status;
      end if;

   elsif p_customer_info_type_code = 'CONTACT' then
      -- call Create_Contact api
         Create_Contact(
                           p_customer_info_ref    => p_customer_info_ref,
                           p_cust_account_id      => l_customer_info_id,
                           p_cust_account_number  => l_customer_info_number,
                           p_type_of_contact      => l_type_of_contact,
                           p_orig_sys_document_ref => p_orig_sys_document_ref,
                           p_orig_sys_line_ref    => l_orig_sys_line_ref,
                           p_order_source_id      => p_order_source_id,
                           x_contact_id           => l_contact_id,
                           x_contact_name         => l_contact_name,
                           x_return_status        => l_return_status
                         );

      -- Check for the return status of the api
      -- to return the proper information to the called program.
      if l_return_status <> FND_API.G_RET_STS_SUCCESS then
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'RETURN STATUS IS NOT SUCCESS , AFTER CREATE CONT.' ) ;
        END IF;
        x_return_status := l_return_status;
      else
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'RETURN STATUS IS SUCCESS , AFTER CREATE ACCOUNT' ) ;
        END IF;
        x_customer_info_id          := l_contact_id;
        x_return_status             := l_return_status;
      end if;
   elsif p_customer_info_type_code = 'ADDRESS' then
      -- call Create_Address api
      Create_Address(p_customer_info_ref    => p_customer_info_ref,
                     p_type_of_address      => l_type_of_address,
                     p_orig_sys_document_ref => p_orig_sys_document_ref,
                     p_orig_sys_line_ref    => l_orig_sys_line_ref,
                     p_order_source_id      => p_order_source_id,
                     p_org_id               => p_org_id,
                     x_usage_site_id        => l_usage_site_id,
                     x_return_status        => l_return_status
                    );
      -- Create_Address;
      -- Check for the return status of the api
      -- to return the proper information to the called program.
     If l_return_status <> FND_API.G_RET_STS_SUCCESS Then
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'RETURN STATUS IS NOT SUCCESS , AFTER CREATE ADDRESS.' ) ;
        END IF;
        x_return_status := l_return_status;
     Else
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'RETURN STATUS IS SUCCESS , AFTER CREATE ADDRESS' ) ;
        END IF;
        -- { Start If
        If l_type_of_address       = 'SHIP_TO' Then
           x_customer_info_id      := l_usage_site_id;
        Elsif l_type_of_address    = 'BILL_TO' Then
           x_customer_info_id      := l_usage_site_id;
        Elsif l_type_of_address    = 'DELIVER_TO' Then
           x_customer_info_id      := l_usage_site_id;
        End If;
        -- End If}
        x_return_status           := l_return_status;
      End If;
   else
      NULL;
      -- Wrong type of information passed
      -- set the error message stack with the error message and
      -- return error to calling api.
   end if;
   -- End of if for p_customer_info_type_code }
Exception
   When Others Then
     x_return_status            := FND_API.G_RET_STS_UNEXP_ERROR;
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'PROBLEM IN CALL TO CREATE_CUSTOMER_INFO. ABORT PROCESSING' ) ;
     END IF;
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'UNEXPECTED ERROR: '||SQLERRM ) ;
     END IF;
     fnd_message.set_name('ONT','ONT_OI_INL_API_FAILED');
     fnd_message.set_token('API_NAME', 'Create_Customer_Info');
     oe_msg_pub.add;
     OE_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,'Unexpected error occured: ' || sqlerrm);
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'EXITING IN CREATE_CUSTOMER_INFO PROCEDURE WITH ERROR' ) ;
     END IF;

End Create_Customer_Info;

-- End of procedure Create_Customer_Info }

Procedure Delete_Customer_Info(
           p_header_customer_rec  In  OE_ORDER_IMPORT_SPECIFIC_PVT.Customer_Rec_Type,
           p_line_customer_tbl    In OE_ORDER_IMPORT_SPECIFIC_PVT.Customer_Tbl_Type)
Is

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
Begin

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'INSIDE DELETE_CUSTOMER_INFO' ) ;
  END IF;

  If p_header_customer_rec.Orig_Sys_Customer_Ref IS NOT NULL Then
    Delete
      From oe_customer_info_iface_all a
     Where customer_info_ref = p_header_customer_rec.Orig_Sys_Customer_Ref
       And customer_info_ref Not In (Select Orig_Sys_Customer_Ref
                                       From Oe_Headers_Iface_All b
                                      Where b.Orig_Sys_Customer_Ref = a.customer_info_ref);
  End If;

  If p_header_customer_rec.Sold_To_Contact_Ref IS NOT NULL Then

    Delete
        From oe_customer_info_iface_all a
        Where customer_info_ref = (Select Parent_Customer_Ref from oe_customer_info_iface_all
                                  where customer_info_ref = p_header_customer_rec.Sold_To_Contact_Ref
                                  and  customer_info_type_code     = 'CONTACT')
         And customer_info_ref Not In (Select Orig_Sys_Customer_Ref
                                         From Oe_Headers_Iface_All b
                                        Where b.Orig_Sys_Customer_Ref = a.customer_info_ref);

    Delete
      From oe_customer_info_iface_all a
     Where customer_info_ref = p_header_customer_rec.Sold_To_Contact_Ref
       And customer_info_ref Not In (Select Sold_To_Contact_Ref
                                       From Oe_Headers_Iface_All b
                                      Where b.Sold_To_Contact_Ref = a.customer_info_ref);
  End If;

  If p_header_customer_rec.Orig_Ship_Address_Ref IS NOT NULL Then


       Delete
        From oe_customer_info_iface_all a
        Where customer_info_ref = (Select Parent_Customer_Ref from oe_customer_info_iface_all
                                  where customer_info_ref = p_header_customer_rec.Orig_Ship_Address_Ref
                                  and   customer_info_type_code     = 'ADDRESS' )
         And customer_info_ref Not In (Select Orig_Sys_Customer_Ref
                                         From Oe_Headers_Iface_All b
                                        Where b.Orig_Sys_Customer_Ref = a.customer_info_ref);

    Delete
      From oe_customer_info_iface_all a
     Where customer_info_ref = p_header_customer_rec.Orig_Ship_Address_Ref
       And customer_info_ref Not In ((Select Orig_Ship_Address_Ref
                                        From Oe_Headers_Iface_All b
                                       Where b.Orig_Ship_Address_Ref = a.customer_info_ref)
				      UNION ALL
                                     (Select Orig_Ship_Address_Ref
                                        From Oe_Lines_Iface_All c
                                       Where c.Orig_Ship_Address_Ref = a.customer_info_ref));
  End If;

  If p_header_customer_rec.Orig_Bill_Address_Ref IS NOT NULL Then


       Delete
        From oe_customer_info_iface_all a
        Where customer_info_ref = (Select Parent_Customer_Ref from oe_customer_info_iface_all
                                  where customer_info_ref = p_header_customer_rec.Orig_Bill_Address_Ref
                                  and   customer_info_type_code     = 'ADDRESS')
         And customer_info_ref Not In (Select Orig_Sys_Customer_Ref
                                         From Oe_Headers_Iface_All b
                                        Where b.Orig_Sys_Customer_Ref = a.customer_info_ref);



    Delete
      From oe_customer_info_iface_all a
     Where customer_info_ref = p_header_customer_rec.Orig_Bill_Address_Ref
       And customer_info_ref Not In ((Select Orig_Bill_Address_Ref
                                       From Oe_Headers_Iface_All b
                                      Where b.Orig_Bill_Address_Ref = a.customer_info_ref)
				      UNION ALL
                                     (Select Orig_Bill_Address_Ref
                                        From Oe_Lines_Iface_All c
                                       Where c.Orig_Bill_Address_Ref = a.customer_info_ref));
  End If;

  If p_header_customer_rec.Orig_Deliver_Address_Ref IS NOT NULL Then


       Delete
        From oe_customer_info_iface_all a
        Where customer_info_ref = (Select Parent_Customer_Ref from oe_customer_info_iface_all
                                  where customer_info_ref = p_header_customer_rec.Orig_Deliver_Address_Ref
                                  and   customer_info_type_code     = 'ADDRESS')
         And customer_info_ref Not In (Select Orig_Sys_Customer_Ref
                                         From Oe_Headers_Iface_All b
                                        Where b.Orig_Sys_Customer_Ref = a.customer_info_ref);

    Delete
      From oe_customer_info_iface_all a
     Where customer_info_ref = p_header_customer_rec.Orig_Deliver_Address_Ref
       And customer_info_ref Not In ((Select Orig_Deliver_Address_Ref
                                       From Oe_Headers_Iface_All b
                                      Where b.Orig_Deliver_Address_Ref = a.customer_info_ref)
				      UNION ALL
                                     (Select Orig_Deliver_Address_Ref
                                        From Oe_Lines_Iface_All c
                                       Where c.Orig_Deliver_Address_Ref = a.customer_info_ref));
  End If;

  If p_header_customer_rec.Ship_To_Contact_Ref IS NOT NULL Then

       Delete
        From oe_customer_info_iface_all a
        Where customer_info_ref = (Select Parent_Customer_Ref from oe_customer_info_iface_all
                                  where customer_info_ref = p_header_customer_rec.Ship_To_Contact_Ref
                                  and   customer_info_type_code     = 'CONTACT')
         And customer_info_ref Not In (Select Orig_Sys_Customer_Ref
                                         From Oe_Headers_Iface_All b
                                        Where b.Orig_Sys_Customer_Ref = a.customer_info_ref);



    Delete
      From oe_customer_info_iface_all a
     Where customer_info_ref = p_header_customer_rec.Ship_To_Contact_Ref
       And customer_info_ref Not In ((Select Ship_To_Contact_Ref
                                       From Oe_Headers_Iface_All b
                                      Where b.Ship_To_Contact_Ref = a.customer_info_ref)
				      UNION ALL
                                     (Select Ship_To_Contact_Ref
                                        From Oe_Lines_Iface_All c
                                       Where c.Ship_To_Contact_Ref = a.customer_info_ref));
  End If;

  If p_header_customer_rec.Bill_To_Contact_Ref IS NOT NULL Then

       Delete
        From oe_customer_info_iface_all a
        Where customer_info_ref = (Select Parent_Customer_Ref from oe_customer_info_iface_all
                                  where customer_info_ref = p_header_customer_rec.Bill_To_Contact_Ref
                                  and   customer_info_type_code     = 'CONTACT')
         And customer_info_ref Not In (Select Orig_Sys_Customer_Ref
                                         From Oe_Headers_Iface_All b
                                        Where b.Orig_Sys_Customer_Ref = a.customer_info_ref);


    Delete
      From oe_customer_info_iface_all a
     Where customer_info_ref = p_header_customer_rec.Bill_To_Contact_Ref
       And customer_info_ref Not In ((Select Bill_To_Contact_Ref
                                       From Oe_Headers_Iface_All b
                                      Where b.Bill_To_Contact_Ref = a.customer_info_ref)
				      UNION ALL
                                     (Select Bill_To_Contact_Ref
                                        From Oe_Lines_Iface_All c
                                       Where c.Bill_To_Contact_Ref = a.customer_info_ref));
  End If;

  If p_header_customer_rec.Deliver_To_Contact_Ref IS NOT NULL Then


       Delete
        From oe_customer_info_iface_all a
        Where customer_info_ref = (Select Parent_Customer_Ref from oe_customer_info_iface_all
                                  where customer_info_ref = p_header_customer_rec.Deliver_To_Contact_Ref
                                  and   customer_info_type_code     = 'CONTACT')
         And customer_info_ref Not In (Select Orig_Sys_Customer_Ref
                                         From Oe_Headers_Iface_All b
                                        Where b.Orig_Sys_Customer_Ref = a.customer_info_ref);


    Delete
      From oe_customer_info_iface_all a
     Where customer_info_ref = p_header_customer_rec.Deliver_To_Contact_Ref
       And customer_info_ref Not In ((Select Deliver_To_Contact_Ref
                                       From Oe_Headers_Iface_All b
                                      Where b.Deliver_To_Contact_Ref = a.customer_info_ref)
				      UNION ALL
                                     (Select Deliver_To_Contact_Ref
                                        From Oe_Lines_Iface_All c
                                       Where c.Deliver_To_Contact_Ref = a.customer_info_ref));
  End If;

  For i In 1..p_line_customer_tbl.COUNT Loop
    If p_line_customer_tbl(i).Orig_Ship_Address_Ref IS NOT NULL Then

       Delete
        From oe_customer_info_iface_all a
        Where customer_info_ref = (Select Parent_Customer_Ref from oe_customer_info_iface_all
                                  where customer_info_ref = p_line_customer_tbl(i).Orig_Ship_Address_Ref
                                  and   customer_info_type_code     = 'ADDRESS' )
         And customer_info_ref Not In (Select Orig_Sys_Customer_Ref
                                         From Oe_Headers_Iface_All b
                                        Where b.Orig_Sys_Customer_Ref = a.customer_info_ref);


      Delete
        From oe_customer_info_iface_all a
       Where customer_info_ref = p_line_customer_tbl(i).Orig_Ship_Address_Ref
         And customer_info_ref Not In ((Select Orig_Ship_Address_Ref
                                         From Oe_Lines_Iface_All b
                                        Where b.Orig_Ship_Address_Ref = a.customer_info_ref)
					UNION ALL
                                       (Select Orig_Ship_Address_Ref
                                         From Oe_Headers_Iface_All c
                                        Where c.Orig_Ship_Address_Ref = a.customer_info_ref));
    End If;

    If p_line_customer_tbl(i).Orig_Bill_Address_Ref IS NOT NULL Then

       Delete
        From oe_customer_info_iface_all a
        Where customer_info_ref = (Select Parent_Customer_Ref from oe_customer_info_iface_all
                                  where customer_info_ref = p_line_customer_tbl(i).Orig_Bill_Address_Ref
                                  and   customer_info_type_code     = 'ADDRESS' )
         And customer_info_ref Not In (Select Orig_Sys_Customer_Ref
                                         From Oe_Headers_Iface_All b
                                        Where b.Orig_Sys_Customer_Ref = a.customer_info_ref);


      Delete
        From oe_customer_info_iface_all a
       Where customer_info_ref = p_line_customer_tbl(i).Orig_Bill_Address_Ref
         And customer_info_ref Not In ((Select Orig_Bill_Address_Ref
                                         From Oe_Lines_Iface_All b
                                        Where b.Orig_Bill_Address_Ref = a.customer_info_ref)
					UNION ALL
                                       (Select Orig_Bill_Address_Ref
                                         From Oe_Headers_Iface_All c
                                        Where c.Orig_Bill_Address_Ref = a.customer_info_ref));
    End If;

    If p_line_customer_tbl(i).Orig_Deliver_Address_Ref IS NOT NULL Then

       Delete
        From oe_customer_info_iface_all a
        Where customer_info_ref = (Select Parent_Customer_Ref from oe_customer_info_iface_all
                                  where customer_info_ref = p_line_customer_tbl(i).Orig_Deliver_Address_Ref
                                  and   customer_info_type_code     = 'ADDRESS')
         And customer_info_ref Not In (Select Orig_Sys_Customer_Ref
                                         From Oe_Headers_Iface_All b
                                        Where b.Orig_Sys_Customer_Ref = a.customer_info_ref);


      Delete
        From oe_customer_info_iface_all a
       Where customer_info_ref = p_line_customer_tbl(i).Orig_Deliver_Address_Ref
         And customer_info_ref Not In ((Select Orig_Deliver_Address_Ref
                                         From Oe_Lines_Iface_All b
                                        Where b.Orig_Deliver_Address_Ref = a.customer_info_ref)
					UNION ALL
                                       (Select Orig_Deliver_Address_Ref
                                         From Oe_Headers_Iface_All c
                                        Where c.Orig_Deliver_Address_Ref = a.customer_info_ref));
    End If;

    If p_line_customer_tbl(i).Ship_To_Contact_Ref IS NOT NULL Then


       Delete
        From oe_customer_info_iface_all a
        Where customer_info_ref = (Select Parent_Customer_Ref from oe_customer_info_iface_all
                                  where customer_info_ref = p_line_customer_tbl(i).Ship_To_Contact_Ref
                                  and   customer_info_type_code     = 'CONTACT')
         And customer_info_ref Not In (Select Orig_Sys_Customer_Ref
                                         From Oe_Headers_Iface_All b
                                        Where b.Orig_Sys_Customer_Ref = a.customer_info_ref);


      Delete
        From oe_customer_info_iface_all a
       Where customer_info_ref = p_line_customer_tbl(i).Ship_To_Contact_Ref
         And customer_info_ref Not In ((Select Ship_To_Contact_Ref
                                         From Oe_Lines_Iface_All b
                                        Where b.Ship_To_Contact_Ref = a.customer_info_ref)
					UNION ALL
                                       (Select Ship_To_Contact_Ref
                                         From Oe_Headers_Iface_All c
                                        Where c.Ship_To_Contact_Ref = a.customer_info_ref));
    End If;

    If p_line_customer_tbl(i).Bill_To_Contact_Ref IS NOT NULL Then


       Delete
        From oe_customer_info_iface_all a
        Where customer_info_ref = (Select Parent_Customer_Ref from oe_customer_info_iface_all
                                  where customer_info_ref = p_line_customer_tbl(i).Bill_To_Contact_Ref
                                  and   customer_info_type_code     = 'CONTACT')
         And customer_info_ref Not In (Select Orig_Sys_Customer_Ref
                                         From Oe_Headers_Iface_All b
                                        Where b.Orig_Sys_Customer_Ref = a.customer_info_ref);


      Delete
        From oe_customer_info_iface_all a
       Where customer_info_ref = p_line_customer_tbl(i).Bill_To_Contact_Ref
         And customer_info_ref Not In ((Select Bill_To_Contact_Ref
                                         From Oe_Lines_Iface_All b
                                        Where b.Bill_To_Contact_Ref = a.customer_info_ref)
					UNION ALL
                                       (Select Bill_To_Contact_Ref
                                         From Oe_Headers_Iface_All c
                                        Where c.Bill_To_Contact_Ref = a.customer_info_ref));
    End If;

    If p_line_customer_tbl(i).Deliver_To_Contact_Ref IS NOT NULL Then

       Delete
        From oe_customer_info_iface_all a
        Where customer_info_ref = (Select Parent_Customer_Ref from oe_customer_info_iface_all
                                  where customer_info_ref = p_line_customer_tbl(i).Deliver_To_Contact_Ref
                                  and   customer_info_type_code     = 'CONTACT')
         And customer_info_ref Not In (Select Orig_Sys_Customer_Ref
                                         From Oe_Headers_Iface_All b
                                        Where b.Orig_Sys_Customer_Ref = a.customer_info_ref);



      Delete
        From oe_customer_info_iface_all a
       Where customer_info_ref = p_line_customer_tbl(i).Deliver_To_Contact_Ref
         And customer_info_ref Not In ((Select Deliver_To_Contact_Ref
                                         From Oe_Lines_Iface_All b
                                        Where b.Deliver_To_Contact_Ref = a.customer_info_ref)
					UNION ALL
                                       (Select Deliver_To_Contact_Ref
                                         From Oe_Headers_Iface_All c
                                        Where c.Deliver_To_Contact_Ref = a.customer_info_ref));
    End If;

  End Loop;
Exception
   When Others Then
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'PROBLEM IN CALL TO DELETE_CUSTOMER_INFO. ABORT PROCESSING' ) ;
         oe_debug_pub.add(  'UNEXPECTED ERROR: '||SQLERRM ) ;
     END IF;
     fnd_message.set_name('ONT','ONT_OI_INL_API_FAILED');
     fnd_message.set_token('API_NAME', 'Delete_Customer_Info');
     oe_msg_pub.add;
     OE_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,'Unexpected error occured: ' || sqlerrm);
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'EXITING IN DELETE_CUSTOMER_INFO PROCEDURE WITH ERROR' ) ;
     END IF;
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
End Delete_Customer_Info;

END OE_INLINE_CUSTOMER_PUB;

/
