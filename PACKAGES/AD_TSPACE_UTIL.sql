--------------------------------------------------------
--  DDL for Package AD_TSPACE_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AD_TSPACE_UTIL" AUTHID CURRENT_USER as
/* $Header: adtsutls.pls 115.9 2002/12/12 21:09:54 athies noship $*/
   -- Star of Comments
   --
   -- Name
   --
   --   Package name:   AD_TSPACE_UTIL
   --
   -- History
   --                Sept-10-02           hxue    Creation Date
   --                Dec-10-02            sgadag  Added function to accept
   --						  application_id
   --
   --
procedure is_new_ts_mode(x_ts_mode out NOCOPY varchar2);
   --
   -- Purpose
   --
   --   Check whether the database is in new tablespace management mode or not.
   --
   -- Arguments
   --
   -- Out Parameters
   --
   --   x_ts_mode     Return value of 'Y' indicates new tablespace management mode
   --                 Return value of 'N' indicates old tablespace management mode
   --
   -- Example
   --
   --   none
   --
   -- Notes
   --
   --   none
   --
procedure get_object_tablespace(x_product_short_name in varchar2,
                                x_object_name in varchar2,
                                x_object_type in varchar2,
                                x_index_lookup_flag in varchar2,
                                x_validate_ts_exists in varchar2,
                                x_is_object_registered out NOCOPY varchar2,
                                x_ts_exists out NOCOPY varchar2,
                                x_tablespace out NOCOPY varchar2);
   --
   -- Purpose
   --
   --   Returns the tablespace based on the product short name,
   --   object name, object type and index look up flag.
   --   Also return flags which indicate if the object specified has been registered in
   --   FND_OBJECT_TABLESPACES and if x_validate_ts_exists is passed an 'Y', will validate
   --   whether or not the tablespace exists in the database
   --
   -- Arguments
   --
   -- In Parameters
   --   x_product_short_name: Application Short Name that the object belongs to
   --   x_object_name: the name of object
   --	x_object_type: valid object types are TABLE, MVIEW, AQ_TABLE, IOT_TABLE and MV_LOG.
   --	x_index_lookup_flag: to get the tablespace for an index, pass the table
   --                        name on which the index is based as x_object_name,
   --                        pass 'TABLE' as x_object_type
   --                        and 'Y' as x_index_lookup_flag. Set this flag
   --                        to 'N'' if you are not looking up and index
   --	x_validate_ts_exists: 'Y': to check if the tablespace exist,
   --                         'N': do not check if the tablespace exist,
   -- Out Parameters
   --	x_is_object_registered: 'Y' indicates the object has been registered in
   --                               FND_OBJECT_TABLESPACES
   --                           'N' indicates the object has not been registered
   --	x_ts_exists:
   --                           'Y': indicates the tablespace exists
   --                           'N': indicates the tablespace does not exist
   --                           This will be Null if x_validate_ts_exists is 'N''
   --
   --	x_tablespace: the name of the(physical) tablespace
   --
   --  Example
   --
   --    none
   --
   --  Notes
   --
   --    none
   --
procedure get_tablespace_name(x_product_short_name in varchar2,
                              x_tablespace_type in varchar2,
                              x_validate_ts_exists in varchar2,
                              x_ts_exists out NOCOPY varchar2,
                              x_tablespace out NOCOPY varchar2);
   --
   -- Purpose
   --
   --   Returns a physical tablespace given a tablespace type (logical tablespace)
   --   and Application Short Name. Also returns a flag which indicates if the
   --   tablespace exists in the database
   --
   -- Arguments
   --  In Parameters
   --   x_product_short_name: Application Short Name that object belongs to
   --   x_tablespace_type: the tablespace type (logical tablespace name)
   --	x_validate_ts_exists: 'Y' to check if the tablespace exists,
   --                         'N' do not check
   -- Out Parameters
   --	x_ts_exists:          'Y': indicates the tablespace exists
   --                         'N': indicates the tablespace does not exist
   --                         This will be Null if x_validate_ts_exists is 'N'
   --
   --	x_tablespace: the name of the (physical) tablespace
   --
   -- Example
   --
   --   none
   --
   -- Notes
   --
   --   none
   --
function get_appl_id(x_product_short_name in varchar2) return number;
   -- Function to return application_short_name from FND_APPLICATION
   -- when passed application_id
function get_product_short_name(x_appl_id in number) return varchar2;
   -- Function to return application_id from FND_APPLICATION
   -- when passed application_short_name
end AD_TSPACE_UTIL;

 

/
