--------------------------------------------------------
--  DDL for Package AMS_EVHRULES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_EVHRULES_PVT" AUTHID CURRENT_USER AS
/* $Header: amsvebrs.pls 115.34 2002/12/18 18:46:48 soagrawa ship $ */


-----------------------------------------------------------------------
-- PROCEDURE
--    handle_evh_status
--
-- PURPOSE
--    Validate the event header status.
--
-- NOTES
--    1. If the user status is not specified, default it;
--       otherwise validate it.
--    2. The system status code will be determined by the user status.
-----------------------------------------------------------------------
PROCEDURE handle_evh_status(
   p_user_status_id  IN  NUMBER,
   x_status_code     OUT NOCOPY VARCHAR2,
   x_return_status   OUT NOCOPY VARCHAR2
);

PROCEDURE Update_Event_Schedule_Status (
	p_event_offer_id             IN NUMBER,
   p_new_status_id           IN NUMBER,
   p_new_status_code         IN VARCHAR2
 ) ;

PROCEDURE Update_Event_Header_Status (
	p_event_header_id             IN NUMBER,
   p_new_status_id           IN NUMBER,
   p_new_status_code         IN VARCHAR2
 ) ;

PROCEDURE Update_Owner(
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_commit            IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,
   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,
   p_object_type       IN  VARCHAR2 := NULL ,
   p_event_id          IN  NUMBER,
   p_owner_id      IN  NUMBER   );

-----------------------------------------------------------------------
-- PROCEDURE
--    Send_Out_Information
--
-- PURPOSE
--    Send Information to registrants if Venue/Date are changed or event
--    is cancelled.
--
-- NOTES

-----------------------------------------------------------------------

PROCEDURE Send_Out_Information(
   p_object_type       IN  VARCHAR2,
   p_object_id         IN  NUMBER ,
   p_trigger_type      IN  VARCHAR2 ,
--   p_bind_values       IN  AMF_REQUEST.string_tbl_type ,  -- Modified by ptendulk on 13-Dec-2002 for 1:1
   p_bind_values       IN  JTF_FM_REQUEST_GRP.G_VARCHAR_TBL_TYPE,
   p_bind_names        IN  JTF_FM_REQUEST_GRP.G_VARCHAR_TBL_TYPE,
   x_return_status     OUT NOCOPY VARCHAR2
);




-----------------------------------------------------------------------
-- PROCEDURE
--    check_evh_update
--
-- PURPOSE
--    Check if Event HEader record can be updated.
--
-- NOTES

-----------------------------------------------------------------------
PROCEDURE check_evh_update(
   p_evh_rec       IN  AMS_EventHeader_PVT.evh_rec_type,
   x_return_status  OUT NOCOPY VARCHAR2
);



-----------------------------------------------------------------------
-- PROCEDURE
--    check_evh_fund_source
--
-- PURPOSE
--    Check Event Header fund_source_type and fund_source_id.
--
-- NOTES
--    1. fund_source_type could be 'FUND', 'CAMPAIGN', 'MASTER_EVENT', 'EVENT_OFFER'.
--    2. fund_source_type can't be null if fund_source_id is provided.
-----------------------------------------------------------------------
PROCEDURE check_Evh_fund_source(
   p_fund_source_type  IN  VARCHAR2,
   p_fund_source_id    IN  NUMBER,
   x_return_status     OUT NOCOPY VARCHAR2
);


---------------------------------------------------------------------
-- PROCEDURE
--    check_evh_calendar
--
-- HISTORY
--    10/01/2000  sugupta  Created.
---------------------------------------------------------------------
PROCEDURE check_evh_calendar(
   p_evh_calendar   IN  VARCHAR2,
   p_start_period_name   IN  VARCHAR2,
   p_end_period_name     IN  VARCHAR2,
   p_start_date          IN  DATE,
   p_end_date            IN  DATE,
   x_return_status       OUT NOCOPY VARCHAR2
);


---------------------------------------------------------------------
-- PROCEDURE
--    push_source_code
--
-- PURPOSE
--    After creating event headers or event offers, push the source code
--    into ams_source_codes table.
---------------------------------------------------------------------
/*
PROCEDURE push_source_code(
   p_source_code    IN  VARCHAR2,
   p_arc_object     IN  VARCHAR2,
   p_object_id      IN  NUMBER
);
*/
-----------------------------------------------------------------------
-- PROCEDURE
--    udpate_evh_source_code
--
-- HISTORY
--    09/31/00  sugupta  Created.
-----------------------------------------------------------------------
PROCEDURE update_evh_source_code(
   p_evh_id      IN  NUMBER,
   p_source_code      IN  VARCHAR2,
   p_global_flag      IN  VARCHAR2,
   x_source_code      OUT NOCOPY VARCHAR2,
   x_return_status    OUT NOCOPY VARCHAR2
);
-----------------------------------------------------------------------
-- PROCEDURE
--    udpate_evo_source_code
--
-- HISTORY
--    09/31/00  sugupta  Created.
-----------------------------------------------------------------------
PROCEDURE update_evo_source_code(
   p_evo_id      IN  NUMBER,
   p_source_code      IN  VARCHAR2,
   p_global_flag      IN  VARCHAR2,
   x_source_code      OUT NOCOPY VARCHAR2,
   x_return_status    OUT NOCOPY VARCHAR2
);

