--------------------------------------------------------
--  DDL for Package Body INVP_CMERGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INVP_CMERGE" as
    /* $Header: invcm3b.pls 120.1 2005/07/01 13:12:48 appldev ship $ */
    procedure MERGE (req_id NUMBER, set_num NUMBER, process_mode VARCHAR2) is
    begin
  	  INVP_cmerge_txhi.merge(req_id, set_num, process_mode);
          INVP_cmerge_spdm.merge(req_id, set_num, process_mode);
    end MERGE;
end INVP_CMERGE;

/
