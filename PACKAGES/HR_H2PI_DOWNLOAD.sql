--------------------------------------------------------
--  DDL for Package HR_H2PI_DOWNLOAD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_H2PI_DOWNLOAD" AUTHID CURRENT_USER AS
/* $Header: hrh2pidl.pkh 120.0 2005/05/31 00:39:00 appldev noship $ */

    procedure  write ( p_errbuf           out nocopy varchar2,
                       p_retcode          out nocopy number,
                       p_clob_to_write    clob );

    procedure download ( p_errbuf              out nocopy varchar2,
                         p_retcode             out nocopy number,
                         p_business_group_id   in  number,
                         p_transfer_start_date in  varchar2,
                         p_transfer_end_date   in  varchar2,
                         p_client_id           in  number);

    function get_request_id return number;

    function get_value_from_id(p_org_information_id in number,
                               p_org_info_number    in number)  return varchar2 ;
end hr_h2pi_download;


 

/
