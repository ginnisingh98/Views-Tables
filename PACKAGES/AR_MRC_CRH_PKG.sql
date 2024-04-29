--------------------------------------------------------
--  DDL for Package AR_MRC_CRH_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_MRC_CRH_PKG" AUTHID CURRENT_USER AS
/* $Header: ARPLMRCS.pls 120.2 2005/10/30 04:24:40 appldev ship $ */
    TYPE t_crh_id       IS TABLE OF NUMBER(15)    INDEX BY BINARY_INTEGER;
    TYPE t_rec_app_id	IS TABLE OF NUMBER(15)    INDEX BY BINARY_INTEGER;
    TYPE t_status	IS TABLE OF VARCHAR2(30)  INDEX BY BINARY_INTEGER;
    TYPE t_matched	IS TABLE OF VARCHAR2(1)   INDEX BY BINARY_INTEGER;
    TYPE t_acctd_from	IS TABLE OF NUMBER	  INDEX BY BINARY_INTEGER;

    p_prv_crh_id	t_crh_id;
    p_last_rec_app_id	t_rec_app_id;
    p_status		t_status;
    p_matched		t_matched;
    p_acctd_from	t_acctd_from;

END ar_mrc_crh_pkg;

 

/
