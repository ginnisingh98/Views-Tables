--------------------------------------------------------
--  DDL for Package Body IBE_ORD_ONECLICK_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBE_ORD_ONECLICK_PVT" AS
/* $Header: IBEVO1CB.pls 120.10.12010000.5 2014/02/11 10:13:00 amaheshw ship $ */

G_PKG_NAME CONSTANT VARCHAR2(30) := 'ibe_ord_oneclick_pvt';
l_true VARCHAR2(1) := FND_API.G_TRUE;

/* Local function to Get Credit Card Type Given The Number
   hekkiral - 21-DEC-2000                                   */

/*function Get_Credit_Card_Type(
    p_Credit_Card_Number NUMBER
) RETURN VARCHAR2;*/
/*-----------------------------------------------------------------------------

        Get_Settings
         - retrives the foreign keys from IBE_ORD_ONECLICK
         - retrives user's main email address associated with partyid in HZ_PARTIES
         - validates the address usage via calls to IBE_ADDRESS_V2PVT.valid_usages

     Key Input: party id and account id

     NOTE: this api can be TRANSACTIONAL in that if an address is not valid,
     it will update the oneclick settings row to be off and null for that address usage.

 ------------------------------------------------------------------------------
*/
procedure Get_Settings(
    p_api_version      IN     NUMBER,
    p_init_msg_list    IN    VARCHAR2 := FND_API.g_false,
    p_commit           IN    VARCHAR2 := FND_API.g_false,
    p_validation_level IN      NUMBER    := FND_API.g_valid_level_full,
    x_return_status    OUT NOCOPY    VARCHAR2,
    x_msg_count        OUT NOCOPY    NUMBER,
    x_msg_data         OUT NOCOPY    VARCHAR2,

    p_party_id         IN     NUMBER := NULL,
    p_acct_id          IN     NUMBER := NULL,

    x_OBJECT_VERSION_NUMBER    OUT NOCOPY    NUMBER,
    x_ONECLICK_ID              OUT NOCOPY    NUMBER,
    x_ENABLED_FLAG             OUT NOCOPY    VARCHAR2,
    x_FREIGHT_CODE             OUT NOCOPY    VARCHAR2,
    x_PAYMENT_ID               OUT NOCOPY    NUMBER,
    x_BILL_PTYSITE_ID          OUT NOCOPY    NUMBER,
    x_SHIP_PTYSITE_ID          OUT NOCOPY    NUMBER,
    x_LAST_UPDATE_DATE         OUT NOCOPY    DATE,
    x_EMAIL_ADDRESS            OUT NOCOPY    VARCHAR2
) is
    l_api_name    CONSTANT VARCHAR2(30)    := 'Get_Settings';
    l_api_version    CONSTANT NUMBER        := 1.0;

    CURSOR c_settings(c_party_id NUMBER, c_acct_id NUMBER) IS
    SELECT     object_version_number,
        ord_oneclick_id,
        enabled_flag,
        freight_code,
        payment_id,
        bill_to_pty_site_id,
        ship_to_pty_site_id,
        last_update_date
    FROM IBE_ORD_ONECLICK
    WHERE
        party_id = c_party_id and
        cust_account_id = c_acct_id;

    Cursor c_email_addr (owner_id NUMBER)
    IS select email_address
    from HZ_CONTACT_POINTS
    where
        contact_point_type = 'EMAIL' and
        owner_table_name = 'HZ_PARTIES' and
        status = 'A' and
        owner_table_id = owner_id and primary_flag = 'Y';

    l_usage_codes     JTF_VARCHAR2_TABLE_100 ;
    l_return_codes     JTF_VARCHAR2_TABLE_100 ;
    l_org_id    NUMBER;
    l_save_flag     VARCHAR2(1) := 'N';

    l_cvv2_setup VARCHAR2(1);
    l_statement_address_setup VARCHAR2(1);

begin
    --ibe_util.enable_debug;
    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       ibe_util.debug('Starting ibe_ord_oneclick_pvt.Get_Settings ' || to_char(sysdate,'DD-MON-YYYY:HH24:MI:SS'));
    END IF;
    SAVEPOINT     Get_Settings_Pvt;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (     l_api_version            ,
                                         p_api_version            ,
                                       l_api_name             ,
                                        G_PKG_NAME )
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- Initialize API rturn status to success
    x_return_status := FND_API.g_ret_sts_success;

IF (IBE_UTIL.G_DEBUGON = l_true) THEN
   ibe_util.debug('------- INPUT: -----------------');
   ibe_util.debug('p_party_id       :'||p_party_id);
   ibe_util.debug('p_acct_id        :'||p_acct_id);
END IF;

 IBE_PAYMENT_INT_PVT.check_Payment_channel_setups(
            p_api_version             => p_api_version
           ,p_init_msg_list           => p_init_msg_list
           ,p_commit                  => p_commit
           ,x_cvv2_setup              => l_cvv2_setup
           ,x_statement_address_setup => l_statement_address_setup
           ,x_return_status           => x_return_status
           ,x_msg_count               => x_msg_count
           ,x_msg_data                => x_msg_data);

      if x_return_status <> FND_API.g_ret_sts_success then
        IF (IBE_UTIL.G_DEBUGON = l_true) THEN
          ibe_util.debug('ibe_ord_oneclick_pvt.Get_Settings - IBY_PAYMENT_INT_PVT.check_Payment_channel_setups ' || x_return_status);
        END IF;
        if x_return_status = FND_API.G_RET_STS_ERROR then
          RAISE FND_API.G_EXC_ERROR;
        elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        end if;
      end if;

/*Changes for credit card consolidation. If Cvv2 is mandatory then xpress checkout should be disabled.
User can't enter cvv2 number during express checkout if cvv2 is mandatory.*/
IF (l_cvv2_setup = FND_API.G_TRUE) THEN
  x_ENABLED_FLAG := 'N';
ELSE

        OPEN c_settings(p_party_id, p_acct_id);
    FETCH c_settings
    INTO
        x_OBJECT_VERSION_NUMBER,
        x_ONECLICK_ID,
        x_ENABLED_FLAG,
        x_FREIGHT_CODE,
        x_PAYMENT_ID,
        x_BILL_PTYSITE_ID,
        x_SHIP_PTYSITE_ID,
        x_LAST_UPDATE_DATE;
    if c_settings%NOTFOUND then
        x_ONECLICK_ID := FND_API.g_miss_num;
    end if;
        CLOSE c_settings;

IF (IBE_UTIL.G_DEBUGON = l_true) THEN
   ibe_util.debug('------- Retrieved From TABLES: -----------------');
   ibe_util.debug('x_OBJECT_VERSION_NUMBER :'||x_OBJECT_VERSION_NUMBER);
   ibe_util.debug('x_ONECLICK_ID           :'||x_ONECLICK_ID);
   ibe_util.debug('x_ENABLED_FLAG          :'||x_ENABLED_FLAG);
   ibe_util.debug('x_FREIGHT_CODE          :'||x_FREIGHT_CODE);
   ibe_util.debug('x_PAYMENT_ID            :'||x_PAYMENT_ID);
   ibe_util.debug('x_BILL_PTYSITE_ID       :'||x_BILL_PTYSITE_ID);
   ibe_util.debug('x_SHIP_PTYSITE_ID       :'||x_SHIP_PTYSITE_ID);
   ibe_util.debug('x_LAST_UPDATE_DATE      :'||to_char(x_LAST_UPDATE_DATE,'DD-MON-YYYY:HH24:MI:SS'));
END IF;

    open c_email_addr(p_party_id);
    fetch c_email_addr into x_EMAIL_ADDRESS;
    close c_email_addr;

IF (IBE_UTIL.G_DEBUGON = l_true) THEN
   ibe_util.debug('x_EMAIL_ADDRESS         :'||x_EMAIL_ADDRESS);
END IF;
    l_org_id := MO_GLOBAL.get_current_org_id();
