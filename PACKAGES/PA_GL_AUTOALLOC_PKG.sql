--------------------------------------------------------
--  DDL for Package PA_GL_AUTOALLOC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_GL_AUTOALLOC_PKG" AUTHID CURRENT_USER AS
/*  $Header: PAXGLAAS.pls 120.1 2005/08/10 15:51:16 dlanka noship $  */

----------------------------------------------------------------------------
/* Given a set id it determines if Project Allocation Rules use GL period or
PA period. If all the rules use PA Period type then return 'P' similarly if
all the rules use GL Period Type then return 'G'- if both types exist return
'B' - if the set does not have any Project Allocation Rules return 'N'*/

FUNCTION 	GET_PERIOD_TYPE (	p_allocation_set_id 	Number	)
RETURN CHAR;

PRAGMA RESTRICT_REFERENCES (Get_Period_Type,WNDS,WNPS);
--------------------------------------------------------------------------
/* This function calls Get_Period_Type to determine which run period (pa/gl)
value is required. It further checks if that period is not null. It returns
TRUE on success, FALSE on failure. */

FUNCTION Valid_Run_Period (	p_allocation_set_id	IN 	Number,
				p_pa_period 		IN	Varchar2
							default  Null,
				p_gl_period 		IN	Varchar2
							default  Null)
RETURN BOOLEAN;

PRAGMA RESTRICT_REFERENCES (Valid_Run_Period,WNDS,WNPS);
-------------------------------------------------------------------------------
/* The function does two things
	1.Identify which period to be passed as parameter to a process.
	2. Submits the Generate Allocation Transactions Request.
   Return Value:
	Request Id.
*/

FUNCTION	SUBMIT_ALLOC_REQUEST(	p_rule_id		IN	Number,
					p_expnd_item_date	IN	Date,
					p_pa_period		IN	Varchar2,
					p_gl_period		IN	Varchar2
				     )
Return Number;
-------------------------------------------------------------------------------
/** This procedure is called from GL package GL_PA_AUTOALLOC_PKG.
    It sets status of a concurrent request called from PA step down allocation.
    This status is displayed in View Status form part of Autoallocation **/

Procedure get_pa_step_status (
                      p_request_Id        In   Number
                     ,p_step_number       In   Number
                     ,p_mode              In   Varchar2
                     ,l_status            Out NOCOPY  Varchar2);

------------------------------------------------------------------------------
END PA_GL_AUTOALLOC_PKG;

 

/