-----------------------------------------------------------------------
-- PROCEDURE
--    udpate_eone_source_code
--
-- HISTORY
--    04/19/01  mukumar Created.
-----------------------------------------------------------------------
PROCEDURE update_eone_source_code(
   p_evo_id      IN  NUMBER,
   p_source_code      IN  VARCHAR2,
   p_global_flag      IN  VARCHAR2,
   x_source_code      OUT NOCOPY VARCHAR2,
   x_return_status    OUT NOCOPY VARCHAR2
);


-----------------------------------------------------------------------
-- PROCEDURE
--    udpate_event_status
--
-- HISTORY
--    09/25/00  mukumar  Created.
--	  10/05/00  gdeodhar Added two more parameters.
-----------------------------------------------------------------------
PROCEDURE update_event_status(
   p_event_id			  IN  NUMBER,
   p_event_activity_type  IN  VARCHAR2,
   p_user_status_id       IN  NUMBER,
   p_fund_amount_tc		  IN  NUMBER,
   p_currency_code_tc	  IN  VARCHAR2
);

--=======================================================================
-- PROCEDURE
--    process_leads
--
-- NOTES
--    This procedure is created to create leads in OTS based on the event
--    registrations and attendance.
--    When the status of the event schedule is changed to CLOSED, this
--    procedure will be called.
--    This method should be pulled out from here and be created as a concurrent
--    program as this operation is more suited for batch operations.
--
-- HISTORY
--    08/02/2001    gdeodhar   Created.
--    22-oct-2002   soagrawa   Modified API signature to take obj type and obj srccd
--                             to be able to generate leads against non-event src cd.
--=======================================================================

PROCEDURE process_leads(
   p_event_id             IN  NUMBER
 , p_obj_type             IN  VARCHAR2 := NULL
 , p_obj_srccd            IN  VARCHAR2 := NULL
);

 --=======================================================================
-- PROCEDURE
--    insert_lead_rec
--
-- NOTES
--    This procedure actually inserts a record in the lead import interface
--    table.
--
-- HISTORY
--    08/13/2001    gdeodhar   Created.
--=======================================================================

PROCEDURE insert_lead_rec(
   p_party_id             IN  NUMBER
   ,p_lit_batch_id        IN  NUMBER
   ,p_event_id            IN  NUMBER
   ,p_source_code         IN  VARCHAR2
   ,p_contact_party_id    IN NUMBER := NULL
);


--=======================================================================
-- PROCEDURE
--    Convert_Evnt_Currency
-- NOTES
--    This procedure is created to convert the transaction currency into
--    functional currency.
-- HISTORY
--    10/30/2000    mukumar   Created.
--=======================================================================
PROCEDURE Convert_Evnt_Currency(
   p_tc_curr     IN    VARCHAR2,
   p_tc_amt      IN    NUMBER,
   x_fc_curr     OUT NOCOPY   VARCHAR2,
   x_fc_amt      OUT NOCOPY   NUMBER
   );

--=======================================================================
-- PROCEDURE
--    Add_Update_Access_record
-- NOTES
--    This procedure is to create or update Acess_record(owner record)
-- HISTORY
--    10/30/2000    mukumar   Created.
--=======================================================================
PROCEDURE Add_Update_Access_record(
   p_object_type     IN    VARCHAR2,
   p_object_id      IN    NUMBER,
   p_Owner_user_id  IN    NUMBER,
   x_return_status    OUT NOCOPY VARCHAR2,
   x_msg_count        OUT NOCOPY VARCHAR2,
   x_msg_data         OUT NOCOPY VARCHAR2
   );

---------------------------------------------------------------------
-- PROCEDURE
--    push_source_code
--
-- PURPOSE
--    After creating campaigns or schedules, push the source code
--    into ams_source_codes table.
---------------------------------------------------------------------
PROCEDURE push_source_code(
   p_source_code    IN  VARCHAR2,
   p_arc_object     IN  VARCHAR2,
   p_object_id      IN  NUMBER,
   p_related_source_code    IN    VARCHAR2 := NULL,
   p_related_source_object  IN    VARCHAR2 := NULL,
   p_related_source_id      IN    NUMBER   := NULL
);
--========================================================================
-- PROCEDURE
--    Create_list
--
-- PURPOSE
--
--
-- NOTE
--    The list of Type <> is created in list header and the association is
--    created in the ams_act_lists table.
--
-- HISTORY
--  06/01/01   mukumar    created
--
--========================================================================
PROCEDURE Create_list
               (p_evo_id     IN     NUMBER,
                p_evo_name   IN     VARCHAR2,
				p_obj_type   In     VARCHAR2,
                p_owner_id        IN     NUMBER);

