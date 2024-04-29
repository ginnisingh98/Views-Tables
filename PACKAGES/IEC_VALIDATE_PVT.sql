--------------------------------------------------------
--  DDL for Package IEC_VALIDATE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEC_VALIDATE_PVT" AUTHID CURRENT_USER AS
/* $Header: IECVALS.pls 120.1 2005/06/06 08:55:22 appldev  $ */

G_NUM_CONTACT_POINTS CONSTANT NUMBER := 6;
G_LISTHEADER_REC_INITIAL  NUMBER :=0;
l_listheader_rec AMS_LISTHEADER_PVT.list_header_rec_type;


TYPE ContactPoint IS RECORD (
   id                 NUMBER(15),
   phone_country_code VARCHAR2(500),
   phone_area_code    VARCHAR2(500),
   phone_number       VARCHAR2(500),
   raw_phone_number   VARCHAR2(500),
   time_zone          VARCHAR2(500),
   phone_line_type    VARCHAR2(30),
   purpose            VARCHAR2(30),
   territory_code     VARCHAR2(500),
   region_id          NUMBER(15),
   cc_tz_id           NUMBER(15),
   valid_flag         VARCHAR2(1),
   dnu_reason         NUMBER
);

TYPE ContactPointList IS VARRAY(6) OF ContactPoint;

TYPE ListEntryCsrType IS REF CURSOR;

PROCEDURE Init_ContactPointRecord
   ( x_contact_point IN OUT NOCOPY ContactPoint);

PROCEDURE Validate_List
   ( p_list_id         IN            NUMBER
   , x_return_code        OUT NOCOPY VARCHAR2);

-- Moves a recycled entry to a new target group and dynamically
-- loads the entry into the AO system.  Call history is moved with the entry.
-- The validation procedure is bypassed since a recycled entry
-- has already been validated.
PROCEDURE Move_RecycledEntry
   ( p_returns_id      IN  NUMBER
   , p_to_list_id      IN  NUMBER);

-- Moves recycled entries to a new target group and dynamically
-- loads the entries into the AO system.  Call history is moved with the entries.
-- The validation procedure is bypassed since a recycled entry
-- has already been validated.
PROCEDURE Move_RecycledEntries
   ( p_returns_id_col  IN  SYSTEM.number_tbl_type
   , p_to_list_id      IN  NUMBER);

-- Moves all validated entries from one target group to another and
-- dynamically loads the entries into the AO system.  Call history is moved
-- with the entries.  The entries are marked as do not use in the original
-- list.  Assumes that target group has been validated.  Only validated
-- entries will be moved.  Non-validated entries will remain untouched.
PROCEDURE Copy_TargetGroupEntries
   ( p_from_list_id  IN  NUMBER
   , p_to_list_id    IN  NUMBER);

-- Dynamically validates and loads a new list entry into the AO system.
PROCEDURE Load_NewEntry
   ( p_list_entry_id   IN  NUMBER
   , p_list_id         IN  NUMBER);

-- Dynamically validates and loads a collection of new list entries into the AO system.
PROCEDURE Load_NewEntries
   ( p_list_entry_id_col   IN  SYSTEM.number_tbl_type
   , p_list_id             IN  NUMBER);

-- Called by the time zone map loader utility to remove redundant
-- time zone mapping entries - performance enhancement for validation
PROCEDURE Update_Tz_Mappings;

-- Dynamically inserts a new record into a calling list
-- If record cannot be inserted or validated, the appropriate
-- failure code will be returned and the entire transaction
-- will be rolled back
PROCEDURE Add_Record_To_List_Interactive
   ( p_list_id	                 IN            NUMBER
   , p_column_name	             IN            SYSTEM.varchar_tbl_type
   , p_column_value              IN            SYSTEM.varchar_tbl_type
   , p_callback_time             IN            DATE DEFAULT NULL
   , x_failure_code                 OUT NOCOPY VARCHAR2
   );

-- Dynamically inserts a new record into a calling list
-- If record cannot be inserted or validated, the appropriate
-- failure code will be returned.  If the record is inserted
-- but fails validation, the record will remain in the calling
-- list as an invalid record
PROCEDURE Add_Record_To_List
   ( p_list_id	                 IN            NUMBER
   , p_column_name	             IN            SYSTEM.varchar_tbl_type
   , p_column_value              IN            SYSTEM.varchar_tbl_type
   , p_callback_time             IN            DATE DEFAULT NULL
   , x_failure_code                 OUT NOCOPY VARCHAR2
   );

-- Updates a contact point in AMS_LIST_ENTRIES and optionally
-- updates the corresponding contact point in HZ_CONTACT_POINTS
PROCEDURE Update_ContactPoint
   ( p_list_id	        IN            NUMBER
   , p_list_entry_id    IN            NUMBER
   , p_party_id         IN            NUMBER
   , p_contact_point_id IN            NUMBER
   , p_index            IN            NUMBER
   , p_country_code	    IN            VARCHAR2
   , p_area_code        IN            VARCHAR2
   , p_phone_number     IN            VARCHAR2
   , p_time_zone        IN            NUMBER
   , p_update_tca_flag  IN            VARCHAR2
   );

-- Called by public api to copy schedule entries
PROCEDURE Copy_ScheduleEntries_Pub
   ( p_src_schedule_id  IN            NUMBER
   , p_dest_schedule_id IN            NUMBER
   , p_commit           IN            BOOLEAN
   , x_return_status       OUT NOCOPY VARCHAR2);

-- Called by public api to move schedule entries
PROCEDURE Move_ScheduleEntries_Pub
   ( p_src_schedule_id  IN            NUMBER
   , p_dest_schedule_id IN            NUMBER
   , p_commit           IN            BOOLEAN
   , x_return_status       OUT NOCOPY VARCHAR2);

-- Called by public api to move schedule entries
PROCEDURE Purge_ScheduleEntries_Pub
   ( p_schedule_id   IN            NUMBER
   , p_commit        IN            BOOLEAN
   , x_return_status    OUT NOCOPY VARCHAR2);


END IEC_VALIDATE_PVT;

 

/
