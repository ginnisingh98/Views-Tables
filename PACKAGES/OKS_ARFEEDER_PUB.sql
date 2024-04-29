--------------------------------------------------------
--  DDL for Package OKS_ARFEEDER_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKS_ARFEEDER_PUB" AUTHID CURRENT_USER AS
/* $Header: OKSPARFS.pls 120.0.12000000.1 2007/01/16 22:04:59 appldev ship $ */

G_EXCEPTION_BILLING EXCEPTION;

G_SUM   CONSTANT NUMBER := 1;
G_DET   CONSTANT NUMBER := 2;
G_SOURCE_NAME CONSTANT VARCHAR2(20) := 'OKS CONTRACTS';
G_LINE_TYPE   CONSTANT VARCHAR2(20) := 'LINE';
G_QTY   CONSTANT NUMBER := 1;
G_ADVANCE   CONSTANT Varchar2(10) := '-2' ;

G_LSE_ID_FOR_USAGE  CONSTANT NUMBER := 12;
G_LSE_ID_FOR_SUBSCR CONSTANT NUMBER := 46;

G_INIT_RAIL_REC RA_INTERFACE_LINES%ROWTYPE;
G_RAIL_REC RA_INTERFACE_LINES_ALL%ROWTYPE;
G_INIT_RAISC_REC RA_INTERFACE_SALESCREDITS%ROWTYPE;
G_RAISC_REC   AR_InterfaceSalesCredits_GRP.salescredit_rec_type;
G_EXCEPTION_HALT_VALIDATION EXCEPTION;

--Start Fix for bug#4198616
G_LOG_YES_NO Varchar2(10);
--End Fix for bug#4198616

  PROCEDURE Get_REC_FEEDER
  (
    X_RETURN_STATUS           OUT    NOCOPY    VARCHAR2,
    X_MSG_COUNT               OUT    NOCOPY    NUMBER,
    X_MSG_DATA                OUT    NOCOPY    VARCHAR2,
    P_FLAG                    IN               NUMBER, -- 1 sales_group_id col present else not
    P_CALLED_FROM             IN               NUMBER,
    P_DATE		      IN               DATE,
    P_CLE_ID                  IN               NUMBER,
    P_PRV                     IN               NUMBER,
    P_BILLREP_TBL             IN OUT NOCOPY OKS_BILL_REC_PUB.bill_report_tbl_type,
    P_BILLREP_TBL_IDX         IN               NUMBER,
    P_BILLREP_ERR_TBL         IN OUT NOCOPY OKS_BILL_REC_PUB.billrep_error_tbl_type,
    P_BILLREP_ERR_TBL_IDX     IN OUT NOCOPY    NUMBER
  );



END OKS_ARFEEDER_PUB;

 

/
