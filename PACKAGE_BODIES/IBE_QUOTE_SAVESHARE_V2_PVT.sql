--------------------------------------------------------
--  DDL for Package Body IBE_QUOTE_SAVESHARE_V2_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBE_QUOTE_SAVESHARE_V2_PVT" as
/*$Header: IBEVSS2B.pls 120.2.12010000.2 2012/09/10 06:46:47 nsatyava ship $ */
l_true VARCHAR2(1)               := FND_API.G_TRUE;

cursor c_check_active_cart(c_party_id        number,
                           c_cust_account_id number) is
       select quote_header_id
       from   IBE_ACTIVE_QUOTES
       where party_id        = c_party_id
       and   cust_account_id = c_cust_account_id
       and   record_type     = 'CART';


cursor  c_get_cart_name(c_q_hdr_id        number,
                        c_party_id        number,
                        c_cust_account_id number) is
       select quote_name
       from   aso_quote_headers_all
       where  party_id = c_party_id
       and    cust_account_id = c_cust_account_id
       and    quote_header_id = c_q_hdr_id;
rec_get_cart_name        c_get_cart_name%rowtype;
rec_check_active_cart    c_check_active_cart%rowtype;
cursor c_userenv_partyid is
       select customer_id
       from FND_USER
       where user_id = FND_GLOBAL.USER_ID;
rec_userenv_partyid      c_userenv_partyid%rowtype;

/*This procedure is used to save the missing party_id and cust_account_id
of the recipient before cart activation*/
PROCEDURE save_party_id(
          p_party_id         NUMBER,
          p_cust_account_id  NUMBER,
          p_retrieval_number NUMBER) is

  cursor c_find_party(c_retrieval_num NUMBER) is
  select quote_sharee_id,quote_header_id,party_id, cust_account_id
  from   ibe_sh_quote_access
  where  quote_sharee_number = c_retrieval_num ;

  cursor c_get_sold_to(c_quote_header_id NUMBER) is
  select cust_account_id, party_type
  from aso_quote_headers_all a, hz_parties p
  where a.party_id = p.party_id
  and quote_header_id = c_quote_header_id;

  rec_get_sold_to c_get_sold_to%rowtype;
  rec_find_party  c_find_party%rowtype;
  l_recip_id        NUMBER := NULL;
  l_cust_account_id NUMBER := NULL;
  l_party_id        NUMBER := NULL;
  l_sold_to_cust    NUMBER := NULL;
  l_quote_header_id NUMBER;
  l_party_type      VARCHAR2(2000);

  BEGIN

    FOR rec_find_party in c_find_party(p_retrieval_number) LOOP
      l_recip_id        := rec_find_party.quote_sharee_id;
      l_party_id        := rec_find_party.party_id;
      l_cust_account_id := rec_find_party.cust_account_id;
      l_quote_header_id := rec_find_party.quote_header_id;
      exit when c_find_party%notfound;
    END LOOP;
    IF(l_party_id is null and l_cust_account_id is null) THEN
	  FOR rec_get_sold_to in c_get_sold_to(l_quote_header_id) LOOP
	    l_sold_to_cust := rec_get_sold_to.cust_account_id;
        l_party_type   := rec_get_sold_to.party_type;
	    exit when c_get_sold_to%NOTFOUND;
	  END LOOP;
      IF(((l_party_type = 'PARTY_RELATIONSHIP')
         and (p_cust_account_id = l_sold_to_cust))or (l_party_type = 'PERSON')) THEN

        IBE_SH_QUOTE_ACCESS_PKG.update_Row(
            p_QUOTE_SHAREE_ID => l_recip_id
           ,p_party_id        => p_party_id
           ,p_cust_account_id => p_cust_account_id);
      ELSE
        IF (IBE_UTIL.G_DEBUGON = l_true) THEN
           IBE_UTIL.DEBUG('Not saving party and cust_account_id because account_ids do not match');
        END IF;
        IF FND_Msg_Pub.Check_Msg_Level (FND_Msg_Pub.G_MSG_LVL_ERROR) THEN
          FND_Message.Set_Name('IBE', 'IBE_SC_ERR_USERACCESS');
          FND_Msg_Pub.Add;
        END IF;
  	    RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;
  END;

/*The "Main" api; a sort of counterpart to IBE_Quote_Save_pvt.save where this api will be the single point
of entry for all of the new save, share, append, and active cart operations
Usages:
One for each operation_code:
"APPEND", "ACTIVATE", "DEACTIVATE", "NAME_CART", "SAVE_RECIPIENTS",
"STOP_SHARING", "SAVE_CART_AND_RECIPIENTS", "END_WORKING"*/
Procedure save_share_v2 (
    P_saveshare_control_rec   IN  SAVESHARE_CONTROL_REC_TYPE
                                  := G_MISS_saveshare_control_rec              ,
    P_party_id                IN  Number                                       ,
    P_cust_account_id         IN  Number                                       ,
    P_retrieval_number        IN  Number                                       ,
    P_Quote_header_rec        IN  ASO_QUOTE_PUB.Qte_Header_Rec_Type            ,
    P_quote_access_tbl        IN  IBE_QUOTE_SAVESHARE_pvt.QUOTE_ACCESS_Tbl_Type
                                  := IBE_QUOTE_SAVESHARE_pvt.G_miss_quote_access_Tbl,
    P_source_quote_header_id  IN  NUMBER   := FND_API.G_MISS_NUM               ,
    P_source_last_update_date IN  Date     := FND_API.G_MISS_DATE              ,
    p_minisite_id             IN  NUMBER                                       ,
    p_URL                     IN  VARCHAR2                                     ,
    p_notes                   IN  VARCHAR2 := FND_API.G_MISS_CHAR              ,
    p_api_version             IN  NUMBER   := 1                                ,
    p_init_msg_list           IN  VARCHAR2 := FND_API.G_TRUE                   ,
    p_commit                  IN  VARCHAR2 := FND_API.G_FALSE                  ,
    x_return_status           OUT NOCOPY VARCHAR2                              ,
    x_msg_count               OUT NOCOPY NUMBER                                ,
    x_msg_data                OUT NOCOPY VARCHAR2                              ) is

    L_control_rec      aso_quote_pub.control_rec_type;
    l_quote_header_id  NUMBER;
    l_api_name         CONSTANT VARCHAR2(30)   := 'SAVESHARE_V2';
    l_api_version      CONSTANT NUMBER         := 1.0;
    l_last_update_date DATE                    ;

BEGIN
    SAVEPOINT  SAVESHARE_V2;
  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call (	l_api_version,
                             			P_Api_Version,
                                   		l_api_name,
                       					G_PKG_NAME )
  THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;
   -- Initialize message list IF p_init_msg_list is set to TRUE.
  IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
  END IF;

   --  Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;
-------------------------------------------------------------------------------------------------------------
--API Body start
-------------------------------------------------------------------------------------------------------------
  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_UTIL.DEBUG('IBE_QUOTE_SAVESHARE_V2_PVT.save_share_v2: START');
     IBE_UTIL.DEBUG('saveshare_control_rec.operation_code is '||p_saveshare_control_rec.operation_code);
  END IF;

  Validate_share_Update(
    p_api_version_number  => 1.0
   ,p_init_msg_list       => FND_API.G_FALSE
   ,p_quote_header_rec    => P_Quote_header_rec
   ,p_quote_access_tbl    => p_quote_access_tbl
   ,p_party_id            => P_party_id
   ,p_cust_account_id     => P_cust_account_id
   ,p_retrieval_number    => p_retrieval_number
   ,p_operation_code      => p_saveshare_control_rec.operation_code
   ,x_return_status       => x_return_status
   ,x_msg_count           => x_msg_count
   ,x_msg_data            => x_msg_data)  ;

  IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF;
  IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  --DBMS_OUTPUT.PUT_LINE('saveshare_control_rec.operation_code is '||p_saveshare_control_rec.operation_code);
    IF ((p_saveshare_control_rec.operation_code = OP_NAME_CART)
       OR (p_saveshare_control_rec.operation_code = OP_SAVE_CART_AND_RECIPIENTS)) THEN
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
         IBE_UTIL.DEBUG('calling IBE_Quote_Save_pvt.SAVE to save the quote name');
      END IF;
      --DBMS_OUTPUT.PUT_LINE_LINE('calling IBE_Quote_Save_pvt.SAVE to save the quote name');
      --DBMS_OUTPUT.PUT_LINE_LINE('incoming quote_name :'||P_Quote_header_rec.quote_name);
      --DBMS_OUTPUT.PUT_LINE_LINE('incoming quote_headeR_id :'||P_Quote_header_rec.quote_header_id);
      IBE_Quote_Save_pvt.save(
        p_api_version_number => p_api_version                      ,
        p_init_msg_list      => fnd_api.g_false                    ,
        p_commit             => fnd_api.g_false                    ,

        p_qte_header_rec     => P_Quote_header_rec                 ,
        p_control_rec        => P_saveshare_control_rec.control_rec,
        x_quote_header_id    => l_quote_header_id                  ,
        x_last_update_date   => l_last_update_date                 ,

        x_return_status      => x_return_status                    ,
        x_msg_count          => x_msg_count                        ,
        x_msg_data           => x_msg_data);

      IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
    END IF;

    IF ((p_saveshare_control_rec.operation_code = OP_SAVE_RECIPIENTS)
       OR (p_saveshare_control_rec.operation_code = OP_SAVE_CART_AND_RECIPIENTS)) THEN
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
         IBE_UTIL.DEBUG('Calling save_recipients to save recipient information');
      END IF;
      --DBMS_OUTPUT.PUT_LINE('Calling save_recipients to save recipient information ');
      --dbms_output.put_line('Comments passed :  '||p_notes);
      IF(nvl(p_quote_access_tbl.count,0) > 0) THEN
        IBE_QUOTE_SAVESHARE_V2_PVT.save_recipients(
              p_quote_access_tbl   => p_quote_access_tbl                ,
              p_quote_header_id    => p_quote_header_rec.quote_header_id,
              p_party_id           => p_party_id                        ,
              p_cust_account_id    => p_cust_account_id                 ,
              p_url                => p_url                             ,
              p_minisite_id        => p_minisite_id                     ,
              p_notes              => p_notes                           ,
              p_api_version        => p_api_version                     ,
              p_init_msg_list      => fnd_api.g_false                   ,
              p_commit             => fnd_api.g_false                   ,
              x_return_status      => x_return_status                   ,
              x_msg_count          => x_msg_count                       ,
              x_msg_data           => x_msg_data);

        IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
          RAISE FND_API.G_EXC_ERROR;
        END IF;

        IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
      END IF; -- IF(nvl(p_quote_access_tbl.count,0)
    END IF;


    IF(p_saveshare_control_rec.operation_code = OP_APPEND) THEN
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
         IBE_UTIL.DEBUG('cALLING APPEND_QUOTE');
      END IF;
      IBE_QUOTE_SAVESHARE_V2_PVT.APPEND_QUOTE(
        P_source_quote_header_id  => P_source_quote_header_id,
        P_source_last_update_date => P_source_last_update_date,
        P_target_header_rec       => P_Quote_header_rec,
        P_control_rec             => P_saveshare_control_rec.control_rec,
        P_delete_source_cart      => P_saveshare_control_rec.delete_source_cart,
        P_combinesameitem         => P_saveshare_control_rec.combinesameitem,
        P_minisite_id             => p_minisite_id,
        p_api_version             => 1,
        p_init_msg_list           => FND_API.G_FALSE,
        p_commit                  => FND_API.G_FALSE,
        x_return_status           => x_return_status,
        x_msg_count               => x_msg_count,
        x_msg_data                => x_msg_data);
      IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;


    ELSIF(p_saveshare_control_rec.operation_code = OP_ACTIVATE_QUOTE) THEN
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
         IBE_UTIL.DEBUG('OPERATION_CODE IS: '||p_saveshare_control_rec.operation_code||'CALLING ACTIVATE_QUOTE');
      END IF;
      --DBMS_OUTPUT.PUT_LINE_LINE('OPERATION_CODE IS: '||p_saveshare_control_rec.operation_code||'CALLING ACTIVATE_QUOTE');
      IBE_QUOTE_SAVESHARE_V2_PVT.ACTIVATE_QUOTE(
               P_Quote_header_rec => P_Quote_header_rec ,
               P_Party_id         => P_party_id                         ,
               P_Cust_account_id  => P_cust_account_id                  ,
               P_control_rec      => P_saveshare_control_rec.control_rec,
               p_retrieval_number => p_retrieval_number                 ,
               P_api_version      => P_api_version                      ,
               P_init_msg_list    => FND_API.G_FALSE                    ,
               P_commit           => FND_API.G_FALSE                    ,
               x_return_status    => x_return_status                    ,
               x_msg_count        => x_msg_count                        ,
               x_msg_data         => x_msg_data);

      IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
      --DBMS_OUTPUT.PUT_LINE_LINE('Finished calling ACTIVATE_QUOTE ');
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
         IBE_UTIL.DEBUG('Finished calling ACTIVATE_QUOTE');
      END IF;

    ELSIF(p_saveshare_control_rec.operation_code = OP_END_WORKING) THEN
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
         IBE_UTIL.DEBUG(' Calling IBE_QUOTE_SAVE_SHARE_V2_PVT.END_WORKING');
      END IF;
      IBE_QUOTE_SAVESHARE_V2_PVT.END_WORKING(
           P_Quote_access_tbl => p_quote_access_tbl ,
           p_quote_header_id  => p_quote_header_rec.quote_header_id,
           p_party_id         => p_party_id         ,
           p_cust_account_id  => p_cust_account_id  ,
           p_retrieval_number => p_retrieval_number ,
           P_URL              => p_url              ,
           P_minisite_id      => p_minisite_id      ,
           p_notes            => p_notes            ,
           p_api_version      => p_api_version      ,
           p_init_msg_list    => fnd_api.g_false    ,
           p_commit           => fnd_api.g_false    ,
           x_return_status    => x_return_status    ,
           x_msg_count        => x_msg_count        ,
           x_msg_data         => x_msg_data         );
      IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
         IBE_UTIL.DEBUG('Done calling IBE_QUOTE_SAVE_SHARE_V2_PVT.END_WORKING');
      END IF;

    ELSIF(p_saveshare_control_rec.operation_code = OP_STOP_SHARING) THEN
      IBE_QUOTE_SAVESHARE_V2_PVT.STOP_SHARING (
        p_quote_header_id  => P_Quote_header_rec.quote_header_id ,
        P_minisite_id      => p_minisite_id                      ,
        p_notes            => p_notes                            ,
        p_quote_access_tbl => p_quote_access_tbl                 ,
        p_api_version      => p_api_version                      ,
        p_init_msg_list    => fnd_api.g_false                    ,
        p_commit           => fnd_api.g_false                    ,
        x_return_status    => x_return_status                    ,
        x_msg_count        => x_msg_count                        ,
        x_msg_data         => x_msg_data                         );

      IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
    END IF;--Check for p_saveshare_control_rec.operation_code
    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       IBE_UTIL.DEBUG('P_saveshare_control_rec.deactivate_cart: '||P_saveshare_control_rec.deactivate_cart);
    END IF;
    IF ((P_saveshare_control_rec.deactivate_cart = FND_API.G_TRUE)
       OR (p_saveshare_control_rec.operation_code = OP_DEACTIVATE)) THEN

      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
         IBE_UTIL.DEBUG('Calling deactivate API');
      END IF;
      --DBMS_OUTPUT.PUT_LINE_LINE('Calling deactivate API');
      IBE_QUOTE_SAVESHARE_V2_PVT.DEACTIVATE_QUOTE  (
          P_Quote_header_id  => P_Quote_header_rec.quote_header_id ,
          P_Party_id         => p_party_id                         ,
          P_Cust_account_id  => p_cust_account_id                  ,
          P_minisite_id      => p_minisite_id                      ,
          p_api_version      => p_api_version                      ,
          p_init_msg_list    => fnd_api.g_false                    ,
          p_commit           => fnd_api.g_false                    ,
          x_return_status    => x_return_status                    ,
          x_msg_count        => x_msg_count                        ,
          x_msg_data         => x_msg_data                         );
      IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        IBE_UTIL.DEBUG('Deactivate owner cart after sharing:Done');
      END IF;
    END IF; --op_code = name_cart with deactivate

    IF (p_saveshare_control_rec.operation_code = OP_DELETE_CART) THEN
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        IBE_UTIL.DEBUG('Save_share_v2:Op_code in p_saveshare_control_rec.operation_code: '||p_saveshare_control_rec.operation_code);
        IBE_UTIL.DEBUG('Save_share_v2:Ready to call IBE_QUOTE_SAVE_PVT.Delete on: '||P_Quote_header_rec.quote_header_id);
        IBE_UTIL.DEBUG('save_share_v2:Expunge flag passed to delete_cart is: '||p_saveshare_control_rec.delete_source_cart);
        IBE_UTIL.DEBUG('save_share_v2:P_Quote_header_rec.last_update_date: '||P_Quote_header_rec.last_update_date);
      END IF;
      --dbms_output.put_line('Save_share_v2:Op_code in p_saveshare_control_rec.operation_code: '||p_saveshare_control_rec.operation_code);
      --dbms_output.put_line('Save_share_v2:Ready to call IBE_QUOTE_SAVE_PVT.Delete on: '||P_Quote_header_rec.quote_header_id);

      IBE_QUOTE_SAVE_PVT.Delete(
           p_api_version_number => p_api_version
           ,p_init_msg_list      => fnd_api.g_false
           ,p_commit             => fnd_api.g_false
           ,x_return_status      => x_return_status
           ,x_msg_count          => x_msg_count
           ,x_msg_data           => x_msg_data
           ,p_quote_header_id    => P_Quote_header_rec.quote_header_id
           ,p_expunge_flag       => FND_API.G_FALSE
           ,p_minisite_id        => p_minisite_id
           ,p_last_update_date   => P_Quote_header_rec.last_update_date
           ,p_Quote_access_tbl   => p_quote_access_tbl
           ,p_notes              => p_notes
           ,p_initiator_party_id => p_party_id
           ,p_initiator_account_id => p_cust_account_id );
        IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
          RAISE FND_API.G_EXC_ERROR;
        END IF;

        IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
        IF (IBE_UTIL.G_DEBUGON = l_true) THEN
          IBE_UTIL.DEBUG('Delete owner cart :Done');
        END IF;
    END IF; --op_code = OP_DELETE_CART

    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       IBE_UTIL.DEBUG('IBE_QUOTE_SAVESHARE_V2_PVT.save_share_v2: END');
    END IF;
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO SAVESHARE_V2;
      x_return_status := FND_API.G_RET_STS_ERROR;
	  FND_Msg_Pub.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count    ,
                                p_data    => x_msg_data);
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
         IBE_Util.Debug('Expected Error in IBE_QUOTE_SAVESHARE_V2_PVT.save_share_v2()');
      END IF;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO SAVESHARE_V2;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	  FND_Msg_Pub.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count    ,
                                p_data    => x_msg_data);
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
         IBE_Util.Debug('Unexpected Error in IBE_QUOTE_SAVESHARE_V2_PVT.save_share_v2()');
      END IF;

   WHEN OTHERS THEN
      ROLLBACK TO SAVESHARE_V2;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	  IF FND_Msg_Pub.Check_Msg_Level(FND_Msg_Pub.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_Msg_Pub.Add_Exc_Msg(G_PKG_NAME,
                                 l_api_name);
      END IF;
      FND_Msg_Pub.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count    ,
                                p_data    => x_msg_data);
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
         IBE_Util.Debug('Unknown error  IBE_QUOTE_SAVESHARE_V2_PVT.save_share_v2()');
      END IF;


