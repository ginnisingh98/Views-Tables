--------------------------------------------------------
--  DDL for Package CCT_CALLCENTER_UTIL_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CCT_CALLCENTER_UTIL_PUB" AUTHID CURRENT_USER as
/* $Header: cctcutls.pls 120.0 2005/06/02 10:05:33 appldev noship $ */

G_MIDDLEWARE_NOT_FOUND NUMBER:=-1;

Procedure getMiddlewareParam(p_resource_id IN Number Default Null,
                             x_middleware_id IN out nocopy Number,
                             x_param_value out nocopy CCT_KEYVALUE_VARR);

Procedure getDialableNumber(p_resource_id IN Number,
                            p_country_code In Number,
                            p_area_code IN Number,
                            p_localNumber In Number,
                            x_dialableNumber out nocopy Number);

End CCT_CALLCENTER_UTIL_PUB;

 

/
