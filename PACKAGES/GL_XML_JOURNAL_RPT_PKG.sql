--------------------------------------------------------
--  DDL for Package GL_XML_JOURNAL_RPT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_XML_JOURNAL_RPT_PKG" AUTHID CURRENT_USER AS
/* $Header: glumlrxs.pls 120.1 2005/12/02 19:54:27 spala noship $ */





Function Net_Line_Balance (P_ACCT_SEG_WHERE  VARCHAR2,
                       P_STATUS         VARCHAR2,
                       P_START_DATE     DATE,
                       P_CURRENCY       VARCHAR2,
                       P_LED_ID         NUMBER,
                       P_BAL_SEG_NAME   VARCHAR2,
                       P_BAL_SEG_VAL    VARCHAR2,
                       P_ACCT_SEG_NAME  VARCHAR2,
                       P_ACCT_SEG_VAL   VARCHAR2,
                       P_SEC_SEG_NAME   VARCHAR2,
                       P_SEC_SEG_VAL    VARCHAR2) RETURN NUMBER;

 Function Net_Begin_Balance (P_ACCT_SEG_WHERE  VARCHAR2,
                       P_STATUS         VARCHAR2,
                       P_START_DATE     DATE,
                       P_CURRENCY       VARCHAR2,
                       P_LED_ID         NUMBER,
                       P_BAL_SEG_NAME   VARCHAR2,
                       P_BAL_SEG_VAL    VARCHAR2,
                       P_ACCT_SEG_NAME  VARCHAR2,
                       P_ACCT_SEG_VAL   VARCHAR2,
                       P_SEC_SEG_NAME   VARCHAR2,
                       P_SEC_SEG_VAL    VARCHAR2) RETURN NUMBER;

FUNCTION Get_Contra_Account(P_Account_Select VARCHAR2,
                            p_Header_id   NUMBER,
                            P_Sub_Doc_Seq_Id NUMBER,
                            P_Sub_Doc_SEq_Val VARCHAR2,
                            p_Accounted_Dr NUMBER,
                            P_Accounted_Cr NUMBER) RETURN VARCHAR2;

type var_t is record (prev_type VARCHAR2(50),
			header_id_prev NUMBER,
			sub_doc_sequence_id_prev NUMBER,
			sub_doc_sequence_value_prev NUMBER,
                        contra_account_name_prev        varchar2(240),
                        bal_seg_val_prev   VARCHAR2(30),
                        acct_seg_val_prev  VARCHAR2(30),
                        sec_seg_val_prev   VARCHAR2(30),
                        ledger_id_prev     NUMBER,
                        line_balance_prev  NUMBER,
                        begin_balance_prev NUMBER);

var var_t;

END GL_XML_JOURNAL_RPT_PKG;

 

/
