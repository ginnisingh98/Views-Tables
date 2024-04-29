--------------------------------------------------------
--  DDL for Package AMS_CPYUTILITY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_CPYUTILITY_PVT" AUTHID CURRENT_USER AS
/* $Header: amsvcpus.pls 115.10 2002/11/22 23:36:39 dbiswas ship $ */

-- Start Of Comments
--
-- Name:
--   Ams_CPYUTILITY_PVT
--
-- Purpose:
--   This is the specification for the utility packages in  copy functionality in Oracle Marketing
--   from their ids.

-- GET_name Procedures
--   These functions will be called by marketing activities such as promotions,campaigns,
--   channels,events,etc and marketing elements such as products,scripts,resources etc while copying them
--   and will provide the names if their is any error.
-- Function:
-- get_objective_name       (see below for specification
-- get_offer_name           (see below for specification)
-- get_script_name          (see below for specification)
-- get_reosurce_name        (see below for specification)
-- get_product_name         (see below for specification)
-- get_cell_name            (see below for specification)
-- get_geo_area_name        (see below for specification)
-- get_attachment_name      (see below for specification)
-- get_deliverable_name     (see below for specification)
-- get_business_party_name  (see below for specification)
-- get_list_header_name     (see below for specification)
-- get_access_name          (see below for specification)
-- get_message_name  (see below for specification)
-- get_event_header_name

-- Unique name generation procedures
-- These functions would be called while copying marketing activities, if the user doesnot enter a new code
-- while creating a new one.
-- Function:
-- FUNCTION new_channel_code
-- FUNCTION new_media_code
-- FUNCTION new_promotion(p_src_name VARCHAR2)

-- Notes:
--
-- History:
--   07//1999  Mumu Pande Updated Comments
--   AMS_CPYUTILITY_PVT package.
--   07/15/1999   Mumu Pande Created (mpande@us.oracle.com)
-- 05-Apr-2001    choang      Added copy_attributes_table_type, copy_columns_rec_type and copy_columns_table_type
--
-- 29-Oct-2001    rrajesh     Added check_attrib_exists.
-- End Of Comments

   -- choang - 05-apr-2001
   -- table and records used by common copy
   TYPE copy_attributes_table_type IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;

   TYPE copy_columns_rec_type IS RECORD (
      column_name    VARCHAR2(30),
      column_value   VARCHAR2(4000)
   );

   TYPE copy_columns_table_type IS TABLE OF copy_columns_rec_type INDEX BY BINARY_INTEGER;

   -- Sub-Program Unit Declarations
   /* For ams_copy only. */
   TYPE log_mesg_type_table IS TABLE OF VARCHAR2(30)
      INDEX BY BINARY_INTEGER;

   TYPE log_mesg_txt_table IS TABLE OF VARCHAR2(4000)
      INDEX BY BINARY_INTEGER;

   TYPE log_act_used_by_table IS TABLE OF VARCHAR2(30)
      INDEX BY BINARY_INTEGER;

   TYPE log_act_used_id_table IS TABLE OF NUMBER
      INDEX BY BINARY_INTEGER;

   FUNCTION get_offer_code(p_offer_id IN NUMBER)
      RETURN VARCHAR2;

   /* For ams_copy. */
   FUNCTION get_event_offer_name(p_event_offering_id IN NUMBER)
      RETURN VARCHAR2;

   /* For ams_copy only. */
   FUNCTION get_geo_area_name(p_geo_hierarchy_id IN NUMBER, p_geo_area_type IN VARCHAR2)
      RETURN VARCHAR2;

   -- For ams_copy.
   FUNCTION get_product_name(p_category_id IN NUMBER)
      RETURN VARCHAR2;

   -- For ams_copy.
   FUNCTION get_message_name(p_message_id IN NUMBER)
      RETURN VARCHAR2;

   /* For ams_copy only.
   FUNCTION get_script_name(p_script_id IN NUMBER)
      RETURN VARCHAR2;
*/

   /* For ams_copy only. */
   FUNCTION get_resource_name(p_resource_id IN NUMBER)
      RETURN VARCHAR2;

   /* For ams_copy only. */
   FUNCTION get_attachment_name(p_act_attachment_id IN NUMBER)
      RETURN VARCHAR2;

   /* For ams_copy only. */
   FUNCTION get_category_name(p_category_id IN NUMBER)
      RETURN VARCHAR2;

   /* For ams_copy only. */
   FUNCTION get_deliverable_name(p_deliverable_id IN NUMBER)
      RETURN VARCHAR2;

   /* For ams_copy only. */
   FUNCTION get_segment_name(p_cell_id IN NUMBER)
      RETURN VARCHAR2;

   FUNCTION get_event_header_name(p_event_header_id IN NUMBER)
      RETURN VARCHAR2;
-- Sub-Program Unit Declarations
   /* Generate unique channel code. */
--   FUNCTION new_channel_code
   --    RETURN VARCHAR2;
   /* Log an error. */

   PROCEDURE write_log_mesg(
      p_act_type       IN   VARCHAR2,
      p_act_id         IN   NUMBER,
      p_message_text   IN   VARCHAR2,
      p_message_type   IN   VARCHAR2);

   /* Refresh the PL/SQL log table. */
   PROCEDURE refresh_log_mesg;

   /* Write the log infomation from PL/SQL table into ams_activity_logs. */
   PROCEDURE insert_log_mesg(x_transaction_id OUT NOCOPY NUMBER);
-- PL/SQL Specification
   /* This function will return a number to see the difference between the start and end dates of the
   source campaign,events or eveo */
   FUNCTION get_dates(
      p_arc_act_code    IN       VARCHAR2,
      p_activity_id     IN       NUMBER,
      x_return_status   OUT NOCOPY      VARCHAR2)
      RETURN NUMBER;

   --
   -- Purpose
   --    Return the column value associated with the given
   --    column, if the value exists.
   --
   PROCEDURE get_column_value (
      p_column_name     IN VARCHAR2,
      p_columns_table   IN copy_columns_table_type,
      x_column_value    OUT NOCOPY VARCHAR2
   );

   --
   -- Purpose
   --    Return FND_API.G_TRUE if the given attribute
   --    is one of the attributes to copy.
   --
   FUNCTION is_copy_attribute (
      p_attribute          IN VARCHAR2,
      p_attributes_table   IN copy_attributes_table_type
   ) RETURN VARCHAR2;

   -- While copying an object to check whether an attribute exists.
   FUNCTION check_attrib_exists (
      p_obj_type        IN VARCHAR2,
      p_obj_id          IN NUMBER,
      p_obj_attribute   IN VARCHAR2
   ) RETURN VARCHAR2;

END;

 

/
