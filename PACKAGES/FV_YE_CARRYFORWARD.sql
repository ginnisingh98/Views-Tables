--------------------------------------------------------
--  DDL for Package FV_YE_CARRYFORWARD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FV_YE_CARRYFORWARD" AUTHID CURRENT_USER AS
-- $Header: FVXYECFS.pls 120.5.12010000.1 2008/07/28 06:33:44 appldev ship $

PROCEDURE Main( errbuf                  OUT NOCOPY VARCHAR2,
                retcode                 OUT NOCOPY NUMBER,
                sob                         NUMBER,
                carryfor_fyr                NUMBER) ;

PROCEDURE Get_Required_Parameters;

PROCEDURE Get_Period_Details ;

PROCEDURE Check_Carryforward_Process;

PROCEDURE Get_Balances;

-- PROCEDURE Get_Attribute_Balances (p_ccid NUMBER);

PROCEDURE Setup_Gl_Interface;

PROCEDURE Submit_Journal_Import;

PROCEDURE Cleanup_Gl_Interface;

function convert_to_num(p_instr varchar2) return number;

FUNCTION Check_bal_seg_value(Vp_fund_value  VARCHAR2 ,
                               Vp_sob_id NUMBER,
                               Vp_bal_seg_val_opt_code VARCHAR)
 return varchar ;

end Fv_Ye_Carryforward;

/
