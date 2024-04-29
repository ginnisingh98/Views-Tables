--------------------------------------------------------
--  DDL for Package PV_LEADLOG_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PV_LEADLOG_PVT" AUTHID CURRENT_USER as
/* $Header: pvxvlals.pls 115.14 2002/11/20 02:06:24 pklin ship $ */

--
-- NAME
--   PV_LEADLOG_PVT
--
-- PURPOSE
--   Private API for creating log entries
--   uses.
--
-- NOTES
--   This pacakge should not be used by any non-osm sources.  All non OSM
--   sources should use the Public create_account API
--
--
--
-- HISTORY

G_INITIAL_AS           NUMBER := 0;
G_CM_REJECT_AS         NUMBER := 1;
G_CM_ADDED_AS          NUMBER := 2;
G_CM_REMOVED_AS        NUMBER := 3;
G_PT_REJECT_AS         NUMBER := 4;
G_PT_TIMEOUT_AS        NUMBER := 5;


-- Start of Comments
--
--  Lead Workflow Record: ASSIGNLOG_REC_TYPE
--
--  Parameters
--
--  Defaulting:
--
--  If Invalid:
--
-- End of Comments

TYPE  ASSIGNLOG_REC_TYPE   IS RECORD
 (ASSIGNMENT_ID          NUMBER,
  LEAD_ASSIGNMENT_ID     NUMBER,
  LEAD_ID                NUMBER     ,
  DURATION                NUMBER     ,
  PARTNER_ID             NUMBER     ,
  CM_ID                  NUMBER,
  LAST_UPDATE_DATE       DATE       ,
  LAST_UPDATED_BY        NUMBER     ,
  CREATION_DATE          DATE       ,
  CREATED_BY             NUMBER     ,
  OBJECT_VERSION_NUMBER  NUMBER     ,
  LAST_UPDATE_LOGIN      NUMBER     ,
  WF_PT_USER             VARCHAR2 (40),
  WF_CM_USER             VARCHAR2 (40),
  WF_ITEM_TYPE           VARCHAR2 (30),
  WF_ITEM_KEY            VARCHAR2 (30),
  ASSIGN_SEQUENCE        NUMBER,
  FROM_STATUS            VARCHAR2 (30),
  STATUS                 VARCHAR2 (30),
  STATUS_DATE            DATE,
  TRANS_TYPE             NUMBER,
  ERROR_TXT              VARCHAR2(200),
  STATUS_CHANGE_COMMENTS VARCHAR2 (60));

G_MISS_ASSIGNLOG_REC ASSIGNLOG_REC_TYPE;

TYPE ASSIGNLOG_TBL_TYPE IS TABLE OF ASSIGNLOG_REC_TYPE
   		INDEX BY BINARY_INTEGER;

G_MISS_ASSIGNLOG_TBL   ASSIGNLOG_TBL_TYPE;



  --
  -- NAME
  --   UpdateWFStatus
  --
  -- PURPOSE
  --   Private API to create log entries
  --
  -- NOTES
  --   This is a private API, which should only be called from PV.
  --   information.
  --
  --
  --

  PROCEDURE CreateAssignLog
    ( p_api_version_number  IN   NUMBER,
      p_init_msg_list       IN   VARCHAR2           := FND_API.G_FALSE,
      p_commit              IN   VARCHAR2           := FND_API.G_FALSE,
      p_validation_level    IN   NUMBER             := FND_API.G_VALID_LEVEL_FULL,
      p_assignlog_rec       IN   ASSIGNLOG_REC_TYPE := G_MISS_ASSIGNLOG_REC,
      x_assignment_id       OUT NOCOPY  NUMBER,
      x_return_status       OUT NOCOPY  VARCHAR2,
      x_msg_count           OUT NOCOPY  NUMBER,
      x_msg_data            OUT NOCOPY  VARCHAR2);


PROCEDURE InsertAssignLogRow (
        X_Rowid                   OUT NOCOPY    ROWID     ,
        x_assignlog_ID            OUT NOCOPY    NUMBER       ,
        p_Lead_assignment_ID      IN     NUMBER       ,
        p_Last_Updated_By         IN     NUMBER       ,
        p_Last_Update_Date        IN     DATE         ,
	p_Object_Version_number   IN     NUMBER       ,
        p_Last_Update_Login       IN     NUMBER       ,
        p_Created_By              IN     NUMBER       ,
        p_Creation_Date           IN     DATE         ,
        p_lead_id                 IN     NUMBER       ,
	p_duration                IN     NUMBER       ,
        p_partner_id              IN     NUMBER       ,
        p_assign_sequence         IN     NUMBER       ,
        p_status_date             IN     DATE         ,
        p_status                  IN     VARCHAR2     ,
        p_cm_id                   IN     NUMBER       ,
        p_wf_pt_user              IN     VARCHAR2     ,
        p_wf_cm_user              IN     VARCHAR2     ,
        p_wf_item_type            IN     VARCHAR2     ,
        p_wf_item_key             IN     VARCHAR2     ,
        p_trans_type              IN     NUMBER       ,
        p_error_txt               IN     VARCHAR2     ,
        p_status_change_comments  IN     VARCHAR2     ,
        x_return_status           OUT NOCOPY    VARCHAR2);

PROCEDURE InsertLeadStatusLogRow (
	X_Rowid                   OUT NOCOPY    ROWID     ,
	x_assignlog_ID            OUT NOCOPY    NUMBER       ,
	p_Last_Updated_By         IN     NUMBER       ,
	p_Last_Update_Date        IN     DATE         ,
	p_Object_Version_number   IN     NUMBER       ,
	p_Last_Update_Login       IN     NUMBER       ,
	p_Created_By              IN     NUMBER       ,
	p_Creation_Date           IN     DATE         ,
	p_lead_id                 IN     NUMBER       ,
	p_partner_id              IN     NUMBER       ,
	p_status_date             IN     DATE         ,
	p_from_status             IN     VARCHAR2     ,
	p_to_status               IN     VARCHAR2     ,
	x_return_status       OUT NOCOPY  VARCHAR2,
	x_msg_count           OUT NOCOPY  NUMBER,
	x_msg_data            OUT NOCOPY  VARCHAR2);

end pv_leadlog_pvt;

 

/
