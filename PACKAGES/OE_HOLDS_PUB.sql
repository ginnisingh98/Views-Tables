--------------------------------------------------------
--  DDL for Package OE_HOLDS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_HOLDS_PUB" AUTHID CURRENT_USER AS
/* $Header: OEXPHLDS.pls 120.5.12010000.6 2011/12/30 03:44:34 slagiset ship $ */

--  Start of Comments
--  API name    OE_Holds_PUB
--  Type        Public
--  Version     Current version = 1.0
--              Initial version = 1.0

--Changes for bug 2673236 :Begin

G_PAYMENT_HOLD_APPLIED  VARCHAR2(1) :='N';  --ER#7479609
G_HDR_PAYMENT VARCHAR2(1) :='N';  --ER#7479609

TYPE Any_Line_Hold_Rec IS RECORD
(      HEADER_ID                     OE_ORDER_HEADERS.HEADER_ID%TYPE := NULL
     , HOLD_ID                       OE_Hold_Sources_ALL.HOLD_ID%TYPE := NULL
     , HOLD_ENTITY_CODE              OE_Hold_Sources_ALL.HOLD_ENTITY_CODE%TYPE := NULL
     , HOLD_ENTITY_ID                OE_Hold_Sources_ALL.HOLD_ENTITY_ID%TYPE := NULL
     , HOLD_ENTITY_CODE2             OE_Hold_Sources_ALL.HOLD_ENTITY_CODE2%TYPE := NULL
     , HOLD_ENTITY_ID2               OE_Hold_Sources_ALL.HOLD_ENTITY_ID2%TYPE := NULL
     , WF_ITEM_TYPE                  VARCHAR2(30) DEFAULT NULL
     , WF_ACTIVITY_NAME              VARCHAR2(30) DEFAULT NULL
     , p_chk_act_hold_only           VARCHAR2(1) DEFAULT 'N'
     , x_result_out                  VARCHAR2(30)
);

-- Check_Any_Line_Hold

PROCEDURE Check_Any_Line_Hold (
    x_hold_rec           IN OUT NOCOPY  OE_Holds_PUB.Any_Line_Hold_Rec
,   x_return_status      OUT NOCOPY VARCHAR2
,   x_msg_count          OUT NOCOPY NUMBER
,   x_msg_data           OUT NOCOPY VARCHAR2
);

--Changes for bug 2673236 :End

--  Apply Holds

PROCEDURE Apply_Holds
(   p_api_version		IN	NUMBER
,   p_init_msg_list		IN	VARCHAR2 DEFAULT FND_API.G_FALSE
,   p_commit			IN	VARCHAR2 DEFAULT FND_API.G_FALSE
,   p_validation_level	IN	NUMBER 	 DEFAULT FND_API.G_VALID_LEVEL_FULL
,   p_header_id		IN	NUMBER 	DEFAULT NULL
,   p_line_id			IN	NUMBER 	DEFAULT NULL
,   p_hold_source_id	IN      NUMBER  DEFAULT NULL
,   p_hold_source_rec	IN	OE_Hold_Sources_Pvt.Hold_Source_REC
                            DEFAULT OE_Hold_Sources_Pvt.G_MISS_Hold_Source_REC
,   p_check_authorization_flag IN VARCHAR2 DEFAULT 'N'  -- bug 8477694
,   x_return_status		OUT NOCOPY /* file.sql.39 change */	VARCHAR2
,   x_msg_count		OUT NOCOPY /* file.sql.39 change */	NUMBER
,   x_msg_data			OUT NOCOPY /* file.sql.39 change */	VARCHAR2
);

-----------------------------------
-- New Overloaded APPLY_HOLD API --
-----------------------------------
Procedure Apply_Holds (
  p_api_version        IN  NUMBER,
  p_init_msg_list      IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
  p_commit             IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
  p_validation_level   IN  NUMBER   DEFAULT FND_API.G_VALID_LEVEL_FULL,
  p_order_tbl          IN  OE_HOLDS_PVT.order_tbl_type,
  p_hold_id            IN  OE_HOLD_DEFINITIONS.HOLD_ID%TYPE,
  p_hold_until_date    IN  OE_HOLD_SOURCES.HOLD_UNTIL_DATE%TYPE DEFAULT NULL,
  p_hold_comment       IN  OE_HOLD_SOURCES.HOLD_COMMENT%TYPE DEFAULT NULL,
  p_check_authorization_flag IN VARCHAR2 DEFAULT 'N',  -- bug 8477694
  x_return_status      OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
  x_msg_count          OUT NOCOPY /* file.sql.39 change */ NUMBER,
  x_msg_data           OUT NOCOPY /* file.sql.39 change */ VARCHAR2 );

