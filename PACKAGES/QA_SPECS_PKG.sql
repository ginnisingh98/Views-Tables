--------------------------------------------------------
--  DDL for Package QA_SPECS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QA_SPECS_PKG" AUTHID CURRENT_USER AS
/* $Header: qaspecs.pls 120.2 2006/07/17 04:18:44 bso noship $ */

    --
    -- General utilities for QA_SPECS entity.
    -- bso Thu May 12 16:52:19 PDT 2005
    --


    --
    -- Find out if an item is subsumed by a Spec's setup.
    -- It is if any one is true:
    --   p_item_id = p_spec_item_id
    --   p_spec_item_id is null and
    --      p_item_id is within the given item category
    --      and item category set.
    --   p_spec_item_id is null and p_spec_cat_id is null and
    --      p_item_id is within the given item category set.
    --   Return 'T' or 'F'
    --
    -- bso Thu May 12 16:54:59 PDT 2005
    --
    FUNCTION spec_item_matched(
        p_organization_id NUMBER,
        p_item_id NUMBER,
        p_spec_item_id NUMBER,
        p_spec_cat_id NUMBER,
        p_spec_cat_set_id NUMBER)
    RETURN VARCHAR2;


    --
    -- Supporting functions that may be useful for
    -- other purposes, thus making them public.
    --
        FUNCTION item_in_cat_set(
            p_organization_id NUMBER,
            p_item_id NUMBER,
            p_spec_cat_set_id NUMBER)
        RETURN BOOLEAN;


        FUNCTION item_in_cat(
            p_organization_id NUMBER,
            p_item_id NUMBER,
            p_spec_cat_id NUMBER,
            p_spec_cat_set_id NUMBER)
        RETURN BOOLEAN;


    --
    -- Tracking Bug 4939897
    -- R12 Forms Tech Stack Upgrade - Obsolete Oracle Graphics
    -- Also a generically useful function.
    -- bso Tue Feb  7 15:41:15 PST 2006
    --
    FUNCTION get_spec_name(p_spec_id NUMBER) RETURN VARCHAR2;


    --
    -- Bug 5231952
    -- Add a utility to copy attachments when assigning a parent
    -- spec to a child.
    -- bso Sun Jul 16 20:27:24 PDT 2006
    --
    PROCEDURE copy_attachment(p_from_spec_id NUMBER, p_to_spec_id NUMBER);


END qa_specs_pkg;

 

/
