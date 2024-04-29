--------------------------------------------------------
--  DDL for Package IEM_ROUTE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEM_ROUTE_PUB" AUTHID CURRENT_USER AS
/* $Header: iemprous.pls 120.1 2006/03/23 02:08:40 pkesani noship $ */

/*GLOBAL VARIABLES AVAILABLE TO THE PUBLIC FOR CALLING
  ===================================================*/

  --The record type for passing in Key-Value pairs
  TYPE keyVals_rec_type is RECORD (
--    key     iem_route_rules.key_type_code%type,
--    value   iem_route_rules.value%type,
    key     VARCHAR2(30),
    value   VARCHAR2(2000),
    datatype varchar2(1));

  --Table of Key-Values
  TYPE keyVals_tbl_type is TABLE OF keyVals_rec_type INDEX BY BINARY_INTEGER;


  --Main Public method
  PROCEDURE route(
  p_api_version_number  IN Number,
  p_init_msg_list       IN VARCHAR2 := NULL,
  p_commit              IN VARCHAR2 := NULL,
  p_keyVals_tbl         IN keyVals_tbl_type,
  p_accountId           IN Number,
  x_groupId             OUT NOCOPY Number,
  x_return_status       OUT NOCOPY VARCHAR2,
  x_msg_count           OUT NOCOPY NUMBER,
  x_msg_data            OUT NOCOPY VARCHAR2);

   function get_key_value (   p_keyVals_tbl IN keyVals_tbl_type,
                              p_key_name IN VARCHAR2 )
   return VARCHAR2;

END IEM_ROUTE_PUB;

 

/
