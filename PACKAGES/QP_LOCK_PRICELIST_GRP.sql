--------------------------------------------------------
--  DDL for Package QP_LOCK_PRICELIST_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QP_LOCK_PRICELIST_GRP" AUTHID CURRENT_USER AS
/* $Header: QPXGLKPS.pls 120.2 2005/10/13 16:01:20 rchellam noship $ */

--GLOBAL Constant holding the package name

G_PKG_NAME	CONSTANT  VARCHAR2(30) := 'QP_LOCK_PRICELIST_GRP';

--Procedure to lock a price list and/or line.
PROCEDURE Lock_Price (p_source_list_line_id        IN    NUMBER,
                      p_list_source_code           IN 	 VARCHAR2,
                      p_orig_system_header_ref	   IN 	 VARCHAR2,
                      --added for MOAC
                      p_org_id                     IN    NUMBER DEFAULT NULL,
                      p_commit                     IN    VARCHAR2 DEFAULT 'F',
                      --added for OKS bug 4504825
                      x_locked_price_list_id       OUT   NOCOPY	NUMBER,
                      x_locked_list_line_id        OUT   NOCOPY NUMBER,
                      x_return_status              OUT   NOCOPY VARCHAR2,
                      x_msg_count                  OUT   NOCOPY NUMBER,
                      x_msg_data                   OUT   NOCOPY VARCHAR2);

END QP_LOCK_PRICELIST_GRP;

 

/
