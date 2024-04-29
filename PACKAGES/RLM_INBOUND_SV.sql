--------------------------------------------------------
--  DDL for Package RLM_INBOUND_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."RLM_INBOUND_SV" AUTHID CURRENT_USER as
/* $Header: RLMEDINS.pls 120.1 2005/07/17 18:16:41 rlanka noship $*/



/*===========================================================================
  PACKAGE NAME:        RLM_INBOUND_SV

  DESCRIPTION:         Contains EDI Gateway transaction processor for the
                       inbound demand.

  CLIENT/SERVER:        Server

  LIBRARY NAME: None

  OWNER:                mnnaraya

  PROCEDURE/FUNCTIONS:  PROCESS_INBOUND, GetCountInterfaceHeaderID

  GLOBALS:

===========================================================================*/
--MOAC: Added p_org_id parameter.

PROCEDURE PROCESS_INBOUND
	(
        errbuf                  OUT NOCOPY             varchar2,
        retcode                 OUT NOCOPY             varchar2,
        p_org_id	        IN	        number,
        p_file_path             IN              varchar2,
        p_file_name             IN              varchar2,
        p_transaction_type      IN              varchar2,
        p_map_id                IN              number,
        p_debug_mode            IN              number,
        p_run_import            IN              varchar2,
        p_enable_warn           IN              varchar2,
        p_warn_replace_schedule IN              VARCHAR2,
        p_child_processes       IN              NUMBER DEFAULT 0,
        p_data_file_char_set    IN              VARCHAR2
	);

/*===========================================================================

  PROCEDURE NAME: GetCountInterfaceHeaderId

  DESCRIPTION:    Derives the number of schedules based on
                  request Id.

  CLIENT/SERVER:  Server

  PARAMETERS:     x_request_id  IN NUMBER

  CREATED:        mnandell

  GLOBALS:

===========================================================================*/
FUNCTION   GetCountInterfaceHeaderId(x_request_id  IN NUMBER)
RETURN NUMBER;


--4316744: Timezone uptake.Added the following new procedure.
/*===========================================================================

  PROCEDURE NAME: UpdateHorizonDates(p_run_id IN NUMBER)

  DESCRIPTION:    Update the horizon dates

  CLIENT/SERVER:  Server

  PARAMETERS:     p_run_id  IN NUMBER

  CREATED:        anviswan

  GLOBALS:

===========================================================================*/
PROCEDURE UpdateHorizonDates(p_run_id IN NUMBER);

END RLM_INBOUND_SV;
 

/
