--------------------------------------------------------
--  DDL for Package GCS_ENG_CP_UTILITY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GCS_ENG_CP_UTILITY_PKG" AUTHID CURRENT_USER as
/* $Header: gcs_cpeng_uts.pls 120.1 2005/10/30 05:17:12 appldev noship $ */

  --
  -- Procedure
  --   generate_xml_and_ntfs()
  -- Purpose
  --   Concurrent program to generate the XML and notifications
  -- Arguments
  --   x_errbuf			Standard error buffer
  --   x_retcode		Standard return code
  --   p_execution_type		"CONS_PROCESS", "IMPACT_ENGINE", "NTF_ONLY"
  --   p_run_name		Process Identifier
  --   p_cons_entity_id		Consolidation Entity
  --   p_category_code		Category Code
  --   p_child_entity_id	Child Entity
  --   p_run_detail_id		Run Detail Identifier
  --   p_entry_id		Entry Identifier
  --   p_load_id		Load Identifier
  -- Notes
  --
   PROCEDURE generate_xml_and_ntfs(
				x_errbuf			OUT NOCOPY VARCHAR2,
				x_retcode			OUT NOCOPY VARCHAR2,
				p_execution_type		IN VARCHAR2,
				p_run_name			IN VARCHAR2,
				p_cons_entity_id		IN NUMBER,
				p_category_code			IN VARCHAR2,
				p_child_entity_id		IN NUMBER,
				p_run_detail_id			IN NUMBER 	DEFAULT NULL,
				p_entry_id			IN NUMBER	DEFAULT NULL,
				p_load_id			IN NUMBER	DEFAULT NULL);

  --
  -- Procedure
  --   submit_xml_ntf_program()
  -- Purpose
  --   API to submit concurrent request to generate notifications and XML
  -- Arguments
  --   p_execution_type         "CONS_PROCESS", "IMPACT_ENGINE", "NTF_ONLY"
  --   p_run_name               Process Identifier
  --   p_cons_entity_id         Consolidation Entity
  --   p_category_code          Category Code
  --   p_child_entity_id        Child Entity
  --   p_run_detail_id          Run Detail Identifier
  --   p_entry_id               Entry Identifier
  --   p_load_id                Load Identifier
  -- Notes
  --
   PROCEDURE submit_xml_ntf_program(
                                p_execution_type                IN VARCHAR2,
                                p_run_name                      IN VARCHAR2,
                                p_cons_entity_id                IN NUMBER,
                                p_category_code                 IN VARCHAR2,
                                p_child_entity_id               IN NUMBER	DEFAULT NULL,
                                p_run_detail_id                 IN NUMBER       DEFAULT NULL,
                                p_entry_id                      IN NUMBER       DEFAULT NULL,
                                p_load_id                       IN NUMBER       DEFAULT NULL);

END GCS_ENG_CP_UTILITY_PKG;


 

/
