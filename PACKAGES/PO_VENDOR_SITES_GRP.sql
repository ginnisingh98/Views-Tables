--------------------------------------------------------
--  DDL for Package PO_VENDOR_SITES_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_VENDOR_SITES_GRP" AUTHID CURRENT_USER AS
/* $Header: POXGDVSS.pls 120.0 2005/06/02 02:01:43 appldev noship $ */

-- Read the profile option that enables/disables the debug log
g_fnd_debug CONSTANT VARCHAR2(1) :=
  NVL (FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

-- other
g_pkg_name CONSTANT VARCHAR2(30) := 'PO_VENDOR_SITE_GRP';
g_module_prefix CONSTANT VARCHAR2(50) := 'po.plsql.'||g_pkg_name||'.';

------------------------------------------------------------------------------
-- API to return supplier's transmission default
-----------------------------------------------------------------------------

Procedure Get_Transmission_Defaults(p_api_version        IN VARCHAR2,
                                    p_init_msg_list      IN VARCHAR2 :=  FND_API.G_FALSE,
                                    p_document_id        IN NUMBER,
                                    p_document_type      IN VARCHAR2,
                                    p_document_subtype   IN VARCHAR2,
                                    p_preparer_id        IN OUT NOCOPY NUMBER,
                                    x_default_method     OUT NOCOPY VARCHAR2,
                                    x_email_address      OUT NOCOPY VARCHAR2,
                                    x_fax_number         OUT NOCOPY VARCHAR2,
                                    x_document_num       OUT NOCOPY VARCHAR2,
                                    x_print_flag         OUT NOCOPY VARCHAR2,
                                    x_fax_flag           OUT NOCOPY VARCHAR2,
                                    x_email_flag         OUT NOCOPY VARCHAR2,
                                    x_return_status      OUT NOCOPY VARCHAR2,
                                    x_msg_count          OUT NOCOPY NUMBER,
                                    x_msg_data           OUT NOCOPY VARCHAR2);

END PO_VENDOR_SITES_GRP;

 

/