Procedure Apply_Holds(
  p_api_version        IN  NUMBER,
  p_init_msg_list      IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
  p_commit             IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
  p_validation_level   IN  NUMBER   DEFAULT FND_API.G_VALID_LEVEL_FULL,
  p_hold_source_rec     IN  OE_HOLDS_PVT.Hold_Source_Rec_Type
                        DEFAULT  OE_HOLDS_PVT.G_MISS_HOLD_SOURCE_REC,
  p_hold_existing_flg   IN  VARCHAR2 DEFAULT 'Y',
  p_hold_future_flg     IN  VARCHAR2 DEFAULT 'Y',
  p_check_authorization_flag IN VARCHAR2 DEFAULT 'N',  -- bug 8477694
  x_return_status       OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
  x_msg_count           OUT NOCOPY /* file.sql.39 change */ NUMBER,
  x_msg_data            OUT NOCOPY /* file.sql.39 change */ VARCHAR2 );



--  Check Holds

PROCEDURE Check_Holds
(   p_api_version		IN	NUMBER
,   p_init_msg_list		IN	VARCHAR2 DEFAULT FND_API.G_FALSE
,   p_commit			IN	VARCHAR2 DEFAULT FND_API.G_FALSE
,   p_validation_level	IN	NUMBER 	 DEFAULT FND_API.G_VALID_LEVEL_FULL
,   p_header_id		IN	NUMBER DEFAULT NULL
,   p_line_id			IN	NUMBER DEFAULT NULL
,   p_hold_id			IN	NUMBER DEFAULT NULL
,   p_wf_item			IN 	VARCHAR2 DEFAULT NULL
,   p_wf_activity		IN 	VARCHAR2 DEFAULT NULL
,   p_entity_code		IN   VARCHAR2 DEFAULT NULL
--ER#7479609,   p_entity_id		IN	NUMBER DEFAULT NULL
,   p_entity_id          IN   oe_hold_sources_all.hold_entity_id%TYPE   DEFAULT NULL  --ER#7479609
,   p_entity_code2		IN   VARCHAR2 DEFAULT NULL
--ER#7479609,   p_entity_id2		IN	NUMBER DEFAULT NULL
,   p_entity_id2         IN   oe_hold_sources_all.hold_entity_id2%TYPE   DEFAULT NULL  --ER#7479609
,   p_chk_act_hold_only  IN   VARCHAR2 DEFAULT 'N'
,   x_result_out		OUT NOCOPY /* file.sql.39 change */	VARCHAR2
,   x_return_status		OUT NOCOPY /* file.sql.39 change */	VARCHAR2
,   x_msg_count		OUT NOCOPY /* file.sql.39 change */	NUMBER
,   x_msg_data			OUT NOCOPY /* file.sql.39 change */	VARCHAR2
);

/* Added 12-15-2005. see bug#4888425 */
PROCEDURE Check_Holds_line (
    p_hdr_id             IN   NUMBER
,   p_line_id            IN   NUMBER   DEFAULT NULL
,   p_hold_id            IN   NUMBER   DEFAULT NULL
,   p_wf_item            IN   VARCHAR2 DEFAULT NULL
,   p_wf_activity        IN   VARCHAR2 DEFAULT NULL
,   p_entity_code        IN   VARCHAR2 DEFAULT NULL
--ER#7479609,   p_entity_id          IN   NUMBER   DEFAULT NULL
,   p_entity_id          IN   oe_hold_sources_all.hold_entity_id%TYPE   DEFAULT NULL  --ER#7479609
,   p_entity_code2       IN   VARCHAR2 DEFAULT NULL
--ER#7479609,   p_entity_id2         IN   NUMBER   DEFAULT NULL
,   p_entity_id2         IN   oe_hold_sources_all.hold_entity_id2%TYPE   DEFAULT NULL  --ER#7479609
,   p_chk_act_hold_only  IN   VARCHAR2 DEFAULT 'N'
,   p_ii_parent_flag     IN   VARCHAR2 DEFAULT 'N'
,   x_result_out         OUT NOCOPY /* file.sql.39 change */  VARCHAR2
,   x_return_status      OUT NOCOPY /* file.sql.39 change */  VARCHAR2
,   x_msg_count          OUT NOCOPY /* file.sql.39 change */  NUMBER
,   x_msg_data           OUT NOCOPY /* file.sql.39 change */  VARCHAR2
);

