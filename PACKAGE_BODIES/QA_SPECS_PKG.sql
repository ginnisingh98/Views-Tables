--------------------------------------------------------
--  DDL for Package Body QA_SPECS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QA_SPECS_PKG" AS
/* $Header: qaspecb.pls 120.2 2006/07/17 04:19:01 bso noship $ */

        --
        -- Simple utility function to test if an ID is
        -- null or -1.  The IDs as setup in qa_specs are
        -- usually filled with -1 to indicate not specified.
        --
        FUNCTION empty(p_id NUMBER) RETURN BOOLEAN IS
        BEGIN
            RETURN (p_id IS NULL) OR (p_id = -1);
        END empty;


        --
        -- Utility function to test if an item is in a
        -- particular item category and category set.
        --
        FUNCTION item_in_cat(
            p_organization_id NUMBER,
            p_item_id NUMBER,
            p_spec_cat_id NUMBER,
            p_spec_cat_set_id NUMBER)
        RETURN BOOLEAN IS
            dummy INTEGER;
            CURSOR c IS
                SELECT 1
                FROM   mtl_item_categories mic
                WHERE  mic.inventory_item_id = p_item_id AND
                       mic.organization_id = p_organization_id AND
                       mic.category_id = p_spec_cat_id AND
                       mic.category_set_id = p_spec_cat_set_id;
        BEGIN
            OPEN c;
            FETCH c INTO dummy;
            CLOSE c;

            RETURN (dummy IS NOT NULL);
        END item_in_cat;


        --
        -- Utility function to test if an item is in a
        -- particular item category set.
        --
        FUNCTION item_in_cat_set(
            p_organization_id NUMBER,
            p_item_id NUMBER,
            p_spec_cat_set_id NUMBER)
        RETURN BOOLEAN IS
            dummy INTEGER;
            CURSOR c IS
                SELECT 1
                FROM   mtl_item_categories mic
                WHERE  mic.inventory_item_id = p_item_id AND
                       mic.organization_id = p_organization_id AND
                       mic.category_set_id = p_spec_cat_set_id;
        BEGIN
            OPEN c;
            FETCH c INTO dummy;
            CLOSE c;

            RETURN (dummy IS NOT NULL);
        END item_in_cat_set;


    --
    -- Find out if an item is subsumed by a Spec's setup.
    -- It is if any one is true:
    --   1. p_item_id = p_spec_item_id
    --   2. p_spec_item_id is null and
    --      p_item_id is within the given item category
    --      and item category set.
    --   3. p_spec_item_id is null and p_spec_cat_id is null and
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
    RETURN VARCHAR2 IS
    BEGIN
        --
        --   3. p_spec_item_id is null and p_spec_cat_id is null and
        --      p_item_id is within the given item category set.
        --
        IF empty(p_spec_item_id) AND
            empty(p_spec_cat_id) AND
            item_in_cat_set(
                p_organization_id,
                p_item_id,
                p_spec_cat_set_id) THEN
            RETURN fnd_api.g_true;
        END IF;

        --
        --   2. p_spec_item_id is null and
        --      p_item_id is within the given item category
        --      and item category set.
        --
        IF empty(p_spec_item_id) AND
            item_in_cat(
                p_organization_id,
                p_item_id,
                p_spec_cat_id,
                p_spec_cat_set_id) THEN
            RETURN fnd_api.g_true;
        END IF;

        --
        --   1. p_item_id = p_spec_item_id
        --
        IF p_item_id = p_spec_item_id THEN
            RETURN fnd_api.g_true;
        END IF;

        RETURN fnd_api.g_false;
    END spec_item_matched;


    --
    -- Tracking Bug 4939897
    -- R12 Forms Tech Stack Upgrade - Obsolete Oracle Graphics
    -- Also a generically useful function to fetch spec name.
    -- bso Tue Feb  7 15:41:15 PST 2006
    --
    FUNCTION get_spec_name(p_spec_id NUMBER) RETURN VARCHAR2 IS
        l_spec_name qa_specs.spec_name%TYPE;
    BEGIN
        SELECT spec_name INTO l_spec_name
        FROM   qa_specs
        WHERE  spec_id = p_spec_id AND rownum <= 1;

        RETURN l_spec_name;
    END get_spec_name;


    --
    -- Bug 5231952
    -- Add a utility to copy attachments when assigning a parent
    -- spec to a child.
    -- bso Sun Jul 16 20:27:24 PDT 2006
    --
    PROCEDURE copy_attachment(p_from_spec_id NUMBER, p_to_spec_id NUMBER) IS
    BEGIN
        --
        -- Use standard FND API to copy attachment from master
        -- spec to child spec.
        --
        fnd_attached_documents2_pkg.copy_attachments(
            x_from_entity_name => 'QA_SPECS',
            x_from_pk1_value   => p_from_spec_id,
            x_to_entity_name   => 'QA_SPECS',
            x_to_pk1_value     => p_to_spec_id);

    END copy_attachment;

END qa_specs_pkg;

/
