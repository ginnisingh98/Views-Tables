--------------------------------------------------------
--  DDL for Package RLM_PS_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."RLM_PS_SV" AUTHID CURRENT_USER as
/*$Header: RLMDPPSS.pls 120.1.12000000.1 2007/01/18 18:31:47 appldev ship $*/
/*===========================================================================
  PACKAGE NAME:	RLM_PS_SV

  DESCRIPTION:	Contains all specifications for the PurgeSchedule package

  CLIENT/SERVER:	Server

  LIBRARY NAME:	None

  OWNER:

  PROCEDURE/FUNCTIONS:

  GLOBALS:

===========================================================================*/
  C_SDEBUG              CONSTANT   NUMBER := rlm_core_sv.C_LEVEL1;
  C_DEBUG               CONSTANT   NUMBER := rlm_core_sv.C_LEVEL2;
  C_TDEBUG              CONSTANT   NUMBER := rlm_core_sv.C_LEVEL3;

/*===========================================================================
  PROCEDURE NAME:    PurgeSchedule

  DESCRIPTION:

  PARAMETERS:    	   p_org_id     NUMBER
                           p_execution_mode VARCHAR2 DEFAULT NULL
			   p_translator_code_from VARCHAR2 DEFAULT NULL
                           p_translator_code_to VARCHAR2 DEFAULT NULL
                           p_customer VARCHAR2 DEFAULT NULL
			   p_ship_to_address_id_from NUMBER DEFAULT NULL
			   p_ship_to_address_id_to NUMBER  DEFAULT NULL
                           p_issue_date_from VARCHAR2 DEFAULT NULL
			   p_issue_date_to VARCHAR2 DEFAULT NULL
			   p_schedule_type VARCHAR2 DEFAULT NULL
			   p_schedule_ref_no VARCHAR2 DEFAULT NULL
			   p_delete_beyond_days NUMBER DEFAULT NULL
                           p_authorization VARCHAR2 DEFAULT NULL
                           p_status  NUMBER DEFAULT NULL


  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:       created asutar 07/31/00
===========================================================================*/
PROCEDURE PurgeSchedule(   errbuf OUT NOCOPY VARCHAR2,
                           retcode OUT NOCOPY NUMBER,
                           p_org_id   NUMBER,
			   p_execution_mode VARCHAR2 DEFAULT NULL,
			   p_translator_code_from VARCHAR2 DEFAULT NULL,
                           p_translator_code_to VARCHAR2 DEFAULT NULL,
                           p_customer VARCHAR2 DEFAULT NULL,
			   p_ship_to_address_id_from NUMBER DEFAULT NULL,
			   p_ship_to_address_id_to NUMBER DEFAULT NULL,
                           p_issue_date_from VARCHAR2 DEFAULT NULL,
			   p_issue_date_to VARCHAR2 DEFAULT NULL,
			   p_schedule_type VARCHAR2 DEFAULT NULL,
			   p_schedule_ref_no VARCHAR2 DEFAULT NULL,
			   p_delete_beyond_days NUMBER DEFAULT NULL,
                           p_authorization VARCHAR2 DEFAULT NULL,
                           p_status NUMBER DEFAULT NULL);


PROCEDURE PurgeInterface(p_execution_mode VARCHAR2 DEFAULT NULL,
                        p_authorization VARCHAR2 DEFAULT NULL,
                        p_ship_to_address_id_from NUMBER DEFAULT NULL,
			p_ship_to_address_id_to NUMBER DEFAULT NULL,
                        p_statement VARCHAR2 DEFAULT NULL);

PROCEDURE PurgeArchive(p_execution_mode VARCHAR2 DEFAULT NULL,
                      p_authorization VARCHAR2 DEFAULT NULL,
                      p_ship_to_address_id_from NUMBER DEFAULT NULL,
		      p_ship_to_address_id_to NUMBER DEFAULT NULL,
                      p_statement VARCHAR2 DEFAULT NULL);



FUNCTION BuildQuery (     p_execution_mode VARCHAR2 DEFAULT NULL,
			   p_translator_code_from VARCHAR2 DEFAULT NULL,
                           p_translator_code_to VARCHAR2 DEFAULT NULL,
                           p_customer VARCHAR2 DEFAULT NULL,
			   p_ship_to_address_id_from NUMBER DEFAULT NULL,
			   p_ship_to_address_id_to NUMBER DEFAULT NULL,
                           p_issue_date_from VARCHAR2 DEFAULT NULL,
			   p_issue_date_to VARCHAR2 DEFAULT NULL,
			   p_schedule_type VARCHAR2 DEFAULT NULL,
			   p_schedule_ref_no NUMBER DEFAULT NULL,
			   p_delete_beyond_days NUMBER DEFAULT NULL,
                           p_authorization VARCHAR2 DEFAULT NULL,
                           p_status NUMBER DEFAULT NULL)
RETURN VARCHAR2;


PROCEDURE RunReport (      p_org_id     NUMBER,
                           p_execution_mode VARCHAR2 DEFAULT NULL,
			   p_translator_code_from VARCHAR2 DEFAULT NULL,
                           p_translator_code_to VARCHAR2 DEFAULT NULL,
                           p_customer VARCHAR2 DEFAULT NULL,
			   p_ship_to_address_id_from NUMBER DEFAULT NULL,
			   p_ship_to_address_id_to NUMBER DEFAULT NULL,
                           p_issue_date_from VARCHAR2 DEFAULT NULL,
			   p_issue_date_to VARCHAR2 DEFAULT NULL,
			   p_schedule_type VARCHAR2 DEFAULT NULL,
			   p_schedule_ref_no NUMBER DEFAULT NULL,
			   p_delete_beyond_days NUMBER DEFAULT NULL,
                           p_authorization VARCHAR2 DEFAULT NULL,
                           p_status NUMBER DEFAULT NULL);


FUNCTION CheckOpenOrder (p_schedule_header_id NUMBER,
                         x_purge_rec          rlm_message_sv.t_PurExp_rec)
RETURN BOOLEAN;

END RLM_PS_SV;
 

/
