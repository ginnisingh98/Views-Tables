--------------------------------------------------------
--  DDL for Package IBE_QUOTE_SAVESHARE_V2_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBE_QUOTE_SAVESHARE_V2_PVT" AUTHID CURRENT_USER AS
/*$Header: IBEVSS2S.pls 115.13 2003/09/18 06:22:27 ajlee ship $ */

G_PKG_NAME CONSTANT VARCHAR2(30) := 'IBE_QUOTE_SAVESHARE_V2_PVT';
--Operation codes in saveshare_control_rec are
OP_APPEND                    CONSTANT NUMBER := 0;
OP_ACTIVATE_QUOTE            CONSTANT NUMBER := 1;
OP_DEACTIVATE                CONSTANT NUMBER := 2;
OP_NAME_CART                 CONSTANT NUMBER := 3;
OP_SAVE_RECIPIENTS	         CONSTANT NUMBER := 4;
OP_STOP_SHARING              CONSTANT NUMBER := 5;
OP_SAVE_CART_AND_RECIPIENTS  CONSTANT NUMBER := 6;
OP_END_WORKING               CONSTANT NUMBER := 7;
OP_DELETE_CART               CONSTANT NUMBER := 8;


/*New saveshare control record type which includes ASO control record*/
TYPE SAVESHARE_CONTROL_REC_TYPE is record(
    control_rec	        ASO_QUOTE_PUB.control_rec_type
                        := ASO_QUOTE_PUB.G_MISS_Control_Rec ,
    delete_source_cart  VARCHAR2(1) := FND_API.G_true       ,
    combinesameitem     VARCHAR2(1) := FND_API.G_true       ,
    operation_code      NUMBER                              ,
    deactivate_cart     VARCHAR2(1) := FND_API.G_false      );


g_miss_saveshare_control_rec  SAVESHARE_CONTROL_REC_TYPE;

TYPE ACTIVE_CARTS_REC_TYPE is record(
    active_quote_id          number :=FND_API.G_MISS_NUM  ,
    object_version_number    number :=FND_API.G_MISS_NUM  ,
    quote_header_id          number :=FND_API.G_MISS_NUM  ,
    party_id                 number :=FND_API.G_MISS_NUM  ,
    cust_account_id          number :=FND_API.G_MISS_NUM  ,
    creation_date            date   := FND_API.G_MISS_DATE,
    created_by               number :=FND_API.G_MISS_NUM  ,
    last_update_date         date   := FND_API.G_MISS_DATE,
    last_updated_by          number :=FND_API.G_MISS_NUM  ,
    last_update_login        number :=FND_API.G_MISS_NUM );

G_MISS_ACTIVE_CARTS_REC      ACTIVE_CARTS_REC_TYPE;

PROCEDURE save_Contact_Point(
  p_api_version_number  IN   NUMBER
  ,p_init_msg_list       IN   VARCHAR2 := FND_API.G_FALSE
  ,p_commit              IN   VARCHAR2 := FND_API.G_FALSE
  ,P_URL                 IN   VARCHAR2 := FND_API.G_MISS_char
  ,P_EMAIL               IN   VARCHAR2 := FND_API.G_MISS_char
  ,p_owner_table_id      IN   NUMBER
  ,p_mode                IN   VARCHAR2
  ,x_contact_point_id    OUT NOCOPY  number
  ,X_Return_Status       OUT NOCOPY  VARCHAR2
  ,X_Msg_Count           OUT NOCOPY  NUMBER
  ,X_Msg_Data            OUT NOCOPY  VARCHAR2
);

Procedure SAVE_SHARE_V2 (
    P_saveshare_control_rec   IN  SAVESHARE_CONTROL_REC_TYPE
                                  := G_MISS_saveshare_control_rec              ,
    P_party_id                IN  NUMBER                                       ,
    P_cust_account_id         IN  NUMBER                                       ,
    P_retrieval_number        IN  NUMBER                                       ,
    P_Quote_header_rec        IN  ASO_QUOTE_PUB.Qte_Header_Rec_Type            ,
    P_quote_access_tbl        IN  IBE_QUOTE_SAVESHARE_pvt.QUOTE_ACCESS_Tbl_Type
                                  := ibe_quote_saveshare_pvt.G_MISS_QUOTE_ACCESS_TBL,
    P_source_quote_header_id  IN  NUMBER   := FND_API.G_MISS_NUM               ,
    P_source_last_update_date IN  DATE     := FND_API.G_MISS_DATE              ,
    p_minisite_id             IN  NUMBER                                       ,
    p_URL                     IN  VARCHAR2                                     ,
    p_notes                   IN  VARCHAR2 := FND_API.G_MISS_CHAR              ,
    p_api_version             IN  NUMBER   := 1                                ,
    p_init_msg_list           IN  VARCHAR2 := FND_API.G_TRUE                   ,
    p_commit                  IN  VARCHAR2 := FND_API.G_FALSE                  ,
    x_return_status           OUT NOCOPY VARCHAR2                              ,
    x_msg_count               OUT NOCOPY NUMBER                                ,
    x_msg_data                OUT NOCOPY VARCHAR2                              );

