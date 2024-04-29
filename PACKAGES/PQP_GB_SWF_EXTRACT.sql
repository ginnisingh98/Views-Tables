--------------------------------------------------------
--  DDL for Package PQP_GB_SWF_EXTRACT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQP_GB_SWF_EXTRACT" AUTHID CURRENT_USER AS
/* $Header: pqpgbswfex.pkh 120.0.12010000.2 2010/01/13 10:43:46 nchinnam noship $ */

PROCEDURE XML_EXTRACT(errbuf          out nocopy varchar2
                     ,retcode         out nocopy varchar2
                     ,p_census_year   in number
                     ,p_request_id    in number
                     ,p_output_dir    in varchar2
                     ,p_serial_number in number
                     );

END PQP_GB_SWF_EXTRACT;

/