END;

/*To handle creating, updating, and removing of recipients.
*Usages:
-Add new set of recipients in first visit to Share Cart Details page
-Handling all possible updates to recipient info from Share Cart Details page in subsequent
updates from "Add/Modify Recipients" - this includes adding recipients, changing recipient
info (access level), and removing recipients.
-"End Working" button from recipient pages
-"Remove" button on the "List of Saved Carts" page for recipients.
-Possibly other api's to do single removes, adds, or updates. */

Procedure save_recipients  (
    P_Quote_access_tbl IN  IBE_QUOTE_SAVESHARE_pvt.QUOTE_ACCESS_TBL_TYPE
                           := IBE_QUOTE_SAVESHARE_pvt.G_miss_quote_access_Tbl     ,
    P_Quote_header_id  IN  Number                                          ,
    P_Party_id         IN  Number                := FND_API.G_MISS_NUM     ,
    P_Cust_account_id  IN  Number                := FND_API.G_MISS_NUM     ,
    P_URL              IN  Varchar2              := FND_API.G_MISS_CHAR    ,
    P_minisite_id      IN  Number                := FND_API.G_MISS_NUM     ,
    p_send_notif       IN  Varchar2              := FND_API.G_TRUE         ,
    p_notes            IN  Varchar2              := FND_API.G_MISS_CHAR    ,
    p_api_version      IN  Number                := 1                      ,
    p_init_msg_list    IN  varchar2              := FND_API.G_TRUE         ,
    p_commit           IN  Varchar2              := FND_API.G_FALSE        ,
    x_return_status    OUT NOCOPY Varchar2                                 ,
    x_msg_count        OUT NOCOPY Number                                   ,
    x_msg_data         OUT NOCOPY Varchar2                                 ) is

cursor c_check_recip_row(c_quote_hdr_id    number,
                         c_party_id        number,
                         c_cust_account_id number) is
  select quote_header_id, quote_sharee_id, quote_sharee_number
  from ibe_sh_quote_access
  where party_id        = c_party_id
  and   cust_account_id = c_cust_account_id
  and   quote_header_id = c_quote_hdr_id
  and   nvl(end_date_active, sysdate+1) > sysdate;

cursor c_recip_details(c_recip_id        NUMBER,
                       c_quote_header_id NUMBER,
                       c_party_id        NUMBER) is
  select nvl(update_privilege_type_code, fnd_api.g_miss_char) access_level,
         party_id,
         cust_account_id,
         contact_point_id,
         quote_header_id,
         quote_sharee_number,
         quote_sharee_id,
         fnd.customer_id shared_by_party_id
  from  ibe_sh_quote_access ibe, fnd_user fnd
  where ibe.created_by = fnd.user_id
  and (quote_sharee_id    = c_recip_id
      or (quote_header_id = c_quote_header_id
      and party_id        = c_party_id));

cursor c_get_owner_ids(c_quote_id number) is
  select party_id, cust_account_id
  from ASO_QUOTE_HEADERS_ALL
  where quote_header_id = c_quote_id;

cursor c_get_created_recip(c_quote_header_id number,
                           c_party_id        number,
                           c_created_by      number) is
  select quote_sharee_id
  from   ibe_sh_quote_access
  where  party_id        = c_party_id
  and    quote_header_id = c_quote_header_id
  and    created_by      = c_created_by;

rec_check_recip_row   c_check_recip_row%rowtype;
rec_recip_details     c_recip_details%rowtype;
rec_get_owner_ids c_get_owner_ids%rowtype;
rec_get_created_recip c_get_created_recip%rowtype;

l_url                     VARCHAR2(2000);
l_quote_present           NUMBER := NULL;
l_retrieval_number        NUMBER;
l_quote_recip_id          NUMBER;
t_counter                 NUMBER := 1;

l_old_access_level        VARCHAR2(1);
l_contact_point_id        NUMBER;
l_api_name                CONSTANT VARCHAR2(30)   := 'SAVERECIPIENTS_V2';
l_api_version             CONSTANT NUMBER         := 1.0;
l_call_save_contact_point VARCHAR2(1) := FND_API.G_FALSE;
l_quote_access_rec        IBE_QUOTE_SAVESHARE_pvt.QUOTE_ACCESS_rec_TYPE;
l_quote_access_rec_owr    IBE_QUOTE_SAVESHARE_pvt.QUOTE_ACCESS_rec_TYPE;
l_call_insert_handler     VARCHAR2(1) := FND_API.G_FALSE;
l_recip_party_id          NUMBER;
l_recip_cust_account_id   NUMBER;
l_sharing_partyid         NUMBER;
l_owner_partyid           NUMBER;
l_owner_accountid         NUMBER;
l_created_by              NUMBER;

BEGIN

  SAVEPOINT  SAVERECIPIENTS_V2;
  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call (	l_api_version,
                             			P_Api_Version,
                                   		l_api_name,
                       					G_PKG_NAME )
  THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;
   -- Initialize message list IF p_init_msg_list is set to TRUE.
  IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
  END IF;

   --  Initialize API return status to success
 x_return_status := FND_API.G_RET_STS_SUCCESS;
-------------------------------------------------------------------------------------------------------------
--API Body start
-------------------------------------------------------------------------------------------------------------


  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_UTIL.DEBUG('IBE_QUOTE_SAVESHARE_V2_PVT.save_recipients: START');
  END IF;
      /*Obtain the party id of the user performing the action on the UI from the env*/
      FOR rec_userenv_partyid in c_userenv_partyid LOOP
        l_sharing_partyid := rec_userenv_partyid.customer_id;
        EXIT when c_userenv_partyid%notfound;
      END LOOP;

      /*obtain the owner party_id of the cart/quote being dealt with*/
      FOR rec_get_owner_ids in c_get_owner_ids(p_quote_header_id) LOOP
        l_owner_partyid := rec_get_owner_ids.party_id;
        l_owner_accountid := rec_get_owner_ids.cust_account_id;
        EXIT when c_get_owner_ids%notfound;
      END LOOP;
      --Loop around the input quote_access table
      FOR counter IN 1..P_quote_access_tbl.COUNT LOOP
	   l_call_insert_handler     := FND_API.G_FALSE;
	   l_call_save_contact_point := FND_API.G_FALSE;
       l_quote_access_rec := P_Quote_access_tbl(counter);

        /*Obtaining the recipient details here when there is a recipient_id or a combnation of party_id
        and quote_hdr_id available in the input quote access record.
        This query will tell us if there is already a recipiet record avialable to re-use.*/
        --Old_access_level will be relevant only when the Op-code in P_Quote_access_tbl(counter) is UPDATE
        --Old_access_level will be passed to notify_access_change API
        IF (IBE_UTIL.G_DEBUGON = l_true) THEN
           IBE_UTIL.DEBUG('Incoming Quote_sharee_id = '||P_Quote_access_tbl(counter).quote_sharee_id);
           IBE_UTIL.DEBUG('Incoming Quote_header_id = '||P_Quote_access_tbl(counter).quote_header_id);
           IBE_UTIL.DEBUG('Incoming party_id = '||P_Quote_access_tbl(counter).party_id);
        END IF;

        IF(((P_Quote_access_tbl(counter).quote_sharee_id is not null) and
           (P_Quote_access_tbl(counter).quote_sharee_id <> FND_API.G_MISS_NUM))or
           ((p_quote_access_tbl(counter).party_id is not null) and
            (p_quote_access_tbl(counter).party_id <> FND_API.G_MISS_NUM))) THEN
          FOR rec_recip_details in c_recip_details(P_Quote_access_tbl(counter).quote_sharee_id,
                                                   P_Quote_access_tbl(counter).quote_header_id,
                                                   P_Quote_access_tbl(counter).party_id) LOOP

            l_old_access_level                     := rec_recip_details.access_level;
            l_quote_access_rec.contact_point_id    := rec_recip_details.contact_point_id;
            l_quote_access_rec.quote_header_id     := rec_recip_details.quote_header_id;
            l_quote_access_rec.quote_sharee_number := rec_recip_details.quote_sharee_number;

            --Use the incoming quote sharee id
            IF ((P_Quote_access_tbl(counter).quote_sharee_id is null) OR
               (P_Quote_access_tbl(counter).quote_sharee_id = FND_API.G_MISS_NUM)) THEN
              l_quote_access_rec.quote_sharee_id := rec_recip_details.quote_sharee_id;
            ELSE
              l_quote_access_rec.quote_sharee_id := P_Quote_access_tbl(counter).quote_sharee_id;
            END IF;

            l_quote_access_rec.shared_by_party_id  := rec_recip_details.shared_by_party_id;
            /*If no party_id and cust_account_id are passed in then query them from the database
            using the quote sharee id*/
            IF (((p_quote_access_tbl(counter).party_id       is null ) OR
             (p_quote_access_tbl(counter).party_id         = FND_API.G_MISS_NUM))AND
             ((p_quote_access_tbl(counter).cust_account_id   is null ) OR
             (p_quote_access_tbl(counter).cust_account_id  = FND_API.G_MISS_NUM))) THEN

              l_quote_access_rec.party_id         := rec_recip_details.party_id;
              l_quote_access_rec.cust_account_id  := rec_recip_details.cust_account_id;

            ELSE

              l_quote_access_rec.party_id        := p_quote_access_tbl(counter).party_id;
              l_quote_access_rec.cust_account_id := p_quote_access_tbl(counter).cust_account_id;

            END IF;
            EXIT WHEN c_recip_details%notfound;
          END LOOP;
        ELSE
          IF (IBE_UTIL.G_DEBUGON = l_true) THEN
             IBE_UTIL.DEBUG('Cannot query recipient details ,recipient_id is null or g_miss');
             IBE_UTIL.DEBUG('Saving recipients for first time?!');
          END IF;
        END IF; --if p_quote_access_tbl(counter).quote_sharee_id is not null and g_miss

        /*Processing the recipients in the input access table according to the op-codes
        corresponding to each recipient record*/
        --Start with 'CREATE' op_code
        IF( p_quote_access_tbl(counter).operation_code = 'CREATE') THEN

          IF (IBE_UTIL.G_DEBUGON = l_true) THEN
             IBE_UTIL.DEBUG('Operation code in quote_access_tbl is '||p_quote_access_tbl(counter).operation_code);
          END IF;
          /*Open this cursor to check if there are any inactive(end-dated) rows existing in sh_quote_access
          for this party, cust and quote combination */
          /*If there is an end-dated record present for the given combination of party, cust_account,
            quote_hdr in quote_access then use this record, else insert a new record*/
          IF (IBE_UTIL.G_DEBUGON = l_true) THEN
            IBE_UTIL.DEBUG('Save_recipients: Opening c_get_created_recip');
            IBE_UTIL.DEBUG('Save_recipients: FND_GLOBAL.USER_ID: '||FND_GLOBAL.USER_ID);
          END IF;
          l_quote_access_rec.quote_sharee_id := FND_API.G_MISS_NUM;
          FOR rec_get_created_recip in c_get_created_recip(p_quote_access_tbl(counter).quote_header_id,
                                                           p_quote_access_tbl(counter).party_id,
                                                           FND_GLOBAL.USER_ID) LOOP
            l_quote_access_rec.quote_sharee_id := rec_get_created_recip.quote_sharee_id;
            IF (IBE_UTIL.G_DEBUGON = l_true) THEN
             IBE_UTIL.DEBUG('Save_recipients: rec_get_created_recip found quote_sharee_id: '||l_quote_access_rec.quote_sharee_id);
            END IF;

            EXIT when c_get_created_recip%NOTFOUND;
          END LOOP;
          IF (l_quote_access_rec.quote_sharee_id is not null AND
              l_quote_access_rec.quote_sharee_id <> FND_API.G_MISS_NUM) THEN
            IF (IBE_UTIL.G_DEBUGON = l_true) THEN
               IBE_UTIL.DEBUG('Record found for the recipient in quote_access table, need to update it');
            END IF;

            IBE_SH_QUOTE_ACCESS_PKG.update_Row(
                      p_quote_sharee_id            => l_quote_access_rec.quote_sharee_id
                     ,p_quote_header_id            => p_quote_header_id
                     ,p_party_id                   => p_quote_access_tbl(counter).party_id
                     ,p_cust_account_id            => p_quote_access_tbl(counter).cust_account_id
                     ,p_update_privilege_type_code => p_quote_access_tbl(counter).update_privilege_type_code
                     ,p_contact_point_id           => p_quote_access_tbl(counter).contact_point_id
                     ,p_start_date_active          => sysdate
                     ,p_end_date_active            => null);
            IF (IBE_UTIL.G_DEBUGON = l_true) THEN
               IBE_UTIL.DEBUG('Finsihed calling update handler of quote_access table');
            END IF;
            --Calling save_contact_point for the updated recipient record just in case the
            --contact point has changed
            IF(p_quote_access_tbl(counter).contact_point_id is null and
               p_quote_access_tbl(counter).EMAIL_CONTACT_ADDRESS is not null) THEN
              l_call_save_contact_point := FND_API.G_TRUE;
            END IF;

          ELSE --Need to create a new record
            IF (IBE_UTIL.G_DEBUGON = l_true) THEN
               IBE_UTIL.DEBUG('Record not found for this recipient in quote_access table');
            END IF;
            --Obtain the recipient number here
            select IBE_SH_QUOTE_ACCESS_s1.nextval into l_quote_recip_id
            from dual;
            IF (IBE_UTIL.G_DEBUGON = l_true) THEN
               IBE_UTIL.DEBUG('sharee id from the sequence is '||l_quote_recip_id );
            END IF;

            IBE_QUOTE_SAVESHARE_pvt.GenerateShareeNumber(
                              p_quote_header_id => p_quote_header_id,
                              p_recip_id        => l_quote_recip_id,
                              x_sharee_number   => l_quote_access_rec.quote_sharee_number);

            IF (IBE_UTIL.G_DEBUGON = l_true) THEN
               IBE_UTIL.DEBUG('sharee number is '||l_quote_access_rec.quote_sharee_number );
            END IF;

            --Deal with saving the contact point here
            /*A contact point is created when there is an input e-mail address and a null
            input contact point id*/
            IF (p_quote_access_tbl(counter).EMAIL_CONTACT_ADDRESS is not null
              and p_quote_access_tbl(counter).EMAIL_CONTACT_ADDRESS <> fnd_api.g_miss_char
              and (p_quote_access_tbl(counter).contact_point_id is null or
                   p_quote_access_tbl(counter).contact_point_id = FND_API.G_MISS_NUM)) THEN
              IF (IBE_UTIL.G_DEBUGON = l_true) THEN
                 IBE_UTIL.DEBUG('saving contact point for the current recipient record');
              END IF;
              l_call_save_contact_point := FND_API.G_TRUE;

            --This is the case when the incoming B2B record has a valid contact_point_id
            ELSIF((p_quote_access_tbl(counter).contact_point_id is not null )
                  and (p_quote_access_tbl(counter).contact_point_id <> FND_API.G_MISS_NUM)) THEN
              IF (IBE_UTIL.G_DEBUGON = l_true) THEN
                 IBE_UTIL.DEBUG('Contact point Id found in the input quote access record');
              END IF;
              l_contact_point_id :=  p_quote_access_tbl(counter).contact_point_id;

            END IF;--save_contact_point
            l_call_insert_handler :=  FND_API.G_TRUE;

          END IF;-- existing recip or new recip

          --Constructing the URL here
          l_url := p_url||l_quote_access_rec.quote_sharee_number;
          IF (IBE_UTIL.G_DEBUGON = l_true) THEN
             IBE_UTIL.DEBUG('URL of shared cart is: '||l_url);
          END IF;

          --Saving the contact_point here
          IF l_call_save_contact_point = FND_API.G_TRUE THEN
            save_contact_point
                (  p_api_version_number => P_Api_Version
                  ,p_init_msg_list      => FND_API.G_FALSE
                  ,p_commit             => FND_API.G_FALSE
                  ,P_EMAIL              => p_quote_access_tbl(counter).EMAIL_CONTACT_ADDRESS
                  ,p_owner_table_id     => l_quote_recip_id
                  ,p_mode               => 'EMAIL'
                  ,x_contact_point_id   => l_contact_point_id
                  ,x_return_status      => x_return_status
                  ,x_msg_count          => x_msg_count
                  ,x_msg_data           => x_msg_data );
              IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
                RAISE FND_API.G_EXC_ERROR;
              END IF;
              IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;

              IF (IBE_UTIL.G_DEBUGON = l_true) THEN
                 IBE_UTIL.DEBUG('Done saving contact point: '||l_contact_point_id);
              END IF;
              l_quote_access_rec.contact_point_id := l_contact_point_id;

          END IF;-- l_call_save_contact_point

          IF (l_call_insert_handler = FND_API.G_TRUE) THEN
            IF (IBE_UTIL.G_DEBUGON = l_true) THEN
               IBE_UTIL.DEBUG('calling ins handler ');
               IBE_UTIL.DEBUG('p_quote_access_tbl(counter).recipient_name: '||p_quote_access_tbl(counter).recipient_name);
            END IF;
            IBE_SH_QUOTE_ACCESS_PKG.Insert_Row(
                  p_quote_sharee_id            => l_quote_recip_id,
                  p_quote_header_id            => p_quote_header_id,
                  p_quote_sharee_number		   => l_quote_access_rec.quote_sharee_number,
                  p_update_privilege_type_code => p_quote_access_tbl(counter).update_privilege_type_code,
                  p_party_id                   => p_quote_access_tbl(counter).party_id,
                  p_cust_account_id            => p_quote_access_tbl(counter).cust_account_id,
                  p_recipient_name             => p_quote_access_tbl(counter).recipient_name,
                  p_contact_point_id           => l_contact_point_id);
            IF (IBE_UTIL.G_DEBUGON = l_true) THEN
               IBE_UTIL.DEBUG('finished inserting ');
            END IF;
          END IF;
          l_quote_access_rec.quote_sharee_id := l_quote_recip_id;
          --calling the new shared cart notification API here

          IF ((p_send_notif = FND_API.G_TRUE) AND (p_quote_access_tbl(counter).notify_flag = FND_API.G_TRUE)) THEN
            IBE_WORKFLOW_PVT.Notify_Shared_Cart(
                p_api_version        => p_api_version      ,
                p_init_msg_list      => p_init_msg_list    ,
                p_quote_access_rec   => l_quote_access_rec ,
                p_minisite_id        => p_minisite_id      ,
                p_url                => l_url              ,
                p_shared_by_party_id => l_sharing_partyid  ,
                p_notes              => p_notes            ,
                x_return_status      => x_return_status    ,
                x_msg_count          => x_msg_count        ,
                x_msg_data           => x_msg_data         );

              IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
                RAISE FND_API.G_EXC_ERROR;
              END IF;

              IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;
          END IF;

          --DBMS_OUTPUT.PUT_LINE('Done calling the new shared cart notification API ');

        ELSIF(p_quote_access_tbl(counter).operation_code = 'UPDATE') THEN

          IF (IBE_UTIL.G_DEBUGON = l_true) THEN
             IBE_UTIL.DEBUG('Operation code in quote_access_table is UPDATE');
          END IF;
          IF((l_quote_access_rec.update_privilege_type_code is not null) and
             (l_quote_access_rec.update_privilege_type_code <> FND_API.G_MISS_CHAR) and
             (l_old_access_level <> l_quote_access_rec.update_privilege_type_code)) then
            IF (IBE_UTIL.G_DEBUGON = l_true) THEN
              IBE_UTIL.DEBUG('Calling IBE_SH_QUOTE_ACCESS_PKG.Update_Row to update the recip record');
              IBE_UTIL.DEBUG('p_quote_access_tbl(counter).quote_sharee_id: '||p_quote_access_tbl(counter).quote_sharee_id);
            END IF;

            IBE_SH_QUOTE_ACCESS_PKG.Update_Row(
              p_QUOTE_HEADER_ID               => p_quote_header_id,
              p_quote_sharee_id               => p_quote_access_tbl(counter).quote_sharee_id,
              p_UPDATE_PRIVILEGE_TYPE_CODE    => p_quote_access_tbl(counter).update_privilege_type_code);

            IF (IBE_UTIL.G_DEBUGON = l_true) THEN
               IBE_UTIL.DEBUG('Done IBE_SH_QUOTE_ACCESS_PKG.Update_Row ');
            END IF;

            /*If access level is being downgraded to 'read-only' */
            IF(p_quote_access_tbl(counter).UPDATE_PRIVILEGE_TYPE_CODE = 'R') THEN
              IF (IBE_UTIL.G_DEBUGON = l_true) THEN
                 IBE_UTIL.DEBUG('Update privilege type is downgraded to read-only');
              END IF;
              FOR rec_check_active_cart in c_check_active_cart(l_quote_access_rec.party_id ,
                                                             l_quote_access_rec.cust_account_id) loop
                l_quote_present := rec_check_active_cart.quote_header_id;
                IF (IBE_UTIL.G_DEBUGON = l_true) THEN
                  IBE_UTIL.DEBUG('Recipient has '||l_quote_present||'as active cart');
                END IF;
                IF((l_quote_present is not null) AND (p_quote_header_id = l_quote_present)) THEN
                  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
                    IBE_UTIL.DEBUG('Recipient has '||l_quote_present||' shared cart as the active-cart , delete this while downgrading level');
                  END IF;
                  --if this recipient has this shared cart as the active cart , then need to delete this
                  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
                    IBE_UTIL.DEBUG('Calling delete handler of active_quotes_all table');
                  END IF;

                  IBE_ACTIVE_QUOTES_ALL_PKG.UPDATE_ROW(
                          x_object_version_number => 1,
                          x_quote_header_id       => null,
                          x_party_id              => l_quote_access_rec.party_id       ,
                          x_cust_account_id       => l_quote_access_rec.cust_account_id,
                          X_RECORD_TYPE           => 'CART',
                          X_CURRENCY_CODE         => null,
                          x_last_update_date      => sysdate,
                          x_last_updated_by       => fnd_global.user_id,
                          x_last_update_login     => 1);
                  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
                    IBE_UTIL.DEBUG('Done calling Update handler of active_quotes_all table to erase the quote header id' );
                  END IF;
                END IF;
                EXIT WHEN c_check_active_cart%NOTFOUND;
              END LOOP; -- for c_check_active_cart
            END IF; -- when privelege is read_only

            -- new access level is available in the quote access record
            IF(p_quote_access_tbl(counter).notify_flag = FND_API.G_TRUE) THEN
              IF (IBE_UTIL.G_DEBUGON = l_true) THEN
                IBE_UTIL.DEBUG('Save_recipients: Ready to call Notify_access_change' );
              END IF;
              --dbms_output.put_line('Save_recipients: Ready to call Notify_access_change ');
              IBE_WORKFLOW_PVT.Notify_access_change(
                p_api_version        => p_api_version      ,
                p_init_msg_list      => p_init_msg_list    ,
                p_quote_access_rec   => l_quote_access_rec ,
                p_minisite_id        => p_minisite_id      ,
                p_url                => p_url              ,
                p_old_accesslevel    => l_old_access_level ,
                p_notes              => p_notes            ,
                p_shared_by_party_id => l_sharing_partyid  ,
                x_return_status      => x_return_status    ,
                x_msg_count          => x_msg_count        ,
                x_msg_data           => x_msg_data         );

                IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
                  RAISE FND_API.G_EXC_ERROR;
                END IF;

                IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                END IF;
            END IF; -- end if notify flag = true for notify access change email
          ELSE
            IF (IBE_UTIL.G_DEBUGON = l_true) THEN
              IBE_UTIL.DEBUG('Opcode was update but access level has not changed. Consider generic email');
              IBE_UTIL.DEBUG('view_shared_cart: l_sharing_partyid : ' || l_sharing_partyid);
              IBE_UTIL.DEBUG('view_shared_cart: l_owner_partyid   : ' || l_owner_partyid);
              IBE_UTIL.DEBUG('view_shared_cart: p_notes           : ' || p_notes);
              IBE_UTIL.DEBUG('view_shared_cart: l_quote_access_rec.qute_sharee_num: '||l_quote_access_rec.quote_sharee_number);
              IBE_UTIL.DEBUG('view_shared_cart: l_quote_access_rec.party_id: '||l_quote_access_rec.party_id);
            END IF;
            IF ((p_quote_access_tbl(counter).notify_flag = FND_API.G_TRUE) AND
                 (nvl(l_quote_access_rec.party_id,-1) <> l_sharing_partyid)) THEN
              l_quote_access_rec.UPDATE_PRIVILEGE_TYPE_CODE := l_old_access_level;
	      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
                 IBE_UTIL.DEBUG('l_quote_access_rec.UPDATE_PRIVILEGE_TYPE_CODE '||l_quote_access_rec.UPDATE_PRIVILEGE_TYPE_CODE);
              END IF;
              IBE_WORKFLOW_PVT.Notify_view_shared_cart(
                p_api_version       => p_api_version      ,
                p_init_msg_list     => p_init_msg_list    ,
                p_quote_access_rec  => l_quote_access_rec ,
                p_minisite_id       => p_minisite_id      ,
                p_url               => p_url              ,
                p_notes             => p_notes            ,
                p_sent_by_party_id  => l_sharing_partyid  ,
                x_return_status     => x_return_status    ,
                x_msg_count         => x_msg_count        ,
                x_msg_data          => x_msg_data         );
              IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
                RAISE FND_API.G_EXC_ERROR;
              END IF;
              IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;
            END IF; -- end if notify_flag = true for generic email
          END IF; -- end if old access level is not diff from new access level
        ELSIF(p_quote_access_tbl(counter).operation_code = 'DELETE') then
        --ELSE --orig functionality was to default to delete, so we've got to keep it that way
