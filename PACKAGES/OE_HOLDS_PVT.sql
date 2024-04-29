--------------------------------------------------------
--  DDL for Package OE_HOLDS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_HOLDS_PVT" AUTHID CURRENT_USER AS
/* $Header: OEXVHLDS.pls 120.2.12010000.5 2009/07/16 13:29:10 msundara ship $ */

-- Hold Source
TYPE Hold_Source_Rec_Type IS RECORD (
	  HOLD_SOURCE_ID         OE_Hold_Sources_ALL.HOLD_SOURCE_ID%TYPE
	, LAST_UPDATE_DATE       OE_Hold_Sources_ALL.LAST_UPDATE_DATE%TYPE
 	, LAST_UPDATED_BY      	 OE_Hold_Sources_ALL.LAST_UPDATED_BY%TYPE
	, CREATION_DATE        	 OE_Hold_Sources_ALL.CREATION_DATE%TYPE
 	, CREATED_BY           	 OE_Hold_Sources_ALL.CREATED_BY%TYPE
	, LAST_UPDATE_LOGIN    	 OE_Hold_Sources_ALL.LAST_UPDATE_LOGIN%TYPE
 	, PROGRAM_APPLICATION_ID OE_Hold_Sources_ALL.PROGRAM_APPLICATION_ID%TYPE
 	, PROGRAM_ID           	 OE_Hold_Sources_ALL.PROGRAM_ID%TYPE
 	, PROGRAM_UPDATE_DATE  	 OE_Hold_Sources_ALL.PROGRAM_UPDATE_DATE%TYPE
 	, REQUEST_ID            OE_Hold_Sources_ALL.REQUEST_ID%TYPE
 	, HOLD_ID               OE_Hold_Sources_ALL.HOLD_ID%TYPE
 	, HOLD_ENTITY_CODE      OE_Hold_Sources_ALL.HOLD_ENTITY_CODE%TYPE
 	, HOLD_ENTITY_ID        OE_Hold_Sources_ALL.HOLD_ENTITY_ID%TYPE
 	, HOLD_UNTIL_DATE       OE_Hold_Sources_ALL.HOLD_UNTIL_DATE%TYPE
 	, RELEASED_FLAG         OE_Hold_Sources_ALL.RELEASED_FLAG%TYPE
 	, HOLD_COMMENT          OE_Hold_Sources_ALL.HOLD_COMMENT%TYPE
 	, CONTEXT               OE_Hold_Sources_ALL.CONTEXT%TYPE
 	, ATTRIBUTE1            OE_Hold_Sources_ALL.ATTRIBUTE1%TYPE
 	, ATTRIBUTE2            OE_Hold_Sources_ALL.ATTRIBUTE2%TYPE
 	, ATTRIBUTE3		    OE_Hold_Sources_ALL.ATTRIBUTE3%TYPE
 	, ATTRIBUTE4            OE_Hold_Sources_ALL.ATTRIBUTE4%TYPE
 	, ATTRIBUTE5            OE_Hold_Sources_ALL.ATTRIBUTE5%TYPE
 	, ATTRIBUTE6            OE_Hold_Sources_ALL.ATTRIBUTE6%TYPE
 	, ATTRIBUTE7            OE_Hold_Sources_ALL.ATTRIBUTE7%TYPE
 	, ATTRIBUTE8            OE_Hold_Sources_ALL.ATTRIBUTE8%TYPE
 	, ATTRIBUTE9            OE_Hold_Sources_ALL.ATTRIBUTE9%TYPE
 	, ATTRIBUTE10           OE_Hold_Sources_ALL.ATTRIBUTE10%TYPE
 	, ATTRIBUTE11           OE_Hold_Sources_ALL.ATTRIBUTE11%TYPE
 	, ATTRIBUTE12           OE_Hold_Sources_ALL.ATTRIBUTE12%TYPE
 	, ATTRIBUTE13    	    OE_Hold_Sources_ALL.ATTRIBUTE13%TYPE
 	, ATTRIBUTE14           OE_Hold_Sources_ALL.ATTRIBUTE14%TYPE
 	, ATTRIBUTE15           OE_Hold_Sources_ALL.ATTRIBUTE15%TYPE
 	, ORG_ID                OE_Hold_Sources_ALL.ORG_ID%TYPE
 	, HOLD_RELEASE_ID       OE_Hold_Sources_ALL.HOLD_RELEASE_ID%TYPE
 	, HOLD_ENTITY_CODE2     OE_Hold_Sources_ALL.HOLD_ENTITY_CODE2%TYPE
 	, HOLD_ENTITY_ID2       OE_Hold_Sources_ALL.HOLD_ENTITY_ID2%TYPE
	-- Header and line id, in case only put this order or line on hold for
	-- a specific header or line. Also for line level hold we need to pass
	-- line id.
	, HEADER_ID             OE_ORDER_HEADERS.HEADER_ID%TYPE
     , LINE_ID               OE_ORDER_LINES.LINE_ID%TYPE
);

