--------------------------------------------------------
--  DDL for Package PA_TXN_INT_TRIG_CTL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_TXN_INT_TRIG_CTL" AUTHID CURRENT_USER as
/* $Header: PAXTRXSS.pls 120.1 2005/11/02 23:26:56 appldev ship $ */

Type NumTabTyp  is table of NUMBER(15)  index by binary_integer ;

expenditure_id      NumTabTyp ;
batch_name          pa_transaction_interface_all.batch_name%type; --added batch_name
--Bug 4552319
batch_name_tbl      pa_plsql_datatypes.char240TabTyp;


Idx           number  := 1    ;

T3_Trig       boolean := TRUE ;
T4_Trig       boolean := TRUE ;

G_TrxImport1  NUMBER DEFAULT NULL;
G_TrxImport2  NUMBER DEFAULT NULL;
G_UserTrxSrc1 varchar2(80);
G_TrxSrc1     varchar2(30);
G_TrxSrc2     varchar2(30);
G_UserTrxSrc2 varchar2(80);
G_TrxSrc3     varchar2(30);
G_SysLink1    varchar2(30);
G_TrxSrc4     varchar2(30);
G_UserTrxSrc3 varchar2(80);
G_SysLink2    varchar2(30);
G_TrxSrc5     varchar2(30);

end pa_txn_int_trig_ctl ;

 

/