--IF(p_quote_access_tbl(counter).operation_code = 'DELETE') THEN  --OPERATION_CODE IS DELETE
          --DBMS_OUTPUT.PUT_LINE('Operation code in save recip is delete: Caling delete_recipient');
          IF (IBE_UTIL.G_DEBUGON = l_true) THEN
             IBE_UTIL.DEBUG('Operation code in save recip is delete');
             IBE_UTIL.DEBUG('Calling delete_recipient');
             IBE_UTIL.DEBUG('l_quote_access_rec.quote_sharee_id: '||l_quote_access_rec.quote_sharee_id);
          END IF;

          IBE_QUOTE_SAVESHARE_V2_PVT.DELETE_RECIPIENT(
            P_Quote_access_rec  => l_quote_access_rec ,
            p_minisite_id       => p_minisite_id      ,
            p_url               => p_url              ,
            p_notes             => p_notes            ,
            x_return_status     => x_return_status    ,
            x_msg_count         => x_msg_count        ,
            x_msg_data          => x_msg_data         );

            IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
              RAISE FND_API.G_EXC_ERROR;
            END IF;
            IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
          IF (IBE_UTIL.G_DEBUGON = l_true) THEN
             IBE_UTIL.DEBUG('Done calling delete_recipient');
          END IF;
        END IF ;--FOR OPERATION CODE
      END LOOP; -- end loop over input table of recipients

      --To send a generic notification to the owner of the cart
      l_quote_access_rec_owr.party_id        := l_owner_partyid;
      l_quote_access_rec_owr.quote_header_id := P_Quote_header_id;

      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        IBE_UTIL.DEBUG('l_sharing_partyid: '||l_sharing_partyid);
        IBE_UTIL.DEBUG('l_owner_partyid: '||l_owner_partyid);
        IBE_UTIL.DEBUG('l_owner_partyid: '||l_owner_accountid);
      END IF;

      IF (l_sharing_partyid <> l_owner_partyid) THEN
        -- for generic email to owner, we need to add some special parameters since we will not have a retrieval number
        l_url := p_url || '&opid=' || l_owner_partyid || '&oaid=' || l_owner_accountid;
        IF (IBE_UTIL.G_DEBUGON = l_true) THEN
          IBE_UTIL.DEBUG('url for generic email to OWNER: '||l_url);
        END IF;
        IBE_WORKFLOW_PVT.Notify_view_shared_cart(
               p_api_version       => p_api_version
              ,p_init_msg_list     => p_init_msg_list
              ,p_quote_access_rec  => l_quote_access_rec_owr
              ,p_minisite_id       => p_minisite_id
              ,p_url               => l_url
              ,p_notes             => p_notes
              ,p_sent_by_party_id  => l_sharing_partyid
              ,p_owner_party_id    => l_owner_partyid
              ,x_return_status     => x_return_status
              ,x_msg_count         => x_msg_count
              ,x_msg_data          => x_msg_data         );
             IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
              RAISE FND_API.G_EXC_ERROR;
            END IF;
            IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
      END IF;

  --DBMS_OUTPUT.PUT_LINE('IBE_QUOTE_SAVESHARE_V2_PVT.save_recipients: END ');

     -- Standard check of p_commit.
  IF FND_API.To_Boolean( p_commit ) THEN
    COMMIT WORK;
  END IF;

  -- Standard call to get message count and if count is 1, get message info.
  FND_Msg_Pub.Count_And_Get(p_encoded => FND_API.G_FALSE,
                            p_count   => x_msg_count    ,
                            p_data    => x_msg_data);
  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_UTIL.DEBUG('IBE_QUOTE_SAVESHARE_V2_PVT.save_recipients: END');
  END IF;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO SAVERECIPIENTS_V2;
      x_return_status := FND_API.G_RET_STS_ERROR;
	  FND_Msg_Pub.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count    ,
                                p_data    => x_msg_data);
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
         IBE_Util.Debug('Expected error in IBE_QUOTE_SAVESHARE_V2_PVT.SAVE_RECIPIENTS()');
      END IF;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO SAVERECIPIENTS_V2;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	  FND_Msg_Pub.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count    ,
                                p_data    => x_msg_data);
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
         IBE_Util.Debug('Unxpected error in  IBE_QUOTE_SAVESHARE_V2_PVT.SAVE_RECIPIENTS()');
      END IF;

   WHEN OTHERS THEN
      ROLLBACK TO SAVERECIPIENTS_V2;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	  IF FND_Msg_Pub.Check_Msg_Level(FND_Msg_Pub.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_Msg_Pub.Add_Exc_Msg(G_PKG_NAME,
                                 l_api_name);
      END IF;
      FND_Msg_Pub.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count    ,
                                p_data    => x_msg_data);
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
         IBE_Util.Debug('Unknown exception IBE_QUOTE_SAVESHARE_V2_PVT.SAVE_RECIPIENTS()');
      END IF;

END;

/*To handle new Active Cart Definition
*Usages:
-"Edit" button called from List of Saved Carts, List of Shared Out Carts, List of Recipient Carts,
or Cart Details */

Procedure activate_quote  (
    P_Quote_header_rec IN  ASO_QUOTE_PUB.Qte_Header_Rec_Type ,
    P_Party_id         IN  NUMBER := FND_API.G_MISS_NUM      ,
    P_Cust_account_id  IN  NUMBER := FND_API.G_MISS_NUM      ,
    P_control_rec      IN ASO_QUOTE_PUB.control_rec_type
                          := ASO_QUOTE_PUB.G_MISS_Control_Rec,
    p_retrieval_number IN  NUMBER := FND_API.G_MISS_NUM      ,
    p_api_version      IN  NUMBER   := 1                     ,
    p_init_msg_list    IN  VARCHAR2 := FND_API.G_TRUE        ,
    p_commit           IN  VARCHAR2 := FND_API.G_FALSE       ,
    x_return_status    OUT NOCOPY VARCHAR2                   ,
    x_msg_count        OUT NOCOPY NUMBER                     ,
    x_msg_data         OUT NOCOPY VARCHAR2                   ) is

l_current_cartname            VARCHAR2(2000);
l_new_cartname                VARCHAR2(2000);
l_quote_header_rec            ASO_QUOTE_PUB.Qte_header_rec_type;
l_quote_header_id             NUMBER;
l_last_update_date            date;
l_control_rec                 ASO_Quote_Pub.Control_Rec_Type
                              := ASO_Quote_Pub.G_Miss_Control_Rec;
l_ac_present                  NUMBER         := null;   --active cart present in active carts table or not
l_ac_party_id                 NUMBER         := null;
l_qhac_present                NUMBER         := null;   --active cart present in quote headers or not
l_qhac_quote_name             VARCHAR2(2000) := null;
l_cart_type                   VARCHAR2(2000) ;
l_api_name                    CONSTANT VARCHAR2(30)   := 'ACTIVATEQUOTE_V2';
l_api_version                 CONSTANT NUMBER         := 1.0;
l_sharee_party_id             NUMBER := FND_API.G_MISS_NUM;
l_sharee_acct_id              NUMBER := FND_API.G_MISS_NUM;
l_sharee_number               NUMBER := FND_API.G_MISS_NUM;


cursor c_check_ac_aqa(c_party_id number,
                      c_cust_account_id number) is
  select aq.quote_header_id ,aq.party_id
  from ibe_active_quotes aq
  where party_id      = c_party_id
  and cust_account_id = c_cust_account_id
  and record_type     = 'CART';

cursor c_check_guest_oneclk(c_qte_hdr_id NUMBER) is
  select quote_source_code
  from aso_quote_headers
  where quote_header_id = c_qte_hdr_id;

cursor c_check_ac_qh(c_qh_id NUMBER) is
  select quote_header_id, quote_name
  from aso_quote_headers
  where quote_header_id = c_qh_id;

rec_check_ac_qh           c_check_ac_qh%rowtype;
rec_check_ac_aqa          c_check_ac_aqa%rowtype;
rec_check_guest_oneclk    c_check_guest_oneclk%rowtype;


