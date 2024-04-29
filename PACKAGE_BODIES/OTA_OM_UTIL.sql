--------------------------------------------------------
--  DDL for Package Body OTA_OM_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_OM_UTIL" AS
/* $Header: otomutil.pkb 115.2 2003/04/09 06:29:54 pbhasin noship $ */
--
-- Package Variables
--
g_package  	VARCHAR2(33) := 'OTA_OM_UTIL.';
--
-- ----------------------------------------------------------------------------
-- |--------------------------< <get_event_details> >------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE get_event_detail
  (p_line_id		IN 	NUMBER,
   p_UOM              	IN	VARCHAR2,
   x_activity_name	OUT     NOCOPY VARCHAR2,
   x_event_title	OUT 	NOCOPY VARCHAR2,
   x_course_start_date	OUT	NOCOPY DATE,
   x_course_end_date	OUT	NOCOPY DATE
  ) IS
  --
  -- Declare cursors and local variables
  --
  l_proc                varchar2(72) := g_package||'get_event_detail';
  --
  CURSOR evt_cur IS
  SELECT act.version_name,
	 evt.title,
	 evt.course_start_date,
	 evt.course_end_date
    FROM ota_events_vl evt,  -- MLS change _vl added
	 ota_activity_versions_tl act -- MLS change _tl added
   WHERE act.activity_version_id = evt.activity_version_id
     AND evt.line_id = p_line_id;


  CURSOR enr_cur IS
  SELECT act.version_name,
	 evt.title,
	 evt.course_start_date,
	 evt.course_end_date
    FROM ota_events_vl evt, -- MLS change _vl added
	 ota_activity_versions_tl act, --MLS change _tl added
	 ota_delegate_bookings dlb
   WHERE act.activity_version_id = evt.activity_version_id
     AND dlb.event_id = evt.event_id
     AND dlb.line_id = p_line_id;

l_no_record 	BOOLEAN := TRUE;

BEGIN
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  	   IF p_UOM = 'ENR' THEN
		   FOR enr_rec IN enr_cur
		  LOOP
		       x_activity_name := enr_rec.version_name;
		       x_event_title := enr_rec.title;
		       x_course_start_date := enr_rec.course_start_date;
		       x_course_end_date := enr_rec.course_end_date;
		       l_no_record := FALSE;
		   END LOOP;

	ELSIF p_UOM = 'EVT' THEN
		   FOR evt_rec IN evt_cur
		  LOOP
		       x_activity_name := evt_rec.version_name;
		       x_event_title := evt_rec.title;
		       x_course_start_date := evt_rec.course_start_date;
		       x_course_end_date := evt_rec.course_end_date;
		       l_no_record := FALSE;
		   END LOOP;
	 END IF;

	  IF l_no_record THEN
	     x_activity_name := NULL;
	     x_event_title := NULL;
	     x_course_start_date := NULL;
     	     x_course_end_date := NULL;
	 END IF;

  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
EXCEPTION
  WHEN others THEN
    --
    -- A validation or unexpected error has occured
    --
    hr_utility.set_location(' Leaving:'||l_proc, 90);
END get_event_detail;
--


END OTA_OM_UTIL;

/