-- in case of a single org env the feature of addr usages is unsupported
if (l_org_id is not null and l_org_id <> 0) then
    l_usage_codes      := JTF_VARCHAR2_TABLE_100(1);
    l_return_codes      := JTF_VARCHAR2_TABLE_100(1);

    if (x_BILL_PTYSITE_ID is not null) then
        -- call address validation apis; if either is not valid turn settings off
        l_usage_codes(1) := 'BILL_TO_COUNTRY';
        IF (IBE_UTIL.G_DEBUGON = l_true) THEN
           ibe_util.debug('Calling IBE_ADDRESS_V2PVT.valid_usages ' || to_char(sysdate,'DD-MON-YYYY:HH24:MI:SS'));
           ibe_util.debug('    party_site_id:     ' || x_BILL_PTYSITE_ID);
           ibe_util.debug('    operating_unit_id: ' || l_org_id);
           ibe_util.debug('    usage_code:        ' || l_usage_codes(1));
        END IF;
        IBE_ADDRESS_V2PVT.valid_usages (
            p_api_version        => l_api_version,
            p_init_msg_list      => FND_API.G_FALSE,
            p_party_site_id      => x_BILL_PTYSITE_ID,
            p_operating_unit_id  => l_org_id,
            p_usage_codes        => l_usage_codes,
            x_return_codes       => l_return_codes,
            x_return_status      => x_return_status,
            x_msg_count          => x_msg_count,
            x_msg_data           => x_msg_data );
        --ibe_util.enable_debug;
        IF (IBE_UTIL.G_DEBUGON = l_true) THEN
           ibe_util.debug('Back from IBE_ADDRESS_V2PVT.valid_usages ' || to_char(sysdate,'DD-MON-YYYY:HH24:MI:SS'));
           ibe_util.debug('    return_code:     ' || l_return_codes(1));
        END IF;

        if x_return_status <> FND_API.g_ret_sts_success then
            IF (IBE_UTIL.G_DEBUGON = l_true) THEN
               ibe_util.debug('ibe_ord_oneclick_pvt.Get_Settings - non success status from IBE_ADDRESS_V2PVT.valid_usages: ' || x_return_status);
            END IF;
            FND_MESSAGE.SET_NAME('IBE','IBE_EXPR_PLSQL_API_ERROR');
                      FND_MESSAGE.SET_TOKEN ( '0' , 'Get_Settings - IBE_ADDRESS_V2PVT.valid_usages' );
                      FND_MESSAGE.SET_TOKEN ( '1' , x_return_status );
            FND_MSG_PUB.Add;
            if x_return_status = FND_API.G_RET_STS_ERROR then
                RAISE FND_API.G_EXC_ERROR;
            elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            end if;
        end if;

        if (l_return_codes(1) <> FND_API.G_RET_STS_SUCCESS) then
            x_BILL_PTYSITE_ID := null;
            l_save_flag := 'Y';
        END IF;
    end if;

    if (x_SHIP_PTYSITE_ID is not null) then
        -- call address validation apis; if either is not valid turn settings off
        l_usage_codes(1) := 'SHIP_TO_COUNTRY';
        IF (IBE_UTIL.G_DEBUGON = l_true) THEN
           ibe_util.debug('Calling IBE_ADDRESS_V2PVT.valid_usages ' || to_char(sysdate,'DD-MON-YYYY:HH24:MI:SS'));
           ibe_util.debug('    party_site_id:     ' || x_SHIP_PTYSITE_ID);
           ibe_util.debug('    operating_unit_id: ' || l_org_id);
           ibe_util.debug('    usage_code:        ' || l_usage_codes(1));
        END IF;
        IBE_ADDRESS_V2PVT.valid_usages (
            p_api_version        => l_api_version,
            p_init_msg_list      => FND_API.G_FALSE,
            p_party_site_id      => x_SHIP_PTYSITE_ID,
            p_operating_unit_id  => l_org_id,
            p_usage_codes        => l_usage_codes,
            x_return_codes       => l_return_codes,
            x_return_status      => x_return_status,
            x_msg_count          => x_msg_count,
            x_msg_data           => x_msg_data );
        --ibe_util.enable_debug;
        IF (IBE_UTIL.G_DEBUGON = l_true) THEN
           ibe_util.debug('Back from IBE_ADDRESS_V2PVT.valid_usages ' || to_char(sysdate,'DD-MON-YYYY:HH24:MI:SS'));
           ibe_util.debug('    return_code:     ' || l_return_codes(1));
        END IF;

        if x_return_status <> FND_API.g_ret_sts_success then
            IF (IBE_UTIL.G_DEBUGON = l_true) THEN
               ibe_util.debug('ibe_ord_oneclick_pvt.Get_Settings - non success status from IBE_ADDRESS_V2PVT.valid_usages: ' || x_return_status);
            END IF;
            FND_MESSAGE.SET_NAME('IBE','IBE_EXPR_PLSQL_API_ERROR');
                      FND_MESSAGE.SET_TOKEN ( '0' , 'Get_Settings - IBE_ADDRESS_V2PVT.valid_usages' );
                      FND_MESSAGE.SET_TOKEN ( '1' , x_return_status );
            FND_MSG_PUB.Add;
            if x_return_status = FND_API.G_RET_STS_ERROR then
                RAISE FND_API.G_EXC_ERROR;
            elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            end if;
        end if;

        if (l_return_codes(1) <> FND_API.G_RET_STS_SUCCESS) then
            x_SHIP_PTYSITE_ID := null;
            l_save_flag := 'Y';
        END IF;
    end if;

    if (l_save_flag = 'Y') then
        x_ENABLED_FLAG := 'N';
    -- we can assume we have a row of data
        IF (IBE_UTIL.G_DEBUGON = l_true) THEN
           ibe_util.debug('One or more addresses were not valid for this orgid for that usage. Updating the settings row...');
           ibe_util.debug('x_ENABLED_FLAG          :'||x_ENABLED_FLAG);
           ibe_util.debug('x_BILL_PTYSITE_ID       :'||x_BILL_PTYSITE_ID);
           ibe_util.debug('x_SHIP_PTYSITE_ID       :'||x_SHIP_PTYSITE_ID);
        END IF;

        update IBE_ORD_ONECLICK
            set enabled_flag = x_ENABLED_FLAG,
            bill_to_pty_site_id = x_BILL_PTYSITE_ID,
            ship_to_pty_site_id = x_SHIP_PTYSITE_ID,
            object_version_number = x_OBJECT_VERSION_NUMBER + 1,
            last_updated_by = FND_GLOBAL.user_id,
            last_update_date = SYSDATE
        where
            ord_oneclick_id = x_ONECLICK_ID;

        x_OBJECT_VERSION_NUMBER := x_OBJECT_VERSION_NUMBER + 1;
        IF (IBE_UTIL.G_DEBUGON = l_true) THEN
           ibe_util.debug('x_OBJECT_VERSION_NUMBER :'||x_OBJECT_VERSION_NUMBER);
        END IF;
    end if;
end if; -- end of if l_org_id_s is not null

end if ; --if l_cvv2_setup

IF (IBE_UTIL.G_DEBUGON = l_true) THEN
   ibe_util.debug('Done with ibe_ord_oneclick_pvt.Get_Settings ' || to_char(sysdate,'DD-MON-YYYY:HH24:MI:SS'));
END IF;

    IF FND_API.To_Boolean( p_commit ) THEN
        COMMIT WORK;
    END IF;
    FND_MSG_PUB.Count_And_Get
        (      p_encoded         => FND_API.G_FALSE,
        p_count             =>      x_msg_count,
            p_data              =>      x_msg_data
        );
    --ibe_util.disable_debug;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        IF (IBE_UTIL.G_DEBUGON = l_true) THEN
           ibe_util.debug('ibe_ord_oneclick_pvt.Get_Settings: EXPECTED ERROR EXCEPTION ' || to_char(sysdate,'DD-MON-YYYY:HH24:MI:SS'));
        END IF;
        ROLLBACK TO Get_Settings_Pvt;
        x_return_status := FND_API.G_RET_STS_ERROR ;
        FND_MSG_PUB.Count_And_Get
            (      p_encoded         => FND_API.G_FALSE,
            p_count             =>      x_msg_count,
                p_data              =>      x_msg_data
            );
        --ibe_util.disable_debug;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        IF (IBE_UTIL.G_DEBUGON = l_true) THEN
           ibe_util.debug('ibe_ord_oneclick_pvt.Get_Settings: UNEXPECTED ERROR EXCEPTION ' || to_char(sysdate,'DD-MON-YYYY:HH24:MI:SS'));
        END IF;
        ROLLBACK TO Get_Settings_Pvt;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        FND_MSG_PUB.Count_And_Get
            (      p_encoded         => FND_API.G_FALSE,
            p_count             =>      x_msg_count,
                   p_data              =>      x_msg_data
            );
        --ibe_util.disable_debug;
    WHEN OTHERS THEN
        IF (IBE_UTIL.G_DEBUGON = l_true) THEN
           ibe_util.debug('ibe_ord_oneclick_pvt.Get_Settings: OTHER EXCEPTION ' || to_char(sysdate,'DD-MON-YYYY:HH24:MI:SS'));
        END IF;
        ROLLBACK TO Get_Settings_Pvt;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          IF     FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
                FND_MSG_PUB.Add_Exc_Msg
                    (    G_PKG_NAME,
                        l_api_name
                );
        END IF;
        FND_MSG_PUB.Count_And_Get
            (      p_encoded         => FND_API.G_FALSE,
            p_count             =>      x_msg_count,
                   p_data              =>      x_msg_data
            );
        --ibe_util.disable_debug;
end Get_Settings;

/*-----------------------------------------------------------------------------

        Save_Settings
         - inserts/updates foreign keys into IBE_ORD_ONECLICK
         - no longer saves user's email address associated with IBE_ORD_ONECLICK
         - assumes address validation was done at the java layer before calling this api

 ------------------------------------------------------------------------------
*/
procedure Save_Settings(
    p_api_version      IN     NUMBER,
    p_init_msg_list    IN    VARCHAR2 := FND_API.g_false,
    p_commit           IN    VARCHAR2 := FND_API.g_false,
    p_validation_level IN      NUMBER    := FND_API.g_valid_level_full,
    x_return_status    OUT NOCOPY    VARCHAR2,
    x_msg_count        OUT NOCOPY    NUMBER,
    x_msg_data         OUT NOCOPY    VARCHAR2,

    p_party_id         IN     NUMBER := NULL,
    p_acct_id          IN     NUMBER := NULL,

    p_OBJECT_VERSION_NUMBER    IN    NUMBER := FND_API.G_MISS_NUM,
    p_ENABLED_FLAG             IN    VARCHAR2 :=  'N',
    p_FREIGHT_CODE             IN    VARCHAR2 :=  FND_API.G_MISS_CHAR,
    p_PAYMENT_ID               IN    NUMBER :=  FND_API.G_MISS_NUM,
    p_BILL_PTYSITE_ID          IN    NUMBER :=  FND_API.G_MISS_NUM,
    p_SHIP_PTYSITE_ID          IN    NUMBER :=  FND_API.G_MISS_NUM
) is
    l_api_name    CONSTANT VARCHAR2(30)    := 'Save_Settings';
    l_api_version    CONSTANT NUMBER        := 1.0;

    l_oneclick_id NUMBER := FND_API.g_miss_num;

    CURSOR c_oneclick_row(c_party_id NUMBER, c_acct_id NUMBER) IS
    SELECT ord_oneclick_id
    from IBE_ORD_ONECLICK
    where party_id = c_party_id and cust_account_id = c_acct_id;

begin
--    ibe_util.enable_debug;
    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       ibe_util.debug('Starting ibe_ord_oneclick_pvt.Save_Settings ' || to_char(sysdate,'DD-MON-YYYY:HH24:MI:SS'));
    END IF;
    SAVEPOINT     Save_Settings_Pvt;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (     l_api_version            ,
                                         p_api_version            ,
                                       l_api_name             ,
                                        G_PKG_NAME )
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- Initialize API rturn status to success
    x_return_status := FND_API.g_ret_sts_success;
IF (IBE_UTIL.G_DEBUGON = l_true) THEN
   ibe_util.debug('-------------Input Parameters ----------');
   ibe_util.debug('party_id                :'||p_party_id);
   ibe_util.debug('account_id                 :'||p_acct_id);
   ibe_util.debug('p_OBJECT_VERSION_NUMBER :'||p_OBJECT_VERSION_NUMBER);
   ibe_util.debug('p_ENABLED_FLAG          :'||p_ENABLED_FLAG);
   ibe_util.debug('p_FREIGHT_CODE          :'||p_FREIGHT_CODE);
   ibe_util.debug('p_PAYMENT_ID            :'||p_PAYMENT_ID);
   ibe_util.debug('p_BILL_PTYSITE_ID       :'||p_BILL_PTYSITE_ID);
   ibe_util.debug('p_SHIP_PTYSITE_ID       :'||p_SHIP_PTYSITE_ID);
   ibe_util.debug('----------Input Parameters /end --------');