-- Hold Release
TYPE Hold_Release_Rec_Type IS RECORD
(	  HOLD_RELEASE_ID 	  OE_Hold_Releases.HOLD_RELEASE_ID%TYPE
 	, CREATION_DATE           OE_Hold_Releases.CREATION_DATE%TYPE
	, CREATED_BY              OE_Hold_Releases.CREATED_BY%TYPE
 	, LAST_UPDATE_DATE        OE_Hold_Releases.LAST_UPDATE_DATE%TYPE
 	, LAST_UPDATED_BY         OE_Hold_Releases.LAST_UPDATED_BY%TYPE
 	, LAST_UPDATE_LOGIN        	OE_Hold_Releases.LAST_UPDATE_LOGIN%TYPE
 	, PROGRAM_APPLICATION_ID   	OE_Hold_Releases.PROGRAM_APPLICATION_ID%TYPE
 	, PROGRAM_ID             	OE_Hold_Releases.PROGRAM_ID%TYPE
 	, PROGRAM_UPDATE_DATE    	OE_Hold_Releases.PROGRAM_UPDATE_DATE%TYPE
 	, REQUEST_ID            	OE_Hold_Releases.REQUEST_ID%TYPE
	, HOLD_SOURCE_ID        	OE_Hold_Releases.HOLD_SOURCE_ID%TYPE
 	, RELEASE_REASON_CODE  		OE_Hold_Releases.RELEASE_REASON_CODE%TYPE
 	, RELEASE_COMMENT      		OE_Hold_Releases.RELEASE_COMMENT%TYPE
 	, CONTEXT              		OE_Hold_Releases.CONTEXT%TYPE
 	, ORDER_HOLD_ID        		OE_Hold_Releases.ORDER_HOLD_ID%TYPE
 	, ATTRIBUTE1           		OE_Hold_Releases.ATTRIBUTE1%TYPE
 	, ATTRIBUTE2           		OE_Hold_Releases.ATTRIBUTE2%TYPE
 	, ATTRIBUTE3           		OE_Hold_Releases.ATTRIBUTE3%TYPE
 	, ATTRIBUTE4           		OE_Hold_Releases.ATTRIBUTE4%TYPE
 	, ATTRIBUTE5            	OE_Hold_Releases.ATTRIBUTE5%TYPE
 	, ATTRIBUTE6            	OE_Hold_Releases.ATTRIBUTE6%TYPE
 	, ATTRIBUTE7            	OE_Hold_Releases.ATTRIBUTE7%TYPE
 	, ATTRIBUTE8            	OE_Hold_Releases.ATTRIBUTE8%TYPE
 	, ATTRIBUTE9            	OE_Hold_Releases.ATTRIBUTE9%TYPE
 	, ATTRIBUTE10           	OE_Hold_Releases.ATTRIBUTE10%TYPE
 	, ATTRIBUTE11           	OE_Hold_Releases.ATTRIBUTE11%TYPE
 	, ATTRIBUTE12           	OE_Hold_Releases.ATTRIBUTE12%TYPE
 	, ATTRIBUTE13           	OE_Hold_Releases.ATTRIBUTE13%TYPE
 	, ATTRIBUTE14           	OE_Hold_Releases.ATTRIBUTE14%TYPE
 	, ATTRIBUTE15            	OE_Hold_Releases.ATTRIBUTE15%TYPE
);

