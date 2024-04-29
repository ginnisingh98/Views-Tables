--------------------------------------------------------
--  DDL for Package FV_YE_CLOSE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FV_YE_CLOSE" AUTHID CURRENT_USER AS
-- $Header: FVXYECPS.pls 120.5.12010000.4 2010/01/07 07:54:19 amaddula ship $

PROCEDURE Main( errbuf                  OUT NOCOPY VARCHAR2,
                retcode                 OUT NOCOPY NUMBER,
		            ledger_id			              NUMBER,
                closing_method              VARCHAR2,
                time_frame                  VARCHAR2,
                fund_group                  VARCHAR2,
                treasury_symbol             VARCHAR2,
                closing_fyr                 NUMBER,
                closing_period              VARCHAR2,
                mode_value                  VARCHAR2,
                post_gl_enable              VARCHAR2,
                post_to_gl                  VARCHAR2);

PROCEDURE Get_Required_Parameters;

PROCEDURE Get_Closing_Fyr_Details ;

PROCEDURE Chk_Dynamic_Insertion;

PROCEDURE Get_Balance_Account_Segments;

PROCEDURE Chk_To_Accounts;

PROCEDURE Purge_Bal_Temp_Table;

PROCEDURE Check_Gl_Data;

PROCEDURE Check_Year_End_Parameters;

PROCEDURE Get_Year_End_Record(trsymbol  VARCHAR2,
                              fundgroup VARCHAR2,
                              timeframe VARCHAR2 ) ;

PROCEDURE Get_Fund_Value;

PROCEDURE Determine_Acct_Flag;

PROCEDURE Get_Year_End_SeqAcct_Info;

PROCEDURE Determine_Child_Accounts;

PROCEDURE Process_Acct;

PROCEDURE Determine_Balance_Read_Flag;

PROCEDURE Get_Balances;

PROCEDURE Get_Segment_Values(ccid NUMBER);

PROCEDURE Determine_DrCr(ccid NUMBER);

PROCEDURE Insert_Balances(ccid          NUMBER,
                          acct          VARCHAR2,
                          bal_amt       NUMBER,
                          dr_cr         VARCHAR2,
                          read_flag     VARCHAR2,
                          remaining_bal NUMBER,
			  processing_type NUMBER,
                          segs          Fnd_Flex_Ext.SegmentArray);

PROCEDURE Update_Closing_Status;

PROCEDURE Populate_Gl_Interface;

PROCEDURE Cleanup_Gl_Interface;

PROCEDURE Submit_Report;

PROCEDURE Determine_Processing_Type(p_type OUT NOCOPY NUMBER);

PROCEDURE Check_bal_seg_value( vp_fund_grp VARCHAR2,vp_time_frame VARCHAR, vp_tsymbol_id VARCHAR ,vp_sob_id NUMBER ,vp_end_date DATE );

end fv_ye_close;

/
