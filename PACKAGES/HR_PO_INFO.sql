--------------------------------------------------------
--  DDL for Package HR_PO_INFO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_PO_INFO" AUTHID CURRENT_USER AS
/* $Header: hrpoinfo.pkh 115.5 2004/04/07 10:50:17 sbuche noship $ */
/*
+==========================================================================+
|                       Copyright (c) 2003 Oracle Corporation              |
|                          Redwood Shores, California, USA                 |
|                               All rights reserved.                       |
+==========================================================================+
Name
        Container for procedures / functions that return HR information to
        PO.
Purpose
        This package, at least initially, is base 11i interoperable
        so that other non-HRMS application teams can include this in
        any of their patches. Care should be taken when maintaining.

        Apps teams call this as a black box, which can include (but is
        not limited to) calling functions from within SQL.  This means
        that parameter ordering should not be adjusted and new parameters
        should be optional or overloaded.

        These procedures will initially be used by PO (Oracle Purchasing)
        and iExpenses.

Change History
-------+--------+-----------+-------+--------------------------------------|
        dcasemor 10-SEP-2003 115.0   Created for bug 3120074.
        dcasemor 15-SEP-2003 115.1   Added wrapper functions to return
                                     varchar2s instead of booleans.
                                     Added the full_cwk_enabled pair of
                                     functions. Added procedures to return
                                     PL/SQL tables for PO bulk APIs.
        dcasemor 16-OCT-2003 115.2   Added more interoperable select
                                     procedures:
                                       - get_vendor_for_primary_asg
                                       - get_vendor_for_asg
                                       - get_po_for_primary_asg
                                       - get_po_for_asg
        sramasam 22-OCT-2003 115.3   Added procedure to return url
                                     to launch Self Service CWK Placement
        sbuche   26-mar-2004 115.4   Bug 3391399:
                                     Added function asg_vendor_id_exist
                                     to check the existance of vendor_id
                                     column in HR assignments tables.
        sbuche   02-APR-2002 115.5   Change requested by OTA:
                                     Added parameter p_effective_date to
                                     the procedure get_person_for_po_line.

                                     Commented following functions and
                                     procedure as they will not work
                                     when more than one person or
                                     assignment exists for a vendor site:

                                     - get_asg_id_for_vendor_site
                                     - get_person_id_for_vendor_site
                                     - get_person_for_vendor_site

---------------------------------------------------------------------------|
*/

    --
    -- Global package variable declarations.
    --
    g_TRUE     CONSTANT VARCHAR2(4) := 'TRUE';
    g_FALSE    CONSTANT VARCHAR2(5) := 'FALSE';
    --
    -- Ideally g_debug would be better as a package private but it needs
    -- to be public so that it can be set in an NDS block.
    --
    g_debug             BOOLEAN     := TRUE;

    --
    -- Public global type declarations.
    --
    TYPE g_table_numbers_t IS TABLE OF NUMBER INDEX BY binary_integer;

--
---------------------------------------------------------------------------|
------------------------< DEBUG_ENABLED >----------------------------------|
---------------------------------------------------------------------------|
--
-- This function determines whether HR debugging is enabled.
-- This is a wrapper to hr_utility.debug_enabled.  In this wrapper, if
-- hr_utility.debug_enabled does not exist the function assumes TRUE.
-- This is compatible with base 11i.
--
  FUNCTION  debug_enabled                           RETURN BOOLEAN;
--
---------------------------------------------------------------------------|
------------------------< FULL_CWK_ENABLED >-------------------------------|
---------------------------------------------------------------------------|
--
-- This function determines whether the contingent worker
-- cross-applications functionality is enabled.  To do this, it checks
-- a PO profile option.
--
  FUNCTION  full_cwk_enabled                        RETURN BOOLEAN;
--
---------------------------------------------------------------------------|
------------------------< FULL_CWK_ENABLED_CHAR >--------------------------|
---------------------------------------------------------------------------|
--
-- This function determines whether the contingent worker
-- cross-applications functionality is enabled.  To do this, it checks
-- a PO profile option.  The function returns 'TRUE' or 'FALSE' as a
-- VARCHAR2 instead of a boolean type so that the function can be used in
-- SQL.
--
  FUNCTION  full_cwk_enabled_char                   RETURN VARCHAR2;
--
---------------------------------------------------------------------------|
------------------------< ASG_PO_COLS_EXIST >------------------------------|
---------------------------------------------------------------------------|
--
-- This function determines whether the PO columns exist on the HR
-- assignments table or not.
--
  FUNCTION  asg_po_cols_exist                       RETURN BOOLEAN;