G_MISS_HOLD_SOURCE_REC            Hold_Source_REC_type;

G_MISS_HOLD_RELEASE_REC		  Hold_Release_REC_type;


	TYPE Hold_Source_Tbl_Type IS TABLE OF Hold_Source_Rec_Type
		INDEX BY BINARY_INTEGER;

	-- Header Rec
	TYPE order_rec_type	IS RECORD (
		Header_Id	OE_ORDER_HEADERS.HEADER_ID%TYPE,
		Line_Id		OE_ORDER_LINES.LINE_ID%TYPE
	);

	TYPE order_tbl_type	IS TABLE OF  order_rec_type
		INDEX BY BINARY_INTEGER;

TYPE operating_units_tab IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;  --ER#7479609


Procedure Apply_Holds(
  p_hold_source_rec     IN  OE_HOLDS_PVT.Hold_Source_Rec_Type
                            DEFAULT  OE_HOLDS_PVT.G_MISS_HOLD_SOURCE_REC,
  p_hold_existing_flg   IN  VARCHAR2 DEFAULT 'Y',
  p_hold_future_flg     IN  VARCHAR2 DEFAULT 'Y',
  p_check_authorization_flag IN VARCHAR2 DEFAULT 'N',  -- bug 8477694
x_return_status OUT NOCOPY VARCHAR2,

x_msg_count OUT NOCOPY NUMBER,

x_msg_data OUT NOCOPY VARCHAR2 );


Procedure Apply_Holds (
  p_order_tbl           IN   OE_HOLDS_PVT.order_tbl_type,
  p_hold_id             IN   OE_HOLD_DEFINITIONS.HOLD_ID%TYPE,
  p_hold_until_date    IN OE_HOLD_SOURCES.HOLD_UNTIL_DATE%TYPE DEFAULT NULL,
  p_hold_comment       IN OE_HOLD_SOURCES.HOLD_COMMENT%TYPE DEFAULT NULL,
  p_check_authorization_flag IN VARCHAR2 DEFAULT 'N',  -- bug 8477694
x_return_status OUT NOCOPY VARCHAR2,

x_msg_count OUT NOCOPY NUMBER,

x_msg_data OUT NOCOPY VARCHAR2 );


Procedure Release_Holds (
  p_hold_source_rec       IN   OE_HOLDS_PVT.hold_source_rec_type,
  p_hold_release_rec      IN   OE_HOLDS_PVT.Hold_Release_Rec_Type,
  p_check_authorization_flag IN VARCHAR2 DEFAULT 'N',  -- bug 8477694
x_return_status OUT NOCOPY VARCHAR2,

x_msg_count OUT NOCOPY NUMBER,

x_msg_data OUT NOCOPY VARCHAR2);


Procedure Release_Holds (
  p_order_tbl              IN   OE_HOLDS_PVT.order_tbl_type,
  p_hold_id                IN   OE_HOLD_DEFINITIONS.HOLD_ID%TYPE
						  DEFAULT NULL,
  p_release_reason_code    IN   OE_HOLD_RELEASES.RELEASE_REASON_CODE%TYPE,
  p_release_comment        IN   OE_HOLD_RELEASES.RELEASE_COMMENT%TYPE DEFAULT NULL,
  p_check_authorization_flag IN VARCHAR2 DEFAULT 'N',  -- bug 8477694
x_return_status OUT NOCOPY VARCHAR2,

x_msg_count OUT NOCOPY NUMBER,

x_msg_data OUT NOCOPY VARCHAR2);