END IF;

    open c_oneclick_row(p_party_id, p_acct_id);
    fetch c_oneclick_row into l_oneclick_id;

    if c_oneclick_row%NOTFOUND then
        IF (IBE_UTIL.G_DEBUGON = l_true) THEN
           ibe_util.debug('ibe_ord_oneclick_pvt.Save_Settings - inserting new row');
        END IF;
        insert into IBE_ORD_ONECLICK_ALL (
            object_version_number,
            ord_oneclick_id,
            party_id,
            cust_account_id,
            enabled_flag,
            freight_code,
            payment_id,
            bill_to_pty_site_id,
            ship_to_pty_site_id,
		  org_id,
            created_by,
            creation_date,
            last_updated_by,
            last_update_date)
        values (1,
            IBE_ORD_ONECLICK_S1.NEXTVAL,
            p_party_id,
            p_acct_id,
            p_ENABLED_FLAG,
            p_FREIGHT_CODE,
            p_PAYMENT_ID,
            p_BILL_PTYSITE_ID,
            p_SHIP_PTYSITE_ID,
		  MO_Global.get_current_org_id(),
            FND_GLOBAL.user_id,
            SYSDATE,
            FND_GLOBAL.user_id,
            SYSDATE)
        returning ord_oneclick_id into l_oneclick_id;
        IF (IBE_UTIL.G_DEBUGON = l_true) THEN
           ibe_util.debug('ibe_ord_oneclick_pvt.Save_Settings - new ord_oneclick_id: ' || to_char(l_oneclick_id));
        END IF;
    else
        IF (IBE_UTIL.G_DEBUGON = l_true) THEN
           ibe_util.debug('ibe_ord_oneclick_pvt.Save_Settings - updating row');
        END IF;
        update IBE_ORD_ONECLICK
        set
            object_version_number = p_OBJECT_VERSION_NUMBER + 1,
            enabled_flag = p_ENABLED_FLAG,
            freight_code = p_FREIGHT_CODE,
            payment_id = p_PAYMENT_ID,
            bill_to_pty_site_id = p_BILL_PTYSITE_ID,
            ship_to_pty_site_id = p_SHIP_PTYSITE_ID,
            last_updated_by = FND_GLOBAL.user_id,
            last_update_date = SYSDATE
        where
            ord_oneclick_id = l_oneclick_id and
            party_id = p_party_id    and
            cust_account_id = p_acct_id and
            object_version_number = p_OBJECT_VERSION_NUMBER;

        IF (SQL%NOTFOUND) THEN
            FND_MESSAGE.Set_Name('IBE', 'IBE_SAVE_ERROR');
            FND_MSG_PUB.Add;
            RAISE FND_API.G_EXC_ERROR;
              END IF;
    end if;
    close c_oneclick_row;

    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       ibe_util.debug('Done with ibe_ord_oneclick_pvt.Save_Settings ' || to_char(sysdate,'DD-MON-YYYY:HH24:MI:SS'));
    END IF;
    IF FND_API.To_Boolean( p_commit ) THEN
        COMMIT WORK;
    END IF;

    FND_MSG_PUB.Count_And_Get
        (      p_encoded         => FND_API.G_FALSE,
        p_count             =>      x_msg_count,
            p_data              =>      x_msg_data
        );
    --ibe_util.disable_debug;
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        IF (IBE_UTIL.G_DEBUGON = l_true) THEN
           ibe_util.debug('ibe_ord_oneclick_pvt.Save_Settings: EXPECTED ERROR EXCEPTION ' || to_char(sysdate,'DD-MON-YYYY:HH24:MI:SS'));
        END IF;
        ROLLBACK TO Save_Settings_Pvt;
        x_return_status := FND_API.G_RET_STS_ERROR ;
        FND_MSG_PUB.Count_And_Get
            (      p_encoded         => FND_API.G_FALSE,
            p_count             =>      x_msg_count,
                p_data              =>      x_msg_data
            );
        --ibe_util.disable_debug;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        IF (IBE_UTIL.G_DEBUGON = l_true) THEN
           ibe_util.debug('ibe_ord_oneclick_pvt.Save_Settings: UNEXPECTED ERROR EXCEPTION ' || to_char(sysdate,'DD-MON-YYYY:HH24:MI:SS'));
        END IF;
        ROLLBACK TO Save_Settings_Pvt;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        FND_MSG_PUB.Count_And_Get
            (      p_encoded         => FND_API.G_FALSE,
            p_count             =>      x_msg_count,
                   p_data              =>      x_msg_data
            );
        --ibe_util.disable_debug;
    WHEN OTHERS THEN
        IF (IBE_UTIL.G_DEBUGON = l_true) THEN
           ibe_util.debug('ibe_ord_oneclick_pvt.Save_Settings: OTHER EXCEPTION ' || to_char(sysdate,'DD-MON-YYYY:HH24:MI:SS'));
        END IF;
        ROLLBACK TO Save_Settings_Pvt;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          IF     FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
                FND_MSG_PUB.Add_Exc_Msg
                    (    G_PKG_NAME,
                        l_api_name
                );
        END IF;
        FND_MSG_PUB.Count_And_Get
            (      p_encoded         => FND_API.G_FALSE,
            p_count             =>      x_msg_count,
                   p_data              =>      x_msg_data
            );
        --ibe_util.disable_debug;
end Save_Settings;

/*-----------------------------------------------------------------------------

        Express_Buy_Order
        - Handles Ordering of Individual Items, Shopping Lists,
          Lines in one Shopping List, and a Shopping Cart
        - p_flag drives the behavior with possible values: 'ITEMS', 'CART', 'LISTS', 'LIST_LINES'
        - depending on the p_flag, appropriate input parameters are expected to be set
        - return the cartid that was ultimately created/updated

 ------------------------------------------------------------------------------
*/

procedure Express_Buy_Order(
    p_api_version      IN          NUMBER,
    p_init_msg_list    IN          VARCHAR2 := FND_API.g_false,
    p_commit           IN          VARCHAR2 := FND_API.g_false,
    p_validation_level IN          NUMBER   := FND_API.g_valid_level_full,
    x_return_status    OUT NOCOPY  VARCHAR2,
    x_msg_count        OUT NOCOPY  NUMBER,
    x_msg_data         OUT NOCOPY  VARCHAR2,

    -- identification
    p_party_id         IN    NUMBER,
    p_acct_id          IN    NUMBER,
    p_retrieval_num    IN    NUMBER := FND_API.g_miss_num, -- optional, only if recipient is expressing a cart

    -- common pricing parameters
    p_currency_code     IN    VARCHAR2 := FND_API.g_miss_char,
    p_price_list_id     IN    NUMBER   := FND_API.g_miss_num,
    p_price_req_type    IN    VARCHAR2 := FND_API.g_miss_char,
    p_incart_event      IN    VARCHAR2 := FND_API.g_miss_char,
    p_incart_line_event IN    VARCHAR2 := FND_API.g_miss_char,

    -- flag to drive behavior
    -- (values: 'ITEMS', 'CART', 'LISTS', 'LIST_LINES')
    p_flag              IN     VARCHAR2 := FND_API.g_miss_char,

    -- for express checkout of a shopping cart
    p_cart_id           IN    NUMBER := FND_API.g_miss_num,
    p_minisite_id       IN    NUMBER := FND_API.g_miss_num, -- for stop sharing notification

    -- for express checkout of a list of shopping lists
    p_list_ids      IN    JTF_NUMBER_TABLE,
    p_list_ovns     IN    JTF_NUMBER_TABLE,

    -- for express checkout of a list of shopping list lines
    p_list_line_ids    IN    JTF_NUMBER_TABLE,
    p_list_line_ovns   IN    JTF_NUMBER_TABLE,

    -- for express checkout of a list of items (usually from catalog)
    p_item_ids     IN    JTF_NUMBER_TABLE,
    p_qtys         IN    JTF_NUMBER_TABLE,
    p_org_ids      IN    JTF_NUMBER_TABLE,
    p_uom_codes    IN    JTF_VARCHAR2_TABLE_100,

    -- return the quote header id
    x_new_cart_id    OUT NOCOPY    NUMBER,

    -- TimeStamp check
    p_last_update_date           IN DATE     := FND_API.G_MISS_DATE,
    x_last_update_date         OUT NOCOPY  DATE,
    p_price_mode VARCHAR2 := 'ENTIRE_QUOTE'
) is
    l_api_name     CONSTANT VARCHAR2(30) := 'Express_Buy_Order';
    l_api_version  CONSTANT NUMBER       := 1.0;

    -- local variables for finding an active express cart
    l_curr_cart_id        NUMBER       := FND_API.g_miss_num;
    l_curr_cart_date      DATE         :=  FND_API.G_MISS_DATE;
    l_curr_cart_currcode  VARCHAR2(15) :=  FND_API.G_MISS_CHAR;

    l_retrieval_num       NUMBER       := FND_API.g_miss_num;
    l_sharee_party_id     NUMBER       := FND_API.g_miss_num;
    l_sharee_acct_id      NUMBER       := FND_API.g_miss_num;

    l_object_version_number  NUMBER       := FND_API.G_MISS_NUM;
    l_ord_oneclick_id        NUMBER       := FND_API.G_MISS_NUM;
    l_enabled_flag           VARCHAR2(1)  :=  'N';
    l_freight_code           VARCHAR2(30) :=  FND_API.G_MISS_CHAR; -- amaheshw bug 18159497
    l_payment_id             NUMBER       :=  FND_API.G_MISS_NUM;
    l_bill_to_pty_site_id    NUMBER       :=  FND_API.G_MISS_NUM;
    l_ship_to_pty_site_id    NUMBER       :=  FND_API.G_MISS_NUM;
    l_settings_date          DATE         :=  FND_API.G_MISS_DATE;

    -- local variables and cursors for updating a quote
    l_save_trigger            VARCHAR2(1) := 'Y';
    l_credit_card_num         NUMBER;
    l_credit_card_name        VARCHAR2(80);
    l_credit_card_exp         DATE;
    l_credit_card_holder_name VARCHAR2(50);
    l_control_rec             ASO_QUOTE_PUB.Control_Rec_Type;
    l_qte_header_rec          ASO_QUOTE_PUB.Qte_Header_Rec_Type;
    l_qte_line_tbl            ASO_QUOTE_PUB.Qte_Line_Tbl_Type;
    l_hd_payment_tbl          ASO_QUOTE_PUB.Payment_Tbl_Type;
    l_hd_shipment_tbl         ASO_QUOTE_PUB.Shipment_Tbl_Type;
    l_hd_tax_detail_tbl       ASO_QUOTE_PUB.Tax_Detail_Tbl_Type;
    l_payment_rec             ASO_QUOTE_PUB.Payment_Rec_Type;
    l_shipment_rec            ASO_QUOTE_PUB.Shipment_Rec_Type;
    l_tax_detail_rec          ASO_QUOTE_PUB.Tax_Detail_Rec_Type;
    l_attach_contract         VARCHAR2(1);
    l_contract_template_id    NUMBER;

    lx_quote_header_id        NUMBER;
    lx_last_update_date       DATE;

    l_party_type              VARCHAR2(30);
    l_optional_party_id       NUMBER := FND_API.g_miss_num;
    l_count_tax               NUMBER := 0;
    l_payment_rec_id          NUMBER :=  FND_API.G_MISS_NUM;
    l_count                   NUMBER := 0;

    CURSOR c_quote(c_party_id NUMBER, c_acct_id NUMBER) IS
    SELECT quote_header_id, creation_date, currency_code
    FROM aso_quote_headers
    WHERE
    quote_source_code = 'IStore Oneclick' and
    party_id = c_party_id and
    cust_account_id = c_acct_id and
    quote_name is null and
    order_id   is null and
    nvl(trunc(quote_expiration_date), trunc(sysdate)+1) >= trunc(sysdate);

    CURSOR c_quote_date(c_qte_header_id NUMBER) IS
    SELECT last_update_date
    FROM ASO_QUOTE_HEADERS
    WHERE quote_header_id = c_qte_header_id;

