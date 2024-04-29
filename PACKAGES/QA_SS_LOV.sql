--------------------------------------------------------
--  DDL for Package QA_SS_LOV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QA_SS_LOV" AUTHID CURRENT_USER as
/* $Header: qltsslvb.pls 115.10 2002/11/27 19:33:05 jezheng ship $ */


procedure gen_list (
vchar_id IN qa_chars.char_id%TYPE,
rnumb IN NUMBER,
cnumb IN NUMBER,
find1 IN VARCHAR2
		);

procedure LOV_Header  (
			vchar_id IN qa_chars.char_id%TYPE,
			rnumb IN NUMBER,
			cnumb IN NUMBER,
			find_str IN VARCHAR2
		);

procedure LOV_Values (
vchar_id IN qa_chars.char_id%TYPE DEFAULT NULL,
rnumb IN NUMBER DEFAULT NULL,
cnumb IN NUMBER DEFAULT NULL,
start_row IN NUMBER DEFAULT 1,
p_end_row IN NUMBER DEFAULT NULL,
orgz_id IN NUMBER DEFAULT NULL,
plan_id_i IN NUMBER DEFAULT NULL,
x_txn_num IN NUMBER DEFAULT NULL,
x_wip_entity_type IN NUMBER DEFAULT NULL,
x_wip_rep_sch_id IN NUMBER DEFAULT NULL,
x_po_header_id IN NUMBER DEFAULT NULL,
x_po_release_id IN NUMBER DEFAULT NULL,
x_po_line_id IN NUMBER DEFAULT NULL,
x_line_location_id IN NUMBER DEFAULT NULL,
x_po_distribution_id IN NUMBER DEFAULT NULL,
x_item_id IN NUMBER DEFAULT NULL,
x_wip_entity_id IN NUMBER DEFAULT NULL,
x_wip_line_id IN NUMBER DEFAULT NULL,
x_po_shipment_id IN NUMBER DEFAULT NULL,
p1 IN VARCHAR2 DEFAULT NULL,
p2 IN VARCHAR2 DEFAULT NULL,
p3 IN VARCHAR2 DEFAULT NULL,
p4 IN VARCHAR2 DEFAULT NULL,
p5 IN VARCHAR2 DEFAULT NULL,
p6 IN VARCHAR2 DEFAULT NULL,
p7 IN VARCHAR2 DEFAULT NULL,
p8 IN VARCHAR2 DEFAULT NULL,
p9 IN VARCHAR2 DEFAULT NULL,
p10 IN VARCHAR2 DEFAULT NULL,
p11 IN VARCHAR2 DEFAULT NULL,
p12 IN VARCHAR2 DEFAULT NULL,
p13 IN VARCHAR2 DEFAULT NULL,
p14 IN VARCHAR2 DEFAULT NULL,
p15 IN VARCHAR2 DEFAULT NULL,
p16 IN VARCHAR2 DEFAULT NULL,
p17 IN VARCHAR2 DEFAULT NULL,
p18 IN VARCHAR2 DEFAULT NULL,
p19 IN VARCHAR2 DEFAULT NULL,
p20 IN VARCHAR2 DEFAULT NULL,
p21 IN VARCHAR2 DEFAULT NULL,
p22 IN VARCHAR2 DEFAULT NULL,
p23 IN VARCHAR2 DEFAULT NULL,
p24 IN VARCHAR2 DEFAULT NULL,
p25 IN VARCHAR2 DEFAULT NULL,
p26 IN VARCHAR2 DEFAULT NULL,
p27 IN VARCHAR2 DEFAULT NULL,
p28 IN VARCHAR2 DEFAULT NULL,
p29 IN VARCHAR2 DEFAULT NULL,
p30 IN VARCHAR2 DEFAULT NULL,
p31 IN VARCHAR2 DEFAULT NULL,
p32 IN VARCHAR2 DEFAULT NULL,
p33 IN VARCHAR2 DEFAULT NULL,
p34 IN VARCHAR2 DEFAULT NULL,
p35 IN VARCHAR2 DEFAULT NULL,
p36 IN VARCHAR2 DEFAULT NULL,
p37 IN VARCHAR2 DEFAULT NULL,
p38 IN VARCHAR2 DEFAULT NULL,
p39 IN VARCHAR2 DEFAULT NULL,
p40 IN VARCHAR2 DEFAULT NULL,
p41 IN VARCHAR2 DEFAULT NULL,
p42 IN VARCHAR2 DEFAULT NULL,
p43 IN VARCHAR2 DEFAULT NULL,
p44 IN VARCHAR2 DEFAULT NULL,
p45 IN VARCHAR2 DEFAULT NULL,
p46 IN VARCHAR2 DEFAULT NULL,
p47 IN VARCHAR2 DEFAULT NULL,
p48 IN VARCHAR2 DEFAULT NULL,
p49 IN VARCHAR2 DEFAULT NULL,
p50 IN VARCHAR2 DEFAULT NULL,
p51 IN VARCHAR2 DEFAULT NULL,
p52 IN VARCHAR2 DEFAULT NULL,
p53 IN VARCHAR2 DEFAULT NULL,
p54 IN VARCHAR2 DEFAULT NULL,
p55 IN VARCHAR2 DEFAULT NULL,
p56 IN VARCHAR2 DEFAULT NULL,
p57 IN VARCHAR2 DEFAULT NULL,
p58 IN VARCHAR2 DEFAULT NULL,
p59 IN VARCHAR2 DEFAULT NULL,
p60 IN VARCHAR2 DEFAULT NULL,
p61 IN VARCHAR2 DEFAULT NULL,
p62 IN VARCHAR2 DEFAULT NULL,
p63 IN VARCHAR2 DEFAULT NULL,
p64 IN VARCHAR2 DEFAULT NULL,
p65 IN VARCHAR2 DEFAULT NULL,
p66 IN VARCHAR2 DEFAULT NULL,
p67 IN VARCHAR2 DEFAULT NULL,
p68 IN VARCHAR2 DEFAULT NULL,
p69 IN VARCHAR2 DEFAULT NULL,
p70 IN VARCHAR2 DEFAULT NULL,
p71 IN VARCHAR2 DEFAULT NULL,
p72 IN VARCHAR2 DEFAULT NULL,
p73 IN VARCHAR2 DEFAULT NULL,
p74 IN VARCHAR2 DEFAULT NULL,
p75 IN VARCHAR2 DEFAULT NULL,
p76 IN VARCHAR2 DEFAULT NULL,
p77 IN VARCHAR2 DEFAULT NULL,
p78 IN VARCHAR2 DEFAULT NULL,
p79 IN VARCHAR2 DEFAULT NULL,
p80 IN VARCHAR2 DEFAULT NULL,
p81 IN VARCHAR2 DEFAULT NULL,
p82 IN VARCHAR2 DEFAULT NULL,
p83 IN VARCHAR2 DEFAULT NULL,
p84 IN VARCHAR2 DEFAULT NULL,
p85 IN VARCHAR2 DEFAULT NULL,
p86 IN VARCHAR2 DEFAULT NULL,
p87 IN VARCHAR2 DEFAULT NULL,
p88 IN VARCHAR2 DEFAULT NULL,
p89 IN VARCHAR2 DEFAULT NULL,
p90 IN VARCHAR2 DEFAULT NULL,
p91 IN VARCHAR2 DEFAULT NULL,
p92 IN VARCHAR2 DEFAULT NULL,
p93 IN VARCHAR2 DEFAULT NULL,
p94 IN VARCHAR2 DEFAULT NULL,
p95 IN VARCHAR2 DEFAULT NULL,
p96 IN VARCHAR2 DEFAULT NULL,
p97 IN VARCHAR2 DEFAULT NULL,
p98 IN VARCHAR2 DEFAULT NULL,
p99 IN VARCHAR2 DEFAULT NULL,
p100 IN VARCHAR2 DEFAULT NULL,
p101 IN VARCHAR2 DEFAULT NULL,
p102 IN VARCHAR2 DEFAULT NULL,
p103 IN VARCHAR2 DEFAULT NULL,
p104 IN VARCHAR2 DEFAULT NULL,
p105 IN VARCHAR2 DEFAULT NULL,
p106 IN VARCHAR2 DEFAULT NULL,
p107 IN VARCHAR2 DEFAULT NULL,
p108 IN VARCHAR2 DEFAULT NULL,
p109 IN VARCHAR2 DEFAULT NULL,
p110 IN VARCHAR2 DEFAULT NULL,
p111 IN VARCHAR2 DEFAULT NULL,
p112 IN VARCHAR2 DEFAULT NULL,
p113 IN VARCHAR2 DEFAULT NULL,
p114 IN VARCHAR2 DEFAULT NULL,
p115 IN VARCHAR2 DEFAULT NULL,
p116 IN VARCHAR2 DEFAULT NULL,
p117 IN VARCHAR2 DEFAULT NULL,
p118 IN VARCHAR2 DEFAULT NULL,
p119 IN VARCHAR2 DEFAULT NULL,
p120 IN VARCHAR2 DEFAULT NULL,
p121 IN VARCHAR2 DEFAULT NULL,
p122 IN VARCHAR2 DEFAULT NULL,
p123 IN VARCHAR2 DEFAULT NULL,
p124 IN VARCHAR2 DEFAULT NULL,
p125 IN VARCHAR2 DEFAULT NULL,
p126 IN VARCHAR2 DEFAULT NULL,
p127 IN VARCHAR2 DEFAULT NULL,
p128 IN VARCHAR2 DEFAULT NULL,
p129 IN VARCHAR2 DEFAULT NULL,
p130 IN VARCHAR2 DEFAULT NULL,
p131 IN VARCHAR2 DEFAULT NULL,
p132 IN VARCHAR2 DEFAULT NULL,
p133 IN VARCHAR2 DEFAULT NULL,
p134 IN VARCHAR2 DEFAULT NULL,
p135 IN VARCHAR2 DEFAULT NULL,
p136 IN VARCHAR2 DEFAULT NULL,
p137 IN VARCHAR2 DEFAULT NULL,
p138 IN VARCHAR2 DEFAULT NULL,
p139 IN VARCHAR2 DEFAULT NULL,
p140 IN VARCHAR2 DEFAULT NULL,
p141 IN VARCHAR2 DEFAULT NULL,
p142 IN VARCHAR2 DEFAULT NULL,
p143 IN VARCHAR2 DEFAULT NULL,
p144 IN VARCHAR2 DEFAULT NULL,
p145 IN VARCHAR2 DEFAULT NULL,
p146 IN VARCHAR2 DEFAULT NULL,
p147 IN VARCHAR2 DEFAULT NULL,
p148 IN VARCHAR2 DEFAULT NULL,
p149 IN VARCHAR2 DEFAULT NULL,
p150 IN VARCHAR2 DEFAULT NULL,
p151 IN VARCHAR2 DEFAULT NULL,
p152 IN VARCHAR2 DEFAULT NULL,
p153 IN VARCHAR2 DEFAULT NULL,
p154 IN VARCHAR2 DEFAULT NULL,
p155 IN VARCHAR2 DEFAULT NULL,
p156 IN VARCHAR2 DEFAULT NULL,
p157 IN VARCHAR2 DEFAULT NULL,
p158 IN VARCHAR2 DEFAULT NULL,
p159 IN VARCHAR2 DEFAULT NULL,
p160 IN VARCHAR2 DEFAULT NULL,
i_1 IN VARCHAR2 DEFAULT NULL, -- find_str
a_1 IN VARCHAR2 DEFAULT NULL, -- search on
c_1 IN VARCHAR2 DEFAULT NULL, -- condition
case_sensitive IN VARCHAR2 DEFAULT NULL,
Flag IN NUMBER DEFAULT NULL
		);

