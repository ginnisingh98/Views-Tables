--------------------------------------------------------
--  DDL for Package WMS_OPM_INTEGRATION_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WMS_OPM_INTEGRATION_GRP" AUTHID CURRENT_USER AS
/* $Header: WMSOPMS.pls 120.3 2005/08/29 08:02:02 simran noship $ */

PROCEDURE PROCESS_RESPONSE
                (p_device_id           IN  NUMBER,
                 p_request_id          IN  NUMBER,
                 p_param_values_record IN  WMS_WCS_DEVICE_GRP.MSG_COMPONENT_LOOKUP_TYPE,
                 x_return_status       OUT NOCOPY VARCHAR2,
                 x_msg_count           OUT NOCOPY NUMBER,
                 x_msg_data            OUT NOCOPY VARCHAR2);


END WMS_OPM_INTEGRATION_GRP;

 

/
