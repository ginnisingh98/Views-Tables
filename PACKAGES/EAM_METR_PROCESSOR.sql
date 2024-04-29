--------------------------------------------------------
--  DDL for Package EAM_METR_PROCESSOR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EAM_METR_PROCESSOR" AUTHID CURRENT_USER AS
/* $Header: EAMETRPS.pls 115.4 2004/06/21 23:42:21 jieli ship $ */

  procedure process_meter_reading_requests(
              errbuf     out NOCOPY varchar2,
              retcode    out NOCOPY varchar2,
              p_group_id in number,
              p_commit   in boolean default true);

END eam_metr_processor;

 

/