procedure delete_holds (
  p_order_rec          IN OE_HOLDS_PVT.order_rec_type,
x_return_status OUT NOCOPY VARCHAR2,

x_msg_count OUT NOCOPY NUMBER,

x_msg_data OUT NOCOPY VARCHAR2 );


procedure validate (
  p_hold_source_rec    IN   OE_HOLDS_PVT.hold_source_rec_type,
x_return_status OUT NOCOPY VARCHAR2,

x_msg_count OUT NOCOPY NUMBER,

x_msg_data OUT NOCOPY VARCHAR2 );


Procedure Create_Order_Holds(
  p_hold_source_rec       IN   OE_HOLDS_PVT.Hold_Source_Rec_Type,
  p_org_id IN NUMBER  DEFAULT  MO_GLOBAL.get_current_org_id,  --ER#7479609
x_return_status OUT NOCOPY VARCHAR2,

x_msg_count OUT NOCOPY NUMBER,

x_msg_data OUT NOCOPY VARCHAR2);

function entity_code_value (
      p_hold_entity_code IN OE_HOLD_SOURCES_ALL.HOLD_ENTITY_CODE%TYPE
       )
  return VARCHAR2;

function entity_id_value (
      p_hold_entity_code IN OE_HOLD_SOURCES_ALL.HOLD_ENTITY_CODE%TYPE,
      p_hold_entity_id   IN OE_HOLD_SOURCES_ALL.HOLD_ENTITY_ID%TYPE )
  return VARCHAR2;

function user_name (
     p_user_id   IN  FND_USER.USER_ID%TYPE )
   return VARCHAR2;

function hold_name(
      p_hold_source_id  IN  OE_HOLD_SOURCES_ALL.HOLD_SOURCE_ID%TYPE)
  return varchar2;

procedure process_apply_holds_lines (
          p_num_of_records     IN NUMBER
         ,p_sel_rec_tbl        IN OE_GLOBALS.Selected_Record_Tbl
         ,p_hold_id            IN OE_HOLD_DEFINITIONS.HOLD_ID%TYPE
         ,p_hold_until_date    IN OE_HOLD_SOURCES.HOLD_UNTIL_DATE%TYPE
         ,p_hold_comment       IN OE_HOLD_SOURCES.HOLD_COMMENT%TYPE
,x_return_status OUT NOCOPY VARCHAR2

,x_msg_count OUT NOCOPY NUMBER

,x_msg_data OUT NOCOPY VARCHAR2

                                     );

procedure process_apply_holds_orders (
          p_num_of_records     IN NUMBER
         ,p_sel_rec_tbl       IN  OE_GLOBALS.Selected_Record_Tbl
         ,p_hold_id            IN OE_HOLD_DEFINITIONS.HOLD_ID%TYPE
         ,p_hold_until_date    IN OE_HOLD_SOURCES.HOLD_UNTIL_DATE%TYPE
         ,p_hold_comment       IN OE_HOLD_SOURCES.HOLD_COMMENT%TYPE
,x_return_status OUT NOCOPY VARCHAR2

,x_msg_count OUT NOCOPY NUMBER

,x_msg_data OUT NOCOPY VARCHAR2

                                     );

procedure process_release_holds_lines (
       p_num_of_records     IN NUMBER
      ,p_sel_rec_tbl        IN   OE_GLOBALS.Selected_Record_Tbl
      ,p_hold_id            IN OE_HOLD_DEFINITIONS.HOLD_ID%TYPE
      ,p_release_reason_code    IN   OE_HOLD_RELEASES.RELEASE_REASON_CODE%TYPE
      ,p_release_comment        IN   OE_HOLD_RELEASES.RELEASE_COMMENT%TYPE
,x_return_status OUT NOCOPY VARCHAR2

,x_msg_count OUT NOCOPY NUMBER

,x_msg_data OUT NOCOPY VARCHAR2

                                     );

