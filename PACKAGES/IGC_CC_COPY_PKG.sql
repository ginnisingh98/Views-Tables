--------------------------------------------------------
--  DDL for Package IGC_CC_COPY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGC_CC_COPY_PKG" AUTHID CURRENT_USER AS
/* $Header: IGCCCPCS.pls 120.3.12000000.2 2007/09/07 11:55:04 smannava ship $*/

/* ================================================================================
                         PROCEDURE Header_Copy
   ===============================================================================*/


Procedure Header_Copy
(
  p_api_version                 IN      NUMBER,
  p_init_msg_list               IN      VARCHAR2 := FND_API.G_FALSE,
  p_commit                      IN      VARCHAR2 := FND_API.G_FALSE,
  p_validation_level            IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  x_return_status               OUT NOCOPY     VARCHAR2,
  x_msg_count                   OUT NOCOPY     NUMBER,
  x_msg_data                    OUT NOCOPY     VARCHAR2,

  p_old_cc_header_id            IN      igc_cc_headers.cc_header_id%TYPE,
  p_new_cc_header_id            IN      igc_cc_headers.cc_header_id%TYPE,
  p_cc_num			IN	igc_cc_headers.cc_num%TYPE,
  p_cc_type			IN	igc_cc_headers.cc_type%TYPE
  );

END IGC_CC_COPY_PKG;

 

/