BEGIN

  SAVEPOINT  ACTIVATEQUOTE_V2;
  -- Standard call to check for call compatibility.
  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_UTIL.DEBUG('Activate_quote:Before caling the compatible_api_call API');
  END IF;
  IF NOT FND_API.Compatible_API_Call (	l_api_version,
                             			P_Api_Version,
                                   		l_api_name,
                       					G_PKG_NAME )
  THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;
   -- Initialize message list IF p_init_msg_list is set to TRUE.
  IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
  END IF;

   --  Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;


  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_UTIL.DEBUG('IBE_QUOTE_SAVESHARE_V2_PVT.activate_quote: START');
     IBE_UTIL.DEBUG('p_party_id : '||p_party_id);
     IBE_UTIL.DEBUG('p_cust_account_id: '||p_cust_account_id);
	IBE_UTIL.DEBUG('p_retrieval_number: '||p_retrieval_number);
	IBE_UTIL.DEBUG('p_quote_header_id: '||p_quote_header_rec.quote_header_id);
  END IF;
  --DBMS_OUTPUT.PUT_LINE('IBE_QUOTE_SAVESHARE_V2_PVT.activate_quote: START');
  FOR rec_check_guest_oneclk in c_check_guest_oneclk(p_quote_header_rec.quote_header_id) LOOP
    l_cart_type := rec_check_guest_oneclk.quote_source_code;
    EXIT WHEN c_check_guest_oneclk%notfound;
  END LOOP;
  --DBMS_OUTPUT.PUT_LINE('l_cart_type: '||nvl(l_cart_type,'Null'));
  --Cannot activate a guest cart, Installbase cart, Punchout cart
  IF ((l_cart_type <> 'IStore Walkin')and
      (l_cart_type <> 'IStore Oneclick')and
      (l_cart_type <> 'IStore InstallBase')and
      (l_cart_type <> 'IStore ProcPunchout'))THEN
     IBE_Quote_Misc_pvt.validate_user_update
      (p_quote_header_id        => p_quote_header_rec.quote_header_id,
       p_party_id               => p_party_id,
       p_cust_account_id        => p_cust_account_id,
       p_quote_retrieval_number => p_retrieval_number,
       p_validate_user          => FND_API.G_TRUE,
       p_last_update_date       => p_quote_header_rec.last_update_date,
       x_return_status          => x_return_status,
       x_msg_count              => x_msg_count,
       x_msg_data               => x_msg_data);

      IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
    --DBMS_OUTPUT.PUT_LINE('Opening the cursor to check  active cart present in active carts table');
    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       IBE_UTIL.DEBUG('Opening the cursor to check  active cart present in active carts table');
    END IF;
    /*c_check_ac_aqa will query to check if p_party_id already has an active cart in active_quotes table
    If yes then update the quote_header_id of this record to p_quote_header_rec.quote_header_id(new active_cart hdr_id)
    else insert a record into the active_quotes table*/

    for rec_check_ac_aqa in c_check_ac_aqa( p_party_id,
                                            p_cust_account_id) loop
      l_ac_present  := rec_check_ac_aqa.quote_header_id;
      l_ac_party_id := rec_check_ac_aqa.party_id;
      exit when c_check_ac_aqa%notfound;
    end loop;

    IF (l_ac_present is not null) THEN
      --There already an active cart for p_party_id in active_quotes_table
      --DBMS_OUTPUT.PUT_LINE('active cart present in active carts table for: '||l_quote_header_rec.quote_header_id);
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
         IBE_UTIL.DEBUG('active cart present in active carts table l_ac_present: '||l_ac_present);
      END IF;

      IF(FND_API.G_TRUE=IBE_QUOTE_MISC_PVT.is_quote_usable(l_ac_present,p_party_id,p_cust_account_id)) THEN
        IF (IBE_UTIL.G_DEBUGON = l_true) THEN
           IBE_UTIL.DEBUG('current active cart is still validate.');
           IBE_UTIL.DEBUG('checking if it is a unnamed cart.');
        END IF;
      for rec_check_ac_qh in c_check_ac_qh(l_ac_present) loop
        --Openin this cursor to check if the active cart name is IBEUNNAMED
        --DBMS_OUTPUT.PUT_LINE('Opened cursor c_check_ac_qh ');
        l_qhac_present    := rec_check_ac_qh.quote_header_id;
        l_qhac_quote_name := rec_check_ac_qh.quote_name;
        exit when c_check_ac_qh%notfound;

        IF (IBE_UTIL.G_DEBUGON = l_true) THEN
           IBE_UTIL.DEBUG('l_qhac_present: '||l_qhac_present);
           IBE_UTIL.DEBUG('l_qhac_quote_name: '||l_qhac_quote_name);
        END IF;

      end loop;
      --DBMS_OUTPUT.PUT_LINE('after end loop of c_check_ac_qh ');

      IF (l_qhac_quote_name = 'IBE_PRMT_SC_UNNAMED') THEN

        --change the IBEUNNAMED cart to IBEDEFAULTNAMED and save it by calling IBE_Quote_Save_pvt.SAVE
        l_quote_header_rec.quote_header_id := l_qhac_present;
        l_quote_header_rec.quote_name      := 'IBE_PRMT_SC_DEFAULTNAMED';
        --reasons for calling save here
        --to save the IBEUNNAMED cart to IBEDEFAULTNAMED
        IF (IBE_UTIL.G_DEBUGON = l_true) THEN
           IBE_UTIL.DEBUG('Unnamed cart found for: '||l_quote_header_rec.quote_header_id);
           IBE_UTIL.DEBUG('renaming it to IBEDEFAULTNAMED...');
        END IF;
        IBE_Quote_Save_pvt.save(
                  p_api_version_number => p_api_version      ,
                  p_init_msg_list      => fnd_api.g_false    ,
                  p_commit             => fnd_api.g_false    ,

                  p_qte_header_rec     => l_Quote_header_rec ,
                  --p_control_rec        => l_control_rec      ,
                  x_quote_header_id    => l_quote_header_id  ,
                  x_last_update_date   => l_last_update_date ,

                  x_return_status      => x_return_status    ,
                  x_msg_count          => x_msg_count        ,
                  x_msg_data           => x_msg_data);
        IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
          IF (IBE_UTIL.G_DEBUGON = l_true) THEN
             IBE_UTIL.DEBUG('failed to rename the cart.');
          END IF;
          RAISE FND_API.G_EXC_ERROR;
        END IF;

        IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
          IF (IBE_UTIL.G_DEBUGON = l_true) THEN
             IBE_UTIL.DEBUG('failed to rename the cart, unexpected error.');
          END IF;
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

      END IF;--l_qhac_quote_name = 'IBEUNNAMED'
      ELSE
        IF (IBE_UTIL.G_DEBUGON = l_true) THEN
           IBE_UTIL.DEBUG('invalid or expired active cart ignored.');
        END IF;
      END IF; -- end of is_quote_usable
    END IF;  --l_ac_present

    IF (l_ac_party_id is not null) THEN
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
         IBE_UTIL.DEBUG('IBE_QUOTE_SAVESHARE_V2_PVT.activate_quote:User already has a row in active_quotes table');
         IBE_UTIL.DEBUG('IBE_QUOTE_SAVESHARE_V2_PVT.activate_quote:Calling update row hdlr');
      END IF;
      --DBMS_OUTPUT.PUT_LINE('Calling update row handler for active carts');

      IBE_ACTIVE_QUOTES_ALL_PKG.update_row(
                  X_OBJECT_VERSION_NUMBER  => 1,
                  x_last_update_date       => sysdate,
                  x_last_updated_by        => fnd_global.user_id,
                  x_last_update_login      => 1,
		        X_RECORD_TYPE            => 'CART',
                  X_CURRENCY_CODE          => null,
                  x_party_id               => p_party_id,
                  x_cust_account_id        => p_cust_account_id,
                  x_quote_header_id        => p_quote_header_rec.quote_header_id);

    ELSE

      --no previous active carts present for p_party_id hence inserting a new record
      --DBMS_OUTPUT.PUT_LINE('no active carts present for p_party_id hence inserting a new record');
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
         IBE_UTIL.DEBUG('no active carts present for p_party_id hence inserting a new record');
         IBE_UTIL.DEBUG('Quote header id of new active active cart is: '||p_quote_header_rec.quote_header_id);
      END IF;
      IBE_ACTIVE_QUOTES_ALL_PKG.Insert_row(
                X_OBJECT_VERSION_NUMBER  => 1,
                X_QUOTE_HEADER_ID        => p_quote_header_rec.quote_header_id,
                X_PARTY_ID               => p_party_id,
                X_CUST_ACCOUNT_ID        => p_cust_account_id,
                X_LAST_UPDATE_DATE       => sysdate,
                X_CREATION_DATE          => sysdate,
		      X_RECORD_TYPE            => 'CART',
                X_CURRENCY_CODE          => null,
                X_CREATED_BY             => fnd_global.USER_ID,
                X_LAST_UPDATED_BY        => fnd_global.USER_ID,
                X_LAST_UPDATE_LOGIN      => fnd_global.conc_login_id,
                X_ORG_ID                 => MO_GLOBAL.get_current_org_id());
    END IF;

    if ((P_control_rec.pricing_request_type <> FND_API.G_MISS_CHAR) or
        (P_control_rec.header_pricing_event <> FND_API.G_MISS_CHAR) or
        (P_control_rec.line_pricing_event <> FND_API.G_MISS_CHAR) or
        (P_control_rec.CALCULATE_TAX_FLAG <> FND_API.G_MISS_CHAR) or
        (P_control_rec.CALCULATE_FREIGHT_CHARGE_FLAG <> FND_API.G_MISS_CHAR))
    then
      --1. re-price cart based on the state of control_rec
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        IBE_UTIL.DEBUG('Calling SAVE');
        IBE_UTIL.DEBUG('reprice cart based on the state of control_rec');
      END IF;
      if (p_retrieval_number <> FND_API.G_MISS_NUM) then
        IF (IBE_UTIL.G_DEBUGON = l_true) THEN
            IBE_UTIL.DEBUG('repricing as recipient; retrieval num: ' || p_retrieval_number);
        END IF;

        l_sharee_number := p_retrieval_number;
        l_sharee_party_id := p_party_id;
        l_sharee_acct_id  := p_cust_account_id;
      end if;
      IBE_Quote_Save_pvt.save(
                  p_api_version_number => p_api_version             ,
                  p_init_msg_list      => fnd_api.g_false           ,
                  p_commit             => fnd_api.g_false           ,

                  p_qte_header_rec     => p_Quote_header_rec        ,
                  p_control_rec        => P_control_rec              ,

                  p_sharee_number      => l_sharee_number           ,
                  p_sharee_party_id      => l_sharee_party_id       ,
                  p_sharee_cust_account_id  => l_sharee_acct_id        ,

                  x_quote_header_id    => l_quote_header_id          ,
                  x_last_update_date   => l_last_update_date         ,

                  x_return_status      => x_return_status            ,
                  x_msg_count          => x_msg_count                ,
                  x_msg_data           => x_msg_data);
      IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
    end if;
  ELSE
    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       IBE_UTIL.DEBUG('Cannot activate a '||nvl(l_cart_type,'Invalid ')||' Cart');
    END IF;
    --DBMS_OUTPUT.PUT_LINE('Cannot activate a '||nvl(l_cart_type,'Invalid ')||' Cart');

  END IF; --qute source code check
  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_UTIL.DEBUG('IBE_QUOTE_SAVESHARE_V2_PVT.activate_quote: END');
  END IF;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO ACTIVATEQUOTE_V2;
      x_return_status := FND_API.G_RET_STS_ERROR;
	  FND_Msg_Pub.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count    ,
                                p_data    => x_msg_data);
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
         IBE_Util.Debug('Expected error in  IBE_QUOTE_SAVESHARE_V2_PVT.activate_quote()');
      END IF;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO ACTIVATEQUOTE_V2;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	  FND_Msg_Pub.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count    ,
                                p_data    => x_msg_data);
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
         IBE_Util.Debug('Unexpected error in  IBE_QUOTE_SAVESHARE_V2_PVT.activate_quote()');
      END IF;

   WHEN OTHERS THEN
      ROLLBACK TO ACTIVATEQUOTE_V2;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	  IF FND_Msg_Pub.Check_Msg_Level(FND_Msg_Pub.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_Msg_Pub.Add_Exc_Msg(G_PKG_NAME,
                                 l_api_name);
      END IF;
      FND_Msg_Pub.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count    ,
                                p_data    => x_msg_data);
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
         IBE_Util.Debug('Unknown error IBE_QUOTE_SAVESHARE_V2_PVT.activate_quote()');
      END IF;

END;

PROCEDURE save_contact_point(
  p_api_version_number IN  NUMBER
  ,p_init_msg_list     IN  VARCHAR2 := FND_API.G_FALSE
  ,p_commit            IN  VARCHAR2 := FND_API.G_FALSE
  ,P_URL               IN  VARCHAR2 := FND_API.G_MISS_char
  ,P_EMAIL             IN  VARCHAR2 := FND_API.G_MISS_char
  ,p_owner_table_id    IN  NUMBER
  ,p_mode              IN  VARCHAR2
  ,x_contact_point_id  OUT NOCOPY NUMBER
  ,X_Return_Status     OUT NOCOPY VARCHAR2
  ,X_Msg_Count         OUT NOCOPY NUMBER
  ,X_Msg_Data          OUT NOCOPY VARCHAR2
)
IS
  l_api_name             CONSTANT VARCHAR2(30)  := 'SaveContactPoint';
  l_api_version          CONSTANT NUMBER  := 1.0;
  l_application_id       CONSTANT NUMBER  := 671;
  l_object_version_number NUMBER          := 1;
  l_created_by_module VARCHAR2(30)        := 'SHARED CARTS';

  l_test                  number;

  l_contact_points_rec       hz_CONTACT_POINT_V2PUB.CONTACT_POINT_REC_TYPE;

  l_email_rec                hz_CONTACT_POINT_V2PUB.EMAIL_REC_TYPE
                             := hz_CONTACT_POINT_V2PUB.g_miss_EMAIL_REC;
  l_web_rec                  hz_CONTACT_POINT_V2PUB.web_REC_TYPE
                             := hz_CONTACT_POINT_V2PUB.g_miss_web_REC;

  Cursor c_getContactInfo(c_owner_table_id Number
                       ,c_contact_point_type varchar2
                       ,c_owner_table_name  varchar2) IS
  Select contact_point_id, object_version_number
  From  hz_contact_points
  Where OWNER_TABLE_NAME   = c_owner_table_name
  AND  CONTACT_POINT_TYPE  = c_CONTACT_POINT_TYPE
  AND OWNER_TABLE_ID       = c_owner_table_id;



BEGIN
   -- Standard Start of API savepoint
  SAVEPOINT    SAVECONTACTPOINT_PVT;
  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call (l_api_version,
                                      P_Api_Version_Number,
                                      l_api_name,
                                      G_PKG_NAME )
  THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;
   -- Initialize message list IF p_init_msg_list is set to TRUE.
  IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
  END IF;

   --  Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_UTIL.debug('Inside Save_contact_point API');
  END IF;
  --DBMS_OUTPUT.PUT_LINE('Inside Save_contact_point API');
  l_contact_points_rec.status             := 'A';
  l_contact_points_rec.owner_table_id     := p_owner_table_id;
  l_contact_points_rec.created_by_module  := l_created_by_module;
  l_contact_points_rec.application_id     := l_application_id;

  IF (p_mode = 'EMAIL') THEN
       --DBMS_OUTPUT.PUT_LINE('Mode of contact point is EMAIL');
       IF (IBE_UTIL.G_DEBUGON = l_true) THEN
          IBE_UTIL.debug('Mode of contact point is EMAIL');
       END IF;
       l_contact_points_rec.contact_point_type := 'EMAIL';
       l_contact_points_rec.owner_table_name   := 'IBE_SH_QUOTE_ACCESS';
       l_email_rec.email_address               := P_EMAIL;
  elsif (p_mode = 'WEB') THEN
       IF (IBE_UTIL.G_DEBUGON = l_true) THEN
          IBE_UTIL.debug('Mode of contact point is WEB');
       END IF;

       l_contact_points_rec.contact_point_type := 'WEB';
       l_contact_points_rec.owner_table_name   := 'IBE_SH_QUOTE_ACCESS';
       l_web_rec.url                           := P_URL;
       l_web_rec.web_type                      := 'com';
  END IF;


  SELECT COUNT(contact_point_id)
  INTO l_test
  FROM hz_contact_points
  WHERE owner_table_name = l_contact_points_rec.owner_table_name
    AND owner_table_id   = l_contact_points_rec.owner_table_id;

  IF l_test = 0 THEN
       IF (IBE_UTIL.G_DEBUGON = l_true) THEN
          IBE_UTIL.DEBUG('call hz_conteact_point_pub.create_contact_points at'
                     || to_char(sysdate, 'mm/dd/yyyy:hh24:MI:SS'));
       END IF;

       --DBMS_OUTPUT.PUT_LINE('Create contact point ');
       hz_contact_point_v2pub.create_contact_point
       (    p_init_msg_list      => FND_API.G_FALSE
           ,p_contact_point_rec => l_contact_points_rec
           ,p_web_rec            => l_web_rec
           ,p_email_rec          => l_email_rec
           ,x_contact_point_id   => x_contact_point_id
           ,x_return_status      => x_return_status
           ,x_msg_count          => x_msg_count
           ,x_msg_data           => x_msg_data
       );
       IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
         RAISE FND_API.G_EXC_ERROR;
       END IF;
       IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;
       IF (IBE_UTIL.G_DEBUGON = l_true) THEN
          IBE_UTIL.DEBUG('done hz_conteact_point_pub.create_contact_points at'
                     || to_char(sysdate, 'mm/dd/yyyy:hh24:MI:SS'));
       END IF;

  else
       --DBMS_OUTPUT.PUT_LINE('Updating contact point ');
       open c_getContactInfo(l_contact_points_rec.owner_table_id
                             ,l_contact_points_rec.contact_point_type
                             ,l_contact_points_rec.owner_table_name);
       fetch c_getContactInfo into  l_contact_points_rec.contact_point_id
                                    ,l_object_version_number;
       close c_getContactInfo;
       IF (IBE_UTIL.G_DEBUGON = l_true) THEN
          IBE_UTIL.DEBUG('call hz_conteact_point_pub.update_contact_points at'
                      || to_char(sysdate, 'mm/dd/yyyy:hh24:MI:SS'));
       END IF;

       hz_contact_point_v2pub.update_contact_point(
           p_init_msg_list      => FND_API.G_FALSE
          ,p_contact_point_rec => l_contact_points_rec
          ,p_web_rec            => l_web_rec
          ,p_email_rec          => l_email_rec
          ,p_object_version_number   => l_object_version_number
          ,x_return_status      => x_return_status
          ,x_msg_count          => x_msg_count
          ,x_msg_data           => x_msg_data);

       IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
              RAISE FND_API.G_EXC_ERROR;
       END IF;

       IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;
       IF (IBE_UTIL.G_DEBUGON = l_true) THEN
          IBE_UTIL.DEBUG('done hz_conteact_point_pub.update_contact_points at'
                      || to_char(sysdate, 'mm/dd/yyyy:hh24:MI:SS'));
       END IF;
  END IF;

   -- Standard check of p_commit.
  IF FND_API.To_Boolean( p_commit ) THEN
    COMMIT WORK;
  END IF;

   -- Standard call to get message count and IF count is 1, get message info.
   FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                             p_count   => x_msg_count,
                             p_data    => x_msg_data);
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO SAVECONTACTPOINT_PVT;
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        IBE_UTIL.DEBUG('Expected exception in Ibe_quote_saveshare_v2_pvt.SaveContactPoint');
      end if;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count,
                                p_data    => x_msg_data);
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        IBE_UTIL.DEBUG('Unexpected exception in Ibe_quote_saveshare_v2_pvt.SaveContactPoint');
      end if;

      ROLLBACK TO SAVECONTACTPOINT_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count,
                                p_data    => x_msg_data);
   WHEN OTHERS THEN
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        IBE_UTIL.DEBUG('Unknown exception in Ibe_quote_saveshare_v2_pvt.SaveContactPoint');
      end if;

      ROLLBACK TO SAVECONTACTPOINT_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,
                                 l_api_name);
      END IF;

      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count,
                                p_data    => x_msg_data);
END SAVE_CONTACT_POINT;

/*To mark an active cart as no longer active for the submitted user (either owner or recipient as identified
  by party_id  and account_id) and/or all of that cart's recipients.
*Usages:
-User clicks "save" on a saved active cart
-Other api's where the quote is no longer active (submit quote, request sales assistance, etc)*/

Procedure deactivate_quote  (
    P_Quote_header_id  IN  Number                       ,
    P_Party_id         IN  Number := FND_API.G_MISS_NUM ,
    P_Cust_account_id  IN  Number := FND_API.G_MISS_NUM ,
    P_minisite_id      IN  Number := FND_API.G_MISS_NUM ,
    p_api_version      IN  NUMBER   := 1                ,
    p_init_msg_list    IN  VARCHAR2 := FND_API.G_TRUE   ,
    p_commit           IN  VARCHAR2 := FND_API.G_FALSE ,
    x_return_status    OUT NOCOPY VARCHAR2             ,
    x_msg_count        OUT NOCOPY NUMBER               ,
    x_msg_data         OUT NOCOPY VARCHAR2             ) is

    l_api_name                 CONSTANT VARCHAR2(30)   := 'DEACTIVATEQUOTE_V2';
    l_api_version              CONSTANT NUMBER         := 1.0;

cursor c_select_recip(c_qte_hdr_id number) is
  select party_id, cust_account_id
  from ibe_sh_quote_access
  where quote_header_id = c_qte_hdr_id
  and nvl(end_date_active, sysdate+1) > sysdate ;

rec_select_recip  c_select_recip%rowtype;
l_party_cust_tbl  IBE_QUOTE_SAVESHARE_pvt.QUOTE_ACCESS_Tbl_Type
                  := IBE_QUOTE_SAVESHARE_pvt.g_miss_QUOTE_ACCESS_Tbl;
counter           NUMBER := 1;

