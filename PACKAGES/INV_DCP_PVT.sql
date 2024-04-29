--------------------------------------------------------
--  DDL for Package INV_DCP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_DCP_PVT" AUTHID CURRENT_USER as
/* $Header: INVDCPPS.pls 120.5 2006/07/05 19:08:23 anverma noship $ */


--Whenever DCP code starts debugger, this global is set.
--Value of Y means debug is started
--Value of R means debug is reset.
G_DEBUG_STARTED VARCHAR2(1):= 'N';

G_CHECK_DCP NUMBER :=null;

G_EMAIL_SERVER VARCHAR2(32767);
G_EMAIL_ADDRESS VARCHAR2(32767);

TYPE g_dc_rec_type IS RECORD(
                             trx_hdr_id VARCHAR2(100),
                             dcp_script varchar2(2),
                             msg varchar2(2000),
                             trx_temp_id NUMBER,
                             trx_type VARCHAR2(200),
                             source_type VARCHAR2(200),
                             Action_code VARCHAR2(200),
                             Organization_code VARCHAR2(200),
                             xfer_org_code VARCHAR2(200),
                             item_name VARCHAR2(2000));

TYPE g_dc_tbl_type IS TABLE OF g_dc_rec_type INDEX BY BINARY_INTEGER;

g_dc_table g_dc_tbl_type;

--Table for Action/Serial Status
TYPE g_ser_action_rec IS RECORD(serial_status NUMBER);
TYPE g_ser_status_type IS TABLE OF g_ser_action_rec INDEX BY BINARY_INTEGER;
g_ser_check_tab g_ser_status_type;

--This is the exception raised by outer-level DCP procedures and is used
--by callers like delivery-detail and delivery group APIs, ITS code etc.
data_inconsistency_exception EXCEPTION;

dcp_caught EXCEPTION;

Procedure Send_Mail(sender IN VARCHAR2 DEFAULT NULL,
                    recipient1 IN VARCHAR2 DEFAULT NULL,
                    recipient2 IN VARCHAR2 DEFAULT NULL,
                    recipient3 IN VARCHAR2 DEFAULT NULL,
                    recipient4 IN VARCHAR2 DEFAULT NULL,
                    message IN VARCHAR2);

Procedure Validate_data(p_dcp_event IN VARCHAR2,
                        p_trx_hdr_id IN VARCHAR2,
                        p_temp_id IN NUMBER,
		        p_batch_id IN NUMBER,
                        p_raise_exception IN VARCHAR2 DEFAULT 'N',
			x_return_status OUT NOCOPY VARCHAR2);

Procedure Check_Scripts(p_action_code IN VARCHAR2 ,
                        p_trx_hdr_id IN NUMBER DEFAULT NULL,
                        p_trx_temp_id IN NUMBER DEFAULT NULL,
                        p_batch_id IN NUMBER DEFAULT NULL);

PROCEDURE Post_Process(p_action_code IN VARCHAR2 DEFAULT NULL,
                       p_raise_exception IN VARCHAR2 DEFAULT 'Y');

FUNCTION Is_dcp_enabled RETURN NUMBER;

FUNCTION add_serial_data(trx_qty IN NUMBER,
                         serial_control_code IN NUMBER,
                         xfer_org NUMBER,
                         inv_item_id NUMBER
                        ) RETURN BOOLEAN;

Procedure dump_mmtt;

END INV_DCP_PVT;

 

/