--
---------------------------------------------------------------------------|
------------------------< ASG_VENDOR_ID_EXIST >----------------------------|
---------------------------------------------------------------------------|
--
-- This function determines whether the VENDOR_ID column exist on the HR
-- assignments table or not.
--
  FUNCTION  asg_vendor_id_exist                     RETURN BOOLEAN;
--
---------------------------------------------------------------------------|
------------------------< GET_PERSON_FOR_PO_LINE >-------------------------|
---------------------------------------------------------------------------|
--
-- This procedure returns the person and assignment IDs given the ID of a
-- PO Line. If no match is found, the IDs returned are NULL.
--
  PROCEDURE get_person_for_po_line
                (p_po_line_id       IN         NUMBER
                ,p_person_id        OUT NOCOPY NUMBER
                ,p_assignment_id    OUT NOCOPY NUMBER
                ,p_effective_date   IN         DATE    DEFAULT NULL);
--
---------------------------------------------------------------------------|
------------------------< GET_PERSON_ID_FOR_PO_LINE >----------------------|
---------------------------------------------------------------------------|
--
-- This function returns the person ID given a specific PO Line.
-- If no match is found, it returns NULL.
--
  FUNCTION  get_person_id_for_po_line
                (p_po_line_id       IN         NUMBER) RETURN NUMBER;
--
---------------------------------------------------------------------------|
------------------------< GET_ASG_ID_FOR_PO_LINE >-------------------------|
---------------------------------------------------------------------------|
--
-- This function returns the assignment ID given a specific PO Line.
-- If no match is found, it returns NULL.
--
  FUNCTION  get_asg_id_for_po_line
                (p_po_line_id       IN         NUMBER) RETURN NUMBER;
--
---------------------------------------------------------------------------|
------------------------< ASG_EXIST_FOR_PO >-------------------------------|
---------------------------------------------------------------------------|
--
-- This function determines whether any assignments are assigned to a
-- given PO Header.
--
  FUNCTION asg_exist_for_po
                (p_po_header_id     IN         NUMBER) RETURN BOOLEAN;
--
---------------------------------------------------------------------------|
------------------------< ASG_EXIST_FOR_PO_LINE >--------------------------|
---------------------------------------------------------------------------|
--
-- This function determines whether any assignments are assigned to a
-- specific PO Line.
--
  FUNCTION asg_exist_for_po_line
                (p_po_line_id       IN         NUMBER) RETURN BOOLEAN;
--
---------------------------------------------------------------------------|
------------------------< ASG_EXIST_FOR_PO_CHAR >--------------------------|
---------------------------------------------------------------------------|
--
-- This function determines whether any assignments are assigned to a
-- given PO Header. It returns 'TRUE' or 'FALSE' as a VARCHAR2 instead
-- of a boolean type so that the function can be used in SQL.
--
  FUNCTION asg_exist_for_po_char
                (p_po_header_id     IN         NUMBER) RETURN VARCHAR2;
--
---------------------------------------------------------------------------|
------------------------< ASG_EXIST_FOR_PO_LINE_CHAR >---------------------|
---------------------------------------------------------------------------|
--
-- This function determines whether any assignments are assigned to a
-- specific PO Line. It returns 'TRUE' or 'FALSE' as a VARCHAR2 instead
-- of a boolean type so that the function can be used in SQL.
--
  FUNCTION asg_exist_for_po_line_char
                (p_po_line_id       IN         NUMBER) RETURN VARCHAR2;
--
---------------------------------------------------------------------------|
--
---------------------------------------------------------------------------|
------------------------< ASGS_EXIST_FOR_POS >-----------------------------|
---------------------------------------------------------------------------|
--
-- This procedure takes in a PL/SQL table of numbers. The numbers are
-- PO IDs and these are used to check whether any assignments are
-- assigned to each PO.
-- The same PL/SQL table type is returned, only the IDs returned are
-- restricted to POs that have assignments attached.
--
  PROCEDURE asgs_exist_for_pos
                (p_po_in_tbl        IN         g_table_numbers_t
                ,p_po_out_tbl       OUT NOCOPY g_table_numbers_t);
--
---------------------------------------------------------------------------|
------------------------< ASGS_EXIST_FOR_PO_LINES >------------------------|
---------------------------------------------------------------------------|
--
-- This procedure takes in a PL/SQL table of numbers. The numbers are
-- PO Line IDs and these are used to check whether any assignments are
-- assigned to each PO Line.
-- The same PL/SQL table type is returned, only the IDs returned are
-- restricted to lines that have assignments attached.
--
  PROCEDURE asgs_exist_for_po_lines
                (p_po_lines_in_tbl  IN         g_table_numbers_t
                ,p_po_lines_out_tbl OUT NOCOPY g_table_numbers_t);
