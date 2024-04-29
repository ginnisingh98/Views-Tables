--------------------------------------------------------
--  DDL for Package CAC_SR_UTIL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CAC_SR_UTIL_PVT" AUTHID CURRENT_USER as
/* $Header: cacsrutilvs.pls 120.1 2005/07/02 02:19:24 appldev noship $ */
function GET_OBJECT_NAME (
  P_OBJECT_TYPE in VARCHAR2,
  P_OBJECT_ID in NUMBER)
  RETURN VARCHAR2;

end CAC_SR_UTIL_PVT;

 

/
