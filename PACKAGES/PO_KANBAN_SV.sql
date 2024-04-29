--------------------------------------------------------
--  DDL for Package PO_KANBAN_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_KANBAN_SV" AUTHID CURRENT_USER AS
/* $Header: POXKBANS.pls 115.2 2002/11/25 23:29:54 sbull ship $*/

/*===========================================================================
  PACKAGE NAME:		PO_KANBAN_SV

  DESCRIPTION:          PO Update Kanban Card Status procedures

  CLIENT/SERVER:	Server

  LIBRARY NAME

  PROCEDURES/FUNCTIONS:

  CHANGE HISTORY:       WLAU       8/28/1997     Created
===========================================================================*/


PROCEDURE Update_Card_Status   (p_card_status      IN VARCHAR2,
				p_document_type    IN VARCHAR2,
				p_document_id      IN NUMBER,
				p_kanban_return_status  OUT NOCOPY VARCHAR2);


PROCEDURE Update_Card_Status_Full  (p_kanban_card_ID 	    IN NUMBER,
				    p_kanban_return_status  OUT NOCOPY VARCHAR2);



END PO_KANBAN_SV;

 

/
