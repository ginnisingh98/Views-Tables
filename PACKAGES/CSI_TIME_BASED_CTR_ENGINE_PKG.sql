--------------------------------------------------------
--  DDL for Package CSI_TIME_BASED_CTR_ENGINE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSI_TIME_BASED_CTR_ENGINE_PKG" AUTHID CURRENT_USER AS
/* $Header: csictims.pls 120.0.12010000.1 2008/07/25 08:07:27 appldev ship $ */

--
-- Capture_Readings
--   Loop through all the effective "time" counter instances, and call the
--   "Capture_Ctr_Reading" API for each of them, if its time to update its
--    reading
-- OUT
--   errbuf - return any error messages
--   retcode - return completion status (0 for success, 1 for success with
--             warnings, 2 for error)
--
PROCEDURE Capture_Readings
(
   errbuf	OUT NOCOPY VARCHAR2,
   retcode	OUT NOCOPY NUMBER
);

END CSI_Time_Based_Ctr_Engine_PKG;

/