--
---------------------------------------------------------------------------|
------------------------< GET_PERSON_FOR_VENDOR_SITE >---------------------|
---------------------------------------------------------------------------|
/*
** For a vendor site, more than one Person could exist and in
** that case this procedure will not work.
**
--
-- This procedure returns the person and assignment IDs given the ID of a
-- vendor site. If no match is found, the IDs returned are NULL.
--
  PROCEDURE get_person_for_vendor_site
                (p_vendor_site_id   IN         NUMBER
                ,p_person_id        OUT NOCOPY NUMBER
                ,p_assignment_id    OUT NOCOPY NUMBER
                ,p_effective_date   IN         DATE    DEFAULT NULL);
*/
--
---------------------------------------------------------------------------|
------------------------< GET_PERSON_ID_FOR_VENDOR_SITE >------------------|
---------------------------------------------------------------------------|
/*
** For a vendor site, more than one Person could exist and in
** that case this function will not work.
**
--
-- This function returns the person ID given a specific Vendor Site.
-- If no match is found, it returns NULL.
--
  FUNCTION  get_person_id_for_vendor_site
                (p_vendor_site_id   IN         NUMBER) RETURN NUMBER;
*/
--
---------------------------------------------------------------------------|
------------------------< GET_ASG_ID_FOR_VENDOR_SITE >---------------------|
---------------------------------------------------------------------------|
/*
** For a vendor site, more than one Assignment could exist and in
** that case this function will not work.
**
--
-- This function returns the assignment ID given a specific Vendor Site.
-- If no match is found, it returns NULL.
--
  FUNCTION  get_asg_id_for_vendor_site
                (p_vendor_site_id   IN         NUMBER) RETURN NUMBER;
*/
--
---------------------------------------------------------------------------|
------------------------< ASG_EXIST_FOR_VENDOR >---------------------------|
---------------------------------------------------------------------------|
--
-- This function determines whether any assignments belong o a given
-- Vendor.
--
  FUNCTION asg_exist_for_vendor
                (p_vendor_id        IN         NUMBER) RETURN BOOLEAN;
--
---------------------------------------------------------------------------|
------------------------< ASG_EXIST_FOR_VENDOR_SITE >----------------------|
---------------------------------------------------------------------------|
--
-- This function determines whether any assignments belong to a given
-- Vendor Site.
--
  FUNCTION asg_exist_for_vendor_site
                (p_vendor_site_id   IN         NUMBER) RETURN BOOLEAN;
--
---------------------------------------------------------------------------|
------------------------< ASG_EXIST_FOR_VENDOR_CHAR >----------------------|
---------------------------------------------------------------------------|
--
-- This function determines whether any assignments belong to a given
-- Vendor. The function returns 'TRUE' or 'FALSE' as a VARCHAR2 instead
-- of a boolean type so that it can be used in SQL.
--
  FUNCTION asg_exist_for_vendor_char
                (p_vendor_id        IN         NUMBER) RETURN VARCHAR2;
--
---------------------------------------------------------------------------|
------------------------< ASG_EXIST_FOR_VENDOR_SITE_CHAR >-----------------|
---------------------------------------------------------------------------|
--
-- This function determines whether any assignments belong to a given
-- Vendor Site. The function returns 'TRUE' or 'FALSE' as a VARCHAR2
-- instead of a boolean type so that it can be used in SQL.
--
  FUNCTION asg_exist_for_vendor_site_char
                (p_vendor_site_id   IN         NUMBER) RETURN VARCHAR2;
--
---------------------------------------------------------------------------|
------------------------< ASGS_EXIST_FOR_VENDORS >-------------------------|
---------------------------------------------------------------------------|
--
-- This procedure takes in a PL/SQL table of numbers. The numbers are
-- Vendor IDs and these are used to check whether any assignments are
-- assigned to each vendor.
-- The same PL/SQL table type is returned, only the IDs returned are
-- restricted to vendors that have assignments.
--
  PROCEDURE asgs_exist_for_vendors
                (p_vendors_in_tbl   IN         g_table_numbers_t
                ,p_vendors_out_tbl  OUT NOCOPY g_table_numbers_t);
