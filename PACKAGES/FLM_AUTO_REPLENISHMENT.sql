--------------------------------------------------------
--  DDL for Package FLM_AUTO_REPLENISHMENT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FLM_AUTO_REPLENISHMENT" AUTHID CURRENT_USER AS
/* $Header: FLMCPARS.pls 120.1.12010000.3 2009/06/05 14:13:07 adasa ship $ */

/****************************************************************************
 *    Constants                                                             *
 ****************************************************************************/
/* Kanban Card Supply Status Constants */
G_Supply_Status_New		CONSTANT	NUMBER := 1;
G_Supply_Status_Full		CONSTANT	NUMBER := 2;
G_Supply_Status_Wait		CONSTANT	NUMBER := 3;
G_Supply_Status_Empty		CONSTANT	NUMBER := 4;
G_Supply_Status_InProcess	CONSTANT	NUMBER := 5;
G_Supply_Status_InTransit	CONSTANT	NUMBER := 6;
G_Supply_Status_Exception	CONSTANT	NUMBER := 7;

/* Kanban Card Types Constants */
G_Card_Type_Replenishable	CONSTANT	NUMBER := 1;
G_Card_Type_NonReplenishable	CONSTANT	NUMBER := 2;

/* Kanban Card Status Constants */
G_Card_Status_Active		CONSTANT	NUMBER := 1;
G_Card_Status_Hold		CONSTANT	NUMBER := 2;
G_Card_Status_Cancel		CONSTANT	NUMBER := 3;

/* Wip Supply Type Constants */
G_Supply_Type_Push		CONSTANT	NUMBER := 1;
G_Supply_Type_Assembly_Pull	CONSTANT	NUMBER := 2;
G_Supply_Type_Operation_Pull	CONSTANT	NUMBER := 3;
G_Supply_Type_Bulk		CONSTANT	NUMBER := 4;
G_Supply_Type_Supplier		CONSTANT	NUMBER := 5;
G_Supply_Type_Phantom		CONSTANT	NUMBER := 6;

/* Release Time Fence Code Constants */
G_Release_Time_Kanban_Item	CONSTANT	NUMBER := 6; /* Kanban Item (Do Not Release) */

/* Error Constants */
G_Error_Create_Cards		CONSTANT	NUMBER := 1;
G_Error_Replenish_Cards		CONSTANT	NUMBER := 2;

/***************************************************************************
 *    Types                                                                *
 ***************************************************************************/
/* Modified for Lot Based Material Support.
   Added basis_type and qty_per_lot */
Type comp_rec is record
        (item_id                NUMBER,
         usage                  NUMBER,
         line_id                NUMBER,
	 operation_seq_num	NUMBER,
	 line_op_seq_id	        NUMBER,
	 pull_sequence_id       NUMBER,
	 schedule_number        VARCHAR2(30),
         basis_type		NUMBER,
	 qty_per_lot		NUMBER);

TYPE comp_list is table of comp_rec index by BINARY_INTEGER;

TYPE Pull_Sequence_Id_Tbl_Type IS TABLE OF MTL_KANBAN_PULL_SEQUENCES.PULL_SEQUENCE_ID%TYPE
     INDEX BY BINARY_INTEGER;

TYPE Kanban_Card_Id_Tbl_Type IS TABLE OF MTL_KANBAN_CARDS.KANBAN_CARD_ID%TYPE
     INDEX BY BINARY_INTEGER;

/***************************************************************************
 *    Public Functions                                                     *
 ***************************************************************************/


/***************************************************************************
 *    Public Procedures                                                    *
 ***************************************************************************/

/************************************************************************
 * PROCEDURE Create_And_Replenish_Cards					*
 *  	This is the procedure which is called by the Concurrent	Request *
 *	The Input parameters for this procedure are :			*
 *	p_organization_id - Organization Identifier			*
 *	p_min_line_code   - From Line Identifier			*
 *	p_max_line_code   - To Line Identifier				*
 *			  - To find flow schedules which are on lines	*
			    between From and To Lines identifier	*
 *	p_completion_date - Completion Date of Flow Schedules		*
 *			  - To find flow schedules which have scheduled *
 *			    completion date less than the given date 	*
 *			    greater than the sysdate			*
 *	p_build_sequence  - Build Sequence of Flow Schedules		*
 *			  - To find flow schedules which have build	*
 *			    sequence less than or equal to the given	*
 *			    build sequence and if this parameter is null*
 *			    then find all flow schedules which have not *
 *			    not build sequence				*
 *	p_print_card	  - Print Kanban Cards Option (Yes/No)		*
 ************************************************************************/
PROCEDURE Create_And_Replenish_Cards(
	o_error_code			OUT NOCOPY	NUMBER,
	o_error_msg			OUT NOCOPY	VARCHAR2,
	p_organization_id		IN	NUMBER,
	p_min_line_code			IN	VARCHAR2,
	p_max_line_code			IN	VARCHAR2,
        p_from_completion_date          IN      VARCHAR2, /*Added for bug 6816497 */
	p_completion_date		IN	VARCHAR2,
	p_from_build_sequence           IN      NUMBER, /*Added for bug 6816497 */
	p_build_sequence		IN	NUMBER,
	p_print_card			IN	VARCHAR2);

END FLM_AUTO_REPLENISHMENT;

/
