--------------------------------------------------------
--  DDL for Package EGO_ITEM_COMPARE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EGO_ITEM_COMPARE_PKG" AUTHID CURRENT_USER AS
/* $Header: EGOPICMS.pls 120.1 2007/04/18 18:29:25 ssarnoba ship $ */


-- ===============================================
-- CONSTANTS for package
-- ===============================================
--
-- Package Name
--
    G_PACKAGE_NAME               VARCHAR2(30) := 'EGO_ITEM_COMPARE_PKG';
--
-- Date Format that will be used for logging messages
--
    G_DATE_FORMAT                VARCHAR2(30) := 'SYYYY-MM-DD HH24:MI:SS';

--
-- Data Level Names
--
    G_ITEM_LEVEL_NAME            VARCHAR2(20) := 'ITEM_LEVEL';

--
-- Attribute Group Defaulting Behavior
--

    G_DEFAULTING_AG              EGO_ATTR_GROUP_DL.DEFAULTING%TYPE := 'D';
                                                                -- VARCHAR2(30)
    G_INHERITED_AG               EGO_ATTR_GROUP_DL.DEFAULTING%TYPE := 'I';
                                                                -- VARCHAR2(30)

--
--  Return values for RETCODE parameter (standard for concurrent programs)
--
    RETCODE_SUCCESS              NUMBER    := 0;
    RETCODE_WARNING              NUMBER    := 1;
    RETCODE_ERROR                NUMBER    := 2;

-- =================================================================
-- Global variables
-- =================================================================

    --Example :
    --G_TRACE_ON                NUMBER := 0;   -- Log ON state

-- =========================
-- PROCEDURES AND FUNCTIONS
-- =========================


    FUNCTION Get_Item_Attr_Val (
      p_inventory_item_id     IN   VARCHAR2
     ,p_organization_id       IN   VARCHAR2
     ,p_attr_name             IN   VARCHAR2
     ) RETURN VARCHAR2;
    -- Start OF comments
    -- API name  : Get the Column value for the Item
    -- TYPE      : Public (Called by Item compare VO)
    -- Pre-reqs  : None
    -- FUNCTION  : To retrieve from MTL_SYSTEM_ITEMS, corresponding
    --             column value, and return
    -- Parameters:
    --     IN    :
    --
    --             p_inventory_item_id        IN      VARCHAR2
    --               Primary Key column 1 value
    --
    --             p_organization_id          IN      VARCHAR2
    --               Primary Key column 2 value
    --
    --             p_attr_name                IN      VARCHAR2
    --               Item Attribute name
    --
    --             p_failed_priv_check_str    IN      VARCHAR2
    --               String to return if privilege check fails;
    --               for example, perhaps formatted text for a
    --               "lock" image, or some other such string
    --
    --             p_data_level_name          IN      VARCHAR2

    FUNCTION Get_User_Attr_Val (
        p_appl_id                       IN   NUMBER
       ,p_attr_grp_type                 IN   VARCHAR2
       ,p_attr_grp_name                 IN   VARCHAR2
       ,p_attr_name                     IN   VARCHAR2
       ,p_inventory_item_id             IN   VARCHAR2
       ,p_organization_id               IN   VARCHAR2
       ,p_data_level_name               IN   VARCHAR2
       ,p_failed_priv_check_str         IN   VARCHAR2 DEFAULT NULL
    )
    RETURN VARCHAR2;

END EGO_ITEM_COMPARE_PKG;

/
