--------------------------------------------------------
--  DDL for Package ECE_SPSO_TRANS1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ECE_SPSO_TRANS1" AUTHID CURRENT_USER AS
-- $Header: ECSPSOS.pls 120.2 2005/09/30 05:38:53 arsriniv ship $

/*===========================================================================

  PROCEDURE NAME:      Extract_SPSO_Outbound

  PURPOSE:             This procedure initiates the concurrent process to
                       extract the eligible deliveires on a dparture.

===========================================================================*/
/* Bug 1854866
Assigned default values to the parameter
v_debug_mode of the procedures
extract_spso_outbound and
extract_ssso_outbound since the default
values are assigned to these parameters
in the package body
*/
/*  Bug 2064311
    The  parameter batch_id has been added to the
    procedure specs populate_supplier_sched_api1
    and api3, update_chv_schedule_headers,Extract_SPSO_Outbound
    and Extract_SSSO_Outbound to improve performance
*/


  PROCEDURE Extract_SPSO_Outbound (errbuf OUT NOCOPY VARCHAR2,
                                   retcode OUT NOCOPY VARCHAR2,
                                   cOutput_Path  IN VARCHAR2,
                                   cOutput_Filename IN VARCHAR2,
                                   p_schedule_id IN VARCHAR2 default 0,		--2499414
                                   v_debug_mode IN NUMBER DEFAULT 0,
                                   p_batch_id       IN  NUMBER default 0);   -- Bug 2063617
/*===========================================================================

  PROCEDURE NAME:      Extract_SSSO_Outbound

  PURPOSE:             This procedure initiates the concurrent process to
                       extract the eligible deliveires on a dparture.

===========================================================================*/

  PROCEDURE Extract_SSSO_Outbound (errbuf OUT NOCOPY VARCHAR2,
                                   retcode OUT NOCOPY VARCHAR2,
                                   cOutput_Path  IN VARCHAR2,
                                   cOutput_Filename IN VARCHAR2,
                                   p_schedule_id IN VARCHAR2 default 0,		--2499414
                                   v_debug_mode IN NUMBER DEFAULT 0,
                                   p_batch_id       IN  NUMBER default 0);   -- Bug 2063617


PROCEDURE PUT_DATA_TO_OUTPUT_TABLE(
	p_communication_method	IN  VARCHAR2,
	p_transaction_type	IN  VARCHAR2,		-- plan SPSO, ship SSSO
	p_output_width		IN  INTEGER,
	p_run_id		IN  INTEGER,
	p_header_interface	IN  VARCHAR2 := 'ECE_SPSO_HEADERS',
	p_item_interface	IN  VARCHAR2 := 'ECE_SPSO_ITEMS',
	p_item_d_interface	IN  VARCHAR2 := 'ECE_SPSO_ITEM_DET',
        p_ship_d_interface      IN  VARCHAR2 := 'ECE_SPSO_SHIP_DET'
	);


/* --------------------------------------------------------------------------*/

--  PROCEDURE POPULATE_POCO_TRX
--	This procedure has the following functionalities:
--	1. Build SQL statement dynamically to extract data from
--		Base Application Tables.
--	2. Execute the dynamic SQL statement.
--	3. Assign data into 2-dim PL/SQL table
--	4. Pass data to the code conversion mechanism
--	5. Populate the Interface tables with the extracted data.
-- --------------------------------------------------------------------------

PROCEDURE populate_supplier_sched_api1 (
				cCommunication_Method	IN VARCHAR2,
				cTransaction_Type	IN VARCHAR2,
				dTransaction_date	IN DATE,
				iRun_id			IN INTEGER,
				p_document_type		IN  VARCHAR2 := 'SPS',	-- plan SPS, ship SSS
				p_schedule_id		IN  INTEGER  := 0,
		                p_batch_id              IN   NUMBER default 0,	  --2499414
                        	cHeader_Interface	IN VARCHAR2,
				cItem_Interface		IN VARCHAR2,
				cItem_D_Interface	IN VARCHAR2
);

PROCEDURE POPULATE_SUPPLIER_SCHED_API3
	(
	p_communication_method	IN  VARCHAR2,	-- EDI
	p_transaction_type	IN  VARCHAR2,	-- plan SPSO, ship SSSO
	p_document_type		IN  VARCHAR2,	-- plan SPS, ship SSS
	p_run_id		IN  NUMBER,
	p_schedule_id		IN  INTEGER  default 0,		--2499414
        p_batch_id              IN  NUMBER  default 0		--2499414
   );


PROCEDURE UPDATE_CHV_SCHEDULE_HEADERS (
	p_transaction_type	IN	VARCHAR2,
	p_schedule_id		IN	INTEGER	:= 0,
        p_batch_id             IN      NUMBER default 0,	--2499414
 	p_edi_count		IN	NUMBER  :=0
);


END ECE_SPSO_TRANS1;


 

/
