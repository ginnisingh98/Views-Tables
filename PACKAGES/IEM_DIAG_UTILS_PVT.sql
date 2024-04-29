--------------------------------------------------------
--  DDL for Package IEM_DIAG_UTILS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEM_DIAG_UTILS_PVT" AUTHID CURRENT_USER as
/* $Header: iemdutis.pls 120.0 2005/09/30 14:35:18 chtang noship $*/

G_key      VARCHAR2(8)      :='EMCENTER';

PROCEDURE check_profiles(
        x_customer_num_isnull	      OUT NOCOPY  VARCHAR2,
        x_resource_num_isnull         OUT NOCOPY  VARCHAR2);
END IEM_DIAG_UTILS_PVT;


 

/