function return_col_num ( x_char_id IN NUMBER, x_plan_id IN NUMBER )
RETURN NUMBER;


function value_to_id ( charid IN NUMBER, val IN VARCHAR2, orgz_id IN NUMBER DEFAULT NULL )
RETURN NUMBER;
	-- eg, pass in Project Number as val, will return Project Id


-- commenting out some of the below functions
-- becos they are actually private to this pkg
-- and need not be in the pkg SPEC file (viz. this .pls file)

/*
function Q_Comp_Revision ( Elmt_tab qa_ss_const.var150_table,
                            plan_id_i IN NUMBER DEFAULT NULL,
                            vcharid IN NUMBER DEFAULT NULL,
                            orgz_id IN NUMBER DEFAULT NULL  )
	Return VARCHAR2;

function Q_Comp_Subinventory ( Elmt_tab qa_ss_const.var150_table,
                            plan_id_i IN NUMBER DEFAULT NULL,
                            vcharid IN NUMBER DEFAULT NULL,
                            orgz_id IN NUMBER DEFAULT NULL  )
	Return VARCHAR2;

function Q_Comp_UOM ( Elmt_tab qa_ss_const.var150_table,
                            plan_id_i IN NUMBER DEFAULT NULL,
                            vcharid IN NUMBER DEFAULT NULL,
                            orgz_id IN NUMBER DEFAULT NULL  )
	Return VARCHAR2;

function Q_Customers ( Elmt_tab qa_ss_const.var150_table,
                            plan_id_i IN NUMBER DEFAULT NULL,
                            vcharid IN NUMBER DEFAULT NULL,
                            orgz_id IN NUMBER DEFAULT NULL  )
	Return VARCHAR2;

function Q_Department ( Elmt_tab qa_ss_const.var150_table,
                            plan_id_i IN NUMBER DEFAULT NULL,
                            vcharid IN NUMBER DEFAULT NULL,
                            orgz_id IN NUMBER DEFAULT NULL  )
	Return VARCHAR2;

function Q_From_Op_Seq_Num ( Elmt_tab qa_ss_const.var150_table,
                            plan_id_i IN NUMBER DEFAULT NULL,
                            vcharid IN NUMBER DEFAULT NULL,
                            orgz_id IN NUMBER DEFAULT NULL  )
	Return VARCHAR2;

function Q_Line ( Elmt_tab qa_ss_const.var150_table,
                            plan_id_i IN NUMBER DEFAULT NULL,
                            vcharid IN NUMBER DEFAULT NULL,
                            orgz_id IN NUMBER DEFAULT NULL  )
	Return VARCHAR2;

function Q_Lot_Number ( Elmt_tab qa_ss_const.var150_table,
                            plan_id_i IN NUMBER DEFAULT NULL,
                            vcharid IN NUMBER DEFAULT NULL,
                            orgz_id IN NUMBER DEFAULT NULL  )
	Return VARCHAR2;

function Q_Po_Headers ( Elmt_tab qa_ss_const.var150_table,
                            plan_id_i IN NUMBER DEFAULT NULL,
                            vcharid IN NUMBER DEFAULT NULL,
                            orgz_id IN NUMBER DEFAULT NULL )
	Return VARCHAR2;

function Q_Po_Lines ( Elmt_tab qa_ss_const.var150_table,
                            plan_id_i IN NUMBER DEFAULT NULL,
                            vcharid IN NUMBER DEFAULT NULL,
                            orgz_id IN NUMBER DEFAULT NULL  )
	Return VARCHAR2;

function Q_Po_Release_Nums ( Elmt_tab qa_ss_const.var150_table,
                            plan_id_i IN NUMBER DEFAULT NULL,
                            vcharid IN NUMBER DEFAULT NULL,
                            orgz_id IN NUMBER DEFAULT NULL  )
	Return VARCHAR2;

function Q_Po_Shipments ( Elmt_tab qa_ss_const.var150_table,
                            plan_id_i IN NUMBER DEFAULT NULL,
                            vcharid IN NUMBER DEFAULT NULL,
                            orgz_id IN NUMBER DEFAULT NULL  )
	Return VARCHAR2;

function Q_Project ( Elmt_tab qa_ss_const.var150_table,
                            plan_id_i IN NUMBER DEFAULT NULL,
                            vcharid IN NUMBER DEFAULT NULL,
                            orgz_id IN NUMBER DEFAULT NULL  )
	Return VARCHAR2;

function Q_Receipt_Nums ( Elmt_tab qa_ss_const.var150_table,
                            plan_id_i IN NUMBER DEFAULT NULL,
                            vcharid IN NUMBER DEFAULT NULL,
                            orgz_id IN NUMBER DEFAULT NULL  )
	Return VARCHAR2;

function Q_Resource ( Elmt_tab qa_ss_const.var150_table,
                            plan_id_i IN NUMBER DEFAULT NULL,
                            vcharid IN NUMBER DEFAULT NULL,
                            orgz_id IN NUMBER DEFAULT NULL  )
	Return VARCHAR2;

function Q_Revision ( Elmt_tab qa_ss_const.var150_table,
                            plan_id_i IN NUMBER DEFAULT NULL,
                            vcharid IN NUMBER DEFAULT NULL,
                            orgz_id IN NUMBER DEFAULT NULL  )
	Return VARCHAR2;

function Q_Rma_Number ( Elmt_tab qa_ss_const.var150_table,
                            plan_id_i IN NUMBER DEFAULT NULL,
                            vcharid IN NUMBER DEFAULT NULL,
                            orgz_id IN NUMBER DEFAULT NULL  )
	Return VARCHAR2;

function Q_Serial_Number ( Elmt_tab qa_ss_const.var150_table,
                            plan_id_i IN NUMBER DEFAULT NULL,
                            vcharid IN NUMBER DEFAULT NULL,
                            orgz_id IN NUMBER DEFAULT NULL  )
	Return VARCHAR2;

function Q_Sales_Orders ( Elmt_tab qa_ss_const.var150_table,
                            plan_id_i IN NUMBER DEFAULT NULL,
                            vcharid IN NUMBER DEFAULT NULL,
                            orgz_id IN NUMBER DEFAULT NULL  )
	Return VARCHAR2;

function Q_Subinventory ( Elmt_tab qa_ss_const.var150_table,
                            plan_id_i IN NUMBER DEFAULT NULL,
                            vcharid IN NUMBER DEFAULT NULL,
                            orgz_id IN NUMBER DEFAULT NULL  )
	Return VARCHAR2;

function Q_To_Op_Seq_Num ( Elmt_tab qa_ss_const.var150_table,
                            plan_id_i IN NUMBER DEFAULT NULL,
                            vcharid IN NUMBER DEFAULT NULL,
                            orgz_id IN NUMBER DEFAULT NULL  )
	Return VARCHAR2;

function Q_UOM ( Elmt_tab qa_ss_const.var150_table,
                            plan_id_i IN NUMBER DEFAULT NULL,
                            vcharid IN NUMBER DEFAULT NULL,
                            orgz_id IN NUMBER DEFAULT NULL  )
	Return VARCHAR2;

function Q_Vendors ( Elmt_tab qa_ss_const.var150_table,
                            plan_id_i IN NUMBER DEFAULT NULL,
                            vcharid IN NUMBER DEFAULT NULL,
                            orgz_id IN NUMBER DEFAULT NULL )
	Return VARCHAR2;

function Q_Job ( Elmt_tab qa_ss_const.var150_table,
                            plan_id_i IN NUMBER DEFAULT NULL,
                            vcharid IN NUMBER DEFAULT NULL,
                            orgz_id IN NUMBER DEFAULT NULL  )
	Return VARCHAR2;

function Q_Task ( Elmt_tab qa_ss_const.var150_table,
                            plan_id_i IN NUMBER DEFAULT NULL,
                            vcharid IN NUMBER DEFAULT NULL,
                            orgz_id IN NUMBER DEFAULT NULL  )
	Return VARCHAR2;

function Q_Item ( Elmt_tab qa_ss_const.var150_table,
                            plan_id_i IN NUMBER DEFAULT NULL,
                            vcharid IN NUMBER DEFAULT NULL,
                            orgz_id IN NUMBER DEFAULT NULL  )
	Return VARCHAR2;
*/

	-- Define Package Global Variables
	-- GV stands for Global Variable
	  GV_Wip_Entity_Type NUMBER;
          GV_Wip_Rep_Sch_Id NUMBER;
          GV_Po_Header_Id NUMBER;
          GV_Po_Release_Id NUMBER;
          GV_Po_Line_Id NUMBER;
          GV_Line_Location_Id NUMBER;
          GV_Po_Distribution_Id NUMBER;
          GV_Organization_Id NUMBER;
          GV_Item_Id NUMBER;
          GV_Wip_Entity_Id NUMBER;
          GV_Wip_Line_Id NUMBER;
	  GV_Po_Shipment_Id NUMBER;
	  GV_Txn_Num NUMBER;
	  GV_Elmt_tab qa_ss_const.var150_table;

end qa_ss_lov;


 

/
