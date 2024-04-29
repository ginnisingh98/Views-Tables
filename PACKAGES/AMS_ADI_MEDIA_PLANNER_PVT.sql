--------------------------------------------------------
--  DDL for Package AMS_ADI_MEDIA_PLANNER_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_ADI_MEDIA_PLANNER_PVT" AUTHID CURRENT_USER AS
/* $Header: amsvwmps.pls 120.0 2005/07/01 03:59:38 appldev noship $ */
-- ===============================================================
--                   Start of Comments
-- Package name
--    Web ADI Media Planner
--
-- Purpose
--    This package contains program units used in the integration of
--    Web ADI and Marketing Metrics.  APIs will handle concurrent
--    processing and metrics upload from schedule import and
--    media planner (which is metric update for multiple schedules).
--
-- History
--
-- NOTE
--
--                   End of Comments
-- ===============================================================

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--       Load Metrics
--   Type
--           Private
--   Pre-Req
--
--   Parameters
--
--   IN
--       p_api_version
--       p_init_msg_list      Default FND_API.g_false; indicate whether to
--                            initialize the message buffer.
--       p_commit             Default FND_API.g_false; indicate whether to
--                            commit the transaction.
--       p_upload_batch_id    Batch ID used to identify the records belonging
--                            in the same upload batch.
--       p_object_type        Default 'CSCH'; the type of object the metrics
--                            are being loaded for.
--       p_object_name        Name of the object the metrics are being loaded
--                            for.  The name and parent_id are used to uniquely
--                            identify the record in the interface table
--                            associated with the object; the object ID is not
--                            in the interface table during import.
--       p_parent_type        The type of object of the parent of the object.
--       p_parent_id          The object ID of the parent object.  Used with
--                            object name to identify the record in the
--                            interface table associated with the object; the
--                            record in the interface table does not have the
--                            object ID during import.
--       p_object_id          Used with the metric API.
--       x_return_status      Status of the API execution.
--       x_msg_count          Number of messages in the message buffer.
--       x_msg_data           Contents of the message buffer.
--
--   Version : Current version 1.0
--
--   History
--
--   NOTE
--       Invoked from the import concurrent program after the object gets
--       created and the objet ID is available.
--
--   End of Comments
--   ==============================================================================
PROCEDURE load_metrics (
   p_api_version     IN NUMBER,
   p_init_msg_list   IN VARCHAR2 := FND_API.g_false,
   p_commit          IN VARCHAR2 := FND_API.g_false,
   p_upload_batch_id IN NUMBER,
   p_object_type     IN VARCHAR2 := 'CSCH',
   p_object_name     IN VARCHAR2,
   p_parent_type     IN VARCHAR2,
   p_parent_id       IN NUMBER,
   p_object_id       IN NUMBER,
   x_return_status   OUT NOCOPY VARCHAR2,
   x_msg_count       OUT NOCOPY NUMBER,
   x_msg_data        OUT NOCOPY VARCHAR2
);

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--       Load Metrics
--   Type
--           Private
--   Pre-Req
--
--   Parameters
--
--   IN
--       p_api_version
--       p_init_msg_list      Default FND_API.g_false; indicate whether to
--                            initialize the message buffer.
--       p_commit             Default FND_API.g_false; indicate whether to
--                            commit the transaction.
--       p_media_planner_rec  ###### description here #######
--       x_return_status      Status of the API execution.
--       x_msg_count          Number of messages in the message buffer.
--       x_msg_data           Contents of the message buffer.
--
--   Version : Current version 1.0
--
--   History
--
--   NOTE
--       Invoked from the concurrent program after the media planner record
--       is constructed from the interface table data.
--
--   End of Comments
--   ==============================================================================
PROCEDURE load_metrics (
   p_api_version     IN NUMBER,
   p_init_msg_list   IN VARCHAR2 := FND_API.g_false,
   p_commit          IN VARCHAR2 := FND_API.g_false,
   p_media_planner_rec  IN ams_adi_media_planner%ROWTYPE,
   p_err_recs          IN OUT NOCOPY AMS_ADI_COMMON_PVT.ams_adi_error_rec_t,
   x_return_status   OUT NOCOPY VARCHAR2,
   x_msg_count       OUT NOCOPY NUMBER,
   x_msg_data        OUT NOCOPY VARCHAR2
);

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--       Load Request
--   Type
--           Private
--   Pre-Req
--
--   Parameters
--
--   IN
--       errbuf               Error message buffer for a concurrent program.
--       retcode              Return code for a concurrent program.
--       p_upload_batch_id    Batch ID used to identify the records belonging
--                            in the same upload batch.
--
--   Version : Current version 1.0
--
--   History
--
--   NOTE
--
--   End of Comments
--   ==============================================================================
PROCEDURE load_request (
   x_errbuf         OUT NOCOPY VARCHAR2,
   x_retcode        OUT NOCOPY NUMBER,
   p_upload_batch_id IN NUMBER
);

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--       Purge Import Metrics
--   Type
--           Private
--   Pre-Req
--
--   Parameters
--
--   IN
--       p_object_type
--       p_object_name
--       p_parent_type
--       p_parent_id
--
--   Version : Current version 1.0
--
--   History
--
--   NOTE
--
--   End of Comments
--   ==============================================================================

PROCEDURE purge_import_metrics(
   p_object_type IN VARCHAR2,
   p_object_name IN VARCHAR2,
   p_parent_type IN VARCHAR2,
   p_parent_id IN NUMBER
);

END ams_adi_media_planner_pvt;

 

/
