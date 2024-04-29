--------------------------------------------------------
--  DDL for Package AMW_PROCCERT_REMINDER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMW_PROCCERT_REMINDER_PKG" AUTHID CURRENT_USER AS
/* $Header: amwpsrms.pls 120.0.12000000.1 2007/01/16 20:40:54 appldev ship $ */

-- ===============================================================
-- Start of Comments
-- Package name
--          AMW_PROCCERT_REMINDER_PKG
-- Purpose
--          Contains the PL/Sql Procedures that suppots Sending Process
--          Certification Reminders
-- History
--
-- NOTE
--
-- End of Comments
-- ===============================================================
PROCEDURE send_reminder_to_all_owners(
		  errbuf OUT NOCOPY  VARCHAR2,
		  retcode OUT NOCOPY      VARCHAR2) ;

PROCEDURE update_lastreminder_date(
		  p_certificaion_id IN number,
		  x_return_status OUT NOCOPY VARCHAR2);

PROCEDURE send_reminder_to_owner(
		  p_item_type           IN  VARCHAR2 := 'AMWNOTIF',
		  p_message_name        IN  VARCHAR2 := 'PROCESSCERTIFICATIONREMINDER',
                  p_certification_id	in NUMBER,
		  p_process_owner_id	in NUMBER,
		  p_organization_id	in NUMBER := null,
		  p_process_id		in NUMBER := null,
		  x_return_status OUT NOCOPY VARCHAR2);

PROCEDURE send_reminder_selected_procs(
		p_organization_id IN Number,
		p_entity_id IN Number,
		p_process_id In Number,
		x_return_status OUT NOCOPY VARCHAR2);

END AMW_PROCCERT_REMINDER_PKG;

 

/
