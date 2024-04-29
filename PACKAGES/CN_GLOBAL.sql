--------------------------------------------------------
--  DDL for Package CN_GLOBAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_GLOBAL" AUTHID CURRENT_USER AS
-- $Header: cnsygls.pls 120.0.12010000.3 2009/05/14 05:53:43 rajukum ship $


    -- Global system constants

    yes 		CONSTANT CHAR	:= 'Y';
    no			CONSTANT CHAR	:= 'N';

    ra_system_id	CONSTANT NUMBER := 1;
    ar_system_id	CONSTANT NUMBER := 2;
    oe_system_id	CONSTANT NUMBER := 3;

    col_event_id	CONSTANT	NUMBER := -1000;
    cls_event_id	CONSTANT	NUMBER := -1001;
    inv_event_id	CONSTANT	NUMBER := -1002;
    ord_event_id	CONSTANT	NUMBER := -1003;
    pmt_event_id	CONSTANT	NUMBER := -1004;
    wo_event_id 	CONSTANT	NUMBER := -1005;
    gbk_event_id	CONSTANT	NUMBER := -1006;
    cm_event_id 	CONSTANT	NUMBER := -1007;
    cbk_event_id	CONSTANT	NUMBER := -1008;
    ram_event_id        CONSTANT	NUMBER := -1010;
    aia_event_id	CONSTANT	NUMBER := -1020;
    aia_om_event_id	CONSTANT	NUMBER := -1030;

    trx_batch_size	CONSTANT	NUMBER := 2000;
    col_batch_size	CONSTANT	NUMBER := 2000;
    xfer_batch_size	CONSTANT	NUMBER := 2000;
    cls_batch_size	CONSTANT	NUMBER := 2000;

--  system_start_date	CONSTANT	DATE := '01-JAN-92';
    cbk_grace_period	CONSTANT	NUMBER := 30;

    release_number	CONSTANT	VARCHAR2(20) := '10.6';

    invoices_enabled	CONSTANT	VARCHAR2(1) := 'Y';
    orders_enabled	CONSTANT	VARCHAR2(1) := 'Y';
    payments_enabled	CONSTANT	VARCHAR2(1) := 'Y';
    writeoffs_enabled	CONSTANT	VARCHAR2(1) := 'Y';
    givebacks_enabled	CONSTANT	VARCHAR2(1) := 'Y';
    creditmemos_enabled CONSTANT	VARCHAR2(1) := 'Y';
    clawbacks_enabled	CONSTANT	VARCHAR2(1) := 'Y';
    aia_enabled	        CONSTANT	VARCHAR2(1) := 'Y';
    aia_om_enabled	CONSTANT	VARCHAR2(1) := 'Y';

END cn_global;

/