BEGIN

  SAVEPOINT  DEACTIVATEQUOTE_V2;
  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call (	l_api_version,
                             			P_Api_Version,
                                   		l_api_name,
                       					G_PKG_NAME )
  THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;
   -- Initialize message list IF p_init_msg_list is set to TRUE.
  IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
  END IF;

   --  Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  -------------------------------------------------------------------------------------------------------------
  --API Body start
  -------------------------------------------------------------------------------------------------------------
--dbms_output.put_line(' Deactivate API: Trying to deactivate: '||rec_check_active_cart.quote_header_id);
    FOR rec_check_active_cart in c_check_active_cart(p_party_id,
                                                     p_cust_account_id) LOOP
      IF(rec_check_active_cart.quote_header_id is not null) THEN
        IF (IBE_UTIL.G_DEBUGON = l_true) THEN
           IBE_UTIL.DEBUG('Deactivate API: Trying to deactivate: '||rec_check_active_cart.quote_header_id);
           --dbms_output.put_line(' Deactivate API: Trying to deactivate: '||rec_check_active_cart.quote_header_id);
        END IF;

        --DBMS_OUTPUT.PUT_LINE('rec_check_active_cart.quote_header_id '||rec_check_active_cart.quote_header_id );
        IF (IBE_UTIL.G_DEBUGON = l_true) THEN
           IBE_UTIL.DEBUG('Calling update handler of active_quotes_all table');
        END IF;
        --DBMS_OUTPUT.PUT_LINE('Calling update handler of active_quotes_all table');

        --DBMS_OUTPUT.PUT_LINE('P_quote_header_id '||P_quote_header_id);
        --DBMS_OUTPUT.PUT_LINE('p_quote_access_tbl(counter).party_id '||p_party_id);
        --DBMS_OUTPUT.PUT_LINE('p_quote_access_tbl(counter).cust_account_id '||p_cust_account_id);

         IBE_ACTIVE_QUOTES_ALL_PKG.UPDATE_ROW(
                          X_OBJECT_VERSION_NUMBER => 1,
                          X_QUOTE_HEADER_ID       => null,
                          X_PARTY_ID              => p_party_id       ,
                          X_CUST_ACCOUNT_ID       => p_cust_account_id,
			           X_RECORD_TYPE           => 'CART',
                          X_CURRENCY_CODE         => null,
                          x_last_update_date      => sysdate,
                          x_last_updated_by       => fnd_global.user_id,
                          x_last_update_login     => 1);
        IF (IBE_UTIL.G_DEBUGON = l_true) THEN
           IBE_UTIL.DEBUG('Done calling Update handler of active_quotes_all table to erase the quote header id' );
        END IF;
        --DBMS_OUTPUT.PUT_LINE('Done calling delete handler of active_quotes_all table');
      END IF;
    EXIT when c_check_active_cart%notfound;
    END LOOP; --for c_check_active_cart

    -- Standard check of p_commit.
    IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
    END IF;

    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       IBE_UTIL.DEBUG('IBE_QUOTE_SAVESHARE_V2_PVT.deactivate_quote: END');
    END IF;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO DEACTIVATEQUOTE_V2;
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        IBE_UTIL.DEBUG('Expected exception in Ibe_quote_saveshare_v2_pvt.Deactivate_quote');
      end if;

      x_return_status := FND_API.G_RET_STS_ERROR;
	  FND_Msg_Pub.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count    ,
                                p_data    => x_msg_data);
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
         IBE_Util.Debug('Unexpected error in  IBE_QUOTE_SAVESHARE_V2_PVT.deactivate_quote');
      END IF;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO DEACTIVATEQUOTE_V2;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	  FND_Msg_Pub.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count    ,
                                p_data    => x_msg_data);
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
         IBE_Util.Debug('Unknown error in  IBE_QUOTE_SAVESHARE_V2_PVT.deactivate_quote');
      END IF;

   WHEN OTHERS THEN
      ROLLBACK TO DEACTIVATEQUOTE_V2;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	  IF FND_Msg_Pub.Check_Msg_Level(FND_Msg_Pub.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_Msg_Pub.Add_Exc_Msg(G_PKG_NAME,
                                 l_api_name);
      END IF;
      FND_Msg_Pub.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count    ,
                                p_data    => x_msg_data);
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
         IBE_Util.Debug('Abnormal end   IBE_QUOTE_SAVESHARE_V2_PVT.deactivate_quote');
      END IF;

END;

/*to handle new Active Cart Definition (may be able to use original version w/ updates to handle new
active cart definition)
*Usages:
-Saving active cart and selecting a previously saved cart to append to.
*/
Procedure APPEND_QUOTE(
    P_source_quote_header_id  IN Number                             ,
    P_source_last_update_date IN Date                               ,
    P_target_header_rec       IN ASO_QUOTE_PUB.Qte_Header_Rec_Type  ,
    P_control_rec             IN ASO_QUOTE_PUB.control_rec_type
                               := ASO_QUOTE_PUB.G_MISS_Control_Rec  ,
    P_delete_source_cart      IN Varchar2  := FND_API.G_TRUE         ,
    P_combinesameitem         IN Varchar2  := FND_API.G_TRUE         ,
    P_minisite_id             IN Number    := FND_API.G_MISS_NUM     ,
    p_api_version             IN  NUMBER   := 1                      ,
    p_init_msg_list           IN  VARCHAR2 := FND_API.G_TRUE         ,
    p_commit                  IN  VARCHAR2 := FND_API.G_FALSE        ,
    x_return_status           OUT NOCOPY VARCHAR2                    ,
    x_msg_count               OUT NOCOPY NUMBER                      ,
    x_msg_data                OUT NOCOPY VARCHAR2                           ) is

    l_api_name                 CONSTANT VARCHAR2(30)   := 'APPENDQUOTE_V2';
    l_api_version              CONSTANT NUMBER         := 1.0;


    l_qte_line_tbl             ASO_QUOTE_PUB.qte_line_tbl_type;
    l_qte_line_dtl_tbl         ASO_QUOTE_PUB.qte_line_dtl_tbl_type;
    l_line_attr_ext_tbl        ASO_Quote_Pub.Line_Attribs_Ext_tbl_Type;
    l_line_rltship_tbl         ASO_QUOTE_PUB.line_rltship_tbl_type;
    l_ln_price_attributes_tbl  ASO_Quote_Pub.Price_Attributes_Tbl_Type;
    l_hd_shipment_tbl          ASO_Quote_Pub.Shipment_rec_Type
                                   := ASO_Quote_Pub.G_MISS_SHIPMENT_rec;
    l_last_update_date         DATE;
    l_qte_header_id            NUMBER;

    -- added 12/22/03: PRG, no line merge
    l_Price_Adjustment_Tbl       ASO_Quote_Pub.Price_Adj_Tbl_Type;
    l_Price_Adj_Rltship_Tbl      ASO_Quote_Pub.Price_Adj_Rltship_Tbl_Type;

BEGIN

  SAVEPOINT  APPENDQUOTE_V2;
  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call (	l_api_version,
                             			P_Api_Version,
                                   		l_api_name,
                       					G_PKG_NAME )
  THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;
   -- Initialize message list IF p_init_msg_list is set to TRUE.
  IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
  END IF;

   --  Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;
-------------------------------------------------------------------------------------------------------------
--API Body start
-------------------------------------------------------------------------------------------------------------
  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_UTIL.DEBUG('IBE_QUOTE_SAVESHARE_V2_PVT.APPEND_QUOTE: START');
  END IF;

  IBE_Quote_Misc_pvt.validate_user_update
      (p_quote_header_id  => P_source_quote_header_id,
       p_validate_user    => FND_API.G_TRUE,
       x_return_status    => x_return_status,
       x_msg_count        => x_msg_count,
       x_msg_data         => x_msg_data);

    IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_UTIL.DEBUG('IBE_QUOTE_SAVESHARE_V2_PVT.APPEND_QUOTE:Calling IBE_QUOTE_SAVESHARE_pvt.Copy_lines');
  END IF;
  --DBMS_OUTPUT.PUT_LINE('IBE_QUOTE_SAVESHARE_V2_PVT.APPEND_QUOTE:Calling IBE_QUOTE_SAVESHARE_pvt.Copy_lines ');

  IBE_QUOTE_SAVESHARE_pvt.COPY_LINES(
      p_api_version_number      => p_api_version                      ,
      p_init_msg_list           => FND_API.G_FALSE                    ,
      p_commit                  => FND_API.G_FALSE                    ,

      X_Return_Status           => X_Return_Status                    ,
      X_Msg_Count               => X_Msg_Count                        ,
      X_Msg_Data                => X_Msg_Data                         ,

      p_from_quote_header_id    => P_source_quote_header_id           ,
      p_to_quote_header_id      => p_target_header_rec.quote_header_id,
      x_qte_line_tbl            => l_qte_line_tbl                     ,
      x_qte_line_dtl_tbl        => l_qte_line_dtl_tbl                 ,
      x_line_attr_ext_tbl       => l_line_attr_ext_tbl                ,
      x_line_rltship_tbl        => l_line_rltship_tbl                 ,
      x_ln_price_attributes_tbl => l_ln_price_attributes_tbl          ,
      x_Price_Adjustment_tbl    => l_Price_Adjustment_tbl             ,
      x_Price_Adj_Rltship_tbl   => l_Price_Adj_Rltship_tbl          );

    IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    --DBMS_OUTPUT.PUT_LINE('copy_lines done ');
    --DBMS_OUTPUT.PUT_LINE('immediately after copy_lines p_target_header_rec.quote_header_id '||p_target_header_rec.quote_header_id);

  --l_hd_shipment_tbl(1) 					:= p_hd_shipment_rec; $$ Verify this part. Ned to pass
                                                                         --p_to_hd_shipment_rec?? $$
 -- l_hd_shipment_tbl(1).quote_header_id 	:= P_target_header_rec.quote_header_id;

  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_UTIL.DEBUG('IBE_QUOTE_SAVESHARE_V2_PVT.APPEND_QUOTE:IBE_QUOTE_SAVESHARE_pvt.Copy_lines End');
     IBE_UTIL.DEBUG('IBE_QUOTE_SAVESHARE_V2_PVT.APPEND_QUOTE: Calling IBE_Quote_Save_pvt.Save to save target cart');
  END IF;
  --DBMS_OUTPUT.PUT_LINE('IBE_QUOTE_SAVESHARE_V2_PVT.APPEND_QUOTE: Calling IBE_Quote_Save_pvt.Save to save target cart ');
  --DBMS_OUTPUT.PUT_LINE('before save p_target_header_rec.quote_header_id '||p_target_header_rec.quote_header_id);
  IBE_Quote_Save_pvt.SAVE
  (   p_api_version_number => p_api_version
      ,p_init_msg_list     => FND_API.G_FALSE
      ,p_commit            => FND_API.G_FALSE
      ,p_qte_header_rec    => p_target_header_rec
      ,p_Qte_Line_Tbl      => l_qte_line_tbl
      ,p_Qte_Line_Dtl_Tbl  => l_qte_line_dtl_tbl
      ,p_Line_Attr_Ext_Tbl => l_line_attr_ext_tbl
      ,p_Line_rltship_tbl  => l_line_rltship_tbl
      ,p_control_rec       => P_control_rec
      ,p_Price_Adjustment_tbl     => l_Price_Adjustment_tbl
      ,p_Price_Adj_Rltship_tbl    => l_Price_Adj_Rltship_tbl
     -- ,p_hd_shipment_tbl   => l_hd_shipment_tbl
      ,x_quote_header_id   => l_qte_header_id
      ,x_last_update_date  => l_last_update_date
      ,x_return_status     => x_return_status
      ,x_msg_count         => x_msg_count
      ,x_msg_data          => x_msg_data) ;
    --DBMS_OUTPUT.PUT_LINE('IBE_QUOTE_SAVESHARE_V2_PVT.APPEND_QUOTE: Done save ');
    IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       IBE_UTIL.DEBUG('IBE_QUOTE_SAVESHARE_V2_PVT.APPEND_QUOTE: P_delete_source_cart: '||P_delete_source_cart);
    END IF;
    IF (P_delete_source_cart = FND_API.G_TRUE ) THEN
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
         IBE_UTIL.DEBUG('IBE_QUOTE_SAVESHARE_V2_PVT.APPEND_QUOTE: P_delete_source_cart is true');
      END IF;
      IBE_Quote_Save_pvt.Delete(
         p_api_version_number => p_api_version
        ,p_init_msg_list      => FND_API.G_FALSE
        ,p_commit             => FND_API.G_FALSE
        ,x_return_status      => x_return_status
        ,x_msg_count          => x_msg_count
        ,x_msg_data           => x_msg_data
        ,p_quote_header_id    => P_source_quote_header_id
        ,p_expunge_flag       => FND_API.G_FALSE
        ,p_minisite_id        => p_minisite_id
        ,p_last_update_date   => P_source_last_update_date);

      IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
         IBE_UTIL.DEBUG('IBE_QUOTE_SAVESHARE_V2_PVT.APPEND_QUOTE:Delete on source cart done');
      END IF;
    END IF;

  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_UTIL.DEBUG('IBE_QUOTE_SAVESHARE_V2_PVT.APPEND_QUOTE: END');
  END IF;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO APPENDQUOTE_V2;
      x_return_status := FND_API.G_RET_STS_ERROR;
	  FND_Msg_Pub.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count    ,
                                p_data    => x_msg_data);
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
         IBE_Util.Debug('Expected error in IBE_QUOTE_SAVESHARE_V2_PVT.append_quote()');
      END IF;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO APPENDQUOTE_V2;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	  FND_Msg_Pub.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count    ,
                                p_data    => x_msg_data);
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
         IBE_Util.Debug('Unexpected error in IBE_QUOTE_SAVESHARE_V2_PVT.append_quote()');
      END IF;

   WHEN OTHERS THEN
      ROLLBACK TO APPENDQUOTE_V2;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	  IF FND_Msg_Pub.Check_Msg_Level(FND_Msg_Pub.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_Msg_Pub.Add_Exc_Msg(G_PKG_NAME,
                                 l_api_name);
      END IF;
      FND_Msg_Pub.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count    ,
                                p_data    => x_msg_data);
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
         IBE_Util.Debug('Abnormal end   IBE_QUOTE_SAVESHARE_V2_PVT.append_quote()');
      END IF;

END;

/*to handle removing of all recipients of one cartId
*Usages:
-"Stop Sharing" button from List of Shared Out Carts, List of Shared Out Quotes
-Other apis where cart becomes "unusable" - submit quote and delete on the shared cart.
*/

Procedure stop_sharing (
    p_quote_header_id  IN  Number                                 ,
    p_delete_context   IN  VARCHAR2 := 'IBE_SC_CART_STOPSHARING'  ,
    P_minisite_id      IN  Number := FND_API.G_MISS_NUM           ,
    p_notes            IN  Varchar2 := FND_API.G_MISS_CHAR        ,
    p_quote_access_tbl IN  IBE_QUOTE_SAVESHARE_pvt.QUOTE_ACCESS_Tbl_Type
                           := IBE_QUOTE_SAVESHARE_pvt.G_miss_quote_access_Tbl,
    p_api_version      IN  NUMBER   := 1                          ,
    p_init_msg_list    IN  VARCHAR2 := FND_API.G_TRUE             ,
    p_commit           IN  VARCHAR2 := FND_API.G_FALSE            ,
    x_return_status    OUT NOCOPY VARCHAR2                        ,
    x_msg_count        OUT NOCOPY NUMBER                          ,
    x_msg_data         OUT NOCOPY VARCHAR2                               ) is

    l_api_name         CONSTANT VARCHAR2(30)   := 'STOPSHARING_V2';
    l_api_version      CONSTANT NUMBER         := 1.0;
    tbl_counter        NUMBER                  := 1;

    l_quote_access_tbl     IBE_QUOTE_SAVESHARE_pvt.QUOTE_ACCESS_Tbl_Type
                           := IBE_QUOTE_SAVESHARE_pvt.g_miss_quote_access_tbl;
    l_quote_access_tbl_tmp IBE_QUOTE_SAVESHARE_pvt.QUOTE_ACCESS_Tbl_Type
                           := IBE_QUOTE_SAVESHARE_pvt.g_miss_quote_access_tbl;
    l_owner_party_id   NUMBER;
    l_owner_cust_account_id  NUMBER;
    l_sharing_party_id NUMBER;

    cursor c_get_recipients(c_qte_hdr_id NUMBER) is
      select quote_sharee_id,
             party_id,
             cust_account_id,
             SH.contact_point_id,
             quote_sharee_number,
             HZ.EMAIL_ADDRESS,
             FND.customer_id shared_by_party_id
      from IBE_SH_QUOTE_ACCESS SH,
           HZ_CONTACT_POINTS HZ,
           FND_USER FND
      where SH.contact_point_id = HZ.Contact_point_id
      and quote_header_id = c_qte_hdr_id
      and nvl(end_date_active, sysdate+1) > sysdate
      and sh.created_by = fnd.user_id;

    cursor c_get_recipient_info(c_recipient_id NUMBER) is
      select quote_sharee_id,
             party_id,
             cust_account_id,
             SH.contact_point_id,
             quote_sharee_number,
             HZ.EMAIL_ADDRESS,
             FND.customer_id shared_by_party_id
      from IBE_SH_QUOTE_ACCESS SH,
           HZ_CONTACT_POINTS HZ,
           FND_USER FND
      where SH.contact_point_id = HZ.Contact_point_id
      and quote_sharee_id = c_recipient_id
      and nvl(end_date_active, sysdate+1) > sysdate
      and sh.created_by = fnd.user_id;

    CURSOR c_get_owner(c_quote_header_id NUMBER) is
      select party_id, cust_account_id
      from aso_quote_headers
      where quote_header_id = c_quote_header_id;


    rec_get_recipients     c_get_recipients%rowtype;
    rec_get_owner          c_get_owner%rowtype;
    rec_get_recipient_info c_get_recipient_info%rowtype;

BEGIN
  SAVEPOINT  STOPSHARING_V2;
  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call (	l_api_version,
                             			P_Api_Version,
                                   		l_api_name,
                       					G_PKG_NAME )
  THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;
   -- Initialize message list IF p_init_msg_list is set to TRUE.
  IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
  END IF;

   --  Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;
