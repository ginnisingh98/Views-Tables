--------------------------------------------------------
--  DDL for Package ZPB_PERSONAL_AW
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ZPB_PERSONAL_AW" AUTHID CURRENT_USER as
/* $Header: zpbpersonalaw.pls 120.0.12010.4 2006/08/03 17:36:45 appldev noship $ */

-------------------------------------------------------------------------------
-- AW_CREATE - Driver program to create the user's personal AW from the shared
--             AW
--
-- IN: p_user          - The user ID
-------------------------------------------------------------------------------
procedure aw_create(p_user             in varchar2,
                    p_business_area_id in number);

-------------------------------------------------------------------------------
-- AW_DELETE - Driver program to completely and irreversibly delete
--                      the user's personal AW.  Will delete the AW and any
--                      SQL Views defined for that AW.
--
-- IN: p_user          - The user ID
-------------------------------------------------------------------------------
procedure aw_delete(p_user             in varchar2,
                    p_business_area_id in number);

-------------------------------------------------------------------------------
-- AW_UPDATE - Driver program to update the user's personal AW from the shared
--             AW
--
-- IN: p_user          - The user ID
--     x_return_status - The return status
--
-- OUT: whether the structures have changed to require a new Metadata Map
-------------------------------------------------------------------------------
function AW_UPDATE(p_user          IN            VARCHAR2,
                   x_return_status IN OUT NOCOPY VARCHAR2,
                   p_read_only     IN            VARCHAR2 := FND_API.G_FALSE)
   return BOOLEAN;

-------------------------------------------------------------------------------
-- DATA_VIEWS_CREATE - Creates the views associated with the measures of the
--                     instance.
--
-- IN: p_user     - User ID
--     p_instance - The instance ID
-------------------------------------------------------------------------------
procedure DATA_VIEWS_CREATE(p_user     in varchar2,
                            p_instance in varchar2,
                            p_type     in varchar2,
                            p_template in varchar2 default null,
                            p_approver in varchar2 default null);

-------------------------------------------------------------------------------
-- IMPORT - Imports objects from one AW to personal AW
--
-- IN: p_user    - The user id.
--     p_fromAw  - The AW to import from.  Defaults to the shared AW
--     p_noScope - 'Y' if readscoping should be removed for the import
-------------------------------------------------------------------------------
procedure IMPORT (p_user    in varchar2,
                  p_fromAw  in varchar2 default null,
                  p_noScope in varchar2 default 'N');

-------------------------------------------------------------------------------
-- MEASURES_DELETE - Deletes measures defined in the personal
--
-- IN: p_user     - The User ID
--     p_instance - The instance ID
--     p_type     - SHARED_VIEW, PERSONAL, APPROVER. def. SHARED_VIEW
--     p_template - The template ID. Null if N/A (default)
--     p_approvee - The approvee ID. Null if N/A (default)
--
-------------------------------------------------------------------------------
procedure measures_delete(p_user     in varchar2,
                          p_instance in varchar2,
                          p_type     in varchar2 default 'SHARED_VIEW',
                          p_template in varchar2 default NULL,
                          p_approvee in varchar2 default NULL);

-------------------------------------------------------------------------------
-- MEASURES_SHARED_UPDATE - Creates any formulas and views that point to the
--                          shared AW measure formulas
--
-- IN: p_user          - User ID
--     x_return_status - The return status
--
-- OUT: whether the structures have changed to require a new Metadata Map
-------------------------------------------------------------------------------
function MEASURES_SHARED_UPDATE(p_user          IN            VARCHAR2,
                                x_return_status IN OUT NOCOPY VARCHAR2)
   return BOOLEAN;

-------------------------------------------------------------------------------
-- METADATA_CREATE - Copies the metadata objects from shared AW into a
--                      new personal AW.  Copies all dimensions, hierarchies,
--                      levels, aggregation, allocation, and attributes defined
--                      in ECM.
--
-- IN: p_user - User ID
-------------------------------------------------------------------------------
procedure metadata_create(p_user     in varchar2);

-------------------------------------------------------------------------------
-- METADATA_UPDATE - Updates the Personal AW with any changes to the shared
--                      AW's metadata.  It will merge the changes in the
--                      shared with the personal, never deleting any user-
--                      created personal metadata or data objects.
--
-- IN: p_user          - The user ID
--     x_return_status - The return status
--
-- OUT: The list of Dimension ID's whose views need to be recreated
-------------------------------------------------------------------------------
function METADATA_UPDATE(p_user          IN            VARCHAR2,
                         x_return_status IN OUT NOCOPY VARCHAR2)
   return VARCHAR2;

