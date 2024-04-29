--------------------------------------------------------
--  DDL for Package HR_H2PI_BASELINE_DATA_DOWNLOAD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_H2PI_BASELINE_DATA_DOWNLOAD" AUTHID CURRENT_USER AS
/* $Header: hrh2pipd.pkh 120.0 2005/05/31 00:41:10 appldev noship $ */

procedure download (p_errbuf              out nocopy varchar2,
                    p_retcode             out nocopy number,
                    p_business_group_id   in  number,
                    p_client_id           in  number);

END hr_h2pi_baseline_data_download;


 

/