-------------------------------------------------------------------------------------------------------------
--API Body start
-------------------------------------------------------------------------------------------------------------
  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
    IBE_UTIL.DEBUG('IBE_QUOTE_SAVESHARE_V2_PVT.STOP_SHARING: START');
  END IF;
  -- Stop sharing should deactivate owner's active cart if any.
  --dbms_output.put_line('p_quote_header_id: '||p_quote_header_id);
  FOR rec_get_owner in c_get_owner(p_quote_header_id) LOOP
    l_owner_party_id        := rec_get_owner.party_id;
    l_owner_cust_account_id := rec_get_owner.cust_account_id;
    --dbms_output.put_line('loop one in cursor ');
    EXIT when c_get_owner%NOTFOUND;
  END LOOP;
  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
    IBE_UTIL.DEBUG('STOP_SHARING:Calling deactivate API');
  END IF;
  --DBMS_OUTPUT.PUT_LINE('Calling deactivate API to deactivate owner''s cart');
  --dbms_output.put_line('PARTY_ID: '||l_owner_party_id);
  --dbms_output.put_line('CUST_ACCOUNT_ID: '||l_owner_cust_account_id );

  IBE_QUOTE_SAVESHARE_V2_PVT.DEACTIVATE_QUOTE  (
          P_Quote_header_id  => p_quote_header_id       ,
          P_Party_id         => l_owner_party_id        ,
          P_Cust_account_id  => l_owner_cust_account_id ,
          P_minisite_id      => p_minisite_id           ,
          p_api_version      => p_api_version           ,
          p_init_msg_list    => fnd_api.g_false         ,
          p_commit           => fnd_api.g_false         ,
          x_return_status    => x_return_status         ,
          x_msg_count        => x_msg_count             ,
          x_msg_data         => x_msg_data              );
      IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
    IBE_UTIL.DEBUG('STOP_SHARING:Deactivation of owner cart :Done');
  END IF;
  --dbms_output.put_line('STOP_SHARING:Deactivation of owner cart :Done');
  --If there is no input quote access tbl then send notification to all recipients.
  --dbms_output.put_line('p_quote_access_tbl(1).quote_sharee_id: '||nvl(p_quote_access_tbl(1).quote_sharee_id,0));
  IF ((p_quote_access_tbl is not null) or (p_quote_access_tbl.count = 0) ) THEN
    FOR rec_userenv_partyid in c_userenv_partyid LOOP
      l_sharing_party_id := rec_userenv_partyid.customer_id;
      exit when c_userenv_partyid%NOTFOUND;
    END LOOP;

   IF (IBE_UTIL.G_DEBUGON = l_true) THEN
    IBE_UTIL.DEBUG('STOP_SHARING: :: l_sharing_party_id: '|| l_sharing_party_id  );
  END IF;

    --dbms_output.put_line('Input quote access is null ');
    FOR rec_get_recipients in c_get_recipients(p_quote_header_id) LOOP
     IF (IBE_UTIL.G_DEBUGON = l_true) THEN
    IBE_UTIL.DEBUG('STOP_SHARING:: '||tbl_counter||'. quote_sharee_id:'||rec_get_recipients.quote_sharee_id||', party_id:' || rec_get_recipients.party_id );
  END IF;

      l_quote_access_tbl(tbl_counter).quote_sharee_id     := rec_get_recipients.quote_sharee_id;
      l_quote_access_tbl(tbl_counter).party_id            := rec_get_recipients.party_id;
       --dbms_output.put_line('found party_id:  '||rec_get_recipient_info.party_id);
      l_quote_access_tbl(tbl_counter).cust_account_id     := rec_get_recipients.cust_account_id;
      l_quote_access_tbl(tbl_counter).contact_point_id    := rec_get_recipients.contact_point_id;
      l_quote_access_tbl(tbl_counter).quote_header_id     := p_quote_header_id;
      l_quote_access_tbl(tbl_counter).quote_sharee_number := rec_get_recipients.quote_sharee_number;
      l_quote_access_tbl(tbl_counter).email_contact_address := rec_get_recipients.email_address;
      l_quote_access_tbl(tbl_counter).shared_by_party_id  := rec_get_recipients.shared_by_party_id;
      -- 14109131 - STOP SHARED CART NOTIFICATION SENT WHEN RECIPIENT PLACES ORDER
      IF (l_sharing_party_id = rec_get_recipients.party_id) THEN
    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
    IBE_UTIL.DEBUG('STOP_SHARING :: sharee party id is party id so making notify flag false ');

  END IF;
   l_quote_access_tbl(tbl_counter).notify_flag     := FND_API.G_FALSE;
   End IF;
   -- 14109131 - STOP SHARED CART NOTIFICATION SENT WHEN RECIPIENT PLACES ORDER
      tbl_counter := tbl_counter+1;
      EXIT when c_get_recipients%notfound;
    END LOOP;
  ELSE
    --dbms_output.put_line('Input quote access table is not null');

    FOR tbl_counter in 1..p_quote_access_tbl.count LOOP
       --dbms_output.put_line('p_quote_access_tbl(tbl_counter).quote_sharee_id: '||p_quote_access_tbl(tbl_counter).quote_sharee_id);
      FOR rec_get_recipient_info in c_get_recipient_info(l_quote_access_tbl(tbl_counter).quote_sharee_id) LOOP
        IF l_sharing_party_id <> rec_get_recipient_info.party_id THEN
   IF (IBE_UTIL.G_DEBUGON = l_true) THEN
    IBE_UTIL.DEBUG('STOP_SHARING: '||tbl_counter||'. quote_sharee_id:'||p_quote_access_tbl(tbl_counter).quote_sharee_id||', party_id:' || rec_get_recipient_info.party_id ||', notify_flag:' || p_quote_access_tbl(tbl_counter).notify_flag  );
  END IF;


          l_quote_access_tbl(tbl_counter).quote_sharee_id     := p_quote_access_tbl(tbl_counter).quote_sharee_id;
          l_quote_access_tbl(tbl_counter).notify_flag         := p_quote_access_tbl(tbl_counter).notify_flag;
          l_quote_access_tbl(tbl_counter).party_id            := rec_get_recipient_info.party_id;
          --dbms_output.put_line('found party_id:  '||rec_get_recipient_info.party_id);
          l_quote_access_tbl(tbl_counter).cust_account_id     := rec_get_recipient_info.cust_account_id;
          l_quote_access_tbl(tbl_counter).contact_point_id    := rec_get_recipient_info.contact_point_id;
          l_quote_access_tbl(tbl_counter).quote_header_id     := p_quote_header_id;
          l_quote_access_tbl(tbl_counter).quote_sharee_number := rec_get_recipient_info.quote_sharee_number;
          l_quote_access_tbl(tbl_counter).email_contact_address := rec_get_recipient_info.email_address;
          l_quote_access_tbl(tbl_counter).shared_by_party_id  := rec_get_recipient_info.shared_by_party_id;
        END IF;
        EXIT when c_get_recipient_info%notfound;
      END LOOP;
    END LOOP;
  END IF;
  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
    IBE_UTIL.DEBUG('STOP_SHARING:calling delete_recipient on the following recipients:');
  END IF;
  --dbms_output.put_line('STOP_SHARING:calling delete_recipient on the following recipients:');
  FOR i in 1.. l_quote_access_tbl.count LOOP
    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       IBE_UTIL.DEBUG('STOP_SHARING:calling delete_recipient');
       IBE_UTIL.DEBUG('STOP_SHARING:l_quote_access_tbl:'||i||':quote_sharee_id: '||l_quote_access_tbl(i).quote_sharee_id);
       IBE_UTIL.DEBUG('STOP_SHARING:l_quote_access_tbl:'||i||':contact_point_id: '||l_quote_access_tbl(i).contact_point_id);
       IBE_UTIL.DEBUG('STOP_SHARING:l_quote_access_tbl:'||i||':party_id: '||l_quote_access_tbl(i).party_id);
       IBE_UTIL.DEBUG('STOP_SHARING:l_quote_access_tbl:'||i||':cust_account_id: '||l_quote_access_tbl(i).cust_account_id);
    END IF;
    --dbms_output.put_line('STOP_SHARING:l_quote_access_tbl:'||i||':quote_sharee_id: '||l_quote_access_tbl(i).quote_sharee_id);
    --dbms_output.put_line('Calling delete recipient for the recipient record ');
    IBE_QUOTE_SAVESHARE_V2_PVT.DELETE_RECIPIENT(
            P_Quote_access_rec  => l_quote_access_tbl(i) ,
            p_minisite_id       => p_minisite_id         ,
            p_delete_code       => p_delete_context      ,
            p_notes             => p_notes               ,
            x_return_status     => x_return_status       ,
            x_msg_count         => x_msg_count           ,
            x_msg_data          => x_msg_data            );

      IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

  END LOOP;
  --This is to delete any new recipients who got added while we were trying to delete existing recipients.
  --This code is to handle issues arising out of concurrency among multiple admins of a shared cart
  tbl_counter := 1;

  FOR rec_get_recipients in c_get_recipients(p_quote_header_id) LOOP
    l_quote_access_tbl_tmp(tbl_counter).quote_sharee_id       := rec_get_recipients.quote_sharee_id;
    l_quote_access_tbl_tmp(tbl_counter).party_id              := rec_get_recipients.party_id;
    --dbms_output.put_line('found party_id:  '||rec_get_recipient_info.party_id);
    l_quote_access_tbl_tmp(tbl_counter).cust_account_id       := rec_get_recipients.cust_account_id;
    l_quote_access_tbl_tmp(tbl_counter).contact_point_id      := rec_get_recipients.contact_point_id;
    l_quote_access_tbl_tmp(tbl_counter).quote_header_id       := p_quote_header_id;
    l_quote_access_tbl_tmp(tbl_counter).quote_sharee_number   := rec_get_recipients.quote_sharee_number;
    l_quote_access_tbl_tmp(tbl_counter).email_contact_address := rec_get_recipients.email_address;
    l_quote_access_tbl_tmp(tbl_counter).shared_by_party_id    := rec_get_recipients.shared_by_party_id;
    l_quote_access_tbl_tmp(tbl_counter).notify_flag           := FND_API.G_FALSE;
    tbl_counter := tbl_counter+1;
    EXIT when c_get_recipients%notfound;
  END LOOP;

  FOR i in 1.. l_quote_access_tbl_tmp.count LOOP
    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       IBE_UTIL.DEBUG('STOP_SHARING: Concurrency part begins');
       IBE_UTIL.DEBUG('STOP_SHARING:l_quote_access_tbl:'||i||':quote_sharee_id: '||l_quote_access_tbl_tmp(i).quote_sharee_id);
       IBE_UTIL.DEBUG('STOP_SHARING:l_quote_access_tbl:'||i||':contact_point_id: '||l_quote_access_tbl_tmp(i).contact_point_id);
       IBE_UTIL.DEBUG('STOP_SHARING:l_quote_access_tbl:'||i||':party_id: '||l_quote_access_tbl_tmp(i).party_id);
       IBE_UTIL.DEBUG('STOP_SHARING:l_quote_access_tbl:'||i||':cust_account_id: '||l_quote_access_tbl_tmp(i).cust_account_id);
    END IF;
    --dbms_output.put_line('STOP_SHARING:l_quote_access_tbl:'||i||':quote_sharee_id: '||l_quote_access_tbl_tmp(i).quote_sharee_id);
    --dbms_output.put_line('Calling delete recipient for the recipient record ');
    IBE_QUOTE_SAVESHARE_V2_PVT.DELETE_RECIPIENT(
            P_Quote_access_rec  => l_quote_access_tbl_tmp(i) ,
            p_minisite_id       => p_minisite_id         ,
            p_delete_code       => p_delete_context      ,
            p_notes             => FND_API.G_MISS_CHAR   ,
            x_return_status     => x_return_status       ,
            x_msg_count         => x_msg_count           ,
            x_msg_data          => x_msg_data            );

      IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
  END LOOP;
  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
    IBE_UTIL.DEBUG('STOP_SHARING: Concurrency part ends');
  END IF;

  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_UTIL.DEBUG('IBE_QUOTE_SAVESHARE_V2_PVT.STOP_SHARING: END');
  END IF;

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO STOPSHARING_V2;
      x_return_status := FND_API.G_RET_STS_ERROR;
	  FND_Msg_Pub.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count    ,
                                p_data    => x_msg_data);
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
         IBE_Util.Debug('Expected error in IBE_QUOTE_SAVESHARE_V2_PVT.STOPSHARING_V2');
      END IF;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO STOPSHARING_V2;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	  FND_Msg_Pub.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count    ,
                                p_data    => x_msg_data);
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
         IBE_Util.Debug('Unexpected error in  IBE_QUOTE_SAVESHARE_V2_PVT.STOPSHARING_V2');
      END IF;

   WHEN OTHERS THEN
      ROLLBACK TO STOPSHARING_V2;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	  IF FND_Msg_Pub.Check_Msg_Level(FND_Msg_Pub.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_Msg_Pub.Add_Exc_Msg(G_PKG_NAME,
                                 l_api_name);
      END IF;
      FND_Msg_Pub.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count    ,
                                p_data    => x_msg_data);
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
         IBE_Util.Debug('Unknown error in IBE_QUOTE_SAVESHARE_V2_PVT.STOPSHARING_V2');
      END IF;

END;

/*To handle the specific removing of a recipients from one cartId
*Usages:
-"End Working" button
*/
Procedure end_working (
    p_quote_access_tbl  IN  IBE_QUOTE_SAVESHARE_pvt.QUOTE_ACCESS_Tbl_Type
                            := IBE_QUOTE_SAVESHARE_pvt.G_miss_quote_access_Tbl ,
    P_Quote_header_id   IN  Number                                           ,
    P_Party_id          IN  Number         := FND_API.G_MISS_NUM             ,
    P_Cust_account_id   IN  Number         := FND_API.G_MISS_NUM             ,
    p_retrieval_number  IN  Number         := FND_API.G_MISS_NUM             ,
    P_URL               IN  Varchar2       := FND_API.G_MISS_CHAR            ,
    P_minisite_id       IN  Number         := FND_API.G_MISS_NUM             ,
    p_notes             IN  Varchar2       := FND_API.G_MISS_CHAR            ,
    p_api_version       IN  NUMBER         := 1                              ,
    p_init_msg_list     IN  VARCHAR2       := FND_API.G_TRUE                 ,
    p_commit            IN  VARCHAR2       := FND_API.G_FALSE                ,
    x_return_status     OUT NOCOPY VARCHAR2                                  ,
    x_msg_count         OUT NOCOPY NUMBER                                    ,
    x_msg_data          OUT NOCOPY VARCHAR2                                  ) is

    l_api_name         CONSTANT VARCHAR2(30)   := 'ENDWORKING_V2';
    l_api_version      CONSTANT NUMBER         := 1.0;
    l_recip_id         NUMBER;
    l_initiator_id     NUMBER;
    l_quote_access_tbl IBE_QUOTE_SAVESHARE_pvt.QUOTE_ACCESS_Tbl_Type
                       := IBE_QUOTE_SAVESHARE_pvt.G_miss_quote_access_Tbl;
    END_WORKING              NUMBER := 4;

    CURSOR c_get_recip_id(c_retrieval_num   NUMBER,
                          c_party_id        NUMBER,
                          c_cust_account_id NUMBER,
                          c_quote_header_id NUMBER) is
      SELECT quote_sharee_id, quote_header_id
      FROM IBE_SH_QUOTE_ACCESS
      WHERE quote_sharee_number = c_retrieval_num
      OR (party_id = c_party_id and cust_account_id = c_cust_account_id)
      AND quote_header_id = c_quote_header_id
      AND nvl(end_date_active, sysdate+1) > sysdate;

    rec_get_recip_id   c_get_recip_id%rowtype;
    l_quote_access_rec       IBE_QUOTE_SAVESHARE_pvt.QUOTE_ACCESS_REC_TYPE
                             := IBE_QUOTE_SAVESHARE_pvt.G_MISS_QUOTE_ACCESS_REC;
    l_quote_access_rec_recip IBE_QUOTE_SAVESHARE_pvt.QUOTE_ACCESS_REC_TYPE
                             := IBE_QUOTE_SAVESHARE_pvt.G_MISS_QUOTE_ACCESS_REC;

   cursor c_get_recipient_party(c_recipient_id NUMBER) is
     SELECT party_id,
            quote_sharee_number,
            quote_header_id,
            update_privilege_type_code,
            contact_point_id
     FROM ibe_sh_quote_access
     where quote_sharee_id = c_recipient_id;

   rec_get_recipient_party c_get_recipient_party%rowtype;

BEGIN
  SAVEPOINT  ENDWORKING_V2;
  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call (	l_api_version,
                             			P_Api_Version,
                                   		l_api_name,
                       					G_PKG_NAME )
  THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;
   -- Initialize message list IF p_init_msg_list is set to TRUE.
  IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
  END IF;

   --  Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;
-----------------------------------------------------------------------------------------
--API Body start
-----------------------------------------------------------------------------------------
--  l_quote_access_rec := p_quote_access_rec;
  FOR rec_userenv_partyid in c_userenv_partyid LOOP
    l_initiator_id  := rec_userenv_partyid.customer_id;
    EXIT when c_userenv_partyid%notfound;
  END LOOP;

  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_UTIL.DEBUG('IBE_QUOTE_SAVESHARE_V2_PVT.END_WORKING: START');
  END IF;
  --DBMS_OUTPUT.PUT_LINE('IBE_QUOTE_SAVESHARE_V2_PVT.END_WORKING: START');
  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_UTIL.DEBUG('Opening cursor to retrieve the recipient_id');
  END IF;
  --DBMS_OUTPUT.PUT_LINE('Opening cursor to retrieve the recipient_id');
  --DBMS_OUTPUT.PUT_LINE('p_quote_access_rec.quote_sharee_number: '||p_quote_access_rec.quote_sharee_number);
  --DBMS_OUTPUT.PUT_LINE('p_quote_access_rec.party_id: '||p_quote_access_rec.party_id);
  --DBMS_OUTPUT.PUT_LINE('p_quote_access_rec.cust_account_id: '||p_quote_access_rec.cust_account_id);
  --DBMS_OUTPUT.PUT_LINE('p_quote_access_rec.quote_header_id: '||p_quote_access_rec.quote_header_id);

  l_quote_access_tbl:= p_quote_access_tbl;
  FOR rec_get_recip_id in c_get_recip_id(p_retrieval_number,
                                         p_party_id,
                                         p_cust_account_id,
                                         p_quote_header_id) LOOP
    l_quote_access_rec.quote_sharee_id     := rec_get_recip_id.quote_sharee_id;
    l_quote_access_rec.quote_sharee_number := p_retrieval_number;
    l_quote_access_rec.party_id            := p_party_id;
    l_quote_access_rec.cust_account_id     := p_cust_account_id;
    l_quote_access_rec.quote_header_id     := rec_get_recip_id.quote_header_id;
    EXIT WHEN c_get_recip_id%NOTFOUND;
  END LOOP;
  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_UTIL.DEBUG('Recipient id obtained is: '||l_quote_access_rec.quote_sharee_id);
  END IF;