Procedure SAVE_RECIPIENTS  (
    P_Quote_access_tbl IN  IBE_QUOTE_SAVESHARE_pvt.QUOTE_ACCESS_TBL_TYPE
                           := IBE_QUOTE_SAVESHARE_pvt.G_miss_quote_access_Tbl     ,
    P_Quote_header_id  IN  Number                                          ,
    P_Party_id         IN  Number                := FND_API.G_MISS_NUM     ,
    P_Cust_account_id  IN  Number                := FND_API.G_MISS_NUM     ,
    P_URL              IN  Varchar2              := FND_API.G_MISS_CHAR    ,
    P_minisite_id      IN  Number                := FND_API.G_MISS_NUM     ,
    p_send_notif       IN  Varchar2              := FND_API.G_TRUE         ,
    p_notes            IN  Varchar2              := FND_API.G_MISS_CHAR    ,
    p_api_version      IN  NUMBER                := 1                      ,
    p_init_msg_list    IN  VARCHAR2              := FND_API.G_TRUE         ,
    p_commit           IN  VARCHAR2              := FND_API.G_FALSE        ,
    x_return_status    OUT NOCOPY VARCHAR2                                 ,
    x_msg_count        OUT NOCOPY NUMBER                                   ,
    x_msg_data         OUT NOCOPY VARCHAR2                                 );

Procedure ACTIVATE_QUOTE  (
    P_Quote_header_rec IN  ASO_QUOTE_PUB.Qte_Header_Rec_Type ,
    P_Party_id         IN Number := FND_API.G_MISS_NUM       ,
    P_Cust_account_id  IN Number := FND_API.G_MISS_NUM       ,
    P_control_rec      IN ASO_QUOTE_PUB.control_rec_type
                          := ASO_QUOTE_PUB.G_MISS_Control_Rec,
    p_retrieval_number IN  NUMBER := FND_API.G_MISS_NUM      ,
    p_api_version      IN  NUMBER   := 1                     ,
    p_init_msg_list    IN  VARCHAR2 := FND_API.G_TRUE        ,
    p_commit           IN  VARCHAR2 := FND_API.G_FALSE       ,
    x_return_status    OUT NOCOPY VARCHAR2                   ,
    x_msg_count        OUT NOCOPY NUMBER                     ,
    x_msg_data         OUT NOCOPY VARCHAR2                    );

Procedure DEACTIVATE_QUOTE  (
    P_Quote_header_id  IN Number                       ,
    P_Party_id         IN Number := FND_API.G_MISS_NUM ,
    P_Cust_account_id  IN Number := FND_API.G_MISS_NUM ,
    P_minisite_id      IN Number := FND_API.G_MISS_NUM ,
    p_api_version      IN  NUMBER   := 1               ,
    p_init_msg_list    IN  VARCHAR2 := FND_API.G_TRUE  ,
    p_commit           IN  VARCHAR2 := FND_API.G_FALSE ,
    x_return_status    OUT NOCOPY VARCHAR2             ,
    x_msg_count        OUT NOCOPY NUMBER               ,
    x_msg_data         OUT NOCOPY VARCHAR2             );

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
    x_msg_data                OUT NOCOPY VARCHAR2                     );


Procedure STOP_SHARING (
    p_quote_header_id  IN  NUMBER                                 ,
    p_delete_context   IN  VARCHAR2 := 'IBE_SC_CART_STOPSHARING'  ,
    P_minisite_id      IN  Number   := FND_API.G_MISS_NUM         ,
    p_notes            IN  Varchar2 := FND_API.G_MISS_CHAR        ,
    p_quote_access_tbl IN  IBE_QUOTE_SAVESHARE_pvt.QUOTE_ACCESS_Tbl_Type
                           := IBE_QUOTE_SAVESHARE_pvt.G_miss_quote_access_Tbl,
    p_api_version      IN  NUMBER   := 1                          ,
    p_init_msg_list    IN  VARCHAR2 := FND_API.G_TRUE             ,
    p_commit           IN  VARCHAR2 := FND_API.G_FALSE            ,
    x_return_status    OUT NOCOPY VARCHAR2                        ,
    x_msg_count        OUT NOCOPY NUMBER                          ,
    x_msg_data         OUT NOCOPY VARCHAR2                        );

