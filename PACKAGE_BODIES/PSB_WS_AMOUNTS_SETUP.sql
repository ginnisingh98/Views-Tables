--------------------------------------------------------
--  DDL for Package Body PSB_WS_AMOUNTS_SETUP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSB_WS_AMOUNTS_SETUP" as
/* $Header: PSBVWASB.pls 115.3 2002/11/22 07:39:04 pmamdaba ship $ */
------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------

Function ws_get_totals( p_worksheet_id in number,     p_stage in number,
			p_position_line_id in number, p_service_package_id in number,
			p_element_set_id in number,   p_budget_year_id in number)
			RETURN NUMBER IS

  t_amount  number;

 Begin
   Begin
	Select	sum(WAL.Ytd_Amount)
	 Into   t_amount
  	From  	PSB_WS_LINES_POSITIONS WL,
		PSB_WS_ACCOUNT_LINES WAL
	Where   WL.WORKSHEET_ID = p_worksheet_id
	  and   WL.POSITION_LINE_ID = WAL.POSITION_LINE_ID
	  and   WL.VIEW_LINE_FLAG = 'Y'
	  and   WAL.Position_line_ID = p_position_line_id
          and   WAL.Service_Package_ID = p_service_package_id
	  and   WAL.Element_Set_ID = p_element_set_id
          and   WAL.Budget_Year_ID = p_budget_year_id
 	  and ((psb_ws_matrix.get_ws_line_year_st = 0
               and wal.end_stage_seq is null)
           or
               (psb_ws_matrix.get_ws_line_year_st between
                wal.start_stage_seq and nvl(wal.end_stage_seq, 9.99e125)));
--  and   p_stage between  WAL.START_STAGE_SEQ AND WAL.CURRENT_STAGE_SEQ;
	Exception When No_Data_Found then
	  Null;
    End;
  if t_amount = 0 then
    return(1);
  end if;

  return(t_amount);
 End;

End psb_ws_amounts_setup;

/
