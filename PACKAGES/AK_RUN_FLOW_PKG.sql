--------------------------------------------------------
--  DDL for Package AK_RUN_FLOW_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AK_RUN_FLOW_PKG" AUTHID CURRENT_USER as
/* $Header: akdrunfs.pls 115.2 99/07/17 15:19:52 porting s $ */
procedure GET_ATTRIBUTE_LIST_VALUES (
  X_TRACE_NUM                  in NUMBER,
  X_REGION_APPLICATION_ID      in NUMBER,
  X_REGION_CODE                in VARCHAR2
);
end AK_RUN_FLOW_PKG;

 

/
