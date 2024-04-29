--------------------------------------------------------
--  DDL for Package JL_CUSTOM_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JL_CUSTOM_PUB" AUTHID CURRENT_USER AS
/* $Header: jlcustps.pls 120.0.12010000.2 2010/04/09 09:32:19 mbarrett noship $ */

Procedure get_our_number (p_api_version               in            number      default 1.0,
                          p_commit                    in            varchar2    default fnd_api.g_false,
                          p_document_id               in            number,
                          x_our_number                out   nocopy  varchar2,
                          x_return_status             out   nocopy  varchar2,
                          x_msg_data                  out   nocopy  varchar2);

END JL_CUSTOM_PUB;

/
