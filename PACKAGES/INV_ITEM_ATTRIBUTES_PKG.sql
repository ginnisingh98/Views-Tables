--------------------------------------------------------
--  DDL for Package INV_ITEM_ATTRIBUTES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_ITEM_ATTRIBUTES_PKG" AUTHID CURRENT_USER AS
--$Header: INVGIAPS.pls 120.1 2005/07/07 03:25:31 myerrams noship $
--+=======================================================================+
--|               Copyright (c) 1999 Oracle Corporation                   |
--|                       Redwood Shores, CA, USA                         |
--|                         All rights reserved.                          |
--+=======================================================================+
--| FILENAME                                                              |
--|    INVGIAPS.pls                                                       |
--|                                                                       |
--| DESCRIPTION                                                           |
--|     Item attribute processor for the Item Attribute copy form         |
--|                                                                       |
--| HISTORY                                                               |
--|     9/19/2000      DHerring   Created                                 |
--|    11/21/2002      VMa        Added NOCOPY to OUT parameters of       |
--|                               find_org_list, get_type_struct,         |
--|                               call_item_update for performance        |
--|    02/10/2004      vjavli     GSCC standard compliance; added NOCOPY  |
--|    20/AUG/2004     nesoni     Bug# 3770547. Procedure                 |
--|                               populate_temp_table definition has been |
--|                               modified to incorporate                 |
--|                               attribute_category as additional IN     |
--|                               parameter.                              |
--|    10/DEC/2004     nesoni     Bug# 4025750. Procedure                 |
--|                               populate_temp_table modified to         |
--|                               incorporate CopyDffToNull  as additional|
--|                               IN parameter.                           |
--+======================================================================*/

--===============================================
-- CONSTANTS for concurrent program return values
--===============================================
-- Return values for RETCODE parameter (standard for concurrent programs):
RETCODE_SUCCESS                         VARCHAR2(10)    := '0';
RETCODE_WARNING                         VARCHAR2(10)    := '1';
RETCODE_ERROR                           VARCHAR2(10)    := '2';


--=================
-- TYPES
--=================

TYPE att_rec_type IS
     RECORD (temp_column_name     VARCHAR2(240)
            ,item_column_name     VARCHAR2(240)
            ,column_type          NUMBER
            ,foreign_key_name     VARCHAR2(240)
            ,foreign_key_column   VARCHAR2(240)
            ,reference_key_column VARCHAR2(240)
            ,display_column       VARCHAR2(240)
            ,chosen_value         VARCHAR2(240)
            ,selected_value       VARCHAR2(240)
            ,lookup_table         VARCHAR2(240)
            ,lookup_type          VARCHAR2(240)
            ,lookup_type_value    VARCHAR2(240)
            ,lookup_column        VARCHAR2(240));

TYPE att_tbl_type IS TABLE OF att_rec_type
     INDEX BY BINARY_INTEGER;

TYPE sel_rec_type IS
     RECORD (organization_id     NUMBER
            ,item_id          NUMBER);

TYPE sel_tbl_type IS TABLE OF sel_rec_type
     INDEX BY BINARY_INTEGER;

TYPE cho_rec_type IS
     RECORD (organization_id         NUMBER
            ,item_id                 NUMBER
            ,attribute01             VARCHAR2(240)
            ,attribute02             VARCHAR2(240)
            ,attribute03             VARCHAR2(240)
            ,attribute04             VARCHAR2(240));


TYPE org_tbl_type IS TABLE OF hr_all_organization_units.organization_id%TYPE;

--=========================
-- PROCEDURES AND FUNCTIONS
--=========================

--=========================================================================
-- PROCEDURE  : find_org_list            PUBLIC
-- PARAMETERS :
-- COMMENT    :
-- PRE-COND   :
--=========================================================================
PROCEDURE find_org_list
( p_org_tab OUT NOCOPY INV_ORGHIERARCHY_PVT.orgid_tbl_type
);

--=========================================================================
-- PROCEDURE  : set_type_struct            PUBLIC
-- PARAMETERS :
-- COMMENT    :
-- PRE-COND   :
--=========================================================================
PROCEDURE set_type_struct
(p_att_tab IN ATT_TBL_TYPE
,p_cho_rec IN CHO_REC_TYPE
,p_sel_tab IN SEL_TBL_TYPE);

--=========================================================================
-- PROCEDURE  : get_type_struct            PUBLIC
-- PARAMETERS :
-- COMMENT    :
-- PRE-COND   :
--=========================================================================
PROCEDURE get_type_struct
(p_att_tab OUT NOCOPY ATT_TBL_TYPE
,p_cho_rec OUT NOCOPY CHO_REC_TYPE
,p_sel_tab OUT NOCOPY SEL_TBL_TYPE);