procedure process_release_holds_orders (
       p_num_of_records     IN NUMBER
      ,p_sel_rec_tbl         IN   OE_GLOBALS.Selected_Record_Tbl
      ,p_hold_id            IN OE_HOLD_DEFINITIONS.HOLD_ID%TYPE
      ,p_release_reason_code    IN   OE_HOLD_RELEASES.RELEASE_REASON_CODE%TYPE
      ,p_release_comment        IN   OE_HOLD_RELEASES.RELEASE_COMMENT%TYPE
,x_return_status OUT NOCOPY VARCHAR2

,x_msg_count OUT NOCOPY NUMBER

,x_msg_data OUT NOCOPY VARCHAR2

                                     );

procedure process_create_source(
	     p_hold_source_rec    IN OE_HOLDS_PVT.Hold_Source_Rec_Type
         ,p_hold_existing_flg  IN varchar2
         ,p_hold_future_flg    IN varchar2
         ,p_org_id IN NUMBER  DEFAULT  MO_GLOBAL.get_current_org_id  --ER#7479609
,x_return_status OUT NOCOPY VARCHAR2

,x_msg_count OUT NOCOPY NUMBER

,x_msg_data OUT NOCOPY VARCHAR2

                                        );
procedure process_release_source(
        p_hold_source_id       IN OE_Hold_Sources_ALL.HOLD_SOURCE_ID%TYPE
       ,p_hold_release_rec     IN OE_HOLDS_PVT.Hold_Release_Rec_Type
,x_return_status OUT NOCOPY VARCHAR2

,x_msg_count OUT NOCOPY NUMBER

,x_msg_data OUT NOCOPY VARCHAR2

                                        );
function check_authorization (
 p_hold_id           IN   OE_HOLD_DEFINITIONS.HOLD_ID%TYPE,
 p_authorized_action_code IN OE_HOLD_AUTHORIZATIONS.AUTHORIZED_ACTION_CODE%TYPE,
 p_responsibility_id IN OE_HOLD_AUTHORIZATIONS.RESPONSIBILITY_ID%TYPE,
 p_application_id    IN OE_HOLD_AUTHORIZATIONS.APPLICATION_ID%TYPE,
x_return_status OUT NOCOPY VARCHAR2,

x_msg_count OUT NOCOPY NUMBER,

x_msg_data OUT NOCOPY VARCHAR2

						 )
		 RETURN varchar2;
procedure split_hold (
       p_line_id            IN   NUMBER,
       p_split_from_line_id IN   NUMBER,
x_return_status OUT NOCOPY VARCHAR2,

x_msg_count OUT NOCOPY NUMBER,

x_msg_data OUT NOCOPY VARCHAR2

                     );

Procedure release_orders (
   p_hold_release_rec   IN   OE_HOLDS_PVT.hold_release_rec_type
                      DEFAULT G_MISS_HOLD_RELEASE_REC,
   p_order_rec          IN   OE_HOLDS_PVT.order_rec_type,
   p_hold_source_rec    IN   OE_HOLDS_PVT.Hold_source_Rec_Type
                      DEFAULT  G_MISS_HOLD_SOURCE_REC,
x_return_status OUT NOCOPY VARCHAR2,

x_msg_count OUT NOCOPY NUMBER,

x_msg_data OUT NOCOPY VARCHAR2

);
/*Added New Overloaded procedure Apply_holds for WF_HOLDS ER (bug 6449458)*/
Procedure Apply_Holds(
  p_hold_source_rec     IN  OE_HOLDS_PVT.Hold_Source_Rec_Type,
  p_hold_existing_flg   IN  VARCHAR2,
  p_hold_future_flg     IN  VARCHAR2,
  p_org_id IN NUMBER  DEFAULT  MO_GLOBAL.get_current_org_id,  --ER#7479609
  p_wf_item_type IN  VARCHAR2 DEFAULT NULL,
  p_wf_activity_name IN  VARCHAR2 DEFAULT NULL,
  p_check_authorization_flag IN VARCHAR2 DEFAULT 'N',  -- bug 8477694
  x_return_status       OUT NOCOPY VARCHAR2,
  x_msg_count           OUT NOCOPY NUMBER,
  x_msg_data            OUT NOCOPY VARCHAR2,
  x_is_hold_applied     OUT NOCOPY BOOLEAN
);