Procedure END_WORKING (
    p_quote_access_tbl IN  IBE_QUOTE_SAVESHARE_pvt.QUOTE_ACCESS_Tbl_Type
                           := IBE_QUOTE_SAVESHARE_pvt.G_miss_quote_access_Tbl,
    P_Quote_header_id   IN  Number                                              ,
    P_Party_id          IN  Number         := FND_API.G_MISS_NUM                ,
    P_Cust_account_id   IN  Number         := FND_API.G_MISS_NUM                ,
    p_retrieval_number  IN  Number         := FND_API.G_MISS_NUM                ,
    P_URL               IN  Varchar2       := FND_API.G_MISS_CHAR               ,
    P_minisite_id       IN  Number         := FND_API.G_MISS_NUM                ,
    p_notes             IN  VARCHAR2       := FND_API.G_MISS_CHAR               ,
    p_api_version       IN  NUMBER         := 1                                 ,
    p_init_msg_list     IN  VARCHAR2       := FND_API.G_TRUE                    ,
    p_commit            IN  VARCHAR2       := FND_API.G_FALSE                   ,
    x_return_status     OUT NOCOPY VARCHAR2                                     ,
    x_msg_count         OUT NOCOPY NUMBER                                       ,
    x_msg_data          OUT NOCOPY VARCHAR2                                      );

Procedure SHARE_READONLY  (
    p_quote_header_id  IN  Number                      ,
    P_minisite_id      IN  Number   := FND_API.G_MISS_NUM,
    p_url              IN  VARCHAR2 := FND_API.G_MISS_CHAR,

    p_api_version      IN  NUMBER   := 1               ,
    p_init_msg_list    IN  VARCHAR2 := FND_API.G_TRUE  ,
    p_commit           IN  VARCHAR2 := FND_API.G_FALSE ,
    x_return_status    OUT NOCOPY VARCHAR2                    ,
    x_msg_count        OUT NOCOPY NUMBER                      ,
    x_msg_data         OUT NOCOPY VARCHAR2                    );

Procedure DELETE_RECIPIENT  (
    P_Quote_access_rec  IN  IBE_QUOTE_SAVESHARE_pvt.QUOTE_ACCESS_REC_TYPE
                            := IBE_QUOTE_SAVESHARE_pvt.G_MISS_QUOTE_ACCESS_REC,
    p_minisite_id       IN  NUMBER                                            ,
    p_delete_code       IN  VARCHAR2 := 'IBE_SC_CART_STOPSHARING'             ,
    p_url               IN  VARCHAR2 := FND_API.G_MISS_CHAR                   ,
    p_notes             IN  VARCHAR2 := FND_API.G_MISS_CHAR                   ,
    p_api_version       IN  NUMBER   := 1                                     ,
    p_init_msg_list     IN  VARCHAR2 := FND_API.G_TRUE                        ,
    p_commit            IN  VARCHAR2 := FND_API.G_FALSE                       ,
    x_return_status     OUT NOCOPY VARCHAR2                                   ,
    x_msg_count         OUT NOCOPY NUMBER                                     ,
    x_msg_data          OUT NOCOPY VARCHAR2                                   );

PROCEDURE Validate_share_Update(
 p_api_version_number         IN NUMBER   := 1.0
,p_init_msg_list              IN VARCHAR2 := FND_API.G_FALSE
,p_quote_header_rec           IN ASO_QUOTE_PUB.Qte_Header_Rec_Type
,p_quote_access_tbl           IN IBE_QUOTE_SAVESHARE_pvt.QUOTE_ACCESS_Tbl_Type
                                := IBE_QUOTE_SAVESHARE_pvt.G_miss_quote_access_Tbl
-- partyid and accountid cannot be gmiss coming in
,p_party_id                   IN NUMBER
,p_cust_account_id            IN NUMBER
,p_retrieval_number           IN NUMBER    := FND_API.G_MISS_NUM
,p_operation_code             IN VARCHAR2
,x_return_status              OUT NOCOPY VARCHAR2
,x_msg_count                  OUT NOCOPY NUMBER
,x_msg_data                   OUT NOCOPY VARCHAR2);


END IBE_QUOTE_SAVESHARE_V2_PVT;

 

/
