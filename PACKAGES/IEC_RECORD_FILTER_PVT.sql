--------------------------------------------------------
--  DDL for Package IEC_RECORD_FILTER_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEC_RECORD_FILTER_PVT" AUTHID CURRENT_USER AS
/* $Header: IECRECFS.pls 115.3 2003/08/22 20:42:23 hhuang noship $ */

-----------------------------++++++-------------------------------
--
-- Start of comments
--
--  API name    : Make_ListEntriesAvailable
--  Type        : Private
--  Pre-reqs    : None
--  Function    : Makes list entries with specified do not use reason available by setting
--                the DO_NOT_USE_FLAG to 'N' in IEC_G_RETURN_ENTRIES.  Report counts
--                are updated to reflect that these entries are now available.
--
--  Parameters  : p_list_header_id       IN     NUMBER            Required
--                p_dnu_reason_code      IN     NUMBER            Required
--                p_commit               IN     VARCHAR2          Required
--                x_return_status           OUT VARCHAR2          Required
--
--  Version     : Initial version 1.0
--
-- End of comments
--
-----------------------------++++++-------------------------------
PROCEDURE Make_ListEntriesAvailable
   ( p_list_header_id	  IN	        NUMBER
   , p_dnu_reason_code	  IN	        NUMBER
   , p_commit             IN            BOOLEAN
   , x_return_status         OUT NOCOPY VARCHAR2);

-----------------------------++++++-------------------------------
--
-- Start of comments
--
--  API name    : Get_RecordFilterView
--  Type        : Public
--  Pre-reqs    : None
--  Function    : Returns the record filter view name after verifying that the view
--                exists, creating the view if necessary.
--
--  Parameters  : p_record_filter_id        IN     NUMBER                       Required
--                p_source_type_view_name   IN     VARCHAR2                     Required
--                x_return_code                OUT VARCHAR2                     Required
--
--  Version     : Initial version 1.0
--
-- End of comments
--
-----------------------------++++++-------------------------------
FUNCTION Get_RecordFilterView
   ( p_record_filter_id         IN            NUMBER
   , p_source_type_view_name    IN            VARCHAR2
   , x_return_code                 OUT NOCOPY VARCHAR2
   )
RETURN VARCHAR2;

-----------------------------++++++-------------------------------
--
-- Start of comments
--
--  API name    : Recreate_RecordFilterView
--  Type        : Public
--  Pre-reqs    : None
--  Procedure   : Recreates the record filter view, deleting it first if necessary.
--
--  Parameters  : p_record_filter_id          IN     NUMBER                       Required
--                x_record_filter_view_name      OUT VARCHAR2                     Required
--
--  Version     : Initial version 1.0
--
-- End of comments
--
-----------------------------++++++-------------------------------
PROCEDURE Recreate_RecordFilterView
   ( p_record_filter_id         IN            NUMBER
   , x_record_filter_view_name     OUT NOCOPY VARCHAR2
   );

-----------------------------++++++-------------------------------
--
-- Start of comments
--
--  API name    : Drop_RecordFilterView
--  Type        : Private
--  Pre-reqs    : None
--  Function    :
--
--  Parameters  : p_record_filter_id     IN     NUMBER                       Required
--                x_return_code             OUT VARCHAR2                     Required
--
--  Version     : Initial version 1.0
--
-- End of comments
--
-----------------------------++++++-------------------------------
PROCEDURE Drop_RecordFilterView
   ( p_record_filter_id      IN            NUMBER
   , x_return_code              OUT NOCOPY VARCHAR2
   );

-----------------------------++++++-------------------------------
--
-- Start of comments
--
--  API name    : Get_RecordFilterSourceType
--  Type        : Public
--  Pre-reqs    : None
--  Procedure   : Returns the source type view for the record filter.
--
--  Parameters  : p_record_filter_id          IN     NUMBER                       Required
--                x_source_type_view             OUT VARCHAR2                     Required
--
--  Version     : Initial version 1.0
--
-- End of comments
--
-----------------------------++++++-------------------------------
PROCEDURE Get_RecordFilterSourceType
   ( p_record_filter_id         IN            NUMBER
   , x_source_type_view            OUT NOCOPY VARCHAR2
   );

-----------------------------++++++-------------------------------
--
-- Start of comments
--
--  API name    : Apply_RecordFilter
--  Type        : Public
--  Pre-reqs    : None
--  Procedure   : Applies a specified record filter to an entry
--                belonging to specified target group.
--
--  Parameters  : p_list_entry_id          IN     NUMBER         Required
--                p_list_id                IN     NUMBER         Required
--                p_returns_id             IN     NUMBER         Required
--                p_record_filter_id       IN     NUMBER         Required
--                p_source_type_view_name  IN     VARCHAR2       Required
--                x_callable_flag             OUT VARCHAR2       Required
--
--  Version     : Initial version 1.0
--
-- End of comments
--
-----------------------------++++++-------------------------------
PROCEDURE Apply_RecordFilter
   ( p_list_entry_id          IN            NUMBER
   , p_list_id                IN            NUMBER
   , p_returns_id             IN            NUMBER
   , p_record_filter_id       IN            NUMBER
   , p_source_type_view_name  IN            VARCHAR2
   , x_callable_flag             OUT NOCOPY VARCHAR2
   );

-----------------------------++++++-------------------------------
--
-- Start of comments
--
--  API name    : Cancel_RecordFilter
--  Type        : Public
--  Pre-reqs    : None
--  Procedure   : Remove record filter from all affected entries.
--
--  Parameters  : p_record_filter_id       IN     VARCHAR2        Required
--
--  Version     : Initial version 1.0
--
-- End of comments
--
-----------------------------++++++-------------------------------
PROCEDURE Cancel_RecordFilter (p_record_filter_id IN NUMBER);


-----------------------------++++++-------------------------------
-- Start of comments
--
--  API name    : Cancel_RecordFilterForList
--  Type        : Public
--  Pre-reqs    : None
--  Procedure   : Remove record filter from specified list.
--
--  Parameters  : p_list_header_id         IN     NUMBER        Required
--
--  Version     : Initial version 1.0
--
-- End of comments
--
-----------------------------++++++-------------------------------
PROCEDURE Cancel_RecordFilterForList(p_list_header_id   IN NUMBER);

END IEC_RECORD_FILTER_PVT;

 

/
