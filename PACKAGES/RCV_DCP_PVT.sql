--------------------------------------------------------
--  DDL for Package RCV_DCP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."RCV_DCP_PVT" AUTHID CURRENT_USER AS
  /* $Header: INVRDCPS.pls 120.4 2006/08/21 14:31:33 amohamme noship $ */


  --Whenever DCP code starts debugger, this global is set.
  --Value of Y means debug is started
  --Value of R means debug is reset.
  g_check_dcp NUMBER :=null;
  g_debug_started              VARCHAR2(1)     := 'N';

  g_email_server               VARCHAR2(32767);
  g_email_address              VARCHAR2(32767);
  g_fnd_debug_enabled          VARCHAR2(240);
  g_fnd_debug_level            VARCHAR2(240);
  g_fnd_debug_module           VARCHAR2(240);
  g_fnd_debug_mode             VARCHAR2(240);
  g_po_en_sql_trace            VARCHAR2(240);
  g_inv_debug_enabled 	       VARCHAR2(240);
  g_inv_debug_file 	       VARCHAR2(240);
  g_inv_debug_level 	       VARCHAR2(240);
  g_rcv_debug_enabled 	       VARCHAR2(240);
  g_file_name     	       VARCHAR2(240);

  TYPE g_dc_rec_type IS RECORD(
    header_interface_id      NUMBER
  , interface_transaction_id NUMBER
  , dcp_script                 VARCHAR2(3)
  , msg                        VARCHAR2(2000)
  , shipment_header_id         NUMBER
  , shipment_line_id           NUMBER
  , rhi_receipt_header_id      NUMBER
  , mmt_transaction_id         NUMBER
  , rt_transaction_id          NUMBER
  , oel_line_id                NUMBER
  , moh_header_id              NUMBER
  , mol_line_id                NUMBER
  , msn_serial_number          VARCHAR(30)
  , txn_type                   VARCHAR2(30)
  , to_organization_code       VARCHAR2(200)
  , from_organization_code     VARCHAR2(200)
  , item_name                  VARCHAR2(2000)
  , oel_flow_status_code       VARCHAR2(30)
  , rhi_processing_status_code VARCHAR2(25)
  , rhi_receipt_source_code    VARCHAR2(25)
  , rhi_asn_type 	       VARCHAR2(25)
  , rhi_creation_date 	       DATE
  , rsh_asn_type               VARCHAR2(25)
  , msn_last_update_date       DATE
  , msn_current_status 	       NUMBER
  , wlpn_lpn_context 	       NUMBER
  );

  TYPE g_dc_tbl_type IS TABLE OF g_dc_rec_type
    INDEX BY BINARY_INTEGER;

  g_dc_table                   g_dc_tbl_type;
  --This is the exception raised by outer-level DCP procedures and is used
  --by callers like RCV preprocessor and processor
  data_inconsistency_exception EXCEPTION;
  dcp_caught                   EXCEPTION;

  PROCEDURE send_mail(
    sender     IN VARCHAR2 DEFAULT NULL
  , recipient1 IN VARCHAR2 DEFAULT NULL
  , recipient2 IN VARCHAR2 DEFAULT NULL
  , recipient3 IN VARCHAR2 DEFAULT NULL
  , recipient4 IN VARCHAR2 DEFAULT NULL
  , MESSAGE    IN VARCHAR2
  );

  PROCEDURE switch_debug(
    p_action IN VARCHAR2
  , p_file_name OUT NOCOPY VARCHAR2
  );

  PROCEDURE validate_data(
    p_dcp_event                IN            VARCHAR2
--  , p_header_interface_id    IN            NUMBER DEFAULT NULL
  , p_request_id 	       IN  	     NUMBER DEFAULT NULL
  , p_group_id 		       IN  	     NUMBER DEFAULT NULL
  , p_interface_transaction_id IN            NUMBER DEFAULT NULL
  , p_lpn_group_id 	       IN            NUMBER DEFAULT NULL
  , p_raise_exception          IN            VARCHAR2 DEFAULT 'N'
  , x_return_status            OUT NOCOPY    VARCHAR2
  );

  PROCEDURE check_scripts(
    p_action_code              IN VARCHAR2
  , p_header_interface_id      IN NUMBER DEFAULT NULL
  , p_interface_transaction_id IN NUMBER DEFAULT NULL
  );

  PROCEDURE post_process(p_action_code IN VARCHAR2 DEFAULT NULL, p_raise_exception IN VARCHAR2 DEFAULT 'Y');

  FUNCTION is_dcp_enabled
    RETURN NUMBER;
END rcv_dcp_pvt;

 

/