-------------------------------------------------------------------------------
-- SECURITY_UPDATE - Updates the data access control structures to reflect
--                   the last maintenance changes for a given user.
--
-- IN: p_user          - The User Id
--     x_return_status - The return status
------------------------------------------------------------------------------
procedure SECURITY_UPDATE(p_user          IN            VARCHAR2,
                          x_return_status IN OUT NOCOPY VARCHAR2);

-------------------------------------------------------------------------------
-- API name   : Startup
-- Type       : Private
-- Function   : Starts up the OLAP session for the user. Attaches the AW's
--              needed for the session, synch's them up, and distributes any
--              measures needed
-- Pre-reqs   : None.
-- Parameters :
--   IN : p_api_version      IN NUMBER   Required
--        p_init_msg_list    IN VARCHAR2 Optional Default = G_FALSE
--        p_commit           IN VARCHAR2 Optional Default = G_FALSE
--        p_validation_level IN NUMBER   Optional Default = G_VALID_LEVEL_FULL
--        p_business_area    IN NUMBER   The business area id
--        p_user_id          IN NUMBER   The user id to start up
--
--   OUT : x_return_status OUT  VARCHAR2(1)
--         x_msg_count     OUT  NUMBER
--         x_msg_data      OUT  VARCHAR2(2000)
--
-- Version : Current version    1.0
--           Initial version    1.0
--
-- Notes : None
--
-------------------------------------------------------------------------------
procedure STARTUP(p_api_version      IN         NUMBER,
                  p_init_msg_list    IN         VARCHAR2 := FND_API.G_FALSE,
                  p_commit           IN         VARCHAR2 := FND_API.G_FALSE,
                  p_validation_level IN         NUMBER
                                              := FND_API.G_VALID_LEVEL_FULL,
                  x_return_status    OUT NOCOPY VARCHAR2,
                  x_msg_count        OUT NOCOPY NUMBER,
                  x_msg_data         OUT NOCOPY VARCHAR2,
                  p_user             IN         VARCHAR2,
                  p_read_only        IN         VARCHAR2 := FND_API.G_FALSE);

-------------------------------------------------------------------------------
-- VIEWS_UPDATE - Creates/Updates the Dimension LMAPs for the personal AW.
--
-- IN: p_aw   - AW Name
--     p_user - User ID
--     p_dims - Space-separated list of dimension id's to update. If NULL
--                (the default), all data dimensions are updated
--     p_doPers - Y if should look for personal views (with personal levels)
--                to update
-------------------------------------------------------------------------------
procedure views_update(p_aw     in varchar2,
                       p_user   in varchar2,
                       p_dims   in varchar2 := NULL,
                       p_doPers in varchar2 := 'N');

-------------------------------------------------------------------------------
-- PERSONAL_AW_RW_SCAN checks whether the given user's personal AW is
-- attached R/W by an open session and returns session info sufficient
-- do close the session.
--
-- IN : User ID
-- IN : Business Area ID
-- OUT : SID
-- OUT : serial_no
-- OUT : sess_user
-- OUT : OS_user
-- OUT : status
-- OUT : schema_name
-- OUT : machine name
-------------------------------------------------------------------------------
procedure PERSONAL_AW_RW_SCAN(p_user          in         varchar2,
                              p_business_area in         NUMBER,
                              p_SID           out nocopy number,
                              p_serial_no     out nocopy number,
                              p_sess_user     out nocopy varchar2,
                              p_os_user       out nocopy varchar2,
                              p_status        out nocopy varchar2,
                              p_schema_name   out nocopy varchar2,
                              p_machine       out nocopy varchar2);

-------------------------------------------------------------------------------
-- PERSONAL_AW_SESS_CLOSE kills the specified personal AW r/w session.
--
-- IN : SID
-- IN : SERIAL NO
-------------------------------------------------------------------------------
procedure personal_aw_sess_close(p_SID in number, p_serial_no in number);

-------------------------------------------------------------------------------
-- MEASURES_APPROVER_UPDATE - Deletes any approver formulas that have been
--                            submitted and thus made obsolete in a previous
--                            user session
--
-- IN: p_user          - User ID
--     x_return_status - The return status
--
-------------------------------------------------------------------------------
procedure MEASURES_APPROVER_UPDATE(p_user          IN            VARCHAR2,
                                  x_return_status IN OUT NOCOPY VARCHAR2);

-------------------------------------------------------------------------
-- UPDATE_SHADOW - Called when a user starts shadowing another user
--
-- IN:  p_business_area_id - The current business area id
--      p_shadow_id - The user id of the user who is being shadowed
-----------------------------------------------------------------------
PROCEDURE UPDATE_SHADOW (p_business_area_id IN      NUMBER,
				 		 p_shadow_id        IN      NUMBER default null);

end ZPB_PERSONAL_AW;

 

/
