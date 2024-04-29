--------------------------------------------------------
--  DDL for Package ENI_DENORM_HRCHY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ENI_DENORM_HRCHY" AUTHID CURRENT_USER AS
/* $Header: ENIDENHS.pls 120.1 2007/03/13 08:52:26 lparihar ship $  */

g_delimiter     VARCHAR2(5) := '/////';
-- This Public Function will return the Default Category Set Associated with
-- Product Reporting Functional Area
FUNCTION GET_CATEGORY_SET_ID RETURN NUMBER;

-- This Public Procedure is used to insert records in the Staging Table
-- The staging table will be used in the Incremental Load of Denorm Table.
-- All the modified/new records in the Product Catalog Hierarchy has to be
-- there in the Staging table, which has to be done by calling this procedure.
PROCEDURE INSERT_INTO_STAGING(
      p_object_type     IN VARCHAR2,
      p_object_id       IN NUMBER,
      p_child_id        IN NUMBER,
      p_parent_id       IN NUMBER,
      p_mode_flag       IN VARCHAR2,
      x_return_status   OUT NOCOPY VARCHAR2,
      x_msg_count       OUT NOCOPY NUMBER,
      x_msg_data        OUT NOCOPY VARCHAR2,
      p_language_code   IN VARCHAR2 DEFAULT NULL);

-- This Procedure Denormalizes the Product Catalog Hierarchy into Denorm Table
-- This accepts the refresh mode as 'FULL' for initial load or 'PARTIAL' for incremental load
PROCEDURE LOAD_PRODUCT_HIERARCHY(errbuf OUT NOCOPY VARCHAR2, retcode OUT NOCOPY VARCHAR2, p_refresh_mode IN VARCHAR2);

-- ER: 3154516
-- This Public Function will return the last updated date for Product Catalog from de-norm table
FUNCTION GET_LAST_CATALOG_UPDATE_DATE RETURN DATE;

-- ER: 3185516
-- This is a wrapper procedure, which will be called whenever there is a change in item assignment.
-- This in turn determines whether DBI is installed or not and calls the star pkg if installed.
-- Now this procedure will be called from INV forms, instead of them directly calling ENI Star pkg
PROCEDURE SYNC_CATEGORY_ASSIGNMENTS(
      p_api_version         NUMBER,
      p_init_msg_list       VARCHAR2 := 'F',
      p_inventory_item_id   NUMBER,
      p_organization_id     NUMBER,
      x_return_status       OUT NOCOPY VARCHAR2,
      x_msg_count           OUT NOCOPY NUMBER,
      x_msg_data            OUT NOCOPY VARCHAR2,
      p_category_set_id     NUMBER,
      p_old_category_id     NUMBER,
      p_new_category_id     NUMBER);

-- ER: 3185516
-- This is a wrapper procedure, which will be called after import items
-- This in calls the star pkg and updates the Item Assignment Flag in De-norm table
PROCEDURE SYNC_STAR_ITEMS_FROM_IOI(
      p_api_version         NUMBER,
      p_init_msg_list       VARCHAR2 := 'F',
      p_set_process_id      NUMBER,
      x_return_status       OUT NOCOPY VARCHAR2,
      x_msg_count           OUT NOCOPY NUMBER,
      X_MSG_DATA            OUT NOCOPY VARCHAR2);

FUNCTION split_category_codes(
        p_str      VARCHAR2
       ,p_level    NUMBER
       ,p_delim    VARCHAR2 default g_delimiter) return VARCHAR2;

-- This Procedure Denormalizes the Product Catalog Hierarchy into a separate denorm table
-- [ENI_ICAT_CDENORM_HIERARCHIES]. It is designed to support SBA/OBIEE requirements.
-- The program is designed to flatten the hierarchy for levels ranging between 5 and 10.
-- The number of levels to denormalize is dynamic and is governed by a profile value.
-- Currently it only supports FULL REFRESH.
PROCEDURE LOAD_OBIEE_HIERARCHY(errbuf OUT NOCOPY VARCHAR2, retcode OUT NOCOPY VARCHAR2);

END ENI_DENORM_HRCHY;

/
