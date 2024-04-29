--------------------------------------------------------
--  DDL for Package ZX_MERGE_LOC_CHECK_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ZX_MERGE_LOC_CHECK_PKG" AUTHID CURRENT_USER AS
/* $Header: zxcmergegnrchks.pls 120.0 2005/09/21 04:20:28 sachandr noship $ */

PROCEDURE CHECK_GNR(p_from_location_id IN  NUMBER,
                    p_to_location_id   IN  NUMBER,
                    p_init_msg_list    IN  VARCHAR2,
                    x_merge_yn         OUT NOCOPY VARCHAR2,
                    x_return_status    OUT NOCOPY VARCHAR2,
                    x_msg_count        OUT NOCOPY NUMBER,
                    x_msg_data         OUT NOCOPY VARCHAR2);

END;

 

/
