--------------------------------------------------------
--  DDL for Package WMS_ZONES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WMS_ZONES_PVT" AUTHID CURRENT_USER AS
  /* $Header: WMSZONES.pls 120.0.12010000.2 2009/08/03 06:46:45 ajunnikr ship $ */
  -- Package     : wms_zones_pvt
  -- File        : $RCSfile: WMSZONES.pls,v $
  -- Content     : Contains the
  -- Description :
  -- Notes       :
  -- Modified    : Mon Jul 14 14:29:40 GMT+05:30 2003

  TYPE wms_zone_loc_tbl_t IS TABLE OF wms_zone_locators_temp%ROWTYPE
    INDEX BY BINARY_INTEGER;

  TYPE zoneloc_rowid_t IS TABLE OF VARCHAR2(18) INDEX BY BINARY_INTEGER;
  TYPE zoneloc_messages_t IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

  /**
   * 'Pending removal from Zone' message
   *
  **/
   g_remove_locators_message VARCHAR2(200) := 'Pending removal from Zone';

 /**
   * 'Pending addition to Zone' message
   *
  **/
   g_add_locators_message VARCHAR2(200) := 'Pending addition to Zone';

  PROCEDURE populate_grid(
    p_zone_id                  NUMBER
  , p_org_id                   NUMBER
  , x_record_count  OUT NOCOPY NUMBER
  , x_return_status OUT NOCOPY VARCHAR2
  , x_msg_data      OUT NOCOPY VARCHAR2
  );

  /**
  *   Using the filter criteria given in the Add Locators form,
  *   inserts the locators into the table WMS_ZONE_LOCATORS_TEMP.

  *  @param   p_fm_zone_id    from_zone_id in the range. Will have a null value if the user doesnt choose a from_zone
  *  @param   p_to_zone_id    to_zone_id in the range. Can have a null value if the user doesnt choose a to_zone
  *  @param   p_current_zone_id    The zone_id of the current zone, for which more locators are being added
  *  @param   p_fm_sub_code    From Subinventory code
  *  @param   p_to_sub_code    To Subinventory Code
  *  @param   p_fm_loc_id    From Locator Id in a range of locators. Should contain a value only if either p_fm_sub_code or p_to_sub_code is populated.
  *  @param   p_to_loc_id     To Locator Id in a range of locators. Should contain a value only if either p_fm_sub_code or p_to_sub_code is populated.
  *  @param   p_subinventory_status    Status id of the subinventories
  *  @param   p_locator_status    Status id of the locators
  *  @param   p_subinventory_type    Subinventory Type
  *  @param   p_locator_type    Locator Type
  *  @param   p_fm_picking_order    Picking order of the Locators
  *  @param   p_to_picking_order    Picking order of the Locators
  *  @param   p_fm_dropping_order    Dropping order of the Locators
  *  @param   p_to_dropping_order    Dropping order of the Locators
  *  @param  p_all_locators    Indicates whether all locators is chosen
**/
   PROCEDURE add_locators_to_grid (
      p_fm_zone_id            IN   NUMBER DEFAULT NULL,
      p_to_zone_id            IN   NUMBER DEFAULT NULL,
      p_current_zone_id       IN   NUMBER DEFAULT NULL,
      p_fm_sub_code           IN   VARCHAR2 DEFAULT NULL,
      p_to_sub_code           IN   VARCHAR2 DEFAULT NULL,
      p_fm_loc_id             IN   NUMBER DEFAULT NULL,
      p_to_loc_id             IN   NUMBER DEFAULT NULL,
      p_subinventory_status   IN   NUMBER DEFAULT NULL,
      p_locator_status        IN   NUMBER DEFAULT NULL,
      p_subinventory_type     IN   NUMBER DEFAULT NULL,
      p_locator_type          IN   NUMBER DEFAULT NULL,
      p_fm_picking_order      IN   NUMBER DEFAULT NULL,
      p_to_picking_order      IN   NUMBER DEFAULT NULL,
      p_fm_dropping_order     IN   NUMBER DEFAULT NULL,
      p_to_dropping_order     IN   NUMBER DEFAULT NULL,
      p_organization_id       IN   NUMBER,
      p_mode IN NUMBER DEFAULT NULL,
      p_type IN VARCHAR2 default 'A');

 /**
  *   Contains code to insert records into wms_zones_b and
  *   wms_zones_tl

  *  @param  x_return_status   Return Status - Success, Error, Unexpected Error
  *  @param  x_msg_data   Contains any error messages added to the stack
  *  @param  x_msg_count   Contains the count of the messages added to the stack
  *  @param  p_zone_id   Zone_id
  *  @param  p_zone_name   Name of the new Zone
  *  @param  p_description   Description of the zone
  *  @param  enabled_flag   Flag to indicate whether the zone is enabled or not. '
                            Y' indicates that the zone is enabled.
                            'N' indicates that the zone is not enabled.
                            Any other value will be an error
  *  @param  disable_date   The date when the zone will be disabled.
                            This date cannot be less than the SYSDATE.
  *  @param  p_organization_id   Current Organization id
  *  @param  p_attribute_category   Attribute Category of the Zones Descriptive Flexfield
  *  @param  p_attribute1   Attribute1
  *  @param  p_attribute2   Attribute2
  *  @param  p_attribute3   Attribute3
  *  @param  p_attribute4   Attribute4
  *  @param  p_attribute5   Attribute5
  *  @param  p_attribute6   Attribute6
  *  @param  p_attribute7   Attribute7
  *  @param  p_attribute8   Attribute8
  *  @param  p_attribute9   Attribute9
  *  @param  p_attribute10   Attribute10
  *  @param  p_attribute11   Attribute11
  *  @param  p_attribute12   Attribute12
  *  @param  p_attribute13   Attribute13
  *  @param  p_attribute14   Attribute14
  *  @param  p_attribute15   Attribute15
**/

  PROCEDURE insert_wms_zones (
      x_return_status        OUT NOCOPY      VARCHAR2,
      x_msg_data             OUT NOCOPY      VARCHAR2,
      x_msg_count            OUT NOCOPY      NUMBER,
      p_zone_id              IN              NUMBER,
      p_zone_name            IN              VARCHAR2,
      p_description          IN              VARCHAR2,
      p_type                   in varchar2,
      p_enabled_flag         IN              VARCHAR2,
      p_labor_enabled        IN              VARCHAR2,
      p_disable_date         IN              DATE,
      p_organization_id      IN              NUMBER,
      p_attribute_category   IN              VARCHAR2,
      p_attribute1           IN              VARCHAR2,
      p_attribute2           IN              VARCHAR2,
      p_attribute3           IN              VARCHAR2,
      p_attribute4           IN              VARCHAR2,
      p_attribute5           IN              VARCHAR2,
      p_attribute6           IN              VARCHAR2,
      p_attribute7           IN              VARCHAR2,
      p_attribute8           IN              VARCHAR2,
      p_attribute9           IN              VARCHAR2,
      p_attribute10          IN              VARCHAR2,
      p_attribute11          IN              VARCHAR2,
      p_attribute12          IN              VARCHAR2,
      p_attribute13          IN              VARCHAR2,
      p_attribute14          IN              VARCHAR2,
      p_attribute15          IN              VARCHAR2,
      p_creation_date        IN              DATE,
      p_created_by           IN              NUMBER,
      p_last_update_date     IN              DATE,
      p_last_updated_by      IN              NUMBER,
      p_last_update_login    IN              NUMBER
   );

  /**
  *   Contains code to update records in wms_zones_b and
  *   wms_zones_tl

  *  @param  x_return_status   Return Status - Success, Error, Unexpected Error
  *  @param  x_msg_data   Contains any error messages added to the stack
  *  @param  x_msg_count   Contains the count of the messages added to the stack
  *  @param  p_zone_id   Zone_id
  *  @param  p_zone_name   Name of the new Zone
  *  @param  p_description   Description of the zone
  *  @param  enabled_flag   Flag to indicate whether the zone is enabled or not. 'Y' indicates that the zone is enabled 'N' indicates that the zone is not enabled. Any other value will be an error
  *  @param  disable_date   The date when the zone will be disabled. This date cannot be less than the SYSDATE.
  *  @param  p_organization_id   Current Organization id
  *  @param  p_attribute_category   Attribute Category of the Zones Descriptive Flexfield
  *  @param  p_attribute1   Attribute1
  *  @param  p_attribute2   Attribute2
  *  @param  p_attribute3   Attribute3
  *  @param  p_attribute4   Attribute4
  *  @param  p_attribute5   Attribute5
  *  @param  p_attribute6   Attribute6
  *  @param  p_attribute7   Attribute7
  *  @param  p_attribute8   Attribute8
  *  @param  p_attribute9   Attribute9
  *  @param  p_attribute10   Attribute10
  *  @param  p_attribute11   Attribute11
  *  @param  p_attribute12   Attribute12
  *  @param  p_attribute13   Attribute13
  *  @param  p_attribute14   Attribute14
  *  @param  p_attribute15   Attribute15


**/
   PROCEDURE update_wms_zones (
      x_return_status        OUT NOCOPY      VARCHAR2,
      x_msg_data             OUT NOCOPY      VARCHAR2,
      x_msg_count            OUT NOCOPY      NUMBER,
      p_zone_id              IN              NUMBER,
      p_zone_name            IN              VARCHAR2,
      p_description          IN              VARCHAR2,
       p_type                   in varchar2,
      p_enabled_flag         IN              VARCHAR2,
      p_labor_enabled        IN              VARCHAR2,
      p_disable_date         IN              DATE,
      p_organization_id      IN              NUMBER,
      p_attribute_category   IN              VARCHAR2,
      p_attribute1           IN              VARCHAR2,
      p_attribute2           IN              VARCHAR2,
      p_attribute3           IN              VARCHAR2,
      p_attribute4           IN              VARCHAR2,
      p_attribute5           IN              VARCHAR2,
      p_attribute6           IN              VARCHAR2,
      p_attribute7           IN              VARCHAR2,
      p_attribute8           IN              VARCHAR2,
      p_attribute9           IN              VARCHAR2,
      p_attribute10          IN              VARCHAR2,
      p_attribute11          IN              VARCHAR2,
      p_attribute12          IN              VARCHAR2,
      p_attribute13          IN              VARCHAR2,
      p_attribute14          IN              VARCHAR2,
      p_attribute15          IN              VARCHAR2,
      p_creation_date        IN              DATE,
      p_created_by           IN              NUMBER,
      p_last_update_date     IN              DATE,
      p_last_updated_by      IN              NUMBER,
      p_last_update_login    IN              NUMBER
   );

  /**
  *   This procedure saves the records from
  *   wms_zone_locators_temp to wms_zone_locators. For every
  *   record at a given index in the table p_zoneloc_messages
  *   table, we get the the corresponding rowid from the input
  *   parameter table p_zoneloc_rowid_t for the same index.
  *   If the value in p_zoneloc_messages_t is 0, the
  *   corresponding record will be inserted into the table.
  *   If the value in p_zoneloc_messages_t is 1, the
  *   corresponding record will be deleted from the table.
  *   Else do nothing.

  *  @param  p_zoneloc_rowid_t   Table of records containing the rowids of all the records to be inserted or deleted.
  *  @param  p_zoneloc_messages_t   Indicates whether the corresponding record should be inserted or deleted.
If the value is 0, the corresponding record will be inserted into the table.
If the value is 1, the corresponding record will be deleted from the table.
Else do nothing.
  **/
  PROCEDURE   save_sel_locators(
		p_zoneloc_rowid_t IN wms_zones_pvt.zoneloc_rowid_t,
	  p_zone_id IN wms_zone_locators.zone_id%TYPE);

  /**
  *   This procedure saves all the records from
  *   wms_zone_locators_temp to wms_zone_locators, which have the
  *   message field containing the value 'Pending Addition to
  *   Zone'. All the records whose message field has a value
  *   'Pending Deletion' will be deleted from the table.
**/
  PROCEDURE   save_all_locators(p_zone_id IN wms_zone_locators.zone_id%TYPE,
                                p_org_id IN wms_zone_locators.organization_id%TYPE);

   /**
    *   Lock the record if any attribute changes
    *
    *  @param  x_return_status       Return status, this can be 'S' or  'E'
    *  @param  x_msg_count           Count of messages in stack
    *  @param  x_msg_data            Message, if the count is 1
    *  @param  p_zone_id             Zone id
    *  @param  p_zone_name           Zone name
    *  @param  p_description         Description
    *  @param  p_enabled_flag        Enabled flag
    *  @param  p_disable_date        Disable date
    *  @param  p_organization_id     Organization id
    *  @param  p_attribute_category  Zone DFF context field
    *  @param  p_attribute1          Zone DFF Attribute
    *  @param  p_attribute2          Zone DFF Attribute
    *  @param  p_attribute3          Zone DFF Attribute
    *  @param  p_attribute4          Zone DFF Attribute
    *  @param  p_attribute5          Zone DFF Attribute
    *  @param  p_attribute6          Zone DFF Attribute
    *  @param  p_attribute7          Zone DFF Attribute
    *  @param  p_attribute8          Zone DFF Attribute
    *  @param  p_attribute9          Zone DFF Attribute
    *  @param  p_attribute10         Zone DFF Attribute
    *  @param  p_attribute11         Zone DFF Attribute
    *  @param  p_attribute12         Zone DFF Attribute
    *  @param  p_attribute13         Zone DFF Attribute
    *  @param  p_attribute14         Zone DFF Attribute
    *  @param  p_attribute15         Zone DFF Attribute
    *  @param  p_creation_date       WHO column
    *  @param  p_created_by          WHO column
    *  @param  p_last_update_date    WHO column
    *  @param  p_last_updated_by     WHO column
    *  @param  p_last_update_login   WHO column
    *
    **/
 PROCEDURE lock_row(
                      x_return_status       OUT NOCOPY VARCHAR2,
                      x_msg_data            OUT NOCOPY VARCHAR2,
                      x_msg_count           OUT NOCOPY NUMBER,
                      p_zone_id             IN         NUMBER,
                      p_zone_name           IN         VARCHAR2,
                      p_description         IN         VARCHAR2,
                       p_type                   in varchar2,
                      p_enabled_flag        IN         VARCHAR2,
                      p_labor_enabled       IN         VARCHAR2,
                      p_disable_date        IN         DATE,
                      p_organization_id     IN         NUMBER,
                      p_attribute_category  IN         VARCHAR2,
                      p_attribute1          IN         VARCHAR2,
                      p_attribute2          IN         VARCHAR2,
                      p_attribute3          IN         VARCHAR2,
                      p_attribute4          IN         VARCHAR2,
                      p_attribute5          IN         VARCHAR2,
                      p_attribute6          IN         VARCHAR2,
                      p_attribute7          IN         VARCHAR2,
                      p_attribute8          IN         VARCHAR2,
                      p_attribute9          IN         VARCHAR2,
                      p_attribute10         IN         VARCHAR2,
                      p_attribute11         IN         VARCHAR2,
                      p_attribute12         IN         VARCHAR2,
                      p_attribute13         IN         VARCHAR2,
                      p_attribute14         IN         VARCHAR2,
                      p_attribute15         IN         VARCHAR2,
                      p_creation_date       IN         DATE,
                      p_created_by          IN         NUMBER,
                      p_last_update_date    IN         DATE,
                      p_last_updated_by     IN         NUMBER,
                      p_last_update_login   IN         NUMBER
                     );

   /**
    *   Initialize the data structures needed for procedures of this package to work.
    *
    *   This procedure must always be called once before any call is made to any other
    *   procedure/function of this package.
    *
    *   If any exception is raised during the process of initialization, the same will is
    *   propagated
    *
    **/
   PROCEDURE initialize;

   /**
    *   Caches the commonly used message texts in global variables
    *
    **/
   PROCEDURE populate_message_cache;

   /**
    *   Validate the attributes of Zones.
    *
    *   If any validation fails the procedure sets the x_return_status to 'E'.
    *   If any truncation occurs during validation the x_return status is set to 'W'
    *
    *   Any exception raised during the process of validation is put on the stack
    *
    *  @param  x_return_status       Return status, this can be 'S', 'E' or 'W'
    *  @param  x_msg_count           Count of messages in stack
    *  @param  x_msg_data            Message, if the count is 1
    *  @param  p_zone_id             Zone id
    *  @param  p_zone_name           Zone name
    *  @param  p_description         Description
    *  @param  p_enabled_flag        Enabled flag
    *  @param  p_disable_date        Disable date
    *  @param  p_organization_id     Organization id
    *  @param  p_attribute_category  Zone DFF context field
    *  @param  p_attribute1          Zone DFF Attribute
    *  @param  p_attribute2          Zone DFF Attribute
    *  @param  p_attribute3          Zone DFF Attribute
    *  @param  p_attribute4          Zone DFF Attribute
    *  @param  p_attribute5          Zone DFF Attribute
    *  @param  p_attribute6          Zone DFF Attribute
    *  @param  p_attribute7          Zone DFF Attribute
    *  @param  p_attribute8          Zone DFF Attribute
    *  @param  p_attribute9          Zone DFF Attribute
    *  @param  p_attribute10         Zone DFF Attribute
    *  @param  p_attribute11         Zone DFF Attribute
    *  @param  p_attribute12         Zone DFF Attribute
    *  @param  p_attribute13         Zone DFF Attribute
    *  @param  p_attribute14         Zone DFF Attribute
    *  @param  p_attribute15         Zone DFF Attribute
    *  @param  p_creation_date       WHO column
    *  @param  p_created_by          WHO column
    *  @param  p_last_update_date    WHO column
    *  @param  p_last_updated_by     WHO column
    *  @param  p_last_update_login   WHO column
    *
    **/
   PROCEDURE validate_row(
                          x_return_status       OUT NOCOPY VARCHAR2,
                          x_msg_data            OUT NOCOPY VARCHAR2,
                          x_msg_count           OUT NOCOPY NUMBER,
                          p_zone_id             IN         NUMBER,
                          p_zone_name           IN         VARCHAR2,
                          p_description         IN         VARCHAR2,
                          p_enabled_flag        IN         VARCHAR2,
                          p_disable_date        IN         DATE,
                          p_organization_id     IN         NUMBER,
                          p_attribute_category  IN         VARCHAR2,
                          p_attribute1          IN         VARCHAR2,
                          p_attribute2          IN         VARCHAR2,
                          p_attribute3          IN         VARCHAR2,
                          p_attribute4          IN         VARCHAR2,
                          p_attribute5          IN         VARCHAR2,
                          p_attribute6          IN         VARCHAR2,
                          p_attribute7          IN         VARCHAR2,
                          p_attribute8          IN         VARCHAR2,
                          p_attribute9          IN         VARCHAR2,
                          p_attribute10         IN         VARCHAR2,
                          p_attribute11         IN         VARCHAR2,
                          p_attribute12         IN         VARCHAR2,
                          p_attribute13         IN         VARCHAR2,
                          p_attribute14         IN         VARCHAR2,
                          p_attribute15         IN         VARCHAR2,
                          p_creation_date       IN         DATE,
                          p_created_by          IN         NUMBER,
                          p_last_update_date    IN         DATE,
                          p_last_updated_by     IN         NUMBER,
                          p_last_update_login   IN         NUMBER
                         );

END wms_zones_pvt;

/
