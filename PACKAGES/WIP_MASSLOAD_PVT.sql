--------------------------------------------------------
--  DDL for Package WIP_MASSLOAD_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WIP_MASSLOAD_PVT" AUTHID CURRENT_USER as
 /* $Header: wipmlpvs.pls 120.0.12000000.1 2007/01/18 22:17:54 appldev ship $ */


  procedure processWJSI(p_rowid        in rowid,
                        x_returnStatus out nocopy varchar2,
                        x_errorMsg     out nocopy varchar2);

end wip_massload_pvt;

 

/
