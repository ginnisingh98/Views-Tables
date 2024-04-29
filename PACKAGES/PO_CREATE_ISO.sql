--------------------------------------------------------
--  DDL for Package PO_CREATE_ISO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_CREATE_ISO" AUTHID CURRENT_USER AS
/* $Header: POXCISOS.pls 120.1 2005/06/29 10:58:24 pbamb noship $*/
PROCEDURE LOAD_OM_INTERFACE
(
  errbuf  	out NOCOPY   	varchar2,
  retcode 	out	NOCOPY number,
  p_req_header_id in 	number default null
);

PROCEDURE GET_OPUNIT_DETAILS
(
  l_op_unit_id   in     number,
  l_error_flag   in out NOCOPY varchar2,
  l_currency_code out NOCOPY   varchar2,
  l_ot_id        out NOCOPY    number,
  l_pr_id        out NOCOPY    number,
  l_ac_id        out NOCOPY    number,
  l_ir_id        out NOCOPY    number
);

--
-- OPM INVCONV  umoogala  Process-Discrete Transfers Enh.
-- Added 4th and 5th parameter.
-- Source and Destination orgs will be used to determine whether
-- transfer is between process and discrete mfg orgs. If yes,
-- then get transfer price.
-- For process-to-process get unit price
-- For discrete-to-discrete: no change. should work as is.
--
FUNCTION GET_CST_PRICE
(
  x_item_id              in number,
  x_organization_id      in number,
  x_unit_of_measure      in varchar2,
  x_dest_organization_id in number,
  x_quantity             in number)
RETURN number;


END PO_CREATE_ISO;

 

/
