--------------------------------------------------------
--  DDL for Package POS_VENDOR_MERGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POS_VENDOR_MERGE" AUTHID CURRENT_USER as
-- $Header: POSMERGS.pls 115.1 2002/11/27 18:29:21 bitang ship $


PROCEDURE VENDOR_MERGE (
   p_vendor_id IN NUMBER,           -- new VENDOR_ID
   p_vendor_site_id IN NUMBER,      -- new VENDOR_SITE_ID
   p_dup_vendor_id IN NUMBER,       -- old / disabled VENDOR_ID
   p_dup_vendor_site_id IN NUMBER  -- old / disabled VENDOR_SITE_ID
);


END POS_VENDOR_MERGE;

 

/