--DBMS_OUTPUT.PUT_LINE('Recipient id obtained is: '||l_quote_access_rec.quote_sharee_id);
  IBE_QUOTE_SAVESHARE_V2_PVT.DELETE_RECIPIENT(
        P_Quote_access_rec  => l_quote_access_rec ,
        p_minisite_id       => p_minisite_id      ,
        p_delete_code       => 'END_WORKING'      ,
        p_url               => p_url              ,
        p_notes             => p_notes            ,
        x_return_status     => x_return_status    ,
        x_msg_count         => x_msg_count        ,
        x_msg_data          => x_msg_data         );

      IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

  FOR counter in 1..p_quote_access_tbl.count LOOP
    IF ((l_quote_access_tbl(counter).notify_flag = FND_API.G_TRUE) AND
         (l_quote_access_rec.quote_sharee_id <> l_quote_access_tbl(counter).quote_sharee_id)) THEN

      FOR rec_get_recipient_party in c_get_recipient_party(p_quote_access_tbl(counter).quote_sharee_id) LOOP
        l_quote_access_rec_recip.party_id                   := rec_get_recipient_party.party_id;
        l_quote_access_rec_recip.quote_sharee_number        := rec_get_recipient_party.quote_sharee_number;
        l_quote_access_rec_recip.quote_header_id            := rec_get_recipient_party.quote_header_id;
        l_quote_access_rec_recip.update_privilege_type_code := rec_get_recipient_party.update_privilege_type_code;
        -- As part of bug fix 3349991 getting contact_point_id to the notification api.
        l_quote_access_rec_recip.contact_point_id := rec_get_recipient_party.contact_point_id;
        EXIT when c_get_recipient_party%NOTFOUND;
      END LOOP;

      -- Assign the quote_sharee_id to l_quote_access_rec (value needed in the notification api,3349991)
      l_quote_access_rec_recip.quote_sharee_id := p_quote_access_tbl(counter).quote_sharee_id;

     IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        IBE_UTIL.DEBUG('IBE_QUOTE_SAVESHARE_V2_PVT.END_WORKING: Ready to call view shared cart');
        IBE_UTIL.DEBUG('IBE_QUOTE_SAVESHARE_V2_PVT.END_WORKING:initiator_party_id: '||l_initiator_id);
        IBE_UTIL.DEBUG('IBE_QUOTE_SAVESHARE_V2_PVT.END_WORKING:recipient party_id: '||l_quote_access_rec_recip.party_id);
        IBE_UTIL.DEBUG('IBE_QUOTE_SAVESHARE_V2_PVT.END_WORKING:recipient number: '||l_quote_access_rec_recip.quote_sharee_number);
        IBE_UTIL.DEBUG('IBE_QUOTE_SAVESHARE_V2_PVT.END_WORKING:recipient id: '||l_quote_access_rec_recip.quote_sharee_id);
        IBE_UTIL.DEBUG('IBE_QUOTE_SAVESHARE_V2_PVT.END_WORKING:contact_point_id: '||l_quote_access_rec_recip.contact_point_id);
      END IF;

      IBE_WORKFLOW_PVT.Notify_view_shared_cart(
          p_api_version       => p_api_version
          ,p_init_msg_list    => p_init_msg_list
          ,p_quote_access_rec => l_quote_access_rec_recip
          ,p_minisite_id      => p_minisite_id
          ,p_url              => p_url
          ,p_notes            => p_notes
          ,p_sent_by_party_id => l_initiator_id
          ,x_return_status    => x_return_status
          ,x_msg_count        => x_msg_count
          ,x_msg_data         => x_msg_data         );
        IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
          RAISE FND_API.G_EXC_ERROR;
        END IF;
        IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
    END IF;
  END LOOP;

  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_UTIL.DEBUG('IBE_QUOTE_SAVESHARE_V2_PVT.END_WORKING: END');
  END IF;
  --DBMS_OUTPUT.PUT_LINE('IBE_QUOTE_SAVESHARE_V2_PVT.END_WORKING: END ');
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO ENDWORKING_V2;
      x_return_status := FND_API.G_RET_STS_ERROR;
	  FND_Msg_Pub.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count    ,
                                p_data    => x_msg_data);
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
         IBE_Util.Debug('Expected error in IBE_QUOTE_SAVESHARE_V2_PVT.ENDWORKING');
      END IF;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO ENDWORKING_V2;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	  FND_Msg_Pub.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count    ,
                                p_data    => x_msg_data);
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
         IBE_Util.Debug('Unexpected error in IBE_QUOTE_SAVESHARE_V2_PVT.ENDWORKING)');
      END IF;

   WHEN OTHERS THEN
      ROLLBACK TO ENDWORKING_V2;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	  IF FND_Msg_Pub.Check_Msg_Level(FND_Msg_Pub.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_Msg_Pub.Add_Exc_Msg(G_PKG_NAME,
                                 l_api_name);
      END IF;
      FND_Msg_Pub.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count    ,
                                p_data    => x_msg_data);
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
         IBE_Util.Debug('Unknown error in IBE_QUOTE_SAVESHARE_V2_PVT.ENDWORKING');
      END IF;


END;
/*updates all recipients' access levels to readonly
*Usages:
-Status changes from "cart" to"quote" - request sales assistance, contract cart
*/
Procedure share_readonly  (
    p_quote_header_id  IN  Number                      ,
    P_minisite_id      IN  Number := FND_API.G_MISS_NUM,
    p_url              IN  Varchar2 := FND_API.G_MISS_CHAR,
    p_api_version      IN  NUMBER   := 1               ,
    p_init_msg_list    IN  VARCHAR2 := FND_API.G_TRUE  ,
    p_commit           IN  VARCHAR2 := FND_API.G_FALSE ,
    x_return_status    OUT NOCOPY VARCHAR2             ,
    x_msg_count        OUT NOCOPY NUMBER               ,
    x_msg_data         OUT NOCOPY VARCHAR2             ) is

  l_api_name         CONSTANT VARCHAR2(30)   := 'SHAREREADONLY_V2';
  l_api_version      CONSTANT NUMBER         := 1.0;
  tbl_counter        NUMBER                  := 1;
  l_initiator_id     NUMBER;

  l_quote_access_tbl IBE_QUOTE_SAVESHARE_pvt.QUOTE_ACCESS_Tbl_Type
                     := IBE_QUOTE_SAVESHARE_pvt.g_miss_quote_access_tbl;

  cursor c_get_recipients(c_qte_hdr_id NUMBER) is
    select quote_sharee_id,
           party_id,
           cust_account_id,
           quote_header_id
    from IBE_SH_QUOTE_ACCESS
    where quote_header_id = c_qte_hdr_id
    and nvl(end_date_active,sysdate+1) > sysdate;

  rec_get_recipients c_get_recipients%rowtype;

BEGIN

  SAVEPOINT  SHAREREADONLY_V2;
  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call (	l_api_version,
                             			P_Api_Version,
                                   		l_api_name,
                       					G_PKG_NAME )
  THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;
   -- Initialize message list IF p_init_msg_list is set to TRUE.
  IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
  END IF;

   --  Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;
-------------------------------------------------------------------------------------------------------------
--API Body start
-------------------------------------------------------------------------------------------------------------

  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
    IBE_UTIL.DEBUG('IBE_QUOTE_SAVESHARE_V2_PVT.SHARE_READONLY: START');
    IBE_UTIL.DEBUG('IBE_QUOTE_SAVESHARE_V2_PVT.SHARE_READONLY:quote_header_id: '||p_quote_header_id);
    IBE_UTIL.DEBUG('IBE_QUOTE_SAVESHARE_V2_PVT.SHARE_READONLY: Querying initiator party id');
  END IF;

  FOR rec_userenv_partyid in c_userenv_partyid LOOP
    l_initiator_id := rec_userenv_partyid.customer_id;
    EXIT when c_userenv_partyid%notfound;
  END LOOP;

  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
    IBE_UTIL.DEBUG('Building quote access table');
  END IF;

  FOR rec_get_recipients in c_get_recipients(p_quote_header_id) LOOP

    --Omitting the initiator's details as initiator is not required to get the notification
    IF (l_initiator_id <> nvl(rec_get_recipients.party_id,-1) ) THEN
      l_quote_access_tbl(tbl_counter).quote_sharee_id            := rec_get_recipients.quote_sharee_id;

      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        IBE_UTIL.DEBUG('Added sharee quote_sharee_id: '||rec_get_recipients.quote_sharee_id);
      END IF;

      l_quote_access_tbl(tbl_counter).update_privilege_type_code := 'R';
      l_quote_access_tbl(tbl_counter).party_id                   := rec_get_recipients.party_id;
      l_quote_access_tbl(tbl_counter).cust_account_id            := rec_get_recipients.cust_account_id;
      l_quote_access_tbl(tbl_counter).quote_header_id            := rec_get_recipients.quote_header_id;
      l_quote_access_tbl(tbl_counter).operation_code             := 'UPDATE';
      tbl_counter := tbl_counter+1;
    END IF;
    EXIT when c_get_recipients%notfound;
  END LOOP;
  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_UTIL.DEBUG('Done building quote access table');
  END IF;

  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_UTIL.DEBUG('Calling save_recipients to update recipient access level');
  END IF;
  IBE_QUOTE_SAVESHARE_V2_PVT.save_recipients(
      P_Quote_access_tbl => l_quote_access_tbl ,
      P_Quote_header_id  => P_Quote_header_id  ,
      P_minisite_id      => p_minisite_id      ,
      p_url              => p_url              ,
      p_api_version      => p_api_version      ,
      p_init_msg_list    => fnd_api.g_false    ,
      p_commit           => fnd_api.g_false    ,
      x_return_status    => x_return_status    ,
      x_msg_count        => x_msg_count        ,
      x_msg_data         => x_msg_data         );

  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_UTIL.DEBUG('Done calling save_recipients to update recipient access level');
     IBE_UTIL.DEBUG('IBE_QUOTE_SAVESHARE_V2_PVT.SHARE_READONLY: END');
  END IF;

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO STOPSHARING_V2;
      x_return_status := FND_API.G_RET_STS_ERROR;
	  FND_Msg_Pub.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count    ,
                                p_data    => x_msg_data);
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
         IBE_Util.Debug('Expected error in IBE_QUOTE_SAVESHARE_V2_PVT.SHAREREADONLY_V2');
      END IF;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO STOPSHARING_V2;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	  FND_Msg_Pub.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count    ,
                                p_data    => x_msg_data);
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
         IBE_Util.Debug('Unexpected error in IBE_QUOTE_SAVESHARE_V2_PVT.SHAREREADONLY_V2');
      END IF;

   WHEN OTHERS THEN
      ROLLBACK TO STOPSHARING_V2;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	  IF FND_Msg_Pub.Check_Msg_Level(FND_Msg_Pub.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_Msg_Pub.Add_Exc_Msg(G_PKG_NAME,
                                 l_api_name);
      END IF;
      FND_Msg_Pub.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count    ,
                                p_data    => x_msg_data);
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
         IBE_Util.Debug('Unknown error in IBE_QUOTE_SAVESHARE_V2_PVT.SHAREREADONLY_V2');
      END IF;
END;

/*To delete a recipient (a sort of wrapper around the "raw" delete table hander)
*Usages:
-To remove a recipient from the list of persons to whom a cart is shared.
-All deletes for a recipient should be done using this api.
-As of IBE.P - p_quote_access_rec must have the shared_by_party_id set
*/
Procedure DELETE_RECIPIENT  (
    P_Quote_access_rec  IN  IBE_QUOTE_SAVESHARE_pvt.QUOTE_ACCESS_REC_TYPE
                            := IBE_QUOTE_SAVESHARE_pvt.G_MISS_QUOTE_ACCESS_REC ,
    P_minisite_id       IN  NUMBER                                             ,
    p_delete_code       IN  VARCHAR2 := 'IBE_SC_CART_STOPSHARING'            ,
    p_url               IN  VARCHAR2 := FND_API.G_MISS_CHAR                    ,
    p_notes             IN  VARCHAR2 := FND_API.G_MISS_CHAR                    ,
    p_api_version       IN  NUMBER   := 1                                      ,
    p_init_msg_list     IN  VARCHAR2 := FND_API.G_TRUE                         ,
    p_commit            IN  VARCHAR2 := FND_API.G_FALSE                        ,
    x_return_status     OUT NOCOPY VARCHAR2                                    ,
    x_msg_count         OUT NOCOPY NUMBER                                      ,
    x_msg_data          OUT NOCOPY VARCHAR2                                    ) is

    l_api_name         CONSTANT VARCHAR2(30)   := 'DELETERECIPIENT_V2';
    l_api_version      CONSTANT NUMBER         := 1.0;
    l_url                     VARCHAR2(2000);
    l_owner_partyid           NUMBER;
    l_owner_accountid         NUMBER;
    l_contact_point_rec     HZ_CONTACT_POINT_V2PUB.CONTACT_POINT_REC_TYPE;
    l_party_id              NUMBER;
    l_contact_point_id      NUMBER;
    l_object_version_number NUMBER;


/* Fixed the query for the bug 4860734 */
     cursor c_find_active_cart is
       select a.quote_header_id, a.party_id ,a.cust_account_id
       from   IBE_ACTIVE_QUOTES a, ibe_sh_quote_access b
       where a.party_id = b.party_id
       and a.cust_account_id = b.cust_account_id
       and b.quote_sharee_id = P_Quote_access_rec.quote_sharee_id
       and nvl(b.end_date_active, sysdate+1) > sysdate
       and a.quote_header_id = p_quote_access_rec.quote_header_id
       and record_type= 'CART';

    cursor c_get_owner_ids(c_quote_id number) is
      select party_id, cust_account_id
      from ASO_QUOTE_HEADERS_ALL
      where quote_header_id = c_quote_id;

    cursor c_get_contact_point_ovn(c_quote_sharee_id Number) IS
      select QUOTE_ACCESS.party_id, CNTCT_POINTS.contact_point_id, CNTCT_POINTS.object_version_number
      from  hz_contact_points CNTCT_POINTS, ibe_sh_quote_access QUOTE_ACCESS
      where CNTCT_POINTS.contact_point_id  = QUOTE_ACCESS.contact_point_id
        and quote_sharee_id = c_quote_sharee_id;

    rec_find_active_cart c_find_active_cart%rowtype;
    rec_get_owner_ids c_get_owner_ids%rowtype;

    l_delete_context     VARCHAR2(2000);
    l_shared_by_party_id  NUMBER;

BEGIN

  SAVEPOINT  DELETERECIPIENT_V2;
  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call (	l_api_version,
                             			P_Api_Version,
                                   		l_api_name,
                       					G_PKG_NAME )
  THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;
   -- Initialize message list IF p_init_msg_list is set to TRUE.
  IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
  END IF;

   --  Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;
-------------------------------------------------------------------------------------------------------------
--API Body start
-------------------------------------------------------------------------------------------------------------

  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_UTIL.DEBUG('IBE_QUOTE_SAVESHARE_V2_PVT.DELETE_RECIPIENT: START');
  END IF;
  FOR rec_find_active_cart in c_find_active_cart loop
    IF(rec_find_active_cart.quote_header_id is not null) THEN
    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       IBE_UTIL.DEBUG('IBE_QUOTE_SAVESHARE_V2_PVT.DELETE_RECIPIENT:user has an active cart');
       IBE_UTIL.DEBUG('Calling update row handler to deactivate the cart');
    END IF;
    --DBMS_OUTPUT.PUT_LINE('IBE_QUOTE_SAVESHARE_V2_PVT.DELETE_RECIPIENT:user has an active cart');

    IBE_ACTIVE_QUOTES_ALL_PKG.UPDATE_ROW(
           X_OBJECT_VERSION_NUMBER => 1                                   ,
           X_QUOTE_HEADER_ID       => null                                ,
           X_PARTY_ID              => rec_find_active_cart.party_id       ,
           X_CUST_ACCOUNT_ID       => rec_find_active_cart.cust_account_id,
           X_RECORD_TYPE           => 'CART'                             ,
           X_CURRENCY_CODE         => null                                ,
           x_last_update_date      => sysdate                             ,
           x_last_updated_by       => fnd_global.user_id                  ,
           x_last_update_login     => 1);
    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       IBE_UTIL.DEBUG('Done calling update row handler to deactivate the cart');
    END IF;
    END IF;
    EXIT WHEN c_find_active_cart%NOTFOUND;
  END LOOP;
  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_UTIL.DEBUG('Calling Update row handler on sh_quote_access table to end-date recipient row');
  END IF;
  --DBMS_OUTPUT.PUT_LINE('Calling Update row handler on sh_quote_access table to end-date recipient row');

  open c_get_contact_point_ovn(P_Quote_access_rec.quote_sharee_id);
  fetch c_get_contact_point_ovn into l_party_id, l_contact_point_id, l_object_version_number;

  if(l_party_id is NULL) THEN
     l_contact_point_rec.contact_point_id := l_contact_point_id;
     l_contact_point_rec.status := 'I';
     l_contact_point_rec.primary_flag := 'N';
     HZ_CONTACT_POINT_V2PUB.update_contact_point(
        			p_init_msg_list	     	=>  FND_API.G_FALSE,
				    p_contact_point_rec  	=>  l_contact_point_rec,
				    p_object_version_number =>  l_object_version_number,
				    x_return_status		    =>  x_return_status,
				    x_msg_count		        =>  x_msg_count,
     				x_msg_data		        =>  x_msg_data);

     IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         RAISE FND_API.G_EXC_ERROR;
     END IF;
  END IF;

  IBE_SH_QUOTE_ACCESS_PKG.update_Row(
                     p_quote_sharee_id   => P_Quote_access_rec.quote_sharee_id
                     ,p_end_date_active  => sysdate);
  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
    IBE_UTIL.DEBUG('Done calling Update row handler on sh_quote_access table to end-date recipient row');
  END IF;
  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
    IBE_UTIL.DEBUG('IBE_QUOTE_SAVESHARE_V2_PVT.DELETE_RECIPIENT: END');
    IBE_UTIL.DEBUG('delete_code is: '||p_delete_code);
  END IF;

  IF (p_quote_access_rec.notify_flag = FND_API.G_TRUE) THEN
    --Notify_finish_sharing API with the appropriate delete_code
    IF (p_delete_code = 'END_WORKING') THEN
      /*obtain the owner party_id and acctid of the cart/quote being dealt with*/
      FOR rec_get_owner_ids in c_get_owner_ids(p_quote_access_rec.quote_header_id) LOOP
        l_owner_partyid := rec_get_owner_ids.party_id;
        l_owner_accountid := rec_get_owner_ids.cust_account_id;
        EXIT when c_get_owner_ids%notfound;
      END LOOP;

      -- notification that goes to the owner (so and so has finished working this cart)
      -- for generic email to owner, we need to add some special parameters since we will not have a retrieval number
      l_url := p_url || '&opid=' || l_owner_partyid || '&oaid=' || l_owner_accountid;
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        IBE_UTIL.DEBUG('url for generic email to OWNER: '||l_url);
      END IF;

      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        IBE_UTIL.DEBUG('Calling notify_end_working API');
      END IF;
      IBE_WORKFLOW_PVT.Notify_End_Working(
        p_api_version      => p_api_version                         ,
        p_init_msg_list    => p_init_msg_list                       ,
        p_quote_header_id  => p_quote_access_rec.quote_header_id    ,
        p_party_id         => p_quote_access_rec.party_id           ,
        p_Cust_Account_Id  => p_quote_access_rec.cust_account_id    ,
        p_retrieval_number => p_quote_access_rec.quote_sharee_number,
        p_minisite_id      => p_minisite_id                         ,
        p_url              => l_url                                 ,
        p_notes            => p_notes                               ,
        x_return_status    => x_return_status                       ,
        x_msg_count        => x_msg_count                           ,
        x_msg_data         => x_msg_data                            );

         IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
           RAISE FND_API.G_EXC_ERROR;
         END IF;
         IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        IBE_UTIL.DEBUG('Done calling notify_end_working API');
      END IF;
    ELSE
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        IBE_UTIL.DEBUG('Calling notify_finish_sharing API');
      END IF;
      --DBMS_OUTPUT.PUT_LINE('Calling notify_stop_sharing API ');
      -- notification that goes to the member (you no longer have access to this cart)
      IBE_WORKFLOW_PVT.Notify_Finish_Sharing(
         p_api_version      => p_api_version      ,
         p_init_msg_list    => p_init_msg_list    ,
         p_quote_access_rec => p_quote_access_rec ,  --of the recepient
         p_minisite_id      => p_minisite_id      ,
         p_url              => p_url              ,
         p_context_code     => p_delete_code      ,
         p_shared_by_partyid=> p_quote_access_rec.shared_by_party_id,
         p_notes            => p_notes            ,
         x_return_status    => x_return_status    ,
         x_msg_count        => x_msg_count        ,
         x_msg_data         => x_msg_data         );

         IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
           RAISE FND_API.G_EXC_ERROR;
         END IF;
         IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        IBE_UTIL.DEBUG('Done calling notify_finish_sharing API');
      END IF;
    END IF; --end working or finish sharing
  END IF; --IF notify_flag is true

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO DELETERECIPIENT_V2;
      x_return_status := FND_API.G_RET_STS_ERROR;
	  FND_Msg_Pub.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count    ,
                                p_data    => x_msg_data);
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
         IBE_Util.Debug('Expected error in IBE_QUOTE_SAVESHARE_V2_PVT.DELETE_RECIPIENT()');
      END IF;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO DELETERECIPIENT_V2;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	  FND_Msg_Pub.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count    ,
                                p_data    => x_msg_data);
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
         IBE_Util.Debug('Unexpected error in IBE_QUOTE_SAVESHARE_V2_PVT.DELETE_RECIPIENT()');
      END IF;

   WHEN OTHERS THEN
      ROLLBACK TO DELETERECIPIENT_V2;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	  IF FND_Msg_Pub.Check_Msg_Level(FND_Msg_Pub.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_Msg_Pub.Add_Exc_Msg(G_PKG_NAME,
                                 l_api_name);
      END IF;
      FND_Msg_Pub.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count    ,
                                p_data    => x_msg_data);
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
         IBE_Util.Debug('Unknown error in IBE_QUOTE_SAVESHARE_V2_PVT.DELETE_RECIPIENT()');
      END IF;