--
---------------------------------------------------------------------------|
------------------------< ASGS_EXIST_FOR_VENDOR_SITES >--------------------|
---------------------------------------------------------------------------|
--
-- This procedure takes in a PL/SQL table of numbers. The numbers are
-- Vendor Site IDs and these are used to check whether any assignments are
-- assigned to each vendor site.
-- The same PL/SQL table type is returned, only the IDs returned are
-- restricted to vendor sites that have assignments.
--
  PROCEDURE asgs_exist_for_vendor_sites
            (p_vendor_sites_in_tbl  IN         g_table_numbers_t
            ,p_vendor_sites_out_tbl OUT NOCOPY g_table_numbers_t);
--
---------------------------------------------------------------------------|
------------------------< GET_VENDOR_FOR_PRIMARY_ASG >---------------------|
---------------------------------------------------------------------------|
--
-- Given a person, this procedure returns the Supplier and Supplier Site
-- for the primary assignment.  If the assignment does not have the
-- Supplier set, then both the Supplier and Supplier Site will return null
-- (because the site cannot be set without the supplier).  If the site
-- is not set but the supplier is, then only the site will return null.
--
-- If the person does not exist, or there is no primary assignment as of
-- the effective date, then both the Supplier and Supplier Site return
-- null; the procedure does not raise an error.
--
PROCEDURE get_vendor_for_primary_asg
    (p_person_id            IN         NUMBER
    ,p_effective_date       IN         DATE
    ,p_vendor_id            OUT NOCOPY NUMBER
    ,p_vendor_site_id       OUT NOCOPY NUMBER);
--
---------------------------------------------------------------------------|
------------------------< GET_VENDOR_FOR_ASG >-----------------------------|
---------------------------------------------------------------------------|
--
-- Given an assignment, this procedure returns the Supplier and Supplier
-- Site for that assignment.  If the assignment does not have the
-- Supplier set, then both the Supplier and Supplier Site will return null
-- (because the site cannot be set without the supplier).  If the site
-- is not set but the supplier is, then only the site will return null.
--
-- If the assignment does not exist, or the assignment is not effective
-- as of the effective date, then both the Supplier and Supplier Site
-- return null; the procedure does not raise an error.
--
PROCEDURE get_vendor_for_asg
    (p_assignment_id        IN         NUMBER
    ,p_effective_date       IN         DATE
    ,p_vendor_id            OUT NOCOPY NUMBER
    ,p_vendor_site_id       OUT NOCOPY NUMBER);
--
---------------------------------------------------------------------------|
------------------------< GET_PO_FOR_PRIMARY_ASG >-------------------------|
---------------------------------------------------------------------------|
--
-- Given a person, this procedure returns the PO Header and Line
-- for the primary assignment.  If the assignment does not have the
-- PO set, then both the Header and Line will return null (because
-- the line cannot be set without a header).  If the line is not set
-- but the header is, then only the line will return null.
--
-- If the person does not exist, or there is no primary assignment as of
-- the effective date, then both the PO Header and Line will return
-- null; the procedure does not raise an error.
--
PROCEDURE get_po_for_primary_asg
    (p_person_id            IN         NUMBER
    ,p_effective_date       IN         DATE
    ,p_po_header_id         OUT NOCOPY NUMBER
    ,p_po_line_id           OUT NOCOPY NUMBER);
--
---------------------------------------------------------------------------|
------------------------< GET_PO_FOR_ASG >---------------------------------|
---------------------------------------------------------------------------|
--
-- Given an assignment, this procedure returns the PO Header and Line
-- for the assignment.  If the assignment does not have the PO set, then
-- both the Header and Line will return null (because the line cannot be
-- set without a header).  If the line is not set but the header is, then
-- only the line will return null.
--
-- If the assignment does not exist, or the assignment is not effective
-- as of the effective date, then both the PO Header and Line will return
-- null; the procedure does not raise an error.
--
PROCEDURE get_po_for_asg
    (p_assignment_id        IN         NUMBER
    ,p_effective_date       IN         DATE
    ,p_po_header_id         OUT NOCOPY NUMBER
    ,p_po_line_id           OUT NOCOPY NUMBER);

---------------------------------------------------------------------------|
------------------------< GET_URL_PLACE_CWK >------------------------------|
---------------------------------------------------------------------------|
--
-- Given a po_line_id this procedure will return the url destination which
-- will be rendered in PO notification.
-- On launching this url the user will be taken through the CWK Placement
-- flow of pages.
--
PROCEDURE get_url_place_cwk
    (p_po_line_id           IN         NUMBER
    ,p_destination          OUT NOCOPY VARCHAR2);

END hr_po_info;

 

/
