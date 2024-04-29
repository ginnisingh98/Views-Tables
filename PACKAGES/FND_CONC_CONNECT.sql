--------------------------------------------------------
--  DDL for Package FND_CONC_CONNECT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_CONC_CONNECT" AUTHID CURRENT_USER as
/* $Header: AFCPUTOS.pls 120.2 2005/08/20 20:25:23 pferguso ship $ */

--
  --
  -- Name
  --   srs_url
  -- Purpose
  --  Returns OA Framework Url and cookie information
  --  Set the cookie before launching url
  -- Parameters
  --   function_name Name of function you want to launch, if no function name
  --                 is passed then it will use FNDCPSRSSSWA as default
  --   parameters parameters to the function
  --  rest of the parameters are out.
  --   c_name Cookie Name
  --   domain Domain name
  --   c_value Cookie value
  --   oa_url  Url string to launch

  procedure srs_url(function_name in     varchar2 default null,
                    c_name        in out nocopy varchar2,
                    c_domain      in out nocopy varchar2,
                    c_value       in out nocopy varchar2,
                    oa_url        in out nocopy varchar2,
                    parameters    in     varchar2 default null);

 end FND_CONC_CONNECT;

 

/