/*Added New overloaded procedure create_order_holds for WF_HOLDS ER (bug 6449458)*/
Procedure Create_Order_Holds(
  p_hold_source_rec       IN   OE_HOLDS_PVT.Hold_Source_Rec_Type,
  p_org_id IN NUMBER  DEFAULT  MO_GLOBAL.get_current_org_id,  --ER#7479609
  p_item_type      IN VARCHAR2,
  p_activity_name  IN VARCHAR2,
  x_return_status   OUT NOCOPY VARCHAR2,
  x_msg_count       OUT NOCOPY NUMBER,
  x_msg_data        OUT NOCOPY VARCHAR2,
  x_is_hold_applied OUT NOCOPY BOOLEAN
);

/*Added new overloaded procedure Process_release_holds_lines for ER 1373910 - Progress WF on hold release */
procedure process_release_holds_lines (
          p_num_of_records         IN  NUMBER
         ,p_sel_rec_tbl            IN  OE_GLOBALS.Selected_Record_Tbl
         ,p_hold_id                IN  OE_HOLD_DEFINITIONS.HOLD_ID%TYPE
         ,p_release_reason_code    IN  OE_HOLD_RELEASES.RELEASE_REASON_CODE%TYPE
         ,p_release_comment        IN  OE_HOLD_RELEASES.RELEASE_COMMENT%TYPE
	 ,p_wf_release_action      IN  VARCHAR2
         ,x_return_status          OUT NOCOPY VARCHAR2
         ,x_msg_count              OUT NOCOPY NUMBER
         ,x_msg_data               OUT NOCOPY VARCHAR2
                                     );
/*Added new overloaded procedure Process_release_holds_orders for ER 1373910 - Progress WF on hold release */
procedure process_release_holds_orders (
          p_num_of_records         IN  NUMBER
         ,p_sel_rec_tbl            IN  OE_GLOBALS.Selected_Record_Tbl
         ,p_hold_id                IN  OE_HOLD_DEFINITIONS.HOLD_ID%TYPE
         ,p_release_reason_code    IN  OE_HOLD_RELEASES.RELEASE_REASON_CODE%TYPE
         ,p_release_comment        IN  OE_HOLD_RELEASES.RELEASE_COMMENT%TYPE
	 ,p_wf_release_action      IN  VARCHAR2
         ,x_return_status          OUT NOCOPY VARCHAR2
         ,x_msg_count              OUT NOCOPY NUMBER
         ,x_msg_data               OUT NOCOPY VARCHAR2
                                     );
/*Added new overloaded procedure Process_release_source for ER 1373910 - Progress WF on hold release */
procedure process_release_source       (
          p_hold_source_id         IN OE_Hold_Sources_ALL.HOLD_SOURCE_ID%TYPE
         ,p_hold_release_rec       IN OE_HOLDS_PVT.Hold_Release_Rec_Type
	 ,p_wf_release_action      IN  VARCHAR2
         ,x_return_status          OUT NOCOPY VARCHAR2
         ,x_msg_count              OUT NOCOPY NUMBER
         ,x_msg_data               OUT NOCOPY VARCHAR2
                                     );
END OE_Holds_Pvt;

/