BEGIN
    --ibe_util.enable_debug;
  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
    ibe_util.debug('Starting ibe_ord_oneclick_pvt.Express_Buy_Order ' || to_char(sysdate,'DD-MON-YYYY:HH24:MI:SS'));
    ibe_util.debug('PROCESSING FLAG : ' || p_flag);
  END IF;
  SAVEPOINT  Express_Buy_Order_Pvt;
  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call ( l_api_version ,
                                       p_api_version ,
                                       l_api_name    ,
                                       G_PKG_NAME    )
    THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;
  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_Boolean( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;

  -- Initialize API rturn status to success
  x_return_status := FND_API.g_ret_sts_success;


  l_qte_header_rec.quote_header_id := p_cart_id;
  l_qte_header_rec.party_id        := p_party_id;
  l_qte_header_rec.Cust_account_id := p_acct_id;
  l_qte_header_rec.currency_code   := p_currency_code;
  l_qte_header_rec.price_list_id   := p_price_list_id;


  IF(p_flag = 'CART') THEN
    l_save_trigger := 'Y';

    if ((p_retrieval_num is not null) and (p_retrieval_num <> FND_API.g_miss_num)) then

      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        ibe_util.debug('Express_Buy_Order: Validate_user_update START');
        ibe_util.debug('Express_Buy_Order: p_party_id: '||p_party_id);
        ibe_util.debug('Express_Buy_Order: p_acct_id: '||p_acct_id);
        ibe_util.debug('Express_Buy_Order: p_retrieval_number: '||p_retrieval_num);
      END IF;

      IBE_Quote_Misc_pvt.Validate_User_Update
        (p_init_msg_list          => p_Init_Msg_List
        ,p_quote_header_id        => p_cart_id
        ,p_party_id               => p_party_id
        ,p_cust_account_id        => p_acct_id
        ,p_quote_retrieval_number => p_retrieval_num
        ,p_validate_user          => FND_API.G_TRUE
        ,p_privilege_type_code    => 'A'
	,p_last_update_date       => p_last_update_date
        ,x_return_status          => x_return_status
        ,x_msg_count              => x_msg_count
        ,x_msg_data               => x_msg_data     );

      IF x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

    end if;

  END IF; --  IF(p_flag = 'CART') THEN

  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
    ibe_util.debug('Starting ibe_ord_oneclick_pvt.Get_Express_items_settings ' );
    ibe_util.debug('Input Cartid: '||p_cart_id);
    ibe_util.debug('Input Partyid: '||p_party_id);
    ibe_util.debug('Input Accountid: '||p_acct_id);
    ibe_util.debug('Input p_flag:  '||p_flag);
    ibe_util.debug('Input p_last_update_date:  '||p_last_update_date);
  END IF;

  IBE_ORD_ONECLICK_PVT.Get_Express_items_settings(
           x_qte_header_rec   => l_qte_header_rec
          ,p_flag             => p_flag
          ,x_payment_tbl      => l_hd_payment_tbl
          ,x_hd_shipment_tbl  => l_hd_shipment_tbl
          ,x_hd_tax_dtl_tbl   => l_hd_tax_detail_tbl);

  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
    ibe_util.debug('Output Cartid: '||l_qte_header_rec.quote_header_id);
  END IF;
  l_curr_cart_id := l_qte_header_rec.quote_header_id;

  if (p_flag = 'ITEMS') then
    l_save_trigger := 'Y';
    --set items info

    if (p_item_ids.count > 0) then
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        ibe_util.debug('Express_Buy_Order - ***adding lines for products***');
        ibe_util.debug('Express_Buy_Order - build list of quote lines for oneclick cart');
      END IF;
      l_count := p_item_ids.count;
      FOR i IN 1..l_count LOOP
        l_qte_line_tbl(i).operation_code     := 'CREATE';
        l_qte_line_tbl(i).QUOTE_HEADER_id    := l_curr_cart_id;
        l_qte_line_tbl(i).INVENTORY_ITEM_ID  := p_item_ids(i);
        l_qte_line_tbl(i).QUANTITY           := p_qtys(i);
        l_qte_line_tbl(i).organization_id    := p_org_ids(i);
        l_qte_line_tbl(i).UOM_CODE           := p_uom_codes(i);
        --l_qte_line_tbl(i).price_list_id    := p_flags.PRICE_LIST_ID;
        --l_qte_line_tbl(i).currency_code    := p_flags.CURRENCY_CODE;
        l_qte_line_tbl(i).line_category_code := 'ORDER';

        IF (IBE_UTIL.G_DEBUGON = l_true) THEN
          ibe_util.debug('l_qte_line_tbl(i).operation_code '    || l_qte_line_tbl(i).operation_code);
          ibe_util.debug('l_qte_line_tbl(i).QUOTE_HEADER_id '   || to_char(l_qte_line_tbl(i).QUOTE_HEADER_id));
          ibe_util.debug('l_qte_line_tbl(i).INVENTORY_ITEM_ID ' || to_char(l_qte_line_tbl(i).INVENTORY_ITEM_ID));
          ibe_util.debug('l_qte_line_tbl(i).QUANTITY '          || l_qte_line_tbl(i).QUANTITY);
          ibe_util.debug('l_qte_line_tbl(i).organization_id '   || l_qte_line_tbl(i).operation_code);
          ibe_util.debug('l_qte_line_tbl(i).UOM_CODE '          || l_qte_line_tbl(i).UOM_CODE);
        END IF;
        --ibe_util.debug('l_qte_line_tbl(i).price_list_id ' || to_char(l_qte_line_tbl(i).price_list_id));
        --ibe_util.debug('l_qte_line_tbl(i).currency_code ' || l_qte_line_tbl(i).currency_code);
        IF (IBE_UTIL.G_DEBUGON = l_true) THEN
          ibe_util.debug('l_qte_line_tbl(i).line_category_code ' || l_qte_line_tbl(i).line_category_code);
        END IF;
      End Loop;
    else
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        ibe_util.debug('Express_Buy_Order - oneclick update: no products to add!');
      END IF;
    end if;
  end if; --end if adding itmes

  IF (l_curr_cart_id <> FND_API.g_miss_num) then
    l_qte_header_rec.quote_header_id := l_curr_cart_id;
    /*OPEN c_quote_date(l_qte_header_rec.quote_header_id);
      FETCH c_quote_date INTO l_qte_header_rec.last_update_date;
    CLOSE c_quote_date;*/
    -- We need to pass the lastupdate from UI to check for concurrency issues.
    l_qte_header_rec.last_update_date   := p_last_update_date;
    l_control_rec.last_update_date := l_qte_header_rec.last_update_date;
    IF(p_flag = 'CART') THEN
      --Contract needs to be attached to the xpressed checkout cart.
      --There is no consolidation for carts, hence a contract has to be
      --attached every time a cart is xpressed checked out
      l_attach_contract :=FND_API.G_TRUE;
    END IF;

  ELSE
    -- clear these just in case the previous code used these recs
    l_qte_header_rec.quote_header_id  := FND_API.G_MISS_NUM;
    l_qte_header_rec.quote_name       := '';
    l_qte_header_rec.last_update_date := FND_API.G_MISS_DATE;
    l_control_rec.last_update_date    := FND_API.G_MISS_DATE;
    l_attach_contract                 := FND_API.G_TRUE;
  END IF;

  -- regardless we will need to reprice - whether a new express quote or adding items or adding from lists
  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
    ibe_util.debug('Express_Buy_Order - ***setting pricing flags***');
  END IF;
  l_control_rec.pricing_request_type          := p_price_req_type;
  l_control_rec.header_pricing_event          := p_incart_event;
  l_control_rec.line_pricing_event            := p_incart_line_event;
  l_control_rec.CALCULATE_TAX_FLAG            := 'Y';
  l_control_rec.CALCULATE_FREIGHT_CHARGE_FLAG := 'Y';

  l_control_rec.PRICE_MODE:= p_price_mode;
  if (FND_Profile.Value('IBE_PRICE_CHANGED_LINES') = 'Y' and  p_price_mode = 'CHANGE_LINE') then
     l_qte_header_rec.PRICING_STATUS_INDICATOR := 'I';
     l_qte_header_rec.TAX_STATUS_INDICATOR := 'I';
  end if;

  l_qte_header_rec.currency_code              := p_currency_code;
  l_qte_header_rec.price_list_id              := p_price_list_id;
  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
    ibe_util.debug('l_control_rec.pricing_request_type '          || l_control_rec.pricing_request_type);
       ibe_util.debug('l_control_rec.header_pricing_event '          || l_control_rec.header_pricing_event);
       ibe_util.debug('l_control_rec.line_pricing_event '            || l_control_rec.line_pricing_event);
       ibe_util.debug('l_control_rec.CALCULATE_TAX_FLAG '            || l_control_rec.CALCULATE_TAX_FLAG);
       ibe_util.debug('l_control_rec.CALCULATE_FREIGHT_CHARGE_FLAG ' || l_control_rec.CALCULATE_FREIGHT_CHARGE_FLAG);
       ibe_util.debug('l_qte_header_rec.currency_code'               || l_qte_header_rec.currency_code);
       ibe_util.debug('l_qte_header_rec.price_list_id '              || l_qte_header_rec.price_list_id);
  END IF;

  IF (l_save_trigger = 'Y') then
    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      ibe_util.debug('****Calling IBE_Quote_Save_pvt.SAVE**** ' || to_char(sysdate,'DD-MON-YYYY:HH24:MI:SS'));
      ibe_util.debug('     l_qte_header_rec.quote_header_id  : ' || l_qte_header_rec.quote_header_id);
      ibe_util.debug('     l_qte_header_rec.quote_name       : ' || l_qte_header_rec.quote_name);
      ibe_util.debug('     l_qte_header_rec.last_update_date : ' || to_char(l_qte_header_rec.last_update_date,'DD-MON-YYYY:HH24:MI:SS'));
    END IF;

    IF (p_retrieval_num <> FND_API.g_miss_num) then
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        ibe_util.debug('passing sharee party and acct id');
      END IF;
      l_qte_header_rec.party_id        := FND_API.G_MISS_NUM;
      l_qte_header_rec.cust_account_id := FND_API.G_MISS_NUM;
      l_sharee_party_id := p_party_id;
      l_sharee_acct_id  := p_acct_id;
    END IF;

    IBE_Quote_Save_pvt.SAVE(
            p_api_version_number       => p_api_version,
            p_init_msg_list            => FND_API.G_FALSE,
            p_commit                   => FND_API.g_false,
            p_auto_update_active_quote => FND_API.g_false,
    --        p_combineSameItem    => 'Y', -- let api default from profile
            p_sharee_Number            => p_retrieval_num,
            p_sharee_party_id          => l_sharee_party_id,
            p_sharee_cust_account_id   => l_sharee_acct_id,
            p_minisite_id              => p_minisite_id,
            p_control_rec              => l_control_rec,
            p_qte_header_rec           => l_qte_header_rec,
            P_Qte_Line_Tbl             => l_qte_line_tbl,
            P_hd_Payment_Tbl           => l_hd_Payment_Tbl,
            P_hd_Shipment_Tbl          => l_hd_Shipment_Tbl,
            P_hd_Tax_Detail_Tbl        => l_hd_Tax_Detail_Tbl,

            x_quote_header_id          => lx_quote_header_id,
            x_last_update_date         => lx_last_update_date,
            X_Return_Status            => x_Return_Status,
            X_Msg_Count                => x_Msg_Count,
            X_Msg_Data                 => x_Msg_Data);

    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      ibe_util.debug('Back from IBE_Quote_Save_pvt.SAVE ' || to_char(sysdate,'DD-MON-YYYY:HH24:MI:SS') || ' quote_header_id: ' || to_char(lx_quote_header_id));
    END IF;
    IF x_return_status <> FND_API.g_ret_sts_success THEN
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        ibe_util.debug('ibe_ord_oneclick_pvt.Express_Buy_Order - non success status from IBE_Quote_Save_pvt.SAVE: ' || x_return_status);            FND_MESSAGE.SET_NAME('IBE','IBE_EXPR_PLSQL_API_ERROR');
      END IF;
      FND_MESSAGE.SET_TOKEN ( '0' , 'Express_Buy_Order - IBE_Quote_Save_pvt.SAVE' );
      FND_MESSAGE.SET_TOKEN ( '1' , x_return_status );
      FND_MSG_PUB.Add;
      IF x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
      ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
    ELSE
      IF(l_attach_contract = FND_API.G_TRUE) THEN
        IF (OKC_TERMS_UTIL_GRP.Get_Terms_Template('QUOTE', p_cart_id) IS NULL) THEN -- Checking whether a contract has already been attached (Bug 5260372)
          IF (IBE_UTIL.G_DEBUGON = l_true) THEN
            ibe_util.debug('ibe_ord_oneclick_pvt.Express_Buy_Order - : No contract currently attached !');
          END IF;
          IF (FND_Profile.Value('OKC_ENABLE_SALES_CONTRACTS') = 'Y' ) THEN --Only if contracts is enabled
            --instantiate a contract and associate to the quote
            /*mannamra: changes for MOAC: Bug 4682364 	*/
            --l_contract_template_id := FND_PROFILE.VALUE('ASO_DEFAULT_CONTRACT_TEMPLATE'); old style
            l_contract_template_id := to_number(ASO_UTILITY_PVT.GET_OU_ATTRIBUTE_VALUE(ASO_UTILITY_PVT.G_DEFAULT_CONTRACT_TEMPLATE)); --New style
            /*mannamra: end of changes for MOAC*/

            IF (l_contract_template_id is not null) THEN
              IF (IBE_UTIL.G_DEBUGON = l_true) THEN
                IBE_UTIL.debug('l_contract_template_id = '||l_contract_template_id);
                IBE_UTIL.debug('Before calling OKC_TERMS_COPY_GRP.copy_terms_api, quoteheaderId = '||lx_quote_header_id);
              END IF;
              OKC_TERMS_COPY_GRP.copy_terms(
                      p_api_version              =>1.0
                     ,p_template_id              => l_contract_template_id
                     ,p_target_doc_type          => 'QUOTE'
                     ,p_target_doc_id            => lx_quote_header_id
                     ,p_article_effective_date   => null
                     ,p_validation_string        => null
                     ,x_return_status            => x_return_status
                     ,x_msg_count                => x_msg_count
                     ,x_msg_data                 => x_msg_data);

              IF (IBE_UTIL.G_DEBUGON = l_true) THEN
                IBE_UTIL.debug('After copy_terms api, return status = '||x_return_status);
              END IF;
              IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
                RAISE FND_API.G_EXC_ERROR;
              END IF;
              IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;
            END IF; --If contract template id is not null
          END IF; --IF (FND_Profile.Value('OKC_ENABLE_SALES_CONTRACTS')
        ELSE
          IF (IBE_UTIL.G_DEBUGON = l_true) THEN
            ibe_util.debug('ibe_ord_oneclick_pvt.Express_Buy_Order - : A contract is already instanciated for this quote');
          END IF;
        END IF; -- Whether there is a contract currently instanciated for this quote
      END IF; --If l_attach_contract is true
    END IF; -- If l_return_status is success
    IF (p_flag = 'CART') THEN
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        ibe_util.debug('Express_buy_order: Calling stop_sharing for quote_header_id :'||l_qte_header_rec.quote_header_id);
      END IF;
      IBE_QUOTE_SAVESHARE_V2_PVT.stop_sharing (
              p_quote_header_id =>  p_cart_id   ,
              p_delete_context  => 'IBE_SC_CART_ORDERED',
              P_minisite_id     => p_minisite_id        ,
              p_api_version     => p_api_version        ,
              p_init_msg_list   => fnd_api.g_false      ,
              p_commit          => fnd_api.g_false      ,
              x_return_status   => x_return_status      ,
              x_msg_count       => x_msg_count          ,
              x_msg_data        => x_msg_data           );


        IF x_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
        END IF;

        IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
        IF (IBE_UTIL.G_DEBUGON = l_true) THEN
          ibe_util.debug('Express_buy_order: Done Calling stop_sharing');
        END IF;
    END IF;

    l_curr_cart_id                    := lx_quote_header_id;
    l_qte_header_rec.quote_header_id  := l_curr_cart_id;
    l_qte_header_rec.last_update_date := lx_last_update_date;
    l_control_rec.last_update_date    := lx_last_update_date;
  end if; -- end if needed to call quote.save

  -- get ready for the next update of the quote

 /* if (p_flag = 'LISTS') then
    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      ibe_util.debug('Calling IBE_Shop_List_PVT.Save_Quote_From_Lists ' || to_char(sysdate,'DD-MON-YYYY:HH24:MI:SS'));
      ibe_util.debug('p_mode ' || 'MERGE');
    END IF;
    l_count := p_list_ids.count;
    FOR i IN 1..l_count LOOP
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        ibe_util.debug('p_shpListIds' || i || ' ' || p_list_ids(i));
      END IF;
    END LOOP;

    IBE_Shop_List_PVT.Save_Quote_From_Lists(
             P_Api_Version     => 1.0
            ,P_Init_Msg_List   => FND_API.G_FALSE
            ,P_Commit          => FND_API.G_FALSE
            ,p_mode            => 'MERGE'
            --,p_combine_same_item    => null  -- let default from profile
            ,p_sl_header_ids   => p_list_ids
            ,p_sl_header_ovns  => p_list_ovns
            ,p_control_rec     => l_control_rec
            ,p_q_header_rec    => l_qte_header_rec
            ,p_url             => null
            ,p_comments        => null
            ,X_Return_Status   => x_return_status
            ,X_Msg_Count       => x_msg_count
            ,X_Msg_Data        => x_msg_data
            ,x_q_header_id     => lx_quote_header_id );

        --ibe_util.enable_debug;
    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      ibe_util.debug('Back from IBE_Shop_List_PVT.Save_Quote_From_Lists ' || to_char(sysdate,'DD-MON-YYYY:HH24:MI:SS'));
      ibe_util.debug('X_cartId ' || lx_quote_header_id);
    END IF;

    IF x_return_status <> FND_API.g_ret_sts_success THEN
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        ibe_util.debug('ibe_ord_oneclick_pvt.Express_Buy_Order - non success status from IBE_Shop_List_PVT.Save_Quote_From_Lists: ' || x_return_status);            FND_MESSAGE.SET_NAME('IBE','IBE_EXPR_PLSQL_API_ERROR');
      END IF;
      FND_MESSAGE.SET_TOKEN ( '0' , 'Express_Buy_Order - IBE_Shop_List_PVT.Save_Quote_From_Lists' );
      FND_MESSAGE.SET_TOKEN ( '1' , x_return_status );
      FND_MSG_PUB.Add;
      IF x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
      ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
    END IF;

  END IF;
*/
  if (p_flag = 'LIST_LINES') then
    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      ibe_util.debug('Calling IBE_Shop_List_PVT.Save_Quote_From_List_Items ' || to_char(sysdate,'DD-MON-YYYY:HH24:MI:SS'));
      ibe_util.debug('p_mode ' || 'MERGE');
    END IF;
    l_count := p_list_line_ids.count;
    FOR i IN 1..l_count LOOP
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        ibe_util.debug('p_shpListLineIds' || i || ' ' || p_list_line_ids(i));
      END IF;
    end loop;
    IBE_Shop_List_PVT.Save_Quote_From_List_Items(
         P_Api_Version       => 1.0
        ,P_Init_Msg_List    => FND_API.G_FALSE
        ,P_Commit           => FND_API.G_FALSE
        ,p_mode             => 'MERGE'
    --        ,p_combine_same_item    => null  -- let default from profile
        ,p_sl_line_ids      => p_list_line_ids
        ,p_sl_line_ovns     => p_list_line_ovns
        ,p_control_rec      => l_control_rec
        ,p_q_header_rec     => l_qte_header_rec
        ,p_url              => null
        ,p_comments         => null
        ,X_Return_Status    => x_return_status
        ,X_Msg_Count        => x_msg_count
        ,X_Msg_Data         => x_msg_data
        ,x_q_header_id      => lx_quote_header_id        );

        --ibe_util.enable_debug;
    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      ibe_util.debug('Back from IBE_Shop_List_PVT.Save_Quote_From_List_Items ' || to_char(sysdate,'DD-MON-YYYY:HH24:MI:SS'));
      ibe_util.debug('X_cartId ' || lx_quote_header_id);
    END IF;

    if x_return_status <> FND_API.g_ret_sts_success then
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        ibe_util.debug('ibe_ord_oneclick_pvt.Express_Buy_Order - non success status from IBE_Shop_List_PVT.Save_Quote_From_List_Items: ' || x_return_status);            FND_MESSAGE.SET_NAME('IBE','IBE_EXPR_PLSQL_API_ERROR');
      END IF;
      FND_MESSAGE.SET_NAME('IBE','IBE_EXPR_PLSQL_API_ERROR');
      FND_MESSAGE.SET_TOKEN ( '0' , 'Express_Buy_Order - IBE_Shop_List_PVT.Save_Quote_From_List_Items' );
      FND_MESSAGE.SET_TOKEN ( '1' , x_return_status );
      FND_MSG_PUB.Add;
      if x_return_status = FND_API.G_RET_STS_ERROR then
        RAISE FND_API.G_EXC_ERROR;
      elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      end if;
    end if;
  end if;

      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        ibe_util.debug('Express_Buy_Order - BOTTOM LINE: express cart used: ' || l_curr_cart_id);
      END IF;
      -- let the caller know which quote we finally updated
      x_new_cart_id := l_curr_cart_id;

      IF FND_API.To_Boolean( p_commit ) THEN
        COMMIT WORK;
      END IF;
      FND_MSG_PUB.Count_And_Get
        ( p_encoded => FND_API.G_FALSE,
          p_count   => x_msg_count    ,
          p_data    => x_msg_data     );

    --ibe_util.disable_debug;
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        IF (IBE_UTIL.G_DEBUGON = l_true) THEN
           ibe_util.debug('ibe_ord_oneclick_pvt.Express_Buy_Order: EXPECTED ERROR EXCEPTION ' || to_char(sysdate,'DD-MON-YYYY:HH24:MI:SS'));
        END IF;
        ROLLBACK TO Express_Buy_Order_Pvt;
        x_return_status := FND_API.G_RET_STS_ERROR;
	x_last_update_date := IBE_Quote_Misc_pvt.getQuoteLastUpdateDate(p_cart_id);
        FND_MSG_PUB.Count_And_Get
            ( p_encoded         => FND_API.G_FALSE,
              p_count             =>      x_msg_count,
              p_data              =>      x_msg_data
            );
        --ibe_util.disable_debug;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        IF (IBE_UTIL.G_DEBUGON = l_true) THEN
           ibe_util.debug('ibe_ord_oneclick_pvt.Express_Buy_Order: UNEXPECTED ERROR EXCEPTION ' || to_char(sysdate,'DD-MON-YYYY:HH24:MI:SS'));
        END IF;
        ROLLBACK TO Express_Buy_Order_Pvt;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        FND_MSG_PUB.Count_And_Get
            (      p_encoded         => FND_API.G_FALSE,
            p_count             =>      x_msg_count,
                   p_data              =>      x_msg_data
            );
        --ibe_util.disable_debug;
    WHEN OTHERS THEN
        IF (IBE_UTIL.G_DEBUGON = l_true) THEN
           ibe_util.debug('ibe_ord_oneclick_pvt.Express_Buy_Order: OTHER EXCEPTION ' || to_char(sysdate,'DD-MON-YYYY:HH24:MI:SS'));
        END IF;
        ROLLBACK TO Express_Buy_Order_Pvt;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          IF     FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
                FND_MSG_PUB.Add_Exc_Msg
                    (    G_PKG_NAME,
                        l_api_name
                );
        END IF;
        FND_MSG_PUB.Count_And_Get
            (      p_encoded         => FND_API.G_FALSE,
            p_count             =>      x_msg_count,
                   p_data              =>      x_msg_data
            );
        --ibe_util.disable_debug;
end Express_Buy_Order;


Procedure get_express_items_settings(
           x_qte_header_rec   IN OUT NOCOPY aso_quote_pub.Qte_Header_Rec_Type
          ,p_flag             IN     VARCHAR2
          ,x_payment_tbl      IN OUT NOCOPY ASO_QUOTE_PUB.Payment_Tbl_Type
          ,x_hd_shipment_tbl  IN OUT NOCOPY ASO_Quote_Pub.Shipment_Tbl_Type
          ,x_hd_tax_dtl_tbl   IN OUT NOCOPY ASO_QUOTE_PUB.Tax_Detail_Tbl_Type) is

CURSOR c_quote(c_party_id NUMBER, c_acct_id NUMBER) IS
SELECT quote_header_id, creation_date, currency_code
FROM aso_quote_headers
WHERE quote_source_code = 'IStore Oneclick'
and party_id        = c_party_id
and cust_account_id = c_acct_id
and quote_name      is null
and order_id        is null
and nvl(trunc(quote_expiration_date), trunc(sysdate)+1) >= trunc(sysdate);

CURSOR c_settings(c_party_id NUMBER, c_acct_id NUMBER) IS
SELECT  object_version_number,
        ord_oneclick_id,
        enabled_flag,
        freight_code,
        payment_id,
        bill_to_pty_site_id,
        ship_to_pty_site_id,
        last_update_date

FROM IBE_ORD_ONECLICK
WHERE party_id        = c_party_id
and   cust_account_id = c_acct_id;

CURSOR c_quote_date(c_qte_header_id NUMBER) IS
SELECT last_update_date
FROM ASO_QUOTE_HEADERS
WHERE quote_header_id = c_qte_header_id;

CURSOR c_party_type(c_acct_id NUMBER) IS
SELECT p.party_type
FROM HZ_PARTIES p, HZ_CUST_ACCOUNTS a
where p.party_id = a.party_id
and a.cust_account_id = c_acct_id;

CURSOR c_bank_acct(c_ba_id NUMBER) IS
SELECT bank_account_num, inactive_date, bank_account_name
FROM AP_BANK_ACCOUNTS
WHERE bank_account_id = c_ba_id;

CURSOR c_payment(c_qtehdr_id NUMBER) IS
SELECT payment_id
FROM ASO_PAYMENTS
WHERE quote_header_id = c_qtehdr_id
and quote_line_id is null;

CURSOR c_shipment(c_qtehdr_id NUMBER) IS
SELECT shipment_id
FROM ASO_SHIPMENTS
WHERE quote_header_id = c_qtehdr_id
and quote_line_id is null;

CURSOR c_party_name(c_party_id NUMBER) IS
    SELECT substr(party_name,1,50) from HZ_PARTIES
    WHERE party_type = 'PERSON' and party_id = c_party_id
    UNION
    SELECT substr(party_name,1,50) from HZ_PARTIES
    WHERE party_id = (SELECT subject_id from HZ_RELATIONSHIPS
                       WHERE party_id = c_party_id
                       and subject_type = 'PERSON'
                       and object_type = 'ORGANIZATION');

l_true varchar2(10) := 'TRUE';
l_hd_shipment_tbl     ASO_Quote_Pub.Shipment_Tbl_Type
                                  := ASO_Quote_Pub.G_MISS_SHIPMENT_Tbl;
l_hd_payment_tbl	  ASO_QUOTE_PUB.Payment_Tbl_Type;
l_hd_tax_detail_tbl	  ASO_QUOTE_PUB.Tax_Detail_Tbl_Type;

l_qte_header_rec      ASO_QUOTE_PUB.Qte_Header_Rec_Type;
l_push_qte_header_rec ASO_QUOTE_PUB.Qte_Header_Rec_Type;
l_tax_detail_rec	  ASO_QUOTE_PUB.Tax_Detail_Rec_Type;
l_shipment_rec	      ASO_QUOTE_PUB.Shipment_Rec_Type;
l_payment_rec		  ASO_QUOTE_PUB.Payment_Rec_Type;
l_control_rec		  ASO_QUOTE_PUB.Control_Rec_Type;

l_curr_cart_id           NUMBER := FND_API.g_miss_num;
l_curr_cart_date         DATE;
l_curr_cart_currcode     VARCHAR2(10);
l_object_version_number  NUMBER;
l_ord_oneclick_id        NUMBER;
l_enabled_flag           VARCHAR2(3);
l_freight_code           VARCHAR2(30); -- amaheshw bug 18159497
l_payment_id             NUMBER;
l_bill_to_pty_site_id    NUMBER;
l_ship_to_pty_site_id    NUMBER;
l_settings_date          DATE;
l_save_trigger           VARCHAR2(3);
l_party_type             VARCHAR2(300);
l_optional_party_id      NUMBER;
l_count_tax              NUMBER := 0;
l_payment_rec_id         NUMBER :=  FND_API.G_MISS_NUM;
l_count                  NUMBER := 0;
l_retrieval_num          NUMBER := FND_API.g_miss_num;
l_credit_card_num        NUMBER;
l_credit_card_name       VARCHAR2(80);
l_credit_card_exp        DATE;
l_credit_card_holder_name VARCHAR2(50);


lx_quote_header_id       NUMBER;
lx_last_update_date      DATE;
lX_return_status         VARCHAR2(1);
lx_msg_count             NUMBER     ;
lx_msg_data              VARCHAR2(2000);
BEGIN

--Begin API body

IF (IBE_UTIL.G_DEBUGON = l_true) THEN
  ibe_util.debug('Starting ibe_ord_oneclick_pvt.Get_express_items_settings ');
  ibe_util.debug('PROCESSING FLAG : ' || p_flag);
END IF;

l_qte_header_rec := x_qte_header_rec;
if ((x_hd_tax_dtl_tbl is not null) and (x_hd_tax_dtl_tbl.count > 0)) then
  l_tax_detail_rec := x_hd_tax_dtl_tbl(1);
end if;
if ((x_payment_tbl is not null) and (x_payment_tbl.count > 0)) then
  l_payment_rec    := x_payment_tbl(1);
end if;
if ((x_hd_shipment_tbl is not null) and (x_hd_shipment_tbl.count > 0)) then
  l_shipment_rec   := x_hd_shipment_tbl(1);
end if;

OPEN c_settings(x_qte_header_rec.party_id,
                x_qte_header_rec.cust_account_id);
  FETCH c_settings INTO
    l_object_version_number,
    l_ord_oneclick_id,
    l_enabled_flag,
    l_freight_code,
    l_payment_id, --mannamra: In light on credit card consolidation, this will be assignment id
    l_bill_to_pty_site_id,
    l_ship_to_pty_site_id,
    l_settings_date;
CLOSE c_settings;

IF (p_flag <> 'CART') THEN
  -- see if there is a current cart
  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
    ibe_util.debug('get_express_items_settings see if there is a current cart');
    ibe_util.debug('Input Cartid: '||l_qte_header_rec.quote_header_id);
    ibe_util.debug('Input Partyid: '||l_qte_header_rec.party_id);
    ibe_util.debug('Input Accountid: '||l_qte_header_rec.cust_account_id);
  END IF;
  OPEN c_quote(x_qte_header_rec.party_id,
               x_qte_header_rec.cust_account_id);
    FETCH c_quote INTO l_curr_cart_id, l_curr_cart_date, l_curr_cart_currcode;
      if c_quote%NOTFOUND then
        l_curr_cart_id := FND_API.g_miss_num;
      else
        null;
        IF (IBE_UTIL.G_DEBUGON = l_true) THEN
          ibe_util.debug('get_express_items_settings got l_curr_cart_id       ' || to_char(l_curr_cart_id));
          ibe_util.debug('get_express_items_settings got l_curr_cart_date     ' || to_char(l_curr_cart_date,'DD-MON-YYYY:HH:MI:SS'));
          ibe_util.debug('get_express_items_settings got l_curr_cart_currcode ' || l_curr_cart_currcode);
        END IF;
      end if;
  CLOSE c_quote;
end if; -- p_flag <> cart

l_control_rec.AUTO_VERSION_FLAG := 'N';

-- see if we can consolidate
if (l_curr_cart_id <> FND_API.g_miss_num) then

  -- if no then move out the old cart id and set curr_cart_id to null to trigger creating a new one
  if ((l_curr_cart_date < l_settings_date)  or (l_curr_cart_currcode <> x_qte_header_rec.currency_code)) then
    -- this means that the settings (which now include currency) have changed since we first
    -- created this express quote so we cannot safely use this one
    -- update the quote_name and "push it out"
    l_push_qte_header_rec.quote_header_id := l_curr_cart_id;
    l_push_qte_header_rec.quote_name      := l_curr_cart_id;
    OPEN c_quote_date(l_curr_cart_id);
      FETCH c_quote_date INTO l_push_qte_header_rec.last_update_date;
    CLOSE c_quote_date;

    l_control_rec.last_update_date := l_push_qte_header_rec.last_update_date;
    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      ibe_util.debug('****Calling IBE_Quote_Save_pvt.SAVE for pushing out **** ');
      ibe_util.debug('     l_qte_header_rec.quote_header_id  : ' || l_qte_header_rec.quote_header_id);
      ibe_util.debug('     l_qte_header_rec.quote_name       : ' || l_qte_header_rec.quote_name);
      ibe_util.debug('     l_qte_header_rec.last_update_date : ' || to_char(l_qte_header_rec.last_update_date,'DD-MON-YYYY:HH24:MI:SS'));
    END IF;
    IBE_Quote_Save_pvt.SAVE(
       p_api_version_number       => 1.0,
       p_init_msg_list            => FND_API.G_FALSE,
       p_commit                   => FND_API.g_false,
       p_auto_update_active_quote => FND_API.g_false,
       --p_combineSameItem    => 'Y', -- let api default from profile
       p_control_rec              => l_control_rec,
       p_qte_header_rec           => l_push_qte_header_rec,
       p_save_type                => UPDATE_EXPRESSORDER,
       x_quote_header_id          => lx_quote_header_id,
       x_last_update_date         => lx_last_update_date,
       X_Return_Status            => lx_Return_Status,
       X_Msg_Count                => lx_Msg_Count,
       X_Msg_Data                 => lx_Msg_Data);
       --ibe_util.enable_debug;
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        ibe_util.debug('Back from IBE_Quote_Save_pvt.SAVE for pushing out' );
      END IF;
      if lx_return_status <> FND_API.g_ret_sts_success then
        IF (IBE_UTIL.G_DEBUGON = l_true) THEN
          ibe_util.debug('ibe_ord_oneclick_pvt.Express_Buy_Order - non success status from IBE_Quote_Save_pvt.SAVE: ' || lx_return_status);
        END IF;
        FND_MESSAGE.SET_NAME('IBE','IBE_EXPR_PLSQL_API_ERROR');
        FND_MESSAGE.SET_TOKEN ( '0' , 'Get_Express_Items_Settings - IBE_Quote_Save_pvt.SAVE for nonconsolidation' );
        FND_MESSAGE.SET_TOKEN ( '1' , lx_return_status );
        FND_MSG_PUB.Add;
        if lx_return_status = FND_API.G_RET_STS_ERROR then
          RAISE FND_API.G_EXC_ERROR;
        elsif lx_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        end if;
      end if;
      -- set these to g_miss so rest of api can know we have to start with a new quote
      l_qte_header_rec.quote_header_id := FND_API.g_miss_num;
      l_curr_cart_id                   := FND_API.g_miss_num;
      l_curr_cart_date                 := FND_API.g_miss_date;
    else
      --settings have'nt changed so we should consolidate incoming items to the open express-checkout cart
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        ibe_util.debug('ibe_ord_oneclick_pvt.Get_express_items_settings-Consolidating to: '||l_curr_cart_id);
      END IF;
      l_qte_header_rec.quote_header_id := l_curr_cart_id;
    end if; -- end pushing out of old cart
  end if; -- end checking if we can consolidate

  /*At this point, l_curr_cart_id is either set to be the one we should use
  or g_miss_num to trigger creation of a new quote*/

  -- see if we need to apply the Express Checkout Settings (billing, shipping, payment info)
  if ((p_flag = 'CART') or ((p_flag <> 'CART') and (l_curr_cart_id = FND_API.g_miss_num))) then

    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      ibe_util.debug('Express_Buy_Order got l_settings_date ' || to_char(l_settings_date,'DD-MON-YYYY:HH:MI:SS'));
    END IF;

    if (p_flag = 'CART') then
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        ibe_util.debug('Express ordering a CART id : ' || x_qte_header_rec.quote_header_id);
        ibe_util.debug('Making sure user has Full privilege on this cart');
      END IF;
      l_curr_cart_id              := x_qte_header_rec.quote_header_id;
--      l_qte_header_rec.quote_name := l_curr_cart_id;
-- no need to rename the cart anymore since all cart carts will have a name now
    end if; --if p_flag = 'CART'

    OPEN c_party_type(x_qte_header_rec.cust_account_id);
      FETCH c_party_type INTO l_party_type;
    CLOSE c_party_type;

    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      ibe_util.debug('Party Type: ' || l_party_type);
    END IF;

    if (l_party_type <> 'PERSON') then
      l_optional_party_id := x_qte_header_rec.party_id;
    end if;

    select count(*) into l_count_tax
    from ASO_TAX_DETAILS
    where quote_header_id = l_curr_cart_id
    and   quote_line_id is null;

    IF (l_count_tax = 0) then

      l_tax_detail_rec.operation_code := 'CREATE';
      l_tax_detail_rec.quote_header_id := l_curr_cart_id; --will be g_miss for expr chkout of items
      l_tax_detail_rec.tax_exempt_flag := 'S';
      x_hd_tax_dtl_tbl(1) := l_tax_detail_rec;

      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        ibe_util.debug('Get_express_items_settings - *** creating header level tax record***');
        ibe_util.debug('l_tax_detail_rec.operation_code ' || l_tax_detail_rec.operation_code);
        ibe_util.debug('l_tax_detail_rec.quote_header_id ' || l_tax_detail_rec.quote_header_id);
        ibe_util.debug('l_tax_detail_rec.tax_exempt_flag ' || l_tax_detail_rec.tax_exempt_flag);
      END IF;
    END IF; --l_count_tax=0

    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      ibe_util.debug('Get_express_items_settings - ***setting quote header info***');
    END IF;

    l_qte_header_rec.invoice_to_party_site_id := l_bill_to_pty_site_id;
    l_qte_header_rec.invoice_to_party_id      := l_optional_party_id;
    l_qte_header_rec.quote_source_code        := 'IStore Oneclick';
    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      ibe_util.debug('Get_express_items_settings:l_qte_header_rec.party_id ' || l_qte_header_rec.party_id);
      ibe_util.debug('Get_express_items_settings:l_qte_header_rec.cust_account_id ' || l_qte_header_rec.cust_account_id);
      ibe_util.debug('Get_express_items_settings:l_qte_header_rec.invoice_to_party_site_id' || l_qte_header_rec.invoice_to_party_site_id);
      ibe_util.debug('Get_express_items_settings:l_qte_header_rec.invoice_to_party_id ' || l_qte_header_rec.invoice_to_party_id);
      ibe_util.debug('Get_express_items_settings:l_qte_header_rec.quote_source_code ' || l_qte_header_rec.quote_source_code);
    END IF;

    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      ibe_util.debug('Express_Buy_Order - ***setting to create or update payment rec***');
    END IF;
    /*mannamra: In light of credit card consolidation, we will not be storing credit card number in one_click_all table
    we will also just be passing assignment id to ASO whi will in turn create a transaction and
    store the transaction extension id for this quote in aso_payments */

    /*OPEN c_bank_acct(l_payment_id);
      FETCH c_bank_acct INTO l_credit_card_num, l_credit_card_exp, l_credit_card_holder_name;
      if c_bank_acct%NOTFOUND then
        IF (IBE_UTIL.G_DEBUGON = l_true) THEN
          ibe_util.debug('No credit card record found.');
        END IF;
      end if;
    CLOSE c_bank_acct;*/

    --l_credit_card_name := IBE_ORD_ONECLICK_PVT.Get_credit_card_Type(l_credit_card_num);
    /* If Credit Card name is ERROR raise appropriate exception */
    /*If l_credit_card_name = 'ERROR' Then
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        ibe_util.debug('Invalid Credit Card');
      END IF;
    End If;*/

    /* per Bug #3020526, using info from AP_BANK_ACCOUNTS table instead
    OPEN c_party_name(x_qte_header_rec.party_id);
      FETCH c_party_name INTO l_credit_card_holder_name;
      if c_party_name%NOTFOUND then
        IF (IBE_UTIL.G_DEBUGON = l_true) THEN
          ibe_util.debug('No name to use for credit card holder name.');
        END IF;
      end if;
    CLOSE c_party_name;
    */

    OPEN c_payment(l_curr_cart_id);
      FETCH c_payment INTO l_payment_rec.payment_id;
      if c_payment%NOTFOUND then
        l_payment_rec.operation_code := 'CREATE';
      else
        l_payment_rec.operation_code := 'UPDATE';
      end if;
    CLOSE c_payment;

    /*l_payment_rec.payment_term_id             := fnd_profile.value('IBE_DEFAULT_PAYMENT_TERM_ID');
    l_payment_rec.payment_type_code           := 'CREDIT_CARD';
    l_payment_rec.payment_ref_number          := l_credit_card_num;
    l_payment_rec.credit_card_expiration_date := l_credit_card_exp;
    l_payment_rec.credit_card_code            := l_credit_card_name;
    l_payment_rec.credit_card_holder_name     := l_credit_card_holder_name;*/
    l_payment_rec.payment_type_code           := 'CREDIT_CARD';
    l_payment_rec.instr_assignment_id        := l_payment_id;
    x_payment_tbl(1)                          := l_payment_rec;
    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      ibe_util.debug('l_payment_rec.operation_code '   || l_payment_rec.operation_code);
      ibe_util.debug('l_payment_rec.payment_term_id '  || l_payment_rec.payment_term_id);
      ibe_util.debug('l_payment_rec.payment_type_code '|| l_payment_rec.payment_type_code);
      ibe_util.debug('l_payment_rec.payment_ref_number <not logged>');
      ibe_util.debug('l_payment_rec.instr_asssignment_id ' || l_payment_rec.instr_assignment_id);
    END IF;

    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      ibe_util.debug('Get_express_items_settings - ***setting to create or update shipment rec***');
    END IF;
    l_shipment_rec.operation_code := 'UPDATE';
    OPEN c_shipment(l_curr_cart_id);
      FETCH c_shipment INTO l_shipment_rec.shipment_id;
      if c_shipment%NOTFOUND then
        IF (IBE_UTIL.G_DEBUGON = l_true) THEN
          ibe_util.debug('no shipment rec at header, will CREATE one');
        END IF;
        l_shipment_rec.operation_code := 'CREATE';
      end if;
    CLOSE c_shipment;

    l_shipment_rec.ship_method_code      := l_freight_code;
    l_shipment_rec.ship_to_party_site_id := l_ship_to_pty_site_id;
    l_shipment_rec.ship_to_party_id      := l_optional_party_id;
    x_hd_shipment_tbl(1)                 := l_shipment_rec;
    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      ibe_util.debug('l_shipment_rec.shipment_id '           || l_shipment_rec.shipment_id);
      ibe_util.debug('l_shipment_rec.operation_code '        || l_shipment_rec.operation_code);
      ibe_util.debug('l_shipment_rec.ship_method_code '      || l_shipment_rec.ship_method_code);
      ibe_util.debug('l_shipment_rec.ship_to_party_site_id ' || l_shipment_rec.ship_to_party_site_id);
      ibe_util.debug('l_shipment_rec.ship_to_party_id '      || l_shipment_rec.ship_to_party_id);
    END IF;

  END IF; --IF ((p_flag = 'CART') or ((p_flag <> 'CART') and (l_curr_cart_id = FND_API.g_miss_num)))

  x_qte_header_rec    := l_qte_header_rec;

END;


/* Local Function to get credit card type given the number

   -- Input Parameter(s)
      - p_credit_card_number NUMBER
   -- Returns
        Credit_card_type VARCHAR2
   -- hekkiral - 21-DEC-2000
*/
function Get_Credit_Card_Type(
    p_Credit_Card_Number NUMBER
) RETURN VARCHAR2
AS
    l_credit_Card_number Varchar2(30);
    l_credit_card_length Number;
Begin

    l_credit_card_number := to_char(p_credit_card_number);
    l_credit_card_length := length(l_credit_card_number);

    If (l_credit_Card_length = 16 and substr(l_credit_card_number,1,2) in ('51','52','53','54','55') ) Then
        Return ('MC');
    Elsif ((l_credit_Card_length = 13 or l_credit_card_length = 16)    and substr(l_credit_card_number,1,1) = '4') Then
        Return ('VISA');
    Elsif (l_credit_Card_length = 15 and substr(l_credit_card_number,1,2) in ('34','37')) Then
        Return ('AMEX');
    Elsif (l_credit_card_length = 14 and substr(l_credit_card_number,1,3) in ('300','301','302','303','305','36','38')) Then
        Return('DINERS');
    Elsif (l_credit_card_length = 16 and substr(l_credit_card_number,1,4) = '6011') Then
        Return ('DISCOVER');
    Elsif ((l_credit_card_length = 15 and substr(l_credit_card_number,1,4) in ('2014','2149')) or
    ((l_credit_card_length = 15 or l_credit_card_length = 16) and (substr(l_credit_card_number,1,1) = '3' or substr(l_credit_card_number,1,4) in ('2131','1800')))) Then
        Return ('OTHERS');
    Else
        Return('ERROR');
    End If;

End Get_Credit_Card_Type;

/*-----------------------------------------------------------------------------

        Update_Settings
         - Updates the Express checkout settings
         - Called when a credit card is deleted, to check if the deleted
           credit card is the one selected for Express Checkout. If so,
           disables the Express Checkout

 ------------------------------------------------------------------------------
*/
Procedure Update_Settings(
    p_api_version      IN     NUMBER,
    p_init_msg_list    IN    VARCHAR2 := FND_API.g_false,
    p_commit           IN    VARCHAR2 := FND_API.g_false,
    x_return_status    OUT NOCOPY    VARCHAR2,
    x_msg_count        OUT NOCOPY    NUMBER,
    x_msg_data         OUT NOCOPY    VARCHAR2,
    p_party_id         IN     NUMBER := NULL,
    p_acct_id          IN     NUMBER := NULL,
    p_assignment_id    IN     NUMBER := NULL)
IS

    l_api_name      CONSTANT   VARCHAR2(30)  := 'Update_Settings';
    l_api_version   CONSTANT   NUMBER        := 1.0;
    l_object_version_number    NUMBER :=  FND_API.G_MISS_NUM;
    l_oneclick_id              NUMBER :=  FND_API.G_MISS_NUM;
    l_payment_id               NUMBER :=  FND_API.G_MISS_NUM;
    l_bill_ptysite_id          NUMBER :=  FND_API.G_MISS_NUM;
    l_ship_ptysite_id          NUMBER :=  FND_API.G_MISS_NUM;
    l_enabled_flag             VARCHAR2(1) :=  'N';
    l_freight_code             VARCHAR2(30) :=  FND_API.G_MISS_CHAR;

Cursor c_get_oneclick_settings(c_party_id IN NUMBER,
                               c_acct_id IN NUMBER)
   IS

   select ord_oneclick_id, object_version_number, enabled_flag,  freight_code,
          payment_id, bill_to_pty_site_id, ship_to_pty_site_id
   from ibe_ord_oneclick
   where party_id = c_party_id and cust_account_id = c_acct_id;

Begin

    SAVEPOINT     Update_Settings;

    -- Initialize API rturn status to success
    x_return_status := FND_API.g_ret_sts_success;

    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      ibe_util.debug('------- Input to ibe_ord_oneclick_pvt.Update_Settings: -----------------');
      ibe_util.debug('p_party_id :'||p_party_id);
      ibe_util.debug('p_acct_id  :'||p_acct_id);
      ibe_util.debug('p_assignment_id  :'||p_assignment_id);
    END IF;

    OPEN c_get_oneclick_settings(p_party_id, p_acct_id);
       FETCH c_get_oneclick_settings
        INTO
           l_oneclick_id,
           l_object_version_number,
           l_enabled_flag,
           l_freight_code,
           l_payment_id,
           l_bill_ptysite_id,
           l_ship_ptysite_id;

    IF c_get_oneclick_settings%NOTFOUND THEN
        l_oneclick_id := FND_API.g_miss_num;
    END IF;
        CLOSE c_get_oneclick_settings;

    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       ibe_util.debug('------- Retrieved From TABLES: Update_Settings-----------------');
       ibe_util.debug('l_object_version_number :'||l_object_version_number);
       ibe_util.debug('l_oneclick_id           :'||l_oneclick_id);
       ibe_util.debug('l_enabled_flag          :'||l_enabled_flag);
       ibe_util.debug('l_freight_code          :'||l_freight_code);
       ibe_util.debug('l_payment_id            :'||l_payment_id);
       ibe_util.debug('l_bill_ptysite_id       :'||l_bill_ptysite_id);
       ibe_util.debug('l_ship_ptysite_id       :'||l_ship_ptysite_id);
       ibe_util.debug('Checking p_assignment_id not null       :'||p_assignment_id);
    END IF;

    IF p_assignment_id is not NULL and l_oneclick_id <> FND_API.g_miss_num and l_enabled_flag = 'Y' and l_payment_id = p_assignment_id THEN
        l_enabled_flag := 'N';
        l_payment_id := '';

        IF (IBE_UTIL.G_DEBUGON = l_true) THEN
           ibe_util.debug('Update_Settings : Deleted CC is the one selected for Express checkout');
           ibe_util.debug('Update_Settings : Disabling the Express checkout - Calling ibe_ord_oneclick_pvt.save_settings');
        END IF;

        ibe_ord_oneclick_pvt.save_settings(
            p_api_version            => l_api_version,
            p_init_msg_list          => FND_API.G_FALSE,
            p_commit                 => p_commit,
            x_return_status          => x_return_status,
            x_msg_count              => x_msg_count,
            x_msg_data               => x_msg_data,
            p_party_id               => p_party_id,
            p_acct_id                => p_acct_id,
            p_object_version_number  => l_object_version_number,
            p_enabled_flag           => l_enabled_flag,
            p_freight_code           => l_freight_code,
            p_payment_id             => l_payment_id,
            p_bill_ptysite_id        => l_bill_ptysite_id,
            p_ship_ptysite_id        => l_ship_ptysite_id
        );

        IF (IBE_UTIL.G_DEBUGON = l_true) THEN
           ibe_util.debug('Update_Settings : After Calling ibe_ord_oneclick_pvt.save_settings');
           ibe_util.debug('Update_Settings : x_return_status - '||x_return_status);
        END IF;

        IF x_return_status <> FND_API.g_ret_sts_success THEN
           IF (IBE_UTIL.G_DEBUGON = l_true) THEN
             ibe_util.debug('ibe_ord_oneclick_pvt.Update_Settings - call to ibe_ord_oneclick_pvt.save_settings failed' || x_return_status);
           END IF;
           IF x_return_status = FND_API.G_RET_STS_ERROR THEN
              RAISE FND_API.G_EXC_ERROR;
           ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
           END IF;
        END IF;

        IF FND_API.To_Boolean( p_commit ) THEN
          COMMIT WORK;
        END IF;

    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
           ibe_util.debug('Update_Settings : Success - Express Checkout disabled');
           ibe_util.debug('Update_Settings : End');
    END IF;
    ELSE
           IF (IBE_UTIL.G_DEBUGON = l_true) THEN
           ibe_util.debug('Update_Settings : Express Checkout disabled - No need for update');
           ibe_util.debug('Update_Settings : End');
    END IF;

    END IF;

    FND_MSG_PUB.Count_And_Get
        (  p_encoded   => FND_API.G_FALSE,
           p_count     =>      x_msg_count,
           p_data      =>      x_msg_data
        );

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        IF (IBE_UTIL.G_DEBUGON = l_true) THEN
           ibe_util.debug('ibe_ord_oneclick_pvt.Update_Settings: EXPECTED ERROR EXCEPTION ' || to_char(sysdate,'DD-MON-YYYY:HH24:MI:SS'));
        END IF;
        ROLLBACK TO Update_Settings;
        x_return_status := FND_API.G_RET_STS_ERROR ;
        FND_MSG_PUB.Count_And_Get
            ( p_encoded    => FND_API.G_FALSE,
              p_count      =>      x_msg_count,
              p_data       =>      x_msg_data
            );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        IF (IBE_UTIL.G_DEBUGON = l_true) THEN
           ibe_util.debug('ibe_ord_oneclick_pvt.Update_Settings: UNEXPECTED ERROR EXCEPTION ' || to_char(sysdate,'DD-MON-YYYY:HH24:MI:SS'));
        END IF;
        ROLLBACK TO Update_Settings;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        FND_MSG_PUB.Count_And_Get
            ( p_encoded    => FND_API.G_FALSE,
              p_count      =>      x_msg_count,
              p_data       =>      x_msg_data
            );

    WHEN OTHERS THEN
        IF (IBE_UTIL.G_DEBUGON = l_true) THEN
           ibe_util.debug('ibe_ord_oneclick_pvt.Update_Settings: OTHER EXCEPTION ' || to_char(sysdate,'DD-MON-YYYY:HH24:MI:SS'));
        END IF;
        ROLLBACK TO Update_Settings;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          IF  FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
                FND_MSG_PUB.Add_Exc_Msg
                    (    G_PKG_NAME,
                         l_api_name
                    );
           END IF;
        FND_MSG_PUB.Count_And_Get
            ( p_encoded    => FND_API.G_FALSE,
              p_count      =>      x_msg_count,
              p_data       =>      x_msg_data
            );

End Update_Settings;
end ibe_ord_oneclick_pvt;

/