END;

PROCEDURE Validate_share_Update(
 p_api_version_number         IN NUMBER   := 1.0
,p_init_msg_list              IN VARCHAR2 := FND_API.G_FALSE
,p_quote_header_rec           IN ASO_QUOTE_PUB.Qte_Header_Rec_Type
,p_quote_access_tbl           IN IBE_QUOTE_SAVESHARE_pvt.QUOTE_ACCESS_Tbl_Type
                                := IBE_QUOTE_SAVESHARE_pvt.G_miss_quote_access_Tbl
-- partyid and accountid cannot be gmiss coming in
,p_party_id                   IN NUMBER
,p_cust_account_id            IN NUMBER
,p_retrieval_number           IN NUMBER     := FND_API.G_MISS_NUM
,p_operation_code             IN VARCHAR2
,x_return_status              OUT NOCOPY VARCHAR2
,x_msg_count                  OUT NOCOPY NUMBER
,x_msg_data                   OUT NOCOPY VARCHAR2
)

is

l_api_name    CONSTANT VARCHAR2(30) := 'Validate_share_Update';
l_api_version CONSTANT NUMBER       := 1.0;
l_check_updates        VARCHAR2(1)  := FND_API.G_FALSE; -- checks timestamps and if updates are really necessary
l_check_onlynotify     VARCHAR2(1)  := FND_API.G_FALSE;
l_is_owner             VARCHAR2(1)  := FND_API.G_TRUE;
l_owner_party_id       NUMBER;
l_userenv_party_id     NUMBER;
l_access_level         VARCHAR2(30) := null;
l_db_last_update_date  DATE;
l_db_end_date_active   DATE;
l_db_access_level    VARCHAR2(30) := null;
l_db_quote_access_tbl  IBE_QUOTE_SAVESHARE_pvt.QUOTE_ACCESS_Tbl_Type;
l_env_user_id NUMBER;

cursor c_get_owner_partyid(c_quote_id number) is
  select party_id
  from ASO_QUOTE_HEADERS_ALL
  where quote_header_id = c_quote_id;

rec_get_owner_partyid c_get_owner_partyid%rowtype;

cursor c_get_role_by_retr_num(c_retrieval_number number, c_party_id number, c_acct_id number) is
  select update_privilege_type_code
  from ibe_sh_quote_access
  where quote_sharee_number = c_retrieval_number
  and (party_id is null or party_id = c_party_id)
  and (cust_account_id is null or cust_account_id = c_acct_id);

rec_get_role_by_retr_num c_get_role_by_retr_num%rowtype;

cursor c_get_role_by_user(c_party_id number, c_account_id number, c_qte_hdr_id number) is
  select update_privilege_type_code
  from ibe_sh_quote_access
  where quote_header_id = c_qte_hdr_id
  and party_id = c_party_id
  and cust_account_id = c_account_id
  AND nvl(end_date_active, sysdate+1) > sysdate;


rec_get_role_by_user c_get_role_by_user%rowtype;

cursor c_get_recipient_info(c_recipient_id number) is
  select last_update_date, last_updated_by, end_date_active, update_privilege_type_code
  from ibe_sh_quote_access
  where quote_sharee_id = c_recipient_id;

rec_get_recipient_info c_get_recipient_info%rowtype;

BEGIN

  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_UTIL.DEBUG('Begin validate_share_update : ' || to_char(sysdate, 'mm/dd/yyyy:hh24:MI:SS'));
  END IF;

  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call (l_api_version,
			       p_api_version_number,
			       l_api_name,
			       G_PKG_NAME )
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE.

  IF FND_API.To_Boolean( p_init_msg_list ) THEN
	FND_Msg_Pub.initialize;
  END IF;

  --  Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- API body
  -- start by returning the input

  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_UTIL.DEBUG('Incoming quote_header_id is  :'||p_quote_header_rec.quote_header_id);
     IBE_UTIL.DEBUG('Incoming operation_code is   :'||p_operation_code);
     IBE_UTIL.DEBUG('Incoming party_id is         :'||p_party_id);
     IBE_UTIL.DEBUG('Incoming account_id is       :'||p_cust_account_id);
     IBE_UTIL.DEBUG('Incoming retrieval_number is :'||p_retrieval_number);
  END IF;

/*  FOR rec_userenv_partyid in c_userenv_partyid LOOP
    l_userenv_party_id := rec_userenv_partyid.customer_id;
  EXIT when c_userenv_partyid%notfound;
  END LOOP;
*/
  FOR rec_get_owner_partyid in c_get_owner_partyid(p_quote_header_rec.quote_header_id) LOOP
    l_owner_party_id := rec_get_owner_partyid.party_id;
  EXIT when c_get_owner_partyid%notfound;
  END LOOP;
------------ USER VALIDATION - must be either owner or valid recipient ------------------------------
  if (l_owner_party_id <> p_party_id) then
    l_is_owner := FND_API.G_FALSE;
  else
    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      IBE_Util.Debug('Initiator is OWNER');
    END IF;
  end if;

--  if ((l_is_owner = FND_API.G_FALSE) and (p_operation_code <> OP_END_WORKING)) then
  if (l_is_owner = FND_API.G_FALSE) then
  -- if user is not the owner then we need to make sure he is a valid member
    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      IBE_Util.Debug('Initiator may be RECIPIENT');
    END IF;
    if ((p_retrieval_number is not null) and (p_retrieval_number <> FND_API.G_MISS_NUM)) then
      FOR rec_get_role_by_retr_num in c_get_role_by_retr_num(p_retrieval_number, p_party_id, p_cust_account_id) LOOP
        l_access_level := rec_get_role_by_retr_num.update_privilege_type_code;
      EXIT when c_get_role_by_retr_num%notfound;
      END LOOP;
    else
      FOR rec_get_role_by_user in c_get_role_by_user(p_party_id, p_cust_account_id,p_quote_header_rec.quote_header_id) LOOP
        l_access_level := rec_get_role_by_user.update_privilege_type_code;
      EXIT when c_get_role_by_user%notfound;
      END LOOP;
    end if;
    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      IBE_Util.Debug('RECIPIENT access level: ' || l_access_level);
    END IF;
    if (l_access_level is null) then
      IF FND_Msg_Pub.Check_Msg_Level (FND_Msg_Pub.G_MSG_LVL_ERROR) THEN
        FND_Message.Set_Name('IBE', 'IBE_SC_ERR_USERACCESS');
        FND_Msg_Pub.Add;
      END IF;
      -- need to raise an error that the user no longer has access to this cart
      RAISE FND_API.G_EXC_ERROR;
    end if;
  end if;

------------ DETERMINE WHICH VALIDATIONS TO DO BASED ON OP CODE ------------------------------
  -- owner only operations
  if (p_operation_code in (OP_APPEND, OP_NAME_CART, OP_SAVE_CART_AND_RECIPIENTS)) then
    if (l_is_owner = FND_API.G_FALSE) then
      IF FND_Msg_Pub.Check_Msg_Level (FND_Msg_Pub.G_MSG_LVL_ERROR) THEN
        FND_Message.Set_Name('IBE', 'IBE_SC_ERR_PRIVILEGE');
        FND_Msg_Pub.Add;
      END IF;
      -- raise an error that the user does not have this privilege
      RAISE FND_API.G_EXC_ERROR;
    end if;
    if (p_operation_code = OP_SAVE_CART_AND_RECIPIENTS) then
      l_check_updates := FND_API.G_TRUE;
    end if;
  -- owner or admin operations
  elsif (p_operation_code in (OP_STOP_SHARING, OP_DELETE_CART)) then
    if ((l_is_owner = FND_API.G_FALSE) and (l_access_level <> 'A')) then
      IF FND_Msg_Pub.Check_Msg_Level (FND_Msg_Pub.G_MSG_LVL_ERROR) THEN
        FND_Message.Set_Name('IBE', 'IBE_SC_ERR_PRIVILEGE');
        FND_Msg_Pub.Add;
      END IF;
      -- raise an error that the user does not have this privilege
      RAISE FND_API.G_EXC_ERROR;
    end if;
    l_check_onlynotify := FND_API.G_TRUE;
    l_check_updates := FND_API.G_TRUE;
  -- any role, but different checks depending on role
  elsif (p_operation_code = OP_SAVE_RECIPIENTS) then
    if ((l_is_owner = FND_API.G_FALSE) and (l_access_level <> 'A')) then
      -- if not the owner or not admin, then make sure user is only notifying
      l_check_onlynotify := FND_API.G_TRUE;
    end if;
    l_check_updates := FND_API.G_TRUE;
  elsif ((p_operation_code = OP_ACTIVATE_QUOTE) or (p_operation_code = OP_DEACTIVATE)) then
    l_check_updates := FND_API.G_FALSE; -- no validations to do here that have not already been done
  end if; -- end if else over operation_code

  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_UTIL.DEBUG('l_check_onlynotify is  :'||l_check_onlynotify);
     IBE_UTIL.DEBUG('l_check_updates is     :'||l_check_updates);
  END IF;

------------ VALIDATIONS ON THE INPUT QUOTE ACCESS TABLE ------------------------------
  if ((l_check_updates = FND_API.G_TRUE) or (l_check_onlynotify = FND_API.G_TRUE)) then
    l_env_user_id := FND_GLOBAL.USER_ID;
    FOR i in 1..p_quote_access_tbl.count LOOP
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        IBE_UTIL.DEBUG('current quote_sharee_id : '||p_quote_access_tbl(i).quote_sharee_id);
      end if;
      -- populate a local table with all the db data - but index it according to the input table
      -- in this loop, we will check every opcode if necessary
      -- down below, we will end up only checking the ones that have a shareeid
      l_db_quote_access_tbl(i).operation_code := p_quote_access_tbl(i).operation_code;
      if ((p_quote_access_tbl(i).quote_sharee_id is not null)
          and (p_quote_access_tbl(i).quote_sharee_id <> fnd_api.g_miss_num)) then
        --cursor query to get last_update_date, contact_point_id, end_date_active
        FOR rec_get_recipient_info in c_get_recipient_info(p_quote_access_tbl(i).quote_sharee_id) LOOP
          l_db_quote_access_tbl(i).last_update_date := rec_get_recipient_info.last_update_date;
          l_db_quote_access_tbl(i).last_updated_by := rec_get_recipient_info.last_updated_by;
          l_db_quote_access_tbl(i).end_date_active := rec_get_recipient_info.end_date_active;
          l_db_quote_access_tbl(i).update_privilege_type_code := rec_get_recipient_info.update_privilege_type_code;
        EXIT when c_get_recipient_info%notfound;
        END LOOP;
        IF (IBE_UTIL.G_DEBUGON = l_true) THEN
          IBE_UTIL.DEBUG('input op_code           : '||p_quote_access_tbl(i).operation_code);
          IBE_UTIL.DEBUG('input last_update_date  : '||to_char(p_quote_access_tbl(i).last_update_date,'mm/dd/yyyy:hh24:MI:SS'));
          IBE_UTIL.DEBUG('db    last_update_date  : '||to_char(l_db_quote_access_tbl(i).last_update_date,'mm/dd/yyyy:hh24:MI:SS'));
          IBE_UTIL.DEBUG('input access_level      : '||p_quote_access_tbl(i).update_privilege_type_code);
          IBE_UTIL.DEBUG('db    access_level      : '||l_db_quote_access_tbl(i).update_privilege_type_code);
        end if;
        -- do the opcode permissions check as we loop
        if (l_check_onlynotify = FND_API.G_TRUE) then
          -- make sure we are not creating, deleting, or doing any real updates
          if ((p_quote_access_tbl(i).operation_code = 'DELETE')
               or(p_quote_access_tbl(i).operation_code = 'CREATE')
               or ((p_quote_access_tbl(i).operation_code = 'UPDATE')
                   and (p_quote_access_tbl(i).update_privilege_type_code is not null)
                   and (p_quote_access_tbl(i).update_privilege_type_code <> FND_API.G_MISS_CHAR)
                   and (p_quote_access_tbl(i).update_privilege_type_code <> l_db_quote_access_tbl(i).update_privilege_type_code))) then
            IF FND_Msg_Pub.Check_Msg_Level (FND_Msg_Pub.G_MSG_LVL_ERROR) THEN
              FND_Message.Set_Name('IBE', 'IBE_SC_ERR_PRIVILEGE');
              FND_Msg_Pub.Add;
            END IF;
            RAISE FND_API.G_EXC_ERROR;
          end if;
        end if; -- end check onlynotify
      end if;  -- end if we have a quote_sharee_id
    end loop; -- end loop over input access tbl
    -- second loop to check last update dates
    if (l_check_updates = FND_API.G_TRUE) then
      FOR i in 1..p_quote_access_tbl.count LOOP
        IF (IBE_UTIL.G_DEBUGON = l_true) THEN
          IBE_UTIL.DEBUG('current quote_sharee_id : '||p_quote_access_tbl(i).quote_sharee_id);
        end if;
        if ((p_quote_access_tbl(i).quote_sharee_id is not null)
            and (p_quote_access_tbl(i).quote_sharee_id <> fnd_api.g_miss_num)) then

          if ((p_quote_access_tbl(i).last_update_date <> FND_API.G_MISS_DATE) and
              (p_quote_access_tbl(i).last_update_date <> l_db_quote_access_tbl(i).last_update_date)) then
            -- i.e. don't throw exception if we want to end a row and it's already enddated.
            if ((p_quote_access_tbl(i).operation_code = 'DELETE') and (nvl(l_db_quote_access_tbl(i).end_date_active,sysdate-1) < sysdate)) then
              IF (IBE_UTIL.G_DEBUGON = l_true) THEN
                IBE_UTIL.DEBUG('deleteing an end dated row, allowing it to pass through');
              end if;
            elsif (l_env_user_id = l_db_quote_access_tbl(i).last_updated_by) then
              IF (IBE_UTIL.G_DEBUGON = l_true) THEN
                IBE_UTIL.DEBUG('timestamps do not match, but user was the last to update the row so allowing it to go through');
              end if;
            else
              IF FND_Msg_Pub.Check_Msg_Level (FND_Msg_Pub.G_MSG_LVL_ERROR) THEN
                FND_Message.Set_Name('IBE', 'IBE_SC_ERR_MEMBERS_OUT_OF_SYNC');
                FND_Msg_Pub.Add;
              END IF;
              -- need a new error msg that the row has been updated by another user and to try again
              RAISE FND_API.G_EXC_ERROR;
            end if;
          end if; -- end if last_update_dates dont match
        end if;  -- end if shareeid is not null
      end loop; -- end loop over input quote access tbl
    end if; -- end if doing check updates
  end if; -- end check of updates

  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
    IBE_UTIL.DEBUG('End validate_share_update' || to_char(sysdate, 'mm/dd/yyyy:hh24:MI:SS'));
  END IF;

  EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
   x_return_status := FND_API.G_RET_STS_ERROR;
   FND_Msg_Pub.Count_And_Get(p_encoded => FND_API.G_FALSE,
		          p_count   => x_msg_count    ,
			  p_data    => x_msg_data);
  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_Util.Debug('End  IBE_Quote_Misc_pvt.validate_share_update: expected error');
  END IF;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   FND_Msg_Pub.Count_And_Get(p_encoded => FND_API.G_FALSE,
			  p_count   => x_msg_count    ,
			  p_data    => x_msg_data);
   IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      IBE_Util.Debug('End  IBE_Quote_Misc_pvt.validate_share_update: unexpected error');
   END IF;
  WHEN OTHERS THEN
  IF FND_Msg_Pub.Check_Msg_Level(FND_Msg_Pub.G_MSG_LVL_UNEXP_ERROR) THEN
    FND_Msg_Pub.Add_Exc_Msg(G_PKG_NAME,
			   l_api_name);
  END IF;
  FND_Msg_Pub.Count_And_Get(p_encoded => FND_API.G_FALSE,
			  p_count   => x_msg_count    ,
			  p_data    => x_msg_data);
  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_Util.Debug('End IBE_Quote_Misc_pvt.validate_share_update: other exception');
  END IF;
END validate_share_update;

END IBE_QUOTE_SAVESHARE_V2_PVT;

/
