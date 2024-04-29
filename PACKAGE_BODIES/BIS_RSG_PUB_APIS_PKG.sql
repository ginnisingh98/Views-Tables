--------------------------------------------------------
--  DDL for Package Body BIS_RSG_PUB_APIS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIS_RSG_PUB_APIS_PKG" AS
/* $Header: BISRSPAB.pls 120.2 2005/12/07 08:53:38 amitgupt noship $ */
  /*
    List of error codes return by the APIS
    BIS_RSG_NO_RS_FOUND - In case we don't have any data for this request set in our table/wrong req id is given
    BIS_RSG_SUCCESS     - api is successful
    BIS_RSG_ERR_UNEXPECTED - some unexpected error occurred
    BIS_RSG_RS_NO_REF_MODE - in case the the refresh mode option is nulll for request set
                           - like in case of Gather Statistics request set
    BIS_RSG_NO_RS_STANDALONE - There is no request set associated with the request id. This is a standalone request.
    BIS_RSG_NO_RSDATA_FOUND - There is no data for the request set.
  */
   Function Get_RS_Name (p_root_request_id in number, errbuf out NOCOPY varchar2,
                                  errcode out NOCOPY varchar2) return varchar2 IS
    CURSOR CV (req_id in number)IS
    select request_set_name from fnd_request_sets where request_set_id= req_id;

    CURSOR CV_ROOT(req_id in number) IS
    select
       req.argument2
     from
       fnd_concurrent_requests req
     where
       req.request_id = req_id and
       req_id=PRIORITY_REQUEST_ID
       and has_sub_request = 'Y';

    rs_name varchar2(30);
    rset_id  varchar2(20);
    nrset_id number;
  BEGIN
    rs_name := null;

    open cv_root( p_root_request_id);
    fetch cv_root into rset_id;
    if(CV_ROOT%NOTFOUND or rset_id is null) THEN
      fnd_message.set_name('BIS','BIS_RSG_INVALID_ROOT_ID');
      fnd_message.set_token('RSID',TO_CHAR(p_root_request_id));
      errbuf := FND_MESSAGE.GET;
      errcode := 'BIS_RSG_INVALID_ROOT_ID';
      close cv_root;
      return null;
    else
      BEGIN
         nrset_id := to_number(rset_id);
      EXCEPTION
        WHEN OTHERS THEN
          fnd_message.set_name('BIS','BIS_RSG_INVALID_ROOT_ID');
          fnd_message.set_token('RSID',TO_CHAR(p_root_request_id));
          errbuf := FND_MESSAGE.GET;
          errcode := 'BIS_RSG_INVALID_ROOT_ID';
          close cv_root;
          return null;
      END;
    end if;

    open cv(nrset_id);
    fetch cv into rs_name;
    if(CV%NOTFOUND) THEN
      fnd_message.set_name('BIS','BIS_RSG_NO_RS_FOUND');
      fnd_message.set_token('RSID',TO_CHAR(p_root_request_id));
      fnd_message.set_token('RSETID',rset_id);
      errbuf := FND_MESSAGE.GET;
      errcode := 'BIS_RSG_NO_RS_FOUND';
    else
      fnd_message.set_name('BIS','BIS_RSG_SUCCESS');
      errbuf := FND_MESSAGE.GET;
      errcode := 'BIS_RSG_SUCCESS';
    END IF;
    close cv;
    return rs_name;
  EXCEPTION
    WHEN OTHERS THEN
      errbuf := sqlerrm;
      errcode := 'BIS_RSG_ERR_UNEXPECTED';
      return null;
  END Get_RS_Name;

  -- Return the name of the request set of which this request is part of
  -- if not found then return null and set appropriate errcode
  Function Get_Current_RS_Name (errbuf out NOCOPY varchar2,
                                  errcode out NOCOPY varchar2) return varchar2 IS
     rs_name varchar2(30);
     l_request_id  number;
     l_root_request_id number;
  BEGIN
    rs_name := null;
    l_request_id := fnd_global.CONC_REQUEST_ID;
    l_root_request_id := fnd_global.CONC_PRIORITY_REQUEST;

    if(l_request_id = l_root_request_id) then
     fnd_message.set_name('BIS','BIS_RSG_NO_RS_STANDALONE');
     fnd_message.set_token('RSID',TO_CHAR(l_request_id));
     errbuf := FND_MESSAGE.GET;
     errcode := 'BIS_RSG_NO_RS_STANDALONE';
     return null;
    end if;

    rs_name := Get_RS_Name(l_root_request_id,errbuf,errcode);
    return rs_name;
  EXCEPTION
    WHEN OTHERS THEN
      errbuf := sqlerrm;
      errcode := 'BIS_RSG_ERR_UNEXPECTED';
      return null;
  END Get_Current_RS_Name;

  -- Return the refresh mode of the request set
  -- if not found then return null and set appropriate errcode
  Function Get_RS_Refresh_mode (p_req_set_name IN varchar2, errbuf out NOCOPY varchar2,
                                  errcode out NOCOPY varchar2) return varchar2 IS
  CURSOR CV(rs_name in varchar2) is
  SELECT OPTION_VALUE FROM BIS_REQUEST_SET_OPTIONS where
  OPTION_NAME='REFRESH_MODE' and REQUEST_SET_NAME=upper(rs_name)
  and set_app_id = 191;

  l_value varchar2(30);
  BEGIN
    l_value := null;
    open cv(p_req_set_name);
    fetch cv into l_value;
    if(CV%NOTFOUND) THEN
      fnd_message.set_name('BIS','BIS_RSG_NO_RSDATA_FOUND');
      fnd_message.set_token('RSNAME',p_req_set_name);
      errbuf := FND_MESSAGE.GET;
      errcode := 'BIS_RSG_NO_RSDATA_FOUND';
    elsif l_value is null then
      fnd_message.set_name('BIS','BIS_RSG_RS_NO_REF_MODE');
      fnd_message.set_token('RSNAME',p_req_set_name);
      errbuf := FND_MESSAGE.GET;
      errcode := 'BIS_RSG_RS_NO_REF_MODE';
    else
      fnd_message.set_name('BIS','BIS_RSG_SUCCESS');
      errbuf := FND_MESSAGE.GET;
      errcode := 'BIS_RSG_SUCCESS';
    END IF;
    close cv;
    return l_value;
  EXCEPTION
    WHEN OTHERS THEN
      errbuf := sqlerrm;
      errcode := 'BIS_RSG_ERR_UNEXPECTED';
      return null;
  END Get_RS_Refresh_mode;

  -- Return the refresh mode of the request set of which this request is part of
  -- if not found then return null and set appropriate errcode
  Function Get_Current_RS_Refresh_mode (errbuf out NOCOPY varchar2,
                                        errcode out NOCOPY varchar2) return varchar2 IS
    rs_name varchar2(30);
    l_value varchar2(30);
  BEGIN
    --get the name of the current request set
    rs_name := Get_Current_RS_Name(errbuf,errcode);
    if(rs_name is null) then
      return null;
    end if;

    l_value := Get_RS_Refresh_mode(rs_name,errbuf,errcode);
    return l_value;
  END;

  -- populate p_content_list with the list of contents of the request set
  -- if not found then set appropriate errcode
  -- possible values of p_content_type
  -- 'PAGE'  to get the list pf pages in this request set
  -- 'REPORT' to get the list of reports in this request set
  --  nulll to get all the contents of this request set
  Procedure Get_content_in_RS( p_req_set_name IN varchar2, p_content_list OUT NOCOPY BIS_RSG_CONTENT_LIST,
                               p_content_type IN VARCHAR2,errbuf out NOCOPY varchar2,
                               errcode out NOCOPY varchar2) IS
  CURSOR CV (rs_name IN varchar2) IS
  select object_name,object_type from bis_request_set_objects
  where request_set_name = upper(rs_name) and set_app_id = 191;

  CURSOR CV_TYPE (rs_name in varchar2, con_type in varchar2) IS
  select object_name,object_type from bis_request_set_objects
  where request_set_name = upper(rs_name) and object_type = con_type and set_app_id = 191;
  i number;
  BEGIN
     i := 0;
     p_content_list := BIS_RSG_CONTENT_LIST();
     if(p_content_type is null) then
        FOR cv_rec in cv(p_req_set_name) loop
          i:=i+1;
          p_content_list.extend;
          p_content_list(i).name := cv_rec.object_name;
          p_content_list(i).type := cv_rec.object_type;
        End loop;
     else
        FOR cv_rec in cv_type(p_req_set_name,p_content_type) loop
          i:=i+1;
          p_content_list.extend;
          p_content_list(i).name := cv_rec.object_name;
          p_content_list(i).type := cv_rec.object_type;
        End loop;
     end if;

     if(i=0 and p_content_type is null) THEN
       fnd_message.set_name('BIS','BIS_RSG_NO_CONTENT_FOUND');
       fnd_message.set_token('RSNAME',p_req_set_name);
       errbuf := FND_MESSAGE.GET;
       errcode := 'BIS_RSG_NO_CONTENT_FOUND';
     elsif(i=0 and p_content_type ='REPORT') THEN
       fnd_message.set_name('BIS','BIS_RSG_NO_REPORT_FOUND');
       fnd_message.set_token('RSNAME',p_req_set_name);
       errbuf := FND_MESSAGE.GET;
       errcode := 'BIS_RSG_NO_REPORT_FOUND';
     elsif(i=0 and p_content_type ='PAGE') THEN
       fnd_message.set_name('BIS','BIS_RSG_NO_PAGE_FOUND');
       fnd_message.set_token('RSNAME',p_req_set_name);
       errbuf := FND_MESSAGE.GET;
       errcode := 'BIS_RSG_NO_PAGE_FOUND';
     else
       fnd_message.set_name('BIS','BIS_RSG_SUCCESS');
       errbuf := FND_MESSAGE.GET;
       errcode := 'BIS_RSG_SUCCESS';
     end if;
  EXCEPTION
    WHEN OTHERS THEN
      errbuf := sqlerrm;
      errcode := 'BIS_RSG_ERR_UNEXPECTED';
  END;

  -- populate p_content_list with the list of contents of the request set
  -- if not found then set appropriate errcode (overloaded)
  Procedure Get_content_in_RS( p_req_set_name IN varchar2, p_content_list OUT NOCOPY BIS_RSG_CONTENT_LIST,
                               errbuf out NOCOPY varchar2, errcode out NOCOPY varchar2) IS
  BEGIN
    Get_content_in_RS(p_req_set_name,p_content_list,NULL,errbuf,errcode);
  END;

  -- populate p_page_list with the list of page of the request set
  -- if not found then set appropriate errcode
  Procedure Get_pages_in_RS ( p_req_set_name IN varchar2, p_page_list out nocopy BIS_RSG_CONTENT_LIST,
                              errbuf out NOCOPY varchar2, errcode out NOCOPY varchar2) IS
  BEGIN
   Get_content_in_RS(p_req_set_name,p_page_list,'PAGE',errbuf,errcode);
  END;

  -- populate p_page_list with the list of page of the request set of which this request is a part of
  -- if not found then set appropriate errcode
  Procedure Get_reports_in_RS ( p_req_set_name IN varchar2, p_report_list out nocopy BIS_RSG_CONTENT_LIST,
                              errbuf out NOCOPY varchar2, errcode out NOCOPY varchar2) IS
  BEGIN
   Get_content_in_RS(p_req_set_name,p_report_list,'REPORT',errbuf,errcode);
  END;

  -- populate p_report_list with the list of report of the request set
  -- if not found then set appropriate errcode
  Procedure Get_pages_in_current_RS(  p_page_list out nocopy BIS_RSG_CONTENT_LIST,
                              errbuf out NOCOPY varchar2, errcode out NOCOPY varchar2)IS
    rs_name varchar2(30);
  BEGIN
    --get the name of the current request set
    rs_name := Get_Current_RS_Name(errbuf,errcode);
    if(rs_name is not null) then
      Get_content_in_RS(rs_name,p_page_list,'PAGE',errbuf,errcode);
    end if;
  END;

  -- populate p_report_list with the list of report of the request set of which this request is a part of
  -- if not found then set appropriate errcode
  Procedure Get_reports_in_current_RS( p_report_list out nocopy BIS_RSG_CONTENT_LIST,
                              errbuf out NOCOPY varchar2, errcode out NOCOPY varchar2)IS
    rs_name varchar2(30);
  BEGIN
    --get the name of the current request set
    rs_name := Get_Current_RS_Name(errbuf,errcode);
    if(rs_name is not null) then
      Get_content_in_RS(rs_name,p_report_list,'REPORT',errbuf,errcode);
    end if;
  END;

END;

/