PROCEDURE Check_Hold_Sources
(   p_api_version               IN      NUMBER
,   p_init_msg_list             IN      VARCHAR2 DEFAULT FND_API.G_FALSE
,   p_commit                    IN      VARCHAR2 DEFAULT FND_API.G_FALSE
,   p_validation_level  IN      NUMBER   DEFAULT FND_API.G_VALID_LEVEL_FULL
,   p_hold_id                   IN      NUMBER DEFAULT NULL
,   p_wf_item                   IN      VARCHAR2 DEFAULT NULL
,   p_wf_activity               IN      VARCHAR2 DEFAULT NULL
,   p_hold_entity_code          IN      VARCHAR2 DEFAULT NULL
--ER#7479609 ,   p_hold_entity_id            IN      NUMBER DEFAULT NULL
,   p_hold_entity_id            IN      oe_hold_sources_all.hold_entity_id%TYPE DEFAULT NULL  --ER#7479609
,   p_hold_entity_code2         IN      VARCHAR2 DEFAULT NULL
--ER#7479609 ,   p_hold_entity_id2            IN      NUMBER DEFAULT NULL
,   p_hold_entity_id2            IN      oe_hold_sources_all.hold_entity_id2%TYPE DEFAULT NULL  --ER#7479609
,   p_chk_act_hold_only         IN   VARCHAR2 DEFAULT 'N'
,   x_result_out                OUT NOCOPY /* file.sql.39 change */     VARCHAR2
,   x_return_status             OUT NOCOPY /* file.sql.39 change */     VARCHAR2
,   x_msg_count                 OUT NOCOPY /* file.sql.39 change */     NUMBER
,   x_msg_data                  OUT NOCOPY /* file.sql.39 change */     VARCHAR2
);

--  Release Holds

PROCEDURE Release_Holds
(   p_api_version		IN	NUMBER DEFAULT 1.0
,   p_init_msg_list		IN	VARCHAR2 DEFAULT FND_API.G_FALSE
,   p_commit			IN	VARCHAR2 DEFAULT FND_API.G_FALSE
,   p_validation_level	IN	NUMBER DEFAULT FND_API.G_VALID_LEVEL_FULL
,   p_header_id		IN	NUMBER DEFAULT NULL
,   p_line_id			IN	NUMBER DEFAULT NULL
,   p_hold_id			IN	NUMBER DEFAULT NULL
,   p_entity_code		IN	VARCHAR2 DEFAULT NULL
,   p_entity_id		IN	NUMBER DEFAULT NULL
,   p_entity_code2		IN	VARCHAR2 DEFAULT NULL
,   p_entity_id2		IN	NUMBER DEFAULT NULL
,   p_hold_release_rec	IN	OE_Hold_Sources_Pvt.Hold_Release_REC
,   p_check_authorization_flag IN VARCHAR2 DEFAULT 'N'   -- bug 8477694
,   x_return_status		OUT NOCOPY /* file.sql.39 change */	VARCHAR2
,   x_msg_count		OUT NOCOPY /* file.sql.39 change */ 	NUMBER
,   x_msg_data			OUT NOCOPY /* file.sql.39 change */	VARCHAR2
);


------------------------------------
-- New Release Holds API          --
------------------------------------
Procedure Release_Holds (
  p_api_version           IN      NUMBER DEFAULT 1.0,
  p_init_msg_list         IN      VARCHAR2 DEFAULT FND_API.G_FALSE,
  p_commit                IN      VARCHAR2 DEFAULT FND_API.G_FALSE,
  p_validation_level      IN      NUMBER DEFAULT FND_API.G_VALID_LEVEL_FULL,
  p_hold_source_rec       IN   OE_HOLDS_PVT.hold_source_rec_type,
  p_hold_release_rec      IN   OE_HOLDS_PVT.Hold_Release_Rec_Type,
  p_check_authorization_flag IN VARCHAR2 DEFAULT 'N',   -- bug 8477694
  x_return_status         OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
  x_msg_count             OUT NOCOPY /* file.sql.39 change */  NUMBER,
  x_msg_data              OUT NOCOPY /* file.sql.39 change */  VARCHAR2);

