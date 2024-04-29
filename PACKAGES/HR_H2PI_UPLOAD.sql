--------------------------------------------------------
--  DDL for Package HR_H2PI_UPLOAD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_H2PI_UPLOAD" AUTHID CURRENT_USER as
/* $Header: hrh2piul.pkh 120.0 2005/05/31 00:42:10 appldev noship $*/

    g_to_business_group_id hr_all_organization_units.business_group_id%Type;
    g_request_id           fnd_concurrent_requests.request_id%Type;

    procedure upload ( p_errbuf      out nocopy varchar2,
                       p_retcode     out nocopy number,
                       p_file_name   in  varchar2);

    function  get_from_client_id return number;

end hr_h2pi_upload;


 

/
