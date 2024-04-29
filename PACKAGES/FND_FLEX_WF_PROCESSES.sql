--------------------------------------------------------
--  DDL for Package FND_FLEX_WF_PROCESSES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_FLEX_WF_PROCESSES" AUTHID CURRENT_USER AS
/* $Header: AFFFWFPS.pls 120.1.12010000.1 2008/07/25 14:14:59 appldev ship $ */

PROCEDURE validate_on;
PROCEDURE validate_off;

FUNCTION message RETURN VARCHAR2;

PROCEDURE set_session_mode(session_mode IN VARCHAR2);

PROCEDURE add_workflow_item_type(x_application_id IN NUMBER,
				 x_code           IN VARCHAR2,
				 x_num            IN NUMBER,
				 x_item_type      IN VARCHAR2,
				 x_process_name   IN VARCHAR2);

PROCEDURE delete_workflow_item_type(x_application_id IN NUMBER,
				    x_code           IN VARCHAR2,
				    x_num            IN NUMBER,
				    x_item_type      IN VARCHAR2);

PROCEDURE change_workflow_process(x_application_id IN NUMBER,
				  x_code           IN VARCHAR2,
				  x_num            IN NUMBER,
				  x_item_type      IN VARCHAR2,
				  x_process_name   IN VARCHAR2);

-- ======================================================================
-- Adds workflow item type to all existing structures, and sets them to use
-- DEFAULT_ACCOUNT_GENERATION process.
--
PROCEDURE add_new_workflow_item_type(p_application_short_name IN VARCHAR2,
				     p_id_flex_code           IN VARCHAR2,
				     p_wf_item_type           IN VARCHAR2);


END fnd_flex_wf_processes;

/