--==========================================================================
-- PROCEDURE
--    Cancel_RollupEvent
--
-- PURPOSE
--    Cancels the Rolup event and their associated event schedules. If the status
--    order rules does not permit it, it will error out.
--
-- NOTES
-- HISTORY
--    17-Jul-2001  mukumar    Created.
--==========================================================================

PROCEDURE Cancel_RollupEvent(p_evh_id   IN  NUMBER);

--==========================================================================
-- PROCEDURE
--    Cancel_Exec_Event
--
-- PURPOSE
--    Cancels the Rolup event and their associated event schedules. If the status
--    order rules does not permit it, it will error out.
--
-- NOTES
-- HISTORY
--    17-Jul-2001  mukumar    Created.
--==========================================================================

PROCEDURE Cancel_Exec_Event(p_evh_id   IN  NUMBER);

--==========================================================================
-- PROCEDURE
--    Cancel_oneoff_Event
--
-- PURPOSE
--    Cancels the Rolup event and their associated event schedules. If the status
--    order rules does not permit it, it will error out.
--
-- NOTES
-- HISTORY
--    17-Jul-2001  mukumar    Created.
--==========================================================================

PROCEDURE Cancel_oneoff_event(p_offer_id   IN  NUMBER);

--==========================================================================
-- FUNCTION
--    Cancel_all_Event
--
-- PURPOSE
--    Cancels all Rolup event and their associated event schedules. If the status
--    order rules does not permit it, it will error out.
--
-- NOTES
-- HISTORY
--    17-Jul-2001  mukumar    Created.
--    15-Feb_2002  gmadana    Mofified.
--                 Changed it from procedure to function which returns TRUE if
--                 all the Schedules or Headers attached to a given program_id
--                 are CANCELLED otherwise FALSE
--==========================================================================

FUNCTION Cancel_all_Event(p_prog_id   IN  NUMBER)RETURN VARCHAR2;
--==========================================================================
-- PROCEDURE
--    complete_RollupEvent
--
-- PURPOSE
--    completes the Rolup event and their associated event schedules. If the status
--    order rules does not permit it, it will error out.
--
-- NOTES
-- HISTORY
--    17-Jul-2001  mukumar    Created.
--==========================================================================

PROCEDURE complete_RollupEvent(p_evh_id   IN  NUMBER);

--==========================================================================
-- PROCEDURE
--    complete_Exec_Event
--
-- PURPOSE
--    completes the Rolup event and their associated event schedules. If the status
--    order rules does not permit it, it will error out.
--
-- NOTES
-- HISTORY
--    17-Jul-2001  mukumar    Created.
--==========================================================================

PROCEDURE complete_Exec_Event(p_evh_id   IN  NUMBER);

--==========================================================================
-- PROCEDURE
--    complete_oneoff_Event
--
-- PURPOSE
--    completes the Rolup event and their associated event schedules. If the status
--    order rules does not permit it, it will error out.
--
-- NOTES
-- HISTORY
--    17-Jul-2001  mukumar    Created.
--==========================================================================

PROCEDURE complete_oneoff_event(p_offer_id   IN  NUMBER);

--==========================================================================
-- PROCEDURE
--    complete_all_Event
--
-- PURPOSE
--    completes all Rolup event and their associated event schedules. If the status
--    order rules does not permit it, it will error out.
--
-- NOTES
-- HISTORY
--    17-Jul-2001  mukumar    Created.
--==========================================================================

PROCEDURE complete_all_Event(p_prog_id   IN  NUMBER);

--==========================================================================
-- PROCEDURE
--    Create_inventory_item
--
-- PURPOSE
--    completes all Rolup event and their associated event schedules. If the status
--    order rules does not permit it, it will error out.
--
-- NOTES
-- HISTORY
--    17-Jul-2001  mukumar    Created.
--==========================================================================

PROCEDURE create_inventory_item(p_item_number    IN  VARCHAR2,
                                p_item_desc      IN  VARCHAR2,
				p_item_long_desc IN  VARCHAR2,
				p_user_id        IN  NUMBER,
				x_org_id         OUT NOCOPY NUMBER,
				x_inv_item_id    OUT NOCOPY NUMBER,
				x_return_status  OUT NOCOPY  VARCHAR2,
				x_msg_count      OUT NOCOPY  NUMBER,
				x_msg_data       OUT NOCOPY  VARCHAR2);
END AMS_EvhRules_PVT;


 

/
