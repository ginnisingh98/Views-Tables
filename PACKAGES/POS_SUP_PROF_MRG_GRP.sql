--------------------------------------------------------
--  DDL for Package POS_SUP_PROF_MRG_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POS_SUP_PROF_MRG_GRP" AUTHID CURRENT_USER as
/* $Header: POSSPMGS.pls 120.2 2005/12/08 15:42:15 hvadlamu noship $ */

procedure handle_merge(
        p_new_vendor_id       IN NUMBER,
        p_new_vendor_site_id  IN NUMBER,
        p_old_vendor_id       IN NUMBER,
        p_old_vendor_site_id  IN NUMBER,
        x_return_status     OUT NOCOPY VARCHAR2);

END POS_SUP_PROF_MRG_GRP;

 

/
