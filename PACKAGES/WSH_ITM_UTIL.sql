--------------------------------------------------------
--  DDL for Package WSH_ITM_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_ITM_UTIL" AUTHID CURRENT_USER AS
/* $Header: WSHUTITS.pls 120.0.12010000.3 2009/09/23 12:39:00 gbhargav ship $*/
--  Package
--      WSH_ITM_UTIL
--
--  Purpose
--      Spec of package WSH_ITM_UTIL. This package is used to determine the
--      services defined for a Master Organization,their additional country
--      codes and supports combination flag.
--  History
  --
  --

  TYPE CONTROL_ID_LIST IS TABLE OF NUMBER;

  -- Name (RECORD TYPE )
  --   Service_Rec_Type
  -- Purpose
  --   This record type stores three flags for dp, em and ld
  --  indicating whether they are required for a combination of
  --  appication Id and Master Organization.
  --  The addl_country_code columns will store the country codes
  --  against which the check for the particular service has to be
  --  done additionally.


  TYPE  Service_Rec_Type IS RECORD (
		service_type_code	         	WSH_ITM_VENDOR_SERVICES.SERVICE_TYPE%TYPE,
		addl_country_code             varchar2(5));


  TYPE Service_Tbl_Type IS TABLE OF Service_Rec_Type INDEX BY BINARY_INTEGER;

  -- Name
  --   GET_SERVICE_DETAILS
  --   Purpose
  --   On passing the p_application_id, p_master_organization_id and
  --   p_organization_id this procedure returns the services defined for
  --   user and the additional country codes for all the services.
  -- Arguments
  --   p_application_id               p_application_id of a request
  --   p_master_organization_id       p_master_organization_id of a request
  --   p_organization_id              p_organization_id of a request
  --   x_service_tbl                  service types and addl_country_codes
  --                                  returned as a PLSQL table Service_Rec_Type
  --   x_supports_combination_flag    A flag indicating whether a combined
  --                                  request for all the services returned
  --                                  by x_service_types_rec is supported or
  --                                  not.
  --   x_return_status                Return Status
  -- Notes
  --   Refer the record T_SERVICE_TYPES_REC


  PROCEDURE GET_SERVICE_DETAILS (
       p_application_id              IN  NUMBER,
       p_master_organization_id      IN  NUMBER,
       p_organization_id             IN  NUMBER,
       x_service_tbl                 OUT NOCOPY  Service_Tbl_Type,
       x_supports_combination_flag   OUT NOCOPY  VARCHAR2,
       x_return_status               OUT NOCOPY  VARCHAR2);


  -- Name
  --   UPDATE_PROCESS_FLAG
  --   Purpose
  --   To update the process_flag of a request.
  -- Arguments
  --   p_request_control_id        p_request_control_id of a request
  --   p_process_flag              process_flag value
  --   x_return_status             Return Status

  PROCEDURE UPDATE_PROCESS_FLAG (
       p_control_id_list             IN  CONTROL_ID_LIST,
       p_process_flag                IN  NUMBER,
       x_return_status               OUT NOCOPY  VARCHAR2);

  -- Name
  --   get vendor
  --   Purpose
  --   To get the Vendor name from the Request Control ID
  -- Arguments
  --   p_request_control_id        p_request_control_id of a request
  --   x_service_provider	   VendorName
  PROCEDURE GET_SERVICE_PROVIDER(
	p_request_control_id	IN NUMBER,
	x_service_provider	OUT NOCOPY VARCHAR2);

--Added in Bug 8916313
--===================================================================================================
   -- Start of comments
   --
   -- API Name          : GET_COMPLIANCE_STATUS
   -- Type              : Public
   -- Purpose           : Called by OM to get the ITM request control compliance status.
   -- Pre-reqs          : None
   -- Function          : This API can be used to get the compliance status of the ITM request control lines
   --                     In case if multiple request lines are present this will only return the first record
   --                     found with the matching i/p criteria
   --
   -- PARAMETERS        : p_appliciation_id                 i/p Appliciation id
   --                     p_original_sys_reference          i/p Original system reference
   --                     p_original_sys_line_reference     i/p Original system line reference
   --                     x_process_flag                    o/p compliance status.
   --                     x_request_control_id              o/p request_control_id ,
   --                     x_request_set_id                  o/p request_set_id  ,
   --                     x_return_status                   o/p return status
   -- VERSION          :  current version                   1.0
   --                     initial version                   1.0
   -- End of comments
--===================================================================================================

PROCEDURE  GET_COMPLIANCE_STATUS ( p_appliciation_id  IN NUMBER,
                            p_original_sys_reference  IN NUMBER,
                            p_original_sys_line_reference IN NUMBER,
                            x_process_flag  OUT NOCOPY NUMBER,
                            x_request_control_id OUT NOCOPY NUMBER,
                            x_request_set_id OUT NOCOPY NUMBER,
                            x_return_status OUT NOCOPY VARCHAR2);


END WSH_ITM_UTIL;

/