Procedure Release_Holds (
  p_api_version           IN      NUMBER DEFAULT 1.0,
  p_init_msg_list         IN      VARCHAR2 DEFAULT FND_API.G_FALSE,
  p_commit                IN      VARCHAR2 DEFAULT FND_API.G_FALSE,
  p_validation_level      IN      NUMBER DEFAULT FND_API.G_VALID_LEVEL_FULL,
  p_order_tbl              IN   OE_HOLDS_PVT.order_tbl_type,
  p_hold_id                IN   OE_HOLD_DEFINITIONS.HOLD_ID%TYPE DEFAULT NULL,
  p_release_reason_code    IN   OE_HOLD_RELEASES.RELEASE_REASON_CODE%TYPE,
  p_release_comment        IN   OE_HOLD_RELEASES.RELEASE_COMMENT%TYPE
                      DEFAULT  NULL,
  p_check_authorization_flag IN VARCHAR2 DEFAULT 'N',   -- bug 8477694
  x_return_status          OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
  x_msg_count              OUT NOCOPY /* file.sql.39 change */  NUMBER,
  x_msg_data               OUT NOCOPY /* file.sql.39 change */  VARCHAR2);

--  Delete Holds

PROCEDURE Delete_Holds
(   p_header_id          IN   NUMBER 	DEFAULT FND_API.G_MISS_NUM
,   p_line_id			IN	NUMBER 	DEFAULT  FND_API.G_MISS_NUM
);



PROCEDURE evaluate_holds(  p_entity_code         IN   VARCHAR2
                        ,  p_entity_id           IN   NUMBER
                        ,  p_hold_entity_code    IN   VARCHAR2
                        --ER#7479609 ,  p_hold_entity_id      IN   NUMBER
                        ,  p_hold_entity_id      IN oe_hold_sources_all.hold_entity_id%TYPE   --ER#7479609
                        ,  x_return_status       OUT NOCOPY /* file.sql.39 change */  VARCHAR2
                        ,  x_msg_count           OUT NOCOPY /* file.sql.39 change */  NUMBER
                        ,  x_msg_data            OUT NOCOPY /* file.sql.39 change */  VARCHAR2
                        );
PROCEDURE evaluate_holds_post_write
             (  p_entity_code     IN   VARCHAR2
             ,  p_entity_id       IN   NUMBER
             ,  x_return_status       OUT NOCOPY /* file.sql.39 change */  VARCHAR2
             ,  x_msg_count           OUT NOCOPY /* file.sql.39 change */  NUMBER
             ,  x_msg_data            OUT NOCOPY /* file.sql.39 change */  VARCHAR2
             );

PROCEDURE eval_post_write_header
             ( p_entity_code       IN  VARCHAR2
             , p_entity_id         IN  NUMBER
             , p_hold_entity_code  IN  VARCHAR2
             --ER#7479609 , p_hold_entity_id    IN  NUMBER
             , p_hold_entity_id    IN  oe_hold_sources_all.hold_entity_id%TYPE --ER#7479609
             , x_return_status     OUT NOCOPY /* file.sql.39 change */ VARCHAR2
             , x_msg_count         OUT NOCOPY /* file.sql.39 change */ NUMBER
             , x_msg_data          OUT NOCOPY /* file.sql.39 change */ VARCHAR2
             );


PROCEDURE RELEASE_EXPIRED_HOLDS
 (
 p_dummy1            OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
 p_dummy2            OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
 p_org_id            IN   NUMBER
 );

PROCEDURE UPDATE_HOLD_COMMENTS (
  p_hold_source_rec     IN  OE_HOLDS_PVT.Hold_Source_Rec_Type,
  x_return_status       OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
  x_msg_count           OUT NOCOPY /* file.sql.39 change */ NUMBER,
  x_msg_data            OUT NOCOPY /* file.sql.39 change */ VARCHAR2 );


-- For customer global holds

PROCEDURE Process_Holds
(   p_api_version		IN	NUMBER
,   p_init_msg_list		IN	VARCHAR2 DEFAULT FND_API.G_FALSE
,   p_hold_entity_code		IN	VARCHAR2
--ER#7479609 ,   p_hold_entity_id		IN	NUMBER
,   p_hold_entity_id		IN	oe_hold_sources_all.hold_entity_id%TYPE --ER#7479609
,   p_hold_id		        IN	NUMBER DEFAULT 1
,   p_release_reason_code	IN      VARCHAR2 DEFAULT NULL
,   p_action             	IN      VARCHAR2
,   x_return_status       OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count           OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data            OUT NOCOPY /* file.sql.39 change */ VARCHAR2
);

--ER 12363706 start

FUNCTION Hold_exists
(   p_hold_entity_code		IN	VARCHAR2
,   p_hold_entity_id		IN	oe_hold_sources_all.hold_entity_id%TYPE --ER#7479609
,   p_hold_id		        IN	NUMBER DEFAULT 1
,   p_org_id                    IN      NUMBER DEFAULT NULL
)
RETURN boolean;

--ER 12363706 end


END OE_Holds_PUB;

/
