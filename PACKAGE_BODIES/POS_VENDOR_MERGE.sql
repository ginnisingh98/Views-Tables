--------------------------------------------------------
--  DDL for Package Body POS_VENDOR_MERGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POS_VENDOR_MERGE" as
-- $Header: POSMERGB.pls 115.9 2002/11/27 18:29:41 bitang ship $


PROCEDURE VENDOR_MERGE (
   p_vendor_id IN NUMBER,           -- new VENDOR_ID
   p_vendor_site_id IN NUMBER,      -- new VENDOR_SITE_ID
   p_dup_vendor_id IN NUMBER,       -- old / disabled VENDOR_ID
   p_dup_vendor_site_id IN NUMBER  -- old / disabled VENDOR_SITE_ID
)
AS
l_count number;
--
BEGIN

-- Select the number of avtive sites for the old vendor_id
select count(*)
into l_count
from po_vendor_sites_all
where vendor_id = p_dup_vendor_id
and vendor_site_id <> p_dup_vendor_site_id
and
(inactive_date is null OR inactive_date >= sysdate) ;

IF ( l_count = 0  AND (p_vendor_id <> p_dup_vendor_id) ) THEN
    POS_VENDOR_UTIL_PKG.merge_vendor_parties(
       p_vendor_id            -- new VENDOR_ID
       , p_dup_vendor_id        -- old / disabled VENDOR_ID
    );
END IF;
END VENDOR_MERGE;


END POS_VENDOR_MERGE;

/