--=========================================================================
-- PROCEDURE  : populate_type_struct            PUBLIC
-- PARAMETERS :
-- COMMENT    :
-- PRE-COND   :
--=========================================================================
PROCEDURE populate_type_struct(p_att_tab IN ATT_TBL_TYPE);

--=========================================================================
-- PROCEDURE  : populate_temp_table            PUBLIC
-- PARAMETERS :
-- COMMENT    :
-- PRE-COND   :
--=========================================================================
/* Bug: 3770547
One more filter parameter AttributeCategory added to find items that need to be populated*/
/* Bug: 4025750
One more filter parameter p_copy_dff_to_null added to find items that need to be populated*/

PROCEDURE populate_temp_table
(p_item_id          IN NUMBER
,p_org_code_list    IN INV_ORGHIERARCHY_PVT.orgid_tbl_type
,p_cat_id           IN NUMBER
,p_cat_set_id       IN NUMBER
,p_item_low         IN VARCHAR2
,p_item_high        IN VARCHAR2
,p_sts_code         IN VARCHAR2
,p_attribute_category IN VARCHAR2
,p_copy_dff_to_null IN VARCHAR2);

--=========================================================================
-- PROCEDURE  : clear_temp_table                PUBLIC
-- PARAMETERS :
-- COMMENT    : clear MTL_ITEM_ATTRIBUTES_TEMP
--              simple command to purge all records in temp table
--              this may not seem necessary as a temp table loses
--              it's data at the eand of each session.
--              However the session will last until the form is
--              dismissed and the user may query several times
--              before dismissing the form.
--              Each time there is a new query the temp table
--              needs to be purged.

-- PRE-COND   : This procedure prior to poulating the temp table
--=========================================================================
PROCEDURE clear_temp_table;

--=========================================================================
-- PROCEDURE  : call_item_update               PUBLIC
-- PARAMETERS :
-- COMMENT    : Blanket Update records in the  MTL_SYSTEM_ITEMS table
-- PRE-COND   : This procedure will be called from the form
--=========================================================================
PROCEDURE call_item_update(
 p_att_tab           IN  INV_ITEM_ATTRIBUTES_PKG.att_tbl_type
,p_sel_tab           IN  INV_ITEM_ATTRIBUTES_PKG.sel_tbl_type
,p_inventory_item_id OUT NOCOPY NUMBER
,p_organization_id   OUT NOCOPY NUMBER
,p_return_status     OUT NOCOPY VARCHAR2
,p_error_tab         OUT NOCOPY INV_Item_GRP.Error_tbl_type
);

--=========================================================================
-- PROCEDURE  : batch item update               PUBLIC
-- PARAMETERS: x_errbuf                error buffer
--             x_retcode               0 success, 1 warning, 2 error
--             p_att_tab               pl/sql table of records
--             p_sel_tab               pl/sql table of records
-- COMMENT    : Called from a concurrent program if used
--              this procedure allows the user to work in a
--              no modal fashion.
--              Blanket Update records in the MTL_SYSTEM_ITEMS table
--              The struct att_tab contains the columns that
--              are to be updated and the default values they are
--              to be updated to.
--              The struct sel_tab contains the unique id
--              of the records that are to be updated
--              The procedure constructs the record p_item_rec
--              with the default values
--              It then loops through the selected records
--              and calls the published item update api
--              for each unique record.
-- PRE-COND   : This procedure will be called from the form
--=========================================================================
PROCEDURE batch_item_update(
  x_errbuff            OUT NOCOPY VARCHAR2
, x_retcode            OUT NOCOPY NUMBER
, p_seq_id             IN  NUMBER
);

--=========================================================================
-- PROCEDURE  : populate_temp_tables      PUBLIC
-- PARAMETERS :
-- COMMENT    : This procedure is called just before
--              the call to the concurrent program
--              which will update the item attributes.
--
-- PRE-COND   : This procedure will be called from the form
--=========================================================================
PROCEDURE populate_temp_tables(
 p_att_tab IN  INV_ITEM_ATTRIBUTES_PKG.att_tbl_type
,x_seq_id  OUT NOCOPY NUMBER
);

--========================================================================
-- PROCEDURE : Set_Unit_Test_Mode      PUBLIC
-- COMMENT   : This procedure sets the unit test mode that prevents the
--             program from attempting to submit concurrent requests and
--             enables it to run it from SQL*Plus. The Item Interface will
--             not be run.
--=========================================================================
PROCEDURE  Set_Unit_Test;

END INV_ITEM_ATTRIBUTES_PKG;

 

/
