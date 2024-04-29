--------------------------------------------------------
--  DDL for Package BIS_RSG_PUB_APIS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIS_RSG_PUB_APIS_PKG" AUTHID CURRENT_USER AS
/* $Header: BISRSPAS.pls 120.0 2005/10/17 15:26:45 slowe noship $ */
  TYPE BIS_RSG_CONTENT_INFO IS RECORD(
    Name varchar2(480),
    Type varchar2(30)
  );
  TYPE BIS_RSG_CONTENT_LIST IS TABLE OF BIS_RSG_CONTENT_INFO;

  -- Return the name of the request set of which this request is the root
  -- if not found then return null and set appropriate errcode
  Function Get_RS_Name ( p_root_request_id in number,errbuf out NOCOPY varchar2,
                                  errcode out NOCOPY varchar2) return varchar2;

  -- Return the name of the request set of which this request is part of
  -- if not found then return null and set appropriate errcode
  Function Get_Current_RS_Name ( errbuf out NOCOPY varchar2,
                                  errcode out NOCOPY varchar2) return varchar2;

  -- Return the refresh mode of the request set
  -- if not found then return null and set appropriate errcode
  Function Get_RS_Refresh_mode (p_req_set_name IN varchar2, errbuf out NOCOPY varchar2,
                                  errcode out NOCOPY varchar2) return varchar2;

  -- Return the refresh mode of the request set of which this request is part of
  -- if not found then return null and set appropriate errcode
  Function Get_Current_RS_Refresh_mode (errbuf out NOCOPY varchar2,
                                        errcode out NOCOPY varchar2) return varchar2;

  -- populate p_content_list with the list of contents of the request set
  -- if not found then set appropriate errcode (overloaded)
  Procedure Get_content_in_RS( p_req_set_name IN varchar2, p_content_list OUT NOCOPY BIS_RSG_CONTENT_LIST,
                               errbuf out NOCOPY varchar2, errcode out NOCOPY varchar2);

  -- populate p_page_list with the list of page of the request set
  -- if not found then set appropriate errcode
  Procedure Get_pages_in_RS ( p_req_set_name IN varchar2, p_page_list out nocopy BIS_RSG_CONTENT_LIST,
                              errbuf out NOCOPY varchar2, errcode out NOCOPY varchar2);
  -- populate p_page_list with the list of page of the request set of which this request is a part of
  -- if not found then set appropriate errcode
  Procedure Get_pages_in_current_RS( p_page_list out nocopy BIS_RSG_CONTENT_LIST,
                              errbuf out NOCOPY varchar2, errcode out NOCOPY varchar2);

  -- populate p_report_list with the list of report of the request set
  -- if not found then set appropriate errcode
  Procedure Get_reports_in_RS ( p_req_set_name IN varchar2, p_report_list out nocopy BIS_RSG_CONTENT_LIST,
                              errbuf out NOCOPY varchar2, errcode out NOCOPY varchar2);
  -- populate p_report_list with the list of report of the request set of which this request is a part of
  -- if not found then set appropriate errcode
  Procedure Get_reports_in_current_RS( p_report_list out nocopy BIS_RSG_CONTENT_LIST,
                              errbuf out NOCOPY varchar2, errcode out NOCOPY varchar2);

  /*
    List of error codes return by the APIS
    BIS_RSG_NO_RS_FOUND - In case we don't any data for this request set in our table/wrong req id is given
    BIS_RSG_SUCCESS     - api is successful
    BIS_RSG_ERR_UNEXPECTED - some unexpected error occurred
    BIS_RSG_RS_NO_REF_MODE - in case the the refresh mode option is nulll for request set
                           - like in case of Gather Statistics request set
    BIS_RSG_NO_RS_STANDALONE - There is no request set associated with the request id. This is a standalone request.
  */
end BIS_RSG_PUB_APIS_PKG;

 

/
