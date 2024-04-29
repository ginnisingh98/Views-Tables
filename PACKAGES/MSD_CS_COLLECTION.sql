--------------------------------------------------------
--  DDL for Package MSD_CS_COLLECTION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSD_CS_COLLECTION" AUTHID CURRENT_USER as
/* $Header: msdcscls.pls 120.1.12010000.1 2008/05/15 07:09:08 lannapra ship $ */

    Procedure Custom_Stream_Collection (
                  errbuf           OUT NOCOPY  varchar2,
                  retcode          OUT NOCOPY  varchar2,
                  p_collection_type in  varchar2,
                  p_validate_data   in  varchar2,
                  p_definition_id   in  number,
                  p_cs_name         in  varchar2,
                  p_comp_refresh    in  varchar2,
                  p_instance_id     in  number,
                  p_parameter1      in  varchar2,
                  p_parameter2      in  varchar2,
                  p_parameter3      in  varchar2,
                  p_parameter4      in  varchar2,
                  p_parameter5      in  varchar2,
                  p_parameter6      in  varchar2,
                  p_parameter7      in  varchar2,
                  p_parameter8      in  varchar2,
                  p_parameter9      in  varchar2,
                  p_parameter10     in  varchar2,
                  p_request_id      in  number default 0);

End;

/
